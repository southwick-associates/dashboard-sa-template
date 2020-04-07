# functions to update projects

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
#' @family functions to update projects
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
#' @family functions to update projects
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

#' Move raw data to archive drive
#' 
#' TODO: probably want to move all raw data from before some time period
#' 
#' @inheritParams new_project
#' @param current_drive drive from which to move
#' @param archive_drive destination drive
#' @param dirs_to_move directories in which all containing files will be moved.
#' If NULL, no directories will be moved
#' @param files_to_move named files to be moved. If NULL, no files will be moved.
#' @param reverse If TRUE, moves in the opposite direction (e.g., undo)
#' 
#' @family functions to update projects
#' @export
#' @examples 
#' # archive_data("YY", "2019-q4") # archive
#' # archive_data("YY", "2019-q4", reverse = TRUE) # move back
#' 
#' # archive data for all states
#' states <- list.files("E:/SA/Data-sensitive/Data-Dashboards")
#' for (i in states) archive_data(i, "2019-q4")
archive_data <- function(
    state, period,
    current_drive = file.path("E:/SA/Data-sensitive/Data-Dashboards", state),
    archive_drive = file.path("H:/SA/Data-sensitive/Data-Dashboards", state),
    dirs_to_move = paste0("raw-", state, "-", period),
    files_to_move = paste0("raw-", state, "-", period, ".sqlite3"),
    reverse = FALSE
) {
    # store the relevant file names in a vector
    # - want all periods equal and prior to selected
    
    # run the move
    if (reverse) {
        
    }
    # move dirs_to_move
    # move files_to_move
}

#' Permanently remove data
#' 
#' By default you will be prompted to enter "yes" to confirm that you want to
#' remove a specified set of files.
#' 
#' @inheritParams new_project
#' @param drive target location from which to remove files
#' @param force_destroy If TRUE, delete without prompt (potentially useful for
#' batch deletes). Use with caution.
#' 
#' @family functions to update projects
#' @export
destroy_data <- function(
    state, period,
    drive = file.path("H:/SA/Data-sensitive/Data-Dashboards", state),
    force_destroy = FALSE
) {
    if (!force_destroy) {
        cat("Be careful. This will permanently delete these files:",
            drive, "\n")
        user_input <- readline(
            "Enter 'Yes' to permanently remove indicated files: "
        )
        if (!tolower(user_input) == "yes") {
            return("No files have been deleted.")
        }
    }
    # remove files
    cat("Files have been removed from ", drive)
}
