# department.R - Core department structure and methods 
# Part of asa-abm model 

library(data.table) 
library(checkmate)

#' Create NEW department with elements 
#' 
#' @param new_dept_name Name of the department 
#' @param new_target_ratio Target ratio of agents for each department 
# #' @param budget Budget for the department 
#' @return data.table representing department 
#' @export 
create_dept <- function(new_dept_name = NULL, 
                        new_target_ratio = NULL) { 
  if (new_dept_name.is.NULL || new_target_ratio.is.NULL) { 
    message("Please provide new department name and its target ratio")
  }
  # validate parameters 
  assert_character(dept_names, min.len = 1) # at least one department 
  assert_true(length(dept_names) == length(target_ratios)) # same number of departments as target ratios 
  assert_true(abs(sum(target_ratios)-1) < 1e-9) # ratios add up to 100% with tolerance 
  
  # Generate unique department IDs
  dept_ids <- sprintf("dept_%05d", seq_len(length(dept_names)))
  
  departments <- data.table
  
  }

