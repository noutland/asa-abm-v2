# ASA Agent-Based Model v2

A performant, extensible agent-based model for simulating Attraction-Selection-Attrition (ASA) dynamics in organizations.

## Documentation

The full documentation is available at: https://noutland.github.io/asa-abm-v2/

## Project Structure

```
asa_abm_v2/
├── core/               # Core data structures and functions
│   ├── agent.R        # Agent (Person/Employee) definitions
│   ├── organization.R # Organization structure and methods
│   └── interactions.R # Interaction mechanisms
├── simulation/        # Simulation engine
│   ├── engine.R       # Main simulation loop
│   ├── hiring.R       # Hiring and recruitment logic
│   └── turnover.R     # Attrition and satisfaction
├── analysis/          # Analysis and metrics
│   ├── metrics.R      # Organizational metrics
│   └── visualization.R # Plotting functions
├── tests/             # Unit and integration tests
├── data/              # Sample data and results
├── config/            # Configuration files
└── docs/              # Documentation

```

## Key Features

- data.table backend
- Modular architecture 
- Support for multiple identity categories 
- Big Five personality traits
- Homophily and diversity preferences
- Dynamic hiring and turnover
- **Configurable diversity metrics**: Blau's Index (default)

### Usage Example

```r
# Run simulation with Blau's Index (default)
results <- run_asa_simulation(
  initial_size = 100,
  n_steps = 260,
  params = list(
    diversity_metric = "blau",    # or "shannon"
    growth_rate = 0.01,
    hiring_frequency = 12,
    turnover_threshold = -10
  )
)

# Access metrics
metrics <- results$metrics
# Contains: shannon_diversity, blau_index, prop_A, prop_B, etc.
```

## Future Extensions

- Network structures for agent interactions
- Hierarchical organizational divisions
- Inter-organizational mobility
- Advanced visualization capabilities
- Separation diversity metrics (for continuous attributes)
- Disparity diversity metrics (for resource/status variables)
