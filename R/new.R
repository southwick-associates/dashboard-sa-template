# functions for new projects based on templates

#' Setup a new state project with default directories and template scripts
#' 
#' This is intended to be run before data processing for a new state begins.
#' 
#' @param state character: Two letter state designation
#' @param period character: Time period for the first project 
#' (e.g., "2019-q4", "2020-q4", etc.)
#' @param analysis_path character: File path for the analysis
#' @param sensitive_path character: File path for the sensitive data. If NULL,
#' no folders will be created.
#' @param production_path character: File path for the production data. If NULL, 
#' no folders will be created.
#' @param template_path character: Name of inst subpath in the package that points
#' to the template files
#' @param print_message character: Message to print on success
#' 
#' @family functions for new projects based on templates
#' @export
#' @examples
#' # new_project("XX", "2019-q4")
new_project <- function(
    state, 
    period, 
    analysis_path = file.path("E:/SA/Projects/Data-Dashboards", state, period),
    sensitive_path = file.path("E:/SA/Data-Sensitive/Data-Dashboards", state, paste0("raw-", period)),
    production_path = file.path("E:/SA/Data-Production/Data-Dashboards", state),
    template_path = "template",
    print_message = "A new license data project has been initialized"
) {
    # setup folders
    setup_project(state, period, analysis_path, sensitive_path, production_path)
    
    # copy analysis files from template
    template_paths <- list.files(
        system.file(template_path, package = "lictemplate"), full.names = TRUE
    )
    for (i in template_paths) {
        file.copy(i, analysis_path, recursive = TRUE, overwrite = FALSE)
    }
    
    # rename 2 analysis files
    file.rename(
        file.path(analysis_path, "Rprofile-tmp"),
        file.path(analysis_path, ".Rprofile")
    )
    file.rename(
        file.path(analysis_path, "template.Rproj"),
        file.path(analysis_path, paste0(state, "-", period, ".Rproj"))
    )
    
    # replace parameter (state, period) values in select files
    replace_params(
        files = c(
            file.path(analysis_path, "README.md"), 
            file.path(analysis_path, "code", "params.R")
        ), 
        new = c(state, period), old = c("__state__", "__period__")
    )
    
    # print message to console
    message(print_message, ":\n  ", analysis_path)
}

#' Setup a new individual state dashboard with default directories and template scripts
#' 
#' For states which have custom individual dashboards (in addition to national/regional).
#' This function is intended to be run before data processing for a new state begins. 
#' It's just a wrapper for \code{\link{new_project}}.
#' 
#' @inheritParams new_project
#' @param ... other arguments passed to \code{\link{new_project}}
#' 
#' @family functions for new projects based on templates
#' @export
#' @examples
#' # new_project_individual("YY", "2019-q4")
new_project_individual <- function(
    state, period, template_path = "template-individual",
    print_message = "A new individual state dashboard has been initialized",
    ...
) {
    new_project(state, period, template_path = template_path, 
                print_message = print_message, ...)
}
