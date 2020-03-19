# dashboard-sa-template

A set of template files for national/regional dashboard processing with accompanying documentation and examples for Southwick analysts.

## Documentation

- [Dashboard Analyst Introduction](github_vignettes/dashboard-overview.md)
- [Data required from states](github_vignettes/data-required.md)
- [Database Schemas](github_vignettes/data-schema.md)
- [Workflow Overview (incomplete)](github_vignettes/workflow-overview.md)
    
## Usage

### Setting up an Analysis

Using the Southwick Data Server, open an R console (e.g., using RStudio) and populate a directory with template files:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/salicprep")
salicprep::new_state("state-abbreviation", "time-period") # function to be written

# go to the new directory and build the project package library
renv::restore()
```

### Performing an Analysis

Source a sequence of R scripts (in process) in order to:

1. load raw data into a sqlite database
2. standardize raw data into a generic format
3. prepare license type categorization
4. perform initial validation
5. write anonymized production data into sqlite for building dashboards
6. perform final validation
