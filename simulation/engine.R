# engine.R - Main simulation engine
# Part of ASA ABM v2

library(data.table)
library(checkmate)

# Source required modules
source("core/organization.R")
source("core/agent.R") 
source("core/interactions.R")
source("simulation/hiring.R")
source("simulation/turnover.R")

#' Run ASA simulation
#' 
#' @param n_steps Number of simulation steps
#' @param initial_size Initial organization size
#' @param params List of simulation parameters
#' @param verbose Print progress messages
#' @return List with organization history and metrics
#' @export
run_asa_simulation <- function(n_steps = 260,
                              initial_size = 100,
                              params = list(),
                              verbose = TRUE) {
  
  # Validate inputs
  assert_count(n_steps, positive = TRUE)
  assert_count(initial_size, positive = TRUE)
  assert_list(params)
  assert_flag(verbose)
  
  # Set default parameters
  default_params <- list(
    identity_categories = c("A", "B", "C", "D", "E"),
    growth_rate = 0.01,
    hiring_frequency = 12,
    selection_criteria = "conscientiousness",
    n_interactions_per_step = 5,
    interaction_window = 10,
    turnover_threshold = -10,
    turnover_type = "threshold",  # "threshold" or "probabilistic"
    base_turnover_rate = 0.05,
    n_new_applicants = 50,
    applicant_attraction_threshold = -0.5,
    max_application_time = 12
  )
  
  # Merge with user parameters
  params <- modifyList(default_params, params)
  
  # Initialize organization
  if (verbose) message("Initializing organization...")
  org <- create_organization(initial_size, params$identity_categories)
  
  # Initialize tracking structures
  interactions <- initialize_interactions(org)
  applicant_pool <- create_applicant_pool(0)  # Empty initial pool
  
  # Results storage
  org_history <- vector("list", n_steps)
  metrics_history <- data.table()
  
  # Main simulation loop
  if (verbose) message(sprintf("Starting %d-step simulation...", n_steps))
  
  for (step in seq_len(n_steps)) {
    
    # 1. Update tenure
    org <- update_tenure(org)
    
    # 2. Execute interactions
    interactions <- execute_interactions_vectorized(
      org, interactions, step, params$n_interactions_per_step
    )
    
    # 3. Update satisfaction based on interactions
    org <- update_satisfaction_vectorized(
      org, interactions, params$interaction_window
    )
    
    # 4. Execute turnover
    if (params$turnover_type == "threshold") {
      org <- execute_turnover(org, params$turnover_threshold, step)
    } else {
      org <- calculate_turnover_probability(org, params$base_turnover_rate)
      org <- execute_probabilistic_turnover(org, step)
    }
    
    # 5. Hiring cycle
    if (step %% params$hiring_frequency == 0) {
      # Age existing applicant pool
      applicant_pool <- age_applicant_pool(applicant_pool, params$max_application_time)
      
      # Recruit new applicants
      applicant_pool <- recruit_applicants(applicant_pool, params$n_new_applicants)
      
      # Calculate attraction
      applicant_pool <- calculate_applicant_attraction(applicant_pool, org)
      
      # Filter based on attraction
      applicant_pool <- filter_applicant_pool(applicant_pool, params$applicant_attraction_threshold)
      
      # Execute hiring
      hiring_result <- execute_hiring(
        org, applicant_pool, params$growth_rate, 
        params$selection_criteria, step
      )
      
      org <- hiring_result$organization
      applicant_pool <- hiring_result$applicant_pool
    }
    
    # 6. Calculate and store metrics
    step_metrics <- calculate_step_metrics(org, step)
    metrics_history <- rbind(metrics_history, step_metrics)
    
    # 7. Store organization snapshot (optional - memory intensive)
    if (step %% 10 == 0) {  # Store every 10 steps
      org_history[[step]] <- copy(org)
    }
    
    # Progress update
    if (verbose && step %% 50 == 0) {
      message(sprintf("Step %d/%d - Org size: %d, Avg satisfaction: %.2f",
                      step, n_steps, 
                      get_organization_size(org),
                      calculate_average_satisfaction(org)))
    }
  }
  
  if (verbose) message("Simulation complete!")
  
  # Return results
  return(list(
    final_organization = org,
    metrics = metrics_history,
    parameters = params,
    organization_snapshots = org_history[!sapply(org_history, is.null)]
  ))
}

#' Calculate metrics for a single time step
#' 
#' @param org Organization data.table
#' @param time_step Current time step
#' @return data.table row with metrics
calculate_step_metrics <- function(org, time_step) {
  
  # Basic metrics
  size <- get_organization_size(org)
  diversity <- calculate_identity_diversity(org)
  avg_satisfaction <- calculate_average_satisfaction(org)
  
  # Personality metrics
  personality_means <- calculate_personality_averages(org)
  personality_sds <- calculate_personality_variance(org)
  
  # Preference metrics
  avg_homo <- org[is_active == TRUE, mean(homophily_preference, na.rm = TRUE)]
  avg_div <- org[is_active == TRUE, mean(diversity_preference, na.rm = TRUE)]
  sd_homo <- org[is_active == TRUE, sd(homophily_preference, na.rm = TRUE)]
  sd_div <- org[is_active == TRUE, sd(diversity_preference, na.rm = TRUE)]
  
  # Tenure metrics
  avg_tenure <- org[is_active == TRUE, mean(tenure, na.rm = TRUE)]
  
  # Create metrics row
  metrics <- data.table(
    time = time_step,
    size = size,
    identity_diversity = diversity,
    avg_satisfaction = avg_satisfaction,
    avg_tenure = avg_tenure,
    
    # Personality averages
    avg_openness = personality_means[1],
    avg_conscientiousness = personality_means[2],
    avg_extraversion = personality_means[3],
    avg_agreeableness = personality_means[4],
    avg_emotional_stability = personality_means[5],
    
    # Personality SDs
    sd_openness = personality_sds[1],
    sd_conscientiousness = personality_sds[2],
    sd_extraversion = personality_sds[3],
    sd_agreeableness = personality_sds[4],
    sd_emotional_stability = personality_sds[5],
    
    # Preferences
    avg_homophily = avg_homo,
    avg_diversity = avg_div,
    sd_homophily = sd_homo,
    sd_diversity = sd_div
  )
  
  return(metrics)
}

#' Save simulation results
#' 
#' @param results Simulation results list
#' @param filename Base filename for saving
#' @param save_snapshots Whether to save organization snapshots
#' @export
save_simulation_results <- function(results, 
                                   filename = "simulation_results",
                                   save_snapshots = FALSE) {
  
  # Save metrics
  fwrite(results$metrics, paste0(filename, "_metrics.csv"))
  
  # Save parameters
  saveRDS(results$parameters, paste0(filename, "_params.rds"))
  
  # Save final organization state
  fwrite(results$final_organization, paste0(filename, "_final_org.csv"))
  
  # Optionally save snapshots
  if (save_snapshots && length(results$organization_snapshots) > 0) {
    saveRDS(results$organization_snapshots, paste0(filename, "_snapshots.rds"))
  }
  
  message(sprintf("Results saved with prefix: %s", filename))
}