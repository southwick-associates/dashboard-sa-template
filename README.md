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
lictemplate::new_dashboard("SD", "2019-q4")
## A new dashboard project has been initialized:
##  E:/SA/Projects/Data-Dashboards/SD/2019-q4
```

These folders/files are created after running `new_dashboard()`:

![](img/new-dashboard.png)

2. Open the Rstudio project just created and build the project package library with [package renv](https://rstudio.github.io/renv/index.html):

```r
renv::restore()
```

See [package salicprep](https://github.com/southwick-associates/salicprep) for data processing guidelines.
