#!/bin/bash

# Deploy ASA ABM v2 Documentation to GitHub Pages

echo "Building documentation..."
cd docs
Rscript build_documentation.R
cd ..

echo "Preparing for GitHub Pages deployment..."

# Method 1: Using docs folder in main branch
if [ "$1" == "docs-folder" ]; then
    echo "Using docs folder method..."
    
    # Create docs folder in repo root if it doesn't exist
    mkdir -p ../../../docs
    
    # Copy built documentation
    cp -r documentation/* ../../../docs/
    
    # Add .nojekyll file to prevent Jekyll processing
    touch ../../../docs/.nojekyll
    
    echo "Documentation copied to docs folder."
    echo "Next steps:"
    echo "1. git add docs/"
    echo "2. git commit -m 'Update documentation'"
    echo "3. git push origin main"
    echo "4. Enable GitHub Pages in Settings → Pages → Source: main/docs"
    
# Method 2: Using gh-pages branch
elif [ "$1" == "gh-pages" ]; then
    echo "Using gh-pages branch method..."
    
    # Store current branch
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    
    # Copy documentation to temp
    cp -r documentation/* $TEMP_DIR/
    
    # Add .nojekyll file
    touch $TEMP_DIR/.nojekyll
    
    # Switch to gh-pages branch
    git checkout gh-pages 2>/dev/null || git checkout --orphan gh-pages
    
    # Clear everything
    git rm -rf . 2>/dev/null || true
    
    # Copy documentation
    cp -r $TEMP_DIR/* .
    
    # Commit
    git add .
    git commit -m "Update documentation $(date +%Y-%m-%d)"
    
    echo "Documentation prepared in gh-pages branch."
    echo "Next steps:"
    echo "1. git push origin gh-pages"
    echo "2. Enable GitHub Pages in Settings → Pages → Source: gh-pages"
    
    # Return to original branch
    git checkout $CURRENT_BRANCH
    
    # Clean up
    rm -rf $TEMP_DIR
    
else
    echo "Usage: ./deploy_to_github_pages.sh [docs-folder|gh-pages]"
    echo ""
    echo "Options:"
    echo "  docs-folder  - Deploy to /docs folder in main branch"
    echo "  gh-pages     - Deploy to gh-pages branch"
fi