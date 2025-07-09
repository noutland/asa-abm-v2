#!/usr/bin/env Rscript

# Test script for v2 updates
# This tests the bug fixes and new diversity metrics

library(data.table)
library(checkmate)

# Source the required files
source("core/agent.R")
source("core/organization.R")
source("core/interactions.R")
source("simulation/engine.R")
source("simulation/hiring.R")
source("simulation/turnover.R")

cat("Testing ASA ABM v2 with updates...\n\n")

# Test 1: Create organization and test diversity metrics
cat("Test 1: Testing diversity metrics\n")
org <- create_organization(100, c("A", "B", "C", "D", "E"))

# Calculate both diversity metrics
shannon <- calculate_identity_diversity(org)
blau <- calculate_blau_index(org)
props <- get_category_proportions(org)

cat(sprintf("Shannon diversity: %.3f\n", shannon))
cat(sprintf("Blau's Index: %.3f\n", blau))
cat("Category proportions:\n")
print(props)
cat("\n")

# Test 2: Test interaction valence calculation
cat("Test 2: Testing interaction valence (conscientiousness bug fix)\n")
# Create a simple test case - need to match the format from create_organization
test_org <- data.table(
  agent_id = as.character(1:2),
  identity_category = c("A", "B"),
  openness = c(0, 0),
  conscientiousness = c(1, -1),
  extraversion = c(0, 1),
  agreeableness = c(0.5, 0.5),
  emotional_stability = c(1, -1),
  diversity_preference = c(0.5, 0.5),
  homophily_preference = c(0.5, 0.5),
  attraction = 0,
  satisfaction = 0,
  tenure = 0,
  hire_date = 0,
  is_active = TRUE
)
setkey(test_org, agent_id)

# Initialize interactions
interactions <- data.table(
  focal_agent = integer(),
  partner_agent = integer(),
  time_step = integer(),
  valence = numeric()
)

# Simulate one interaction
set.seed(123)
interactions <- execute_interactions_vectorized(test_org, interactions, 1, 1)
cat("Interaction valence (should use conscientiousness difference):\n")
print(interactions)
cat("\n")

# Test 3: Test satisfaction calculation with different diversity metrics
cat("Test 3: Testing satisfaction calculation with different diversity metrics\n")

# Create a larger test organization
test_org2 <- create_organization(50, c("A", "B", "C", "D", "E"))
interactions2 <- initialize_interactions(test_org2)

# Add some interactions
for (i in 1:5) {
  interactions2 <- execute_interactions_vectorized(test_org2, interactions2, i, 5)
}

# Test with Blau's Index (default)
test_org2_blau <- copy(test_org2)
test_org2_blau <- update_satisfaction_vectorized(test_org2_blau, interactions2, 
                                                  window_size = 5, 
                                                  diversity_metric = "blau")
avg_sat_blau <- mean(test_org2_blau$satisfaction, na.rm = TRUE)

# Test with Shannon entropy
test_org2_shannon <- copy(test_org2)
test_org2_shannon <- update_satisfaction_vectorized(test_org2_shannon, interactions2, 
                                                    window_size = 5, 
                                                    diversity_metric = "shannon")
avg_sat_shannon <- mean(test_org2_shannon$satisfaction, na.rm = TRUE)

cat(sprintf("Average satisfaction with Blau's Index: %.3f\n", avg_sat_blau))
cat(sprintf("Average satisfaction with Shannon entropy: %.3f\n", avg_sat_shannon))
cat("\n")

# Test 4: Run a mini simulation
cat("Test 4: Running mini simulation with both diversity metrics\n")

# Run with Blau's Index
set.seed(456)
params_blau <- list(
  n_steps = 20,
  diversity_metric = "blau"
)
results_blau <- run_asa_simulation(50, 20, params_blau, verbose = FALSE)

# Run with Shannon entropy  
set.seed(456)
params_shannon <- list(
  n_steps = 20,
  diversity_metric = "shannon"
)
results_shannon <- run_asa_simulation(50, 20, params_shannon, verbose = FALSE)

# Compare final metrics
final_blau <- results_blau$metrics[.N]
final_shannon <- results_shannon$metrics[.N]

cat("\nFinal metrics comparison:\n")
cat("Metric | Blau | Shannon\n")
cat("-------|------|--------\n")
cat(sprintf("Size | %d | %d\n", final_blau$size, final_shannon$size))
cat(sprintf("Blau Index | %.3f | %.3f\n", final_blau$blau_index, final_shannon$blau_index))
cat(sprintf("Shannon | %.3f | %.3f\n", final_blau$shannon_diversity, final_shannon$shannon_diversity))
cat(sprintf("Avg Satisfaction | %.3f | %.3f\n", final_blau$avg_satisfaction, final_shannon$avg_satisfaction))

# Test 5: Verify metrics output includes category proportions
cat("\nTest 5: Checking category proportions in output\n")
cat("Category proportions from final step:\n")
cat(sprintf("A: %.3f, B: %.3f, C: %.3f, D: %.3f, E: %.3f\n",
            final_blau$prop_A, final_blau$prop_B, final_blau$prop_C, 
            final_blau$prop_D, final_blau$prop_E))

cat("\nAll tests completed successfully!\n")