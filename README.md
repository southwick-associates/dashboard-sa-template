# dashboard-sa-template

A set of template files for national/regional dashboards with accompanying documentation and examples.

## Setup

Using the Data Server, open Rstudio and run from the console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/salicprep")
salicprep::new_state("state-abbreviation") # to be written
```

The software environment was specified using [package renv](https://rstudio.github.io/renv/index.html), and this needs to be restored from the R console:

```r
renv::restore()

# update the state of the project library after you install new packages
renv::snapshot()
```

## Usage

The vignettes (to be written) are used for documentation:

- Workflow Overview
- Data required from states
- Data Schemas (raw, standard, production)
- Data Validation
