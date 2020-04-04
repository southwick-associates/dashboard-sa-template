# functions for making template files/folders

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
#' @family functions for making template files/folders
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
    # error - don't run if the drive in specified paths don't exist
    check_drive <- function(path) {
        path <- gsub("\\\\", "/", path) # ensure directories are separated by "/"
        drive = paste0(unlist(strsplit(path, "/"))[1], "/")
        if (!dir.exists(drive)) {
            stop("The ", drive, " drive from ", path, 
                 " doesn't exist on your computer", call. = FALSE)
        }
    }
    sapply(c(analysis_path, sensitive_path, production_path), check_drive)
    
    # error - don't run if a directory with that time period already exists
    if (dir.exists(analysis_path)) {
        stop("That period already exists!: ", analysis_path, call. = FALSE)
    }
    dir.create(analysis_path, recursive = TRUE)
    
    # create analysis folders/files
    template_paths <- list.files(
        system.file(template_path, package = "lictemplate"), full.names = TRUE
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
    
    # - replace parameter (state, period) values in select files
    replace_params <- function(file) {
        f <- file.path(analysis_path, file)
        x <- readLines(f)
        x <- gsub("__state__", state, x)
        x <- gsub("__period__", period, x)
        cat(x, file = f, sep = "\n")
    }
    replace_params("code/params.R")
    replace_params("README.md")
    
    # create data folders (sensitive, production)
    dir_create <- function(path) {
        if (!is.null(path)) {
            dir.create(path, recursive = TRUE, showWarnings = FALSE)
        }
    }
    dir_create(sensitive_path)
    dir_create(production_path)
    
    # print message
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
#' @family functions for making template files/folders
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
