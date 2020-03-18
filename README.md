# dashboard-sa-template

A set of template files for national/regional dashboard processing with accompanying documentation and examples for Southwick analysts.

## Setup

Using the Southwick Data Server, open an R console (e.g., using RStudio):

```r
install.packages("remotes")
remotes::install_github("southwick-associates/salicprep")
salicprep::new_state("state-abbreviation") # function to be written
```

The software environment was specified using [package renv](https://rstudio.github.io/renv/index.html), and this needs to be restored for a new state:

```r
renv::restore()
renv::snapshot() # update the state of the project library after you install new packages
```

## Usage

The vignettes (in process) are used for documentation:

- [Dashboard Analyst Introduction](github_vignettes/dashboard-overview.md)
- Workflow Overview
    + Data required from states
    + Data Schemas (raw, standard, production)
    + Data Validation
