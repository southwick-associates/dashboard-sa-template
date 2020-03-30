# run scripts and save log files to html

# prepare production data
workflow::run_html("code/1-prep-license-data/01-load-raw.R")
workflow::run_html("code/1-prep-license-data/02-standardize.R")
workflow::run_html("code/1-prep-license-data/03-prep-lic-types.R")
workflow::run_rmd_html("code/1-prep-license-data/04-check-initial.Rmd")
workflow::run_html("code/1-prep-license-data/05-finalize.R")
workflow::run_rmd_html("code/1-prep-license-data/06-check-final.Rmd")

# prepare dashboard summary data
workflow::run_html("code/2-prep-dashboard/01-dashboard-data.R")

# visualize dashboard with shiny
dashtemplate::run_visual()
