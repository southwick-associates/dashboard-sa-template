# run scripts and save log files to html

# prepare production data
workflow::run_html("code/1-prep-license-data/01-load-raw.R")
workflow::run_html("code/1-prep-license-data/02a-lic-types.R")
workflow::run_html("code/1-prep-license-data/02-standardize.R")
workflow::run_html("code/1-prep-license-data/03-pull-geocode.R")
workflow::run_html("code/1-prep-license-data/04-prep-lic-types.R")
workflow::run_rmd_html("code/1-prep-license-data/05-check-initial.Rmd")
workflow::run_html("code/1-prep-license-data/06-finalize.R")
workflow::run_rmd_html("code/1-prep-license-data/07-check-final.Rmd")

# build license history
workflow::run_html("code/2-license-history/1-run-history.R")
workflow::run_html("code/2-license-history/2-summarize.R")

# prepare dashboard summary data
workflow::run_html("code/3-dashboard-results/1-run-dash.R")
# - the 2nd script is to be run interactively

# documentation
# - intended to be run interactively
