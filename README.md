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

- High-performance data.table implementation
- Modular architecture for easy extension
- Support for multiple identity categories (A-E)
- Big Five personality traits
- Homophily and diversity preferences
- Dynamic hiring and turnover
- **Configurable diversity metrics**: Blau's Index (default) or Shannon entropy
- **I-O psychology best practices**: Implements standard diversity indices
- **Comprehensive output metrics**: Including category proportions and dual diversity measures

## Recent Updates (2025)

### Bug Fixes
- Fixed conscientiousness comparison bug in interaction valence calculation
- Improved emotional stability variance using exponential decay function

### New Features
- Implemented Blau's Index as the primary diversity metric (I-O psychology standard)
- Made diversity metrics configurable (`diversity_metric` parameter)
- Added category proportions to output metrics (prop_A through prop_E)
- Both Shannon entropy and Blau's Index calculated in every simulation

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