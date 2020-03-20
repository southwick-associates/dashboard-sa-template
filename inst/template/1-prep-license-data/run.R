# run scripts and save log files to html

workflow::run_html("1-prep-license-data/01-load-raw.R")
workflow::run_html("1-prep-license-data/02-standardize.R")
workflow::run_rmd_html("1-prep-license-data/03-check-initial.Rmd")
workflow::run_html("1-prep-license-data/04-finalize.R")