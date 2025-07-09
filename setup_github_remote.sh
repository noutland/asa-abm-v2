#!/bin/bash

# Setup GitHub Remote for ASA ABM v2

echo "=== GitHub Repository Setup for ASA ABM v2 ==="
echo ""

# Check if git is initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOL'
# R specific
.Rhistory
.RData
.Rproj.user/
*.Rproj

# Documentation build files
docs/_book/
docs/_bookdown_files/
documentation/
*.log

# OS files
.DS_Store
Thumbs.db

# Temporary files
*.tmp
*.temp
*~

# Output files
*.pdf
*.html
*.epub
data/*.csv
data/*.rds

# Keep example outputs
!run_simulation.R

# IDE
.idea/
.vscode/

# R package files
*.tar.gz

# Legacy files (already archived)
legacy_S4_implementation/
EOL
fi

# Create README if it doesn't exist
if [ ! -f README.md ]; then
    echo "Creating main README..."
    cat > README.md << 'EOL'
# ASA Agent-Based Model v2

A high-performance, extensible agent-based model for simulating Attraction-Selection-Attrition (ASA) dynamics in organizations.

## Overview

This model simulates how organizations evolve through the interplay of:
- **Attraction**: How individuals are drawn to organizations
- **Selection**: How organizations choose new members  
- **Attrition**: How and why members leave organizations

## Features

- 🚀 High-performance implementation using `data.table`
- 📊 Comprehensive metrics and visualization
- 🔧 Modular, extensible architecture
- 📚 Complete documentation with examples
- 🧪 Ready for research and experimentation

## Quick Start

```r
# Load the simulation engine
source("asa_abm_v2/simulation/engine.R")

# Run a basic simulation
results <- run_asa_simulation(
  n_steps = 260,      # One year weekly
  initial_size = 100  # Starting employees
)

# View results
summary(results$metrics)
```

## Documentation

Comprehensive documentation is available in the `docs/` folder:
- Getting Started Guide
- Theoretical Background
- User Guide
- API Reference
- Examples and Case Studies

### Building Documentation
```r
cd asa_abm_v2/docs
source("build_documentation.R")
```

## Project Structure

```
asa_abm_v2/
├── core/           # Core data structures
├── simulation/     # Simulation engine
├── analysis/       # Analysis tools
├── docs/           # Documentation source
├── tests/          # Unit tests
└── data/           # Sample data
```

## Requirements

- R >= 4.0.0
- Required packages: `data.table`, `checkmate`, `ggplot2`

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/[username]/asa-abm-v2.git
   ```

2. Install dependencies:
   ```r
   install.packages(c("data.table", "checkmate", "ggplot2"))
   ```

3. Run example simulation:
   ```r
   source("asa_abm_v2/run_simulation.R")
   ```

## Contributing

Contributions are welcome! Please see our contributing guidelines.

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Citation

If you use this model in your research, please cite:
```
[Your Name] (2024). ASA Agent-Based Model v2. 
https://github.com/[username]/asa-abm-v2
```

## Contact

- GitHub Issues: [Report bugs or request features](https://github.com/[username]/asa-abm-v2/issues)
- Email: [your-email]
EOL
fi

# Create LICENSE file
if [ ! -f LICENSE ]; then
    echo "Creating LICENSE file..."
    cat > LICENSE << 'EOL'
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOL
fi

echo ""
echo "=== Repository Structure Ready ==="
echo ""
echo "Next steps:"
echo ""
echo "1. Create a new repository on GitHub:"
echo "   - Go to https://github.com/new"
echo "   - Name it: asa-abm-v2"
echo "   - Make it public or private as desired"
echo "   - DON'T initialize with README (we have one)"
echo ""
echo "2. After creating, run these commands:"
echo ""
echo "   # Add your GitHub remote"
echo "   git remote add origin https://github.com/YOUR_USERNAME/asa-abm-v2.git"
echo ""
echo "   # Add and commit all files"
echo "   git add ."
echo "   git commit -m \"Initial commit: ASA ABM v2 with complete documentation\""
echo ""
echo "   # Push to GitHub"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Enable GitHub Pages:"
echo "   - Go to Settings → Pages"
echo "   - Source: Deploy from branch"
echo "   - Branch: main, folder: /docs"
echo ""
echo "4. (Optional) Set up GitHub Actions for automated docs:"
echo "   The workflow file is already created in .github/workflows/"
echo ""

# Offer to stage files
read -p "Would you like to stage all files now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add .
    echo "Files staged. Ready for commit!"
fi