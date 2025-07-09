# ASA Agent-Based Model v2

A performant, extensible agent-based model for simulating Attraction-Selection-Attrition (ASA) dynamics in organizations.

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
- Support for multiple identity categories
- Big Five personality traits
- Homophily and diversity preferences
- Dynamic hiring and turnover

## Future Extensions

- Network structures for agent interactions
- Hierarchical organizational divisions
- Inter-organizational mobility
- Advanced visualization capabilities