# lictemplate

An R package that provides a template workflow for license data preparation.

## Installation

From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/lictemplate")
```
    
## Usage

1. Populate a directory with template files:

```r
# example for South Dakota 2019 end-of-year dashboard
lictemplate::new_project("SD", "2019-q4")
## A new license data project has been initialized:
##  E:/SA/Projects/Data-Dashboards/SD/2019-q4
```

Running `new_project()` creates data directories and a set of template files/folders for analysis, defaulting to Data Server file paths:

![](img/new-dashboard.png)

2. Open the Rstudio project just created and build the project package library with [package renv](https://rstudio.github.io/renv/index.html):

```r
renv::restore()
```

See [package salicprep](https://github.com/southwick-associates/salicprep) for data processing guidelines.
