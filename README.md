# lictemplate

An R package that provides template workflows for license data preparation and dashboard production. These  workflows make use of several other SA-built R packages: [salic](https://southwick-associates.github.io/salic/), [salicprep](https://github.com/southwick-associates/salicprep), [workflow](https://github.com/southwick-associates/workflow),
[sadash](https://github.com/southwick-associates/sadash).

## Installation

From the R console:

```r
install.packages("remotes")
remotes::install_github("southwick-associates/lictemplate")
```
    
## Usage

Lictemplate provides functions for automating license data workflows:

- **Initialize new projects**: 
    + `new_project()` for a basic processing workflow (e.g., national/regional dashboards)
    + TODO: `new_project_summary()` for states that provide summarized data for national/regional dashboards
    + `new_project_individual()` for more involved individual state dashboards
- **Update existing projects:**
    + `update_project()` to copy the workflow from an earlier time period with updated parameters
    + `setup_data_dive()` to tack on the workflow for producing a data dive project
    + TODO: `archive_raw_data()` to move raw data to the archive H drive.

### Example New Project

To begin a new project, first create data directories and template files for analysis (e.g, on the Data Server, a South Dakota dashboard):

```r
lictemplate::new_project("SD", "2019-q4")
## A new license data project has been initialized:
##  E:/SA/Projects/Data-Dashboards/SD/2019-q4
```

![](img/new-dashboard.png)

Next, open the Rstudio project just created and build the project package library with [package renv](https://rstudio.github.io/renv/index.html):

```r
renv::restore()
```

See [package salicprep](https://github.com/southwick-associates/salicprep) for data processing guidelines.
