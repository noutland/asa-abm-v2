# turnover.R - Attrition and satisfaction management
# Part of ASA ABM v2

library(data.table)
library(checkmate)

#' Execute turnover based on satisfaction threshold
#' 
#' @param org Organization data.table
#' @param turnover_threshold Satisfaction level below which agents leave
#' @param current_time Current simulation time
#' @return Updated organization data.table
#' @export
execute_turnover <- function(org, turnover_threshold = -10, current_time = 0) {
  assert_data_table(org)
  assert_number(turnover_threshold)
  assert_number(current_time, lower = 0)
  
  # Identify leavers
  leavers <- org[is_active == TRUE & satisfaction < turnover_threshold, agent_id]
  n_leavers <- length(leavers)
  
  if (n_leavers > 0) {
    # Mark as inactive instead of removing
    org[agent_id %in% leavers, is_active := FALSE]
    
    # Log turnover event
    message(sprintf("Time %d: %d employees left (satisfaction < %.2f)", 
                    current_time, n_leavers, turnover_threshold))
  }
  
  return(org)
}

#' Calculate voluntary turnover probability
#' 
#' @param org Organization data.table
#' @param base_turnover_rate Base probability of leaving
#' @param satisfaction_weight Weight of satisfaction in turnover decision
#' @return Organization with turnover probabilities
#' @export
calculate_turnover_probability <- function(org, 
                                         base_turnover_rate = 0.05,
                                         satisfaction_weight = 0.1) {
  assert_data_table(org)
  assert_number(base_turnover_rate, lower = 0, upper = 1)
  assert_number(satisfaction_weight, lower = 0)
  
  # Logistic function for turnover probability
  # Higher satisfaction = lower turnover probability
  org[is_active == TRUE, turnover_prob := 
    base_turnover_rate / (1 + exp(satisfaction * satisfaction_weight))]
  
  # Tenure effect - newer employees more likely to leave
  org[is_active == TRUE & tenure < 12, 
      turnover_prob := turnover_prob * 1.5]
  
  # Cap probability at reasonable bounds
  org[turnover_prob > 0.5, turnover_prob := 0.5]
  org[turnover_prob < 0.001, turnover_prob := 0.001]
  
  return(org)
}

#' Execute probabilistic turnover
#' 
#' @param org Organization data.table with turnover probabilities
#' @param current_time Current simulation time
#' @return Updated organization
#' @export
execute_probabilistic_turnover <- function(org, current_time = 0) {
  assert_data_table(org)
  assert_subset("turnover_prob", names(org))
  
  # Generate random draws for each active agent
  org[is_active == TRUE, leave := runif(.N) < turnover_prob]
  
  # Process leavers
  leavers <- org[leave == TRUE, agent_id]
  n_leavers <- length(leavers)
  
  if (n_leavers > 0) {
    org[agent_id %in% leavers, is_active := FALSE]
    message(sprintf("Time %d: %d employees left (probabilistic turnover)", 
                    current_time, n_leavers))
  }
  
  # Clean up temporary column
  org[, leave := NULL]
  
  return(org)
}

#' Update agent tenure
#' 
#' @param org Organization data.table
#' @param time_increment Time units to add to tenure
#' @return Updated organization
#' @export
update_tenure <- function(org, time_increment = 1) {
  assert_data_table(org)
  assert_count(time_increment, positive = TRUE)
  
  # Increment tenure for active agents only
  org[is_active == TRUE, tenure := tenure + time_increment]
  
  return(org)
}

#' Get turnover statistics
#' 
#' @param org Organization data.table
#' @param time_window Time period to analyze
#' @return List of turnover statistics
#' @export
get_turnover_stats <- function(org, time_window = 12) {
  assert_data_table(org)
  
  # Calculate various turnover metrics
  total_employees <- nrow(org)
  active_employees <- org[is_active == TRUE, .N]
  inactive_employees <- org[is_active == FALSE, .N]
  
  # Turnover rate
  turnover_rate <- inactive_employees / total_employees
  
  # Average tenure of leavers vs stayers
  avg_tenure_active <- org[is_active == TRUE, mean(tenure, na.rm = TRUE)]
  avg_tenure_inactive <- org[is_active == FALSE, mean(tenure, na.rm = TRUE)]
  
  # Satisfaction analysis
  avg_satisfaction_active <- org[is_active == TRUE, mean(satisfaction, na.rm = TRUE)]
  avg_satisfaction_at_exit <- org[is_active == FALSE, mean(satisfaction, na.rm = TRUE)]
  
  # Identity category turnover
  identity_turnover <- org[, .(
    total = .N,
    left = sum(!is_active),
    turnover_rate = sum(!is_active) / .N
  ), by = identity_category]
  
  stats <- list(
    active_employees = active_employees,
    total_turnover = inactive_employees,
    turnover_rate = turnover_rate,
    avg_tenure_active = avg_tenure_active,
    avg_tenure_at_exit = avg_tenure_inactive,
    avg_satisfaction_active = avg_satisfaction_active,
    avg_satisfaction_at_exit = avg_satisfaction_at_exit,
    identity_turnover = identity_turnover
  )
  
  return(stats)
}

#' Predict agents at risk of leaving
#' 
#' @param org Organization data.table
#' @param risk_threshold Satisfaction percentile to flag as at-risk
#' @return data.table of at-risk agents
#' @export
identify_flight_risks <- function(org, risk_threshold = 0.25) {
  assert_data_table(org)
  assert_number(risk_threshold, lower = 0, upper = 1)
  
  # Calculate satisfaction threshold
  satisfaction_cutoff <- quantile(org[is_active == TRUE, satisfaction], 
                                 probs = risk_threshold, 
                                 na.rm = TRUE)
  
  # Identify at-risk agents
  at_risk <- org[is_active == TRUE & satisfaction <= satisfaction_cutoff]
  
  # Sort by risk (lowest satisfaction first)
  setorder(at_risk, satisfaction)
  
  return(at_risk[, .(agent_id, identity_category, satisfaction, tenure)])
}