# lictemplate

An R package that provides a template workflow for license data preparation.

## Installation

Note: Not yet ready to install. From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/lictemplate")
```
    
## Usage

Using the Southwick Data Server, open an R console (e.g., using RStudio) and populate a directory with template files:

```r
lictemplate::new_dashboard("state-abbreviation", "time-period")
```

Open the Rstudio project just created and build the project package library with [package renv](https://rstudio.github.io/renv/index.html):

```r
renv::restore()
```

See [Workflow Overview](github_vignettes/workflow-overview.md) for data processing guidelines.
