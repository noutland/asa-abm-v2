# hiring.R - Hiring and recruitment logic
# Part of ASA ABM v2

library(data.table)
library(checkmate)

#' Execute hiring process
#' 
#' @param org Organization data.table
#' @param applicant_pool Applicant pool data.table
#' @param growth_rate Proportion of current size to hire
#' @param selection_criteria Criteria for selection ("conscientiousness", "fit", "random")
#' @param current_time Current simulation time
#' @return List with updated organization and remaining applicant pool
#' @export
execute_hiring <- function(org, 
                          applicant_pool, 
                          growth_rate = 0.1,
                          selection_criteria = "conscientiousness",
                          current_time = 0) {
  
  # Validate inputs
  assert_data_table(org)
  assert_data_table(applicant_pool)
  assert_number(growth_rate, lower = 0, upper = 1)
  assert_choice(selection_criteria, c("conscientiousness", "fit", "random"))
  
  # Calculate number to hire
  current_size <- get_organization_size(org)
  n_to_hire <- round(current_size * growth_rate)
  
  # Handle edge cases
  if (n_to_hire == 0 || nrow(applicant_pool) == 0) {
    return(list(organization = org, applicant_pool = applicant_pool))
  }
  
  # Adjust if not enough applicants
  n_to_hire <- min(n_to_hire, nrow(applicant_pool))
  
  # Rank applicants based on selection criteria
  if (selection_criteria == "conscientiousness") {
    # Sort by conscientiousness (descending)
    setorder(applicant_pool, -conscientiousness)
  } else if (selection_criteria == "fit") {
    # Sort by attraction to organization (descending)
    setorder(applicant_pool, -attraction)
  } else {
    # Random selection - shuffle rows
    applicant_pool <- applicant_pool[sample(.N)]
  }
  
  # Select top applicants
  selected_indices <- seq_len(n_to_hire)
  selected_applicants <- applicant_pool[selected_indices]
  remaining_applicants <- applicant_pool[-selected_indices]
  
  # Convert selected applicants to employees
  new_employees <- applicants_to_employees(selected_applicants, current_time)
  
  # Add to organization
  updated_org <- rbind(org, new_employees, fill = TRUE)
  
  # Log hiring event
  if (n_to_hire > 0) {
    message(sprintf("Time %d: Hired %d new employees (selection: %s)", 
                    current_time, n_to_hire, selection_criteria))
  }
  
  return(list(
    organization = updated_org,
    applicant_pool = remaining_applicants
  ))
}

#' Execute recruitment campaign
#' 
#' @param existing_pool Existing applicant pool
#' @param n_new_applicants Number of new applicants to generate
#' @param identity_categories Possible identity categories
#' @return Updated applicant pool
#' @export
recruit_applicants <- function(existing_pool = NULL,
                             n_new_applicants = 50,
                             identity_categories = c("A", "B", "C", "D", "E")) {
  
  # Generate new applicants
  new_applicants <- create_applicant_pool(n_new_applicants, identity_categories)
  
  # Combine with existing pool if provided
  if (!is.null(existing_pool)) {
    assert_data_table(existing_pool)
    combined_pool <- rbind(existing_pool, new_applicants, fill = TRUE)
    return(combined_pool)
  }
  
  return(new_applicants)
}

#' Calculate organization-applicant fit metrics
#' 
#' @param org Organization data.table
#' @param applicants Applicant pool data.table
#' @return Applicants with fit metrics added
#' @export
calculate_fit_metrics <- function(org, applicants) {
  assert_data_table(org)
  assert_data_table(applicants)
  
  # Calculate organization personality profile
  org_personality <- calculate_personality_averages(org)
  names(org_personality) <- c("org_O", "org_C", "org_E", "org_A", "org_ES")
  
  # Calculate personality distance for each applicant
  applicants[, personality_fit := -sqrt(
    (openness - org_personality["org_O"])^2 +
    (conscientiousness - org_personality["org_C"])^2 +
    (extraversion - org_personality["org_E"])^2 +
    (agreeableness - org_personality["org_A"])^2 +
    (emotional_stability - org_personality["org_ES"])^2
  )]
  
  # Calculate preference alignment
  org_avg_homo <- org[is_active == TRUE, mean(homophily_preference)]
  org_avg_div <- org[is_active == TRUE, mean(diversity_preference)]
  
  applicants[, preference_fit := -sqrt(
    (homophily_preference - org_avg_homo)^2 +
    (diversity_preference - org_avg_div)^2
  )]
  
  # Combined fit score
  applicants[, overall_fit := personality_fit + preference_fit + attraction]
  
  return(applicants)
}

#' Get hiring statistics
#' 
#' @param org Organization data.table
#' @param time_window Recent time period to analyze
#' @return List of hiring statistics
#' @export
get_hiring_stats <- function(org, time_window = 12) {
  assert_data_table(org)
  
  current_time <- max(org$hire_date, 0)
  recent_hires <- org[hire_date > (current_time - time_window)]
  
  stats <- list(
    total_employees = get_organization_size(org),
    recent_hires = nrow(recent_hires),
    hiring_rate = nrow(recent_hires) / time_window,
    avg_conscientiousness_hired = mean(recent_hires$conscientiousness, na.rm = TRUE),
    identity_distribution_hires = table(recent_hires$identity_category)
  )
  
  return(stats)
}