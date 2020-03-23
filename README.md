# lictemplate

An R package that provides a template workflow for license data preparation.

## Installation

From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/lictemplate")
```
    
## Usage

Populate a directory with template files:

```r
lictemplate::new_dashboard("state-abbreviation", "time-period")
```

Open the Rstudio project just created and build the project package library with [package renv](https://rstudio.github.io/renv/index.html):

```r
renv::restore()
```

See [package salicprep](https://github.com/southwick-associates/salicprep) for data processing guidelines.
