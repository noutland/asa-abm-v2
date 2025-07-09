# agent.R - Agent (Person/Employee) definitions and methods
# Part of ASA ABM v2

library(data.table)
library(checkmate)

#' Create an applicant pool
#' 
#' @param n_applicants Number of applicants to generate
#' @param identity_categories Vector of possible identity categories
#' @return data.table of applicants
#' @export
create_applicant_pool <- function(n_applicants = 50,
                                identity_categories = c("A", "B", "C", "D", "E")) {
  
  # Validate inputs
  assert_count(n_applicants, positive = TRUE)
  assert_character(identity_categories, min.len = 1)
  
  # Generate unique applicant IDs
  applicant_ids <- sprintf("applicant_%05d_%s", 
                          seq_len(n_applicants),
                          format(Sys.time(), "%Y%m%d%H%M%S"))
  
  # Create applicant pool
  applicants <- data.table(
    agent_id = applicant_ids,
    identity_category = sample(identity_categories, n_applicants, replace = TRUE),
    
    # Big Five personality traits
    openness = rnorm(n_applicants, mean = 0, sd = 1),
    conscientiousness = rnorm(n_applicants, mean = 0, sd = 1),
    extraversion = rnorm(n_applicants, mean = 0, sd = 1),
    agreeableness = rnorm(n_applicants, mean = 0, sd = 1),
    emotional_stability = rnorm(n_applicants, mean = 0, sd = 1),
    
    # Preferences
    diversity_preference = rnorm(n_applicants, mean = 0, sd = 1),
    homophily_preference = rnorm(n_applicants, mean = 0, sd = 1),
    
    # Application state
    attraction = 0,
    application_time = 0
  )
  
  # Set key for efficient operations
  setkey(applicants, agent_id)
  
  return(applicants)
}

#' Create an empty applicant pool with correct structure
#' 
#' @param identity_categories Vector of possible identity categories
#' @return Empty data.table with applicant structure
#' @export
create_empty_applicant_pool <- function(identity_categories = c("A", "B", "C", "D", "E")) {
  # Create empty data.table with all required columns
  empty_pool <- data.table(
    agent_id = character(),
    identity_category = character(),
    openness = numeric(),
    conscientiousness = numeric(),
    extraversion = numeric(),
    agreeableness = numeric(),
    emotional_stability = numeric(),
    diversity_preference = numeric(),
    homophily_preference = numeric(),
    attraction = numeric(),
    application_time = integer()
  )
  
  setkey(empty_pool, agent_id)
  return(empty_pool)
}

#' Calculate attraction for applicants based on organization composition
#' 
#' @param applicants data.table of applicants
#' @param org Organization data.table
#' @param diversity_metric Character string specifying which diversity metric to use ("blau" or "shannon")
#' @return Updated applicants data.table with attraction scores
#' @export
calculate_applicant_attraction <- function(applicants, org, diversity_metric = "blau") {
  assert_data_table(applicants)
  assert_data_table(org)
  assert_choice(diversity_metric, c("blau", "shannon"))
  
  # Calculate organization identity proportions
  id_props <- org[is_active == TRUE, .N, by = identity_category]
  id_props[, prop := N / sum(N)]
  setkey(id_props, identity_category)
  
  # Calculate identity diversity metric based on chosen method
  diversity_index <- if (diversity_metric == "blau") {
    calculate_blau_index(org)
  } else {
    calculate_identity_diversity(org)  # Shannon entropy
  }
  
  # Merge proportions with applicants
  applicants_with_props <- id_props[applicants, on = "identity_category"]
  applicants_with_props[is.na(prop), prop := 0]  # Handle categories not in org
  
  # Calculate attraction based on preferences
  applicants_with_props[, attraction := 
    (homophily_preference * prop) + 
    (diversity_preference * diversity_index)]
  
  # Update original applicants table
  applicants[, attraction := applicants_with_props$attraction]
  
  return(applicants)
}

#' Filter applicants based on attraction threshold
#' 
#' @param applicants data.table of applicants
#' @param min_attraction Minimum attraction score to remain in pool
#' @return Filtered applicants data.table
#' @export
filter_applicant_pool <- function(applicants, min_attraction = -0.5) {
  assert_data_table(applicants)
  assert_number(min_attraction)
  
  # Return only applicants above threshold
  return(applicants[attraction >= min_attraction])
}

#' Age applicant pool (increment application time)
#' 
#' @param applicants data.table of applicants
#' @param max_application_time Maximum time before removal from pool
#' @return Updated applicants data.table
#' @export
age_applicant_pool <- function(applicants, max_application_time = 12) {
  assert_data_table(applicants)
  assert_count(max_application_time, positive = TRUE)
  
  # Increment application time
  applicants[, application_time := application_time + 1]
  
  # Remove stale applications
  return(applicants[application_time <= max_application_time])
}

#' Convert applicants to employees
#' 
#' @param selected_applicants data.table of selected applicants
#' @param hire_time Current simulation time
#' @return data.table of new employees
#' @export
applicants_to_employees <- function(selected_applicants, hire_time = 0) {
  assert_data_table(selected_applicants)
  assert_number(hire_time, lower = 0)
  
  # Copy applicant data
  new_employees <- copy(selected_applicants)
  
  # Update agent IDs
  new_employees[, agent_id := gsub("applicant", "agent", agent_id)]
  
  # Add employee-specific fields
  new_employees[, `:=`(
    satisfaction = 0,
    tenure = 0,
    hire_date = hire_time,
    is_active = TRUE,
    application_time = NULL  # Remove applicant-only field
  )]
  
  return(new_employees)
}