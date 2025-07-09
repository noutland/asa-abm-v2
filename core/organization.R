# organization.R - Core organization structure and methods
# Part of ASA ABM v2

library(data.table)
library(checkmate)

#' Create an organization with agents
#' 
#' @param n_agents Number of agents to create
#' @param identity_categories Vector of possible identity categories
#' @return data.table representing the organization
#' @export
create_organization <- function(n_agents = 100, 
                              identity_categories = c("A", "B", "C", "D", "E")) {
  
  # Validate inputs
  assert_count(n_agents, positive = TRUE)
  assert_character(identity_categories, min.len = 1)
  
  # Generate unique agent IDs
  agent_ids <- sprintf("agent_%05d", seq_len(n_agents))
  
  # Initialize the organization data.table
  org <- data.table(
    agent_id = agent_ids,
    identity_category = sample(identity_categories, n_agents, replace = TRUE),
    
    # Big Five personality traits (standardized)
    openness = rnorm(n_agents, mean = 0, sd = 1),
    conscientiousness = rnorm(n_agents, mean = 0, sd = 1),
    extraversion = rnorm(n_agents, mean = 0, sd = 1),
    agreeableness = rnorm(n_agents, mean = 0, sd = 1),
    emotional_stability = rnorm(n_agents, mean = 0, sd = 1),
    
    # Preferences
    diversity_preference = rnorm(n_agents, mean = 0, sd = 1),
    homophily_preference = rnorm(n_agents, mean = 0, sd = 1),
    
    # State variables
    attraction = 0,
    satisfaction = 0,
    tenure = 0,
    
    # Metadata
    hire_date = 0,
    is_active = TRUE
  )
  
  # Set key for efficient lookups
  setkey(org, agent_id)
  
  return(org)
}

#' Calculate identity diversity using Shannon entropy
#' 
#' @param org Organization data.table
#' @return Numeric diversity index (0 = homogeneous, higher = more diverse)
#' @export
calculate_identity_diversity <- function(org) {
  assert_data_table(org)
  assert_subset("identity_category", names(org))
  
  # Get proportions of each identity category
  props <- org[is_active == TRUE, .N, by = identity_category][, prop := N / sum(N)]$prop
  
  # Calculate Shannon entropy
  # H = -sum(p * log(p))
  shannon_index <- -sum(props * log(props))
  
  return(shannon_index)
}

#' Calculate Blau's Index of heterogeneity for identity categories
#' 
#' @param org Organization data.table
#' @return Numeric diversity index (0 = homogeneous, 1 = maximum diversity)
#' @export
calculate_blau_index <- function(org) {
  assert_data_table(org)
  assert_subset("identity_category", names(org))
  
  # Get proportions of each identity category
  props <- org[is_active == TRUE, .N, by = identity_category][, prop := N / sum(N)]$prop
  
  # Calculate Blau's Index: 1 - sum(p^2)
  # Represents probability that two randomly selected members are from different categories
  blau_index <- 1 - sum(props^2)
  
  return(blau_index)
}

#' Get proportions of each identity category
#' 
#' @param org Organization data.table
#' @return Named vector with proportions for each category
#' @export
get_category_proportions <- function(org) {
  assert_data_table(org)
  assert_subset("identity_category", names(org))
  
  # Get counts and proportions
  category_counts <- org[is_active == TRUE, .N, by = identity_category]
  
  # Create a complete set of categories (A-E) with zeros for missing ones
  all_categories <- data.table(identity_category = c("A", "B", "C", "D", "E"))
  category_props <- merge(all_categories, category_counts, 
                         by = "identity_category", all.x = TRUE)
  category_props[is.na(N), N := 0]
  category_props[, prop := N / sum(N)]
  
  # Convert to named vector
  props <- category_props$prop
  names(props) <- category_props$identity_category
  
  return(props)
}

#' Calculate organization-level personality averages
#' 
#' @param org Organization data.table
#' @return Named vector of personality trait averages
#' @export
calculate_personality_averages <- function(org) {
  assert_data_table(org)
  
  personality_traits <- c("openness", "conscientiousness", "extraversion", 
                         "agreeableness", "emotional_stability")
  
  # Calculate means for active employees only
  avg_traits <- org[is_active == TRUE, 
                    lapply(.SD, mean, na.rm = TRUE), 
                    .SDcols = personality_traits]
  
  return(as.numeric(avg_traits))
}

#' Calculate organization-level personality standard deviations
#' 
#' @param org Organization data.table
#' @return Named vector of personality trait SDs
#' @export
calculate_personality_variance <- function(org) {
  assert_data_table(org)
  
  personality_traits <- c("openness", "conscientiousness", "extraversion", 
                         "agreeableness", "emotional_stability")
  
  # Calculate SDs for active employees only
  sd_traits <- org[is_active == TRUE, 
                   lapply(.SD, sd, na.rm = TRUE), 
                   .SDcols = personality_traits]
  
  return(as.numeric(sd_traits))
}

#' Get organization size (active agents only)
#' 
#' @param org Organization data.table
#' @return Integer count of active agents
#' @export
get_organization_size <- function(org) {
  assert_data_table(org)
  return(org[is_active == TRUE, .N])
}

#' Calculate average satisfaction
#' 
#' @param org Organization data.table
#' @return Numeric average satisfaction
#' @export
calculate_average_satisfaction <- function(org) {
  assert_data_table(org)
  return(org[is_active == TRUE, mean(satisfaction, na.rm = TRUE)])
}

#' Get organization summary statistics
#' 
#' @param org Organization data.table
#' @return List of summary statistics
#' @export
get_organization_summary <- function(org) {
  assert_data_table(org)
  
  summary_stats <- list(
    size = get_organization_size(org),
    identity_diversity = calculate_identity_diversity(org),
    avg_satisfaction = calculate_average_satisfaction(org),
    avg_tenure = org[is_active == TRUE, mean(tenure, na.rm = TRUE)],
    personality_means = calculate_personality_averages(org),
    personality_sds = calculate_personality_variance(org),
    turnover_rate = org[is_active == FALSE, .N] / nrow(org)
  )
  
  return(summary_stats)
}