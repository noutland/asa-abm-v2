# department.R - Core department structure and methods 
# Part of asa-abm model 

library(data.table) 
library(checkmate)

#' Create department with elements 
#' 
#' @param dept_name Name of the department 
#' @param target_ratio Target ratio of agents for each department 
# #' @param budget Budget for the department 
#' @return data.table representing department 
#' @export 
create_dept <- function(dept_name = c("alpha", "beta", "gamma", "delta", "epsilon", "zeta"),
                        target_ratio = c(0.3, 0.1, 0.2, 0.15, 0.05, 0.2)) { 
  # validate parameters 
  assert_character(dept_name, min.len = 1)
  assert_true(length(dept_name) == length(target_ratio))
  assert_true(sum(target_ratio) == 1) 
  
  
  }

