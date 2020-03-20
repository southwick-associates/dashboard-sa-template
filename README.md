# sadashtemplate

An R package to create template files for national/regional dashboard processing and provide documentation for the analysis.

## Documentation

- [Dashboard Analyst Introduction](github_vignettes/dashboard-overview.md)
- [Workflow Overview (incomplete)](github_vignettes/workflow-overview.md)
    + [Rstudio Recommended Settings](github_vignettes/rstudio-settings.md)
- [Data required from states](github_vignettes/data-required.md)
- [Database Schemas](github_vignettes/data-schema.md)

## Installation

Note: Not yet ready to install. From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/sadashtemplate")
```
    
## Usage

Using the Southwick Data Server, open an R console (e.g., using RStudio) and populate a directory with template files:

```r
sadashtemplate::new_dashboard("state-abbreviation", "time-period")
```

Open the Rstudio project just created and build the project package library with [package renv](https://rstudio.github.io/renv/index.html):

```r
renv::restore()
```

See [Workflow Overview](github_vignettes/workflow-overview.md) for data processing guidelines.
