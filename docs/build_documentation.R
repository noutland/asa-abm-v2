# build_documentation.R
# Script to build the ASA ABM v2 documentation

# Required packages are now installed via GitHub Actions workflow
# This ensures consistency and caching for faster builds

# Load bookdown
library(bookdown)

# Set working directory to docs folder
if (!grepl("docs$", getwd())) {
  setwd("docs")
}

# Clean previous builds
if (dir.exists("_book")) {
  unlink("_book", recursive = TRUE)
}
if (dir.exists("../documentation")) {
  unlink("../documentation", recursive = TRUE)
}

# Build the book (HTML only for GitHub Pages)
bookdown::render_book(
  input = ".",
  output_format = "bookdown::gitbook",  # HTML format only
  clean = TRUE,
  envir = parent.frame(),
  quiet = FALSE,
  encoding = "UTF-8"
)

# Alternative: Build specific formats
# bookdown::render_book("index.Rmd", "bookdown::gitbook")
# bookdown::render_book("index.Rmd", "bookdown::pdf_book")

cat("\nDocumentation build complete!\n")
cat("Output location: ../documentation/\n")
cat("\nTo view HTML version, open: ../documentation/index.html\n")