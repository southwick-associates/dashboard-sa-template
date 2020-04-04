# functions for making template files/folders

# Helper Functions --------------------------------------------------------

#' Helper function for setting up project code
#' 
#' Only intended to be run from other functions: (\code{\link{new_project}}), etc.
#' It does some error checking and sets up analysis/data folders.
#' 
#' @inheritParams new_project
#' @family functions for making template files/folders
#' @export
setup_project <- function(
    state, period, analysis_path, sensitive_path, production_path
) {
    # error check - don't run if the drive in specified paths don't exist
    check_drive <- function(path) {
        path <- gsub("\\\\", "/", path) # ensure directories are separated by "/"
        drive = paste0(unlist(strsplit(path, "/"))[1], "/")
        if (!dir.exists(drive)) {
            stop("The ", drive, " drive from ", path, 
                 " doesn't exist on your computer", call. = FALSE)
        }
    }
    sapply(c(analysis_path, sensitive_path, production_path), check_drive)
    
    # error check - don't run if a directory with that time period already exists
    if (dir.exists(analysis_path)) {
        stop("That period already exists!: ", analysis_path, call. = FALSE)
    }
    
    # create data folders (sensitive, production)
    dir_create <- function(path) {
        if (!is.null(path)) {
            dir.create(path, recursive = TRUE, showWarnings = FALSE)
        }
    }
    dir_create(sensitive_path)
    dir_create(production_path)
    
    # create analysis folder
    dir.create(analysis_path, recursive = TRUE)
}

#' Helper function to replace parameter strings
#' 
#' Intended only to be called from other lictemplate functions. Particularly for 
#' use in the "params.R" file.
#' 
#' @param files full path to file(s) that containts strings to be replaced
#' @param new vector of new values to be used
#' @param old corresponding vector of old values to be replaced
#' 
#' @family functions for making template files/folders
#' @export
replace_params <- function(files, new, old) {
    for (f in files) {
        x <- readLines(f)
        for (i in seq_along(new)) {
            x <- gsub(old[i], new[i], x)
        }
        cat(x, file = f, sep = "\n")
    }
}

# New Projects ------------------------------------------------------------

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

# Update Projects ---------------------------------------------------------

#' Setup a new period for a project
#' 
#' This will setup files based on a reference time period, rather than 
#' creating new files based on the default template. By default, the new analysis 
#' folder will include all ref_period R files (.R, .Rmd, etc.) and their
#' containing folders, as well as .txt/.tex files.
#' 
#' @inheritParams new_project
#' @param ref_period folder name of reference time period (e.g., 2019-q4)
#' @param ref_path full file path to reference period analysis folder
#' @param files_to_keep patterns for matching on files in the "code" folder using grep 
#' (not case sensitive). Files with matching patterns will be copied from ref_period.
#' @param top_level_files top-level analysis files that should be copied over
#' 
#' @family functions for making template files/folders
#' @export
update_project <- function(
    state, period, ref_period, 
    ref_path = file.path("E:/SA/Projects/Data-Dashboards", state, ref_period),
    analysis_path = file.path("E:/SA/Projects/Data-Dashboards", state, period),
    sensitive_path = file.path("E:/SA/Data-Sensitive/Data-Dashboards", state, paste0("raw-", period)),
    production_path = file.path("E:/SA/Data-Production/Data-Dashboards", state),
    files_to_keep = c("\\.r", "documentation\\.tex", "\\.txt"),
    top_level_files = c(".Rprofile", "README.md", "renv.lock", "renv/activate.R",  
                        "renv/settings.dcf")
) {
    # error check - reference path
    if (!dir.exists(ref_path)) {
        stop("The reference path (", ref_path, ") doesn't exist", call. = FALSE)
    }
    
    # setup folders
    setup_project(state, period, analysis_path, sensitive_path, production_path)
    
    # identify files/folders to copy
    match_files <- function(file_match, all_files) {
        x <- lapply(file_match, grep, x = tolower(all_files))
        unique(unlist(x)) 
    }
    code_path <- file.path(ref_path, "code")
    all_files <- list.files(code_path, recursive = TRUE, all.files = TRUE)
    keep_files <- all_files[match_files(files_to_keep, all_files)]
    
    # copy analysis files
    copy_files <- function(file_names) {
        for (i in file_names) {
            old <- file.path(ref_path, i)
            new <- file.path(analysis_path, i)
            if (file.exists(old)) {
                dir.create(dirname(new), recursive = TRUE, showWarnings = FALSE)
                file.copy(old, new, overwrite = FALSE)
            }
        }
    }
    copy_files(file.path("code", keep_files))
    
    # copy top-level files
    copy_files(top_level_files)
    
    # copy .Rproj and rename
    oldname <- paste0(state, "-", ref_period, ".Rproj")
    newname <- paste0(state, "-", period, ".Rproj")
    copy_files(oldname)
    file.rename(
        file.path(analysis_path, oldname),
        file.path(analysis_path, newname)
    )
    
    # replace parameters from previous time period
    replace_params(
        files = c(
            file.path(analysis_path, "README.md"), 
            file.path(analysis_path, "code", "params.R")
        ),
        new = period, old = ref_period
    )
    
    # print message
    message("An updated project has been initialized:\n  ", analysis_path)
}

#' Setup data dive template
#' 
#' This is to be run for an existing state-time_period dashboard project. 
#' It creates a new folder with template code. Defaults to placing a "5-data-dive"
#' folder in the working directory (i.e., when state and time_period are NULL).
#' 
#' @inheritParams new_project
#' @param dive_path folder for data dive code
#' @family functions for making template files/folders
#' @export
#' @examples 
#' # setup_data_dive("YY", "2019-q4")
setup_data_dive <- function(
    state, period, 
    analysis_path = file.path("E:/SA/Projects/Data-Dashboards", state, period),
    dive_path = file.path(analysis_path, "code", "5-data-dive")
) {
    # error check - whether analysis path exists
    if (!dir.exists(analysis_path)) {
        stop("The analysis path (", analysis_path, ") doesn't exist", call. = FALSE)
    }
    
    # error check - whether data diver directory exists
    if (dir.exists(dive_path)) {
        stop("The data dive path (", dive_path, ") already exists", call. = FALSE)
    }
    
    # create dive_path
    dir.create(dive_path)
    
    # copy template files to dive_path
    template_dir <- system.file("template-dive", package = "lictemplate")
    template_files <- list.files(template_dir)
    
    for (i in template_files) {
        file.copy(
            file.path(template_dir, i), 
            file.path(dive_path, i), 
            overwrite = FALSE
        )
    }
    message("A data dive folder has been initialized:\n  ", dive_path)
}
