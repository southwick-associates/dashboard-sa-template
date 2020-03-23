# functions for making template files/folders

#' Setup a new state dashboard with default directories and template scripts
#' 
#' This is intended to be run before data processing for a new state begins.
#' 
#' @param state character: Two letter state designation
#' @param period character: Time period for the first dashboard 
#' (e.g., "2019-q4", "2020-q4", etc.)
#' @param analysis_path character: File path for the analysis
#' @param sensitive_path character: File path for the sensitive data. If NULL,
#' no folders will be created.
#' @param production_path character: File path for the production data. If NULL, 
#' no folders will be created.
#' @family functions for making template files/folders
#' @export
#' @examples
#' # new_dashboard("YY", "2019-q4")
new_dashboard <- function(
    state, period, 
    analysis_path = file.path("E:/SA/Projects/Data-Dashboards", state, period),
    sensitive_path = file.path("E:/SA/Data-Sensitive/Data-Dashboards", state, paste0("raw-", period)),
    production_path = file.path("E:/SA/Data-Production/Data-Dashboards", state)
) {
    # error - don't run if a directory with that time period already exists
    if (dir.exists(analysis_path)) {
        stop("That period already exists!: ", analysis_path, call. = FALSE)
    }
    dir.create(analysis_path, recursive = TRUE)
    
    # create analysis folders/files
    template_paths <- list.files(
        system.file("template", package = "lictemplate"), full.names = TRUE
    )
    for (i in template_paths) {
        file.copy(i, analysis_path, recursive = TRUE, overwrite = FALSE)
    }
    
    # - rename 2 analysis files
    file.rename(
        file.path(analysis_path, "Rprofile-tmp"),
        file.path(analysis_path, ".Rprofile")
    )
    file.rename(
        file.path(analysis_path, "template.Rproj"),
        file.path(analysis_path, paste0(state, "-", period, ".Rproj"))
    )
    
    # - replace parameter (state, period) values in params.R
    f <- file.path(analysis_path, "params.R")
    x <- readLines(f)
    x <- gsub("__state__", state, x)
    x <- gsub("__period__", period, x)
    cat(x, file = f, sep = "\n")
    
    # create data folders (sensitive, production)
    dir_create <- function(path) {
        if (!is.null(path)) {
            dir.create(path, recursive = TRUE, showWarnings = FALSE)
        }
    }
    dir_create(sensitive_path)
    dir_create(production_path)
    
    # print message
    message("A new dashboard project has been initialized:\n  ", analysis_path)
}
