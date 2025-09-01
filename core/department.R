# department.R - Core department structure and methods 
# Part of asa-abm model 

source("organization.R")

library(data.table) 
library(checkmate)

dept_name = NULL 

#' Create department and structure
#' Allows for user to create new departments and update the data.table 
#' 
#' @param dept_names Name of the department 
#' @param target_ratios Target ratio of agents for each department 
#' @return data.table representing department 
#' @export 
create_dept <- function(dept_names = NULL, 
                        target_ratios = NULL) { 
  # Validate Parameters 
  assert_not_null(dept_names)
  assert_character(dept_names, min.len = 1)
  assert_true(abs(sum(target_ratios)-1) < 1e-9)
  
  # Update Department Names 
  dept_name <<- c(dept_name, dept_names)
  assert_true(length(dept_names) == length(target_ratios))

  # Generate unique department IDs
  dept_ids <- sprintf("dept_%05d", seq_along(dept_name))
  
  # Create Department Structure
  departments <- data.table(
    dept_ids,  
    dept_name,
    target_ratios
  )
  return(departments)
}


#' Allocate employees to departments  
#' 
#' @param org Organization of employees 
#' @return data.table representing department 
#' @export
allocate_dept <- function(org, target_ratios) { 
  assert_data_table(org)
  
  allocate_choices <- c("Need-Based", "Fixed-Ratio")
  
  
  
  selected <- menu(choices = allocate_choices, title = "Allocate employees to departments via:")

  if (selected == 1) { 
    
  } else if (selected == 2) { 
    
  }
  
  
}


