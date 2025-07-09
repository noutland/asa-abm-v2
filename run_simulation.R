# run_simulation.R - Example simulation script
# Demonstrates usage of ASA ABM v2

# Load required libraries
library(data.table)
library(ggplot2)

# Set working directory to asa_abm_v2
setwd("asa_abm_v2")

# Source the simulation engine
source("simulation/engine.R")

# Define simulation parameters
sim_params <- list(
  # Identity categories (matching the default in the system)
  identity_categories = c("A", "B", "C", "D", "E"),
  
  # Growth and hiring
  growth_rate = 0.02,              # 2% growth per hiring cycle
  hiring_frequency = 12,           # Hire every 12 time steps (monthly)
  selection_criteria = "conscientiousness",  # Hire based on conscientiousness
  n_new_applicants = 100,          # 100 new applicants per cycle
  
  # Interactions
  n_interactions_per_step = 10,    # Each agent has 10 interactions per step
  interaction_window = 20,         # Consider last 20 steps for satisfaction
  
  # Turnover
  turnover_type = "threshold",     # Use threshold-based turnover
  turnover_threshold = -5,         # Leave if satisfaction < -5
  
  # Applicant behavior
  applicant_attraction_threshold = -1,  # Min attraction to stay in pool
  max_application_time = 24        # Applications expire after 24 steps
)

# Run simulation
set.seed(42)  # For reproducibility
results <- run_asa_simulation(
  n_steps = 520,          # ~2 years if each step is ~1 week
  initial_size = 100,     # Start with 100 employees
  params = sim_params,
  verbose = TRUE
)

# Save results
save_simulation_results(results, "example_simulation", save_snapshots = TRUE)

# Basic visualization
metrics <- results$metrics

# Plot 1: Organization size over time
p1 <- ggplot(metrics, aes(x = time, y = size)) +
  geom_line(size = 1.2, color = "darkblue") +
  labs(title = "Organization Size Over Time",
       x = "Time Step", y = "Number of Employees") +
  theme_minimal()

print(p1)

# Plot 2: Average satisfaction over time
p2 <- ggplot(metrics, aes(x = time, y = avg_satisfaction)) +
  geom_line(size = 1.2, color = "darkgreen") +
  geom_hline(yintercept = sim_params$turnover_threshold, 
             linetype = "dashed", color = "red") +
  labs(title = "Average Satisfaction Over Time",
       x = "Time Step", y = "Average Satisfaction",
       subtitle = "Red line indicates turnover threshold") +
  theme_minimal()

print(p2)

# Plot 3: Identity diversity over time
p3 <- ggplot(metrics, aes(x = time, y = identity_diversity)) +
  geom_line(size = 1.2, color = "purple") +
  labs(title = "Identity Diversity Over Time",
       x = "Time Step", y = "Shannon Diversity Index") +
  theme_minimal()

print(p3)

# Plot 4: Personality traits evolution
personality_cols <- c("avg_openness", "avg_conscientiousness", "avg_extraversion", 
                     "avg_agreeableness", "avg_emotional_stability")

personality_long <- melt(metrics[, c("time", personality_cols), with = FALSE], 
                        id.vars = "time",
                        variable.name = "trait",
                        value.name = "average")

personality_long[, trait := gsub("avg_", "", trait)]

p4 <- ggplot(personality_long, aes(x = time, y = average, color = trait)) +
  geom_line(size = 1) +
  labs(title = "Average Personality Traits Over Time",
       x = "Time Step", y = "Average Score",
       color = "Trait") +
  theme_minimal() +
  scale_color_brewer(palette = "Set1")

print(p4)

# Summary statistics
cat("\n=== SIMULATION SUMMARY ===\n")
cat(sprintf("Initial size: %d\n", sim_params$initial_size))
cat(sprintf("Final size: %d\n", results$final_organization[is_active == TRUE, .N]))
cat(sprintf("Total hires: %d\n", results$final_organization[, .N] - 100))
cat(sprintf("Total turnover: %d\n", results$final_organization[is_active == FALSE, .N]))
cat(sprintf("Final avg satisfaction: %.2f\n", 
            results$final_organization[is_active == TRUE, mean(satisfaction)]))
cat(sprintf("Final identity diversity: %.2f\n", 
            calculate_identity_diversity(results$final_organization)))

# Identity distribution at end
cat("\nFinal identity distribution:\n")
print(results$final_organization[is_active == TRUE, .N, by = identity_category][order(-N)])

message("\nSimulation complete! Check the plots and saved files.")