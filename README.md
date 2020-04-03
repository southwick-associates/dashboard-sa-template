# lictemplate

An R package that provides a template workflow for license data preparation. The workflow makes use of several other SA-built R packages: [salic](https://southwick-associates.github.io/salic/), [salicprep](https://github.com/southwick-associates/salicprep), [workflow](https://github.com/southwick-associates/workflow).

## Installation

From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/lictemplate")
```
    
## Usage

### 1. Build Templates

Populate a directory with template files:

```r
# example for South Dakota 2019 end-of-year dashboard
lictemplate::new_project("SD", "2019-q4")
## A new license data project has been initialized:
##  E:/SA/Projects/Data-Dashboards/SD/2019-q4
```

Running `new_project()` creates data directories and a set of template files/folders for analysis, defaulting to Data Server file paths:

![](img/new-dashboard.png)

### 2. Build Project Library

Open the Rstudio project just created and build the project package library with [package renv](https://rstudio.github.io/renv/index.html):

```r
renv::restore()
```

### 3. Process Data

See [package salicprep](https://github.com/southwick-associates/salicprep) for data processing guidelines.
