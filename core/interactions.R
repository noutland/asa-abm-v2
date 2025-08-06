# interactions.R - Interaction mechanisms and satisfaction updates
# Part of ASA ABM v2

library(data.table)
library(checkmate)

#' Initialize interaction tracking table
#' 
#' @param org Organization data.table
#' @return data.table for tracking interactions
#' @export
initialize_interactions <- function(org) {
  assert_data_table(org)
  
  # Create empty interactions table
  interactions <- data.table(
    focal_agent = character(),
    partner_agent = character(),
    time_step = integer(),
    valence = numeric(),
    key = c("focal_agent", "partner_agent")
  )
  
  return(interactions)
}

#' Perform one round of random interactions (vectorized)
#' 
#' @param org Organization data.table
#' @param interactions Interaction tracking table
#' @param time_step Current simulation time
#' @param n_interactions Number of interactions per agent
#' @return Updated interactions table
#' @export
execute_interactions_vectorized <- function(org, interactions, time_step, n_interactions = 1) {
  assert_data_table(org)
  assert_data_table(interactions)
  assert_count(time_step, positive = TRUE)
  assert_count(n_interactions, positive = TRUE)
  
  # Get active agents
  active_agents <- org[is_active == TRUE]
  n_agents <- nrow(active_agents)
  
  if (n_agents < 2) return(interactions)
  
  # Generate random pairings for all agents at once
  focal_agents <- rep(active_agents$agent_id, each = n_interactions)
  
  # For each focal agent, select random partners (excluding self)
  partner_agents <- character(length(focal_agents))
  
  for (i in seq_along(focal_agents)) {
    focal <- focal_agents[i]
    possible_partners <- active_agents[agent_id != focal, agent_id]
    partner_agents[i] <- sample(possible_partners, 1)
  }
  
  # Create interaction pairs
  new_interactions <- data.table(
    focal_agent = focal_agents,
    partner_agent = partner_agents,
    time_step = time_step
  )
  
  # Merge agent characteristics for valence calculation
  new_interactions <- merge(new_interactions, 
                           active_agents[, .(agent_id, 
                                           focal_extra = extraversion,
                                           focal_consc = conscientiousness,
                                           focal_agree = agreeableness,
                                           focal_emostab = emotional_stability,
                                           focal_identity = identity_category,
                                           focal_homo = homophily_preference,
                                           focal_div = diversity_preference)],
                           by.x = "focal_agent", by.y = "agent_id")
  
  new_interactions <- merge(new_interactions,
                           active_agents[, .(agent_id,
                                           partner_extra = extraversion,
                                           partner_consc = conscientiousness,
                                           partner_identity = identity_category)],
                           by.x = "partner_agent", by.y = "agent_id")
  
  # Calculate interaction valence (vectorized)
  new_interactions[, valence := 
    abs(focal_extra - partner_extra) * -1 +  # Extraversion difference (negative)
    (focal_consc - partner_consc) +          # Conscientiousness advantage
    focal_agree +                             # Agreeableness benefit
    ifelse(focal_identity == partner_identity, 
           focal_homo,                        # Same identity: homophily preference
           focal_div) +                       # Different identity: diversity preference
    rnorm(.N, mean = 0, sd = exp(-focal_emostab))  # Random component: low ES = high variance, high ES = low variance
  ]
  
  # Keep only essential columns
  new_interactions <- new_interactions[, .(focal_agent, partner_agent, time_step, valence)]
  
  # Append to interactions history
  interactions <- rbind(interactions, new_interactions)
  
  return(interactions)
}

#' Calculate satisfaction for all agents based on interactions
#' 
#' @param org Organization data.table
#' @param interactions Interaction history table
#' @param window_size Number of recent time steps to consider
#' @param diversity_metric Character string specifying which diversity metric to use ("blau" or "shannon")
#' @return Updated organization with satisfaction scores
#' @export
update_satisfaction_vectorized <- function(org, interactions, window_size = 10, diversity_metric = "blau") {
  assert_data_table(org)
  assert_data_table(interactions)
  assert_count(window_size, positive = TRUE)
  assert_choice(diversity_metric, c("blau", "shannon"))
  
  # Get recent interactions
  max_time <- max(interactions$time_step, 0)
  min_time <- max(0, max_time - window_size + 1)
  recent_interactions <- interactions[time_step >= min_time]
  
  # Calculate average interaction valence per agent
  interaction_satisfaction <- recent_interactions[, 
    .(interaction_component = mean(valence)), 
    by = focal_agent]
  
  # Calculate identity-based satisfaction component
  id_props <- org[is_active == TRUE, .N, by = identity_category]
  id_props[, prop := N / sum(N)]
  diversity_index <- if (diversity_metric == "blau") {
    calculate_blau_index(org)
  } else {
    calculate_identity_diversity(org)  # Shannon entropy
  }
  
  # Merge and calculate total satisfaction
  org <- merge(org, interaction_satisfaction, 
               by.x = "agent_id", by.y = "focal_agent", 
               all.x = TRUE, allow.cartesian = TRUE)
  org[is.na(interaction_component), interaction_component := 0]
  
  org <- merge(org, id_props[, .(identity_category, prop)],
               by = "identity_category", all.x = TRUE, allow.cartesian = TRUE)
  org[is.na(prop), prop := 0]
  
  # Update satisfaction
  org[is_active == TRUE, satisfaction := 
    attraction +                                    # Base attraction
    interaction_component +                         # Interaction history
    (homophily_preference * prop) +               # Identity similarity
    (diversity_preference * diversity_index) +     # Diversity preference
    emotional_stability                            # Personality component
  ]
  
  # Clean up temporary columns
  org[, c("interaction_component", "prop") := NULL]
  
  return(org)
}

#' Get interaction summary statistics
#' 
#' @param interactions Interaction history table
#' @param last_n_steps Number of recent steps to analyze
#' @return List of summary statistics
#' @export
get_interaction_summary <- function(interactions, last_n_steps = 10) {
  assert_data_table(interactions)
  
  if (nrow(interactions) == 0) {
    return(list(
      total_interactions = 0,
      avg_valence = NA,
      sd_valence = NA,
      n_unique_pairs = 0
    ))
  }
  
  # Filter to recent interactions
  max_time <- max(interactions$time_step)
  recent <- interactions[time_step > (max_time - last_n_steps)]
  
  summary_stats <- list(
    total_interactions = nrow(recent),
    avg_valence = mean(recent$valence, na.rm = TRUE),
    sd_valence = sd(recent$valence, na.rm = TRUE),
    n_unique_pairs = recent[, uniqueN(paste(focal_agent, partner_agent))]
  )
  
  return(summary_stats)
}