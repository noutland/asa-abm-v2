# ASA ABM v2 Documentation

This directory contains the source files for the comprehensive documentation of the ASA Agent-Based Model v2.

## Documentation Structure

The documentation is organized using the bookdown package and includes:

1. **Getting Started** - Installation and quick start guide
2. **Theoretical Background** - ASA framework and model theory
3. **Architecture Overview** - Technical design and implementation
4. **User Guide** - Detailed usage instructions
5. **ODD Protocol** - Standardized model description
6. **API Reference** - Complete function documentation
7. **Examples** - Practical examples and case studies

## Building the Documentation

### Prerequisites

Install required R packages:
```r
install.packages(c("bookdown", "knitr", "rmarkdown", "ggplot2", "data.table"))
```

For PDF output, you also need:
```r
install.packages("tinytex")
tinytex::install_tinytex()
```

### Build Process

1. **Using the build script** (recommended):
   ```r
   source("build_documentation.R")
   ```

2. **Manual build**:
   ```r
   library(bookdown)
   bookdown::render_book("index.Rmd", "all")
   ```

3. **Build specific format**:
   ```r
   # HTML only
   bookdown::render_book("index.Rmd", "bookdown::gitbook")
   
   # PDF only
   bookdown::render_book("index.Rmd", "bookdown::pdf_book")
   ```

## Output

Built documentation will be saved to `../documentation/` with:
- `index.html` - Main entry point for HTML version
- `asa-abm-v2-documentation.pdf` - PDF version
- `asa-abm-v2-documentation.epub` - EPUB version

## Viewing Documentation

### Local Viewing
Open `../documentation/index.html` in your web browser

### Hosting Options
The HTML output can be hosted on:
- GitHub Pages
- Netlify
- Any static web hosting service

## Contributing to Documentation

1. Edit the relevant `.Rmd` file
2. Rebuild the documentation
3. Test all output formats
4. Submit changes via pull request

## Documentation Standards

- Use clear, concise language
- Include code examples for all functions
- Provide both simple and advanced use cases
- Keep theoretical explanations accessible
- Update API reference when functions change

## File Descriptions

- `index.Rmd` - Main landing page and TOC
- `01-getting-started.Rmd` - Installation and setup
- `02-theoretical-background.Rmd` - ASA theory
- `03-architecture.Rmd` - Technical architecture
- `04-user-guide.Rmd` - Detailed usage guide
- `05-ODD-protocol.Rmd` - Standardized ABM description
- `06-api-reference.Rmd` - Function documentation
- `07-examples.Rmd` - Examples and case studies
- `_bookdown.yml` - Bookdown configuration
- `_output.yml` - Output format settings
- `build_documentation.R` - Build script

## Troubleshooting

### Common Issues

**LaTeX errors when building PDF:**
- Ensure tinytex is properly installed
- Check for special characters in code blocks
- Verify all R packages are installed

**Missing images/plots:**
- Ensure all file paths are relative
- Check that plot code is executable
- Verify working directory is correct

**Build fails:**
- Clear cache: `bookdown::clean_book()`
- Remove `_bookdown_files/` directory
- Check for syntax errors in Rmd files

## Citation

If you use this documentation in academic work, please cite:

```
ASA ABM Development Team (2024). ASA Agent-Based Model v2 Documentation. 
Retrieved from [URL]
```