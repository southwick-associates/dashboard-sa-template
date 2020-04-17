# helper functions

#' Helper function for setting up project code
#' 
#' Only intended to be run from other functions: (\code{\link{new_project}}), etc.
#' It does some error checking and sets up analysis/data folders.
#' 
#' @inheritParams new_project
#' @family helper functions
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
#' @family helper functions
#' @export
replace_params <- function(files, new, old) {
    for (f in files) {
        if (!file.exists(f)) {
            next
        }
        x <- readLines(f)
        for (i in seq_along(new)) {
            x <- gsub(old[i], new[i], x)
        }
        cat(x, file = f, sep = "\n")
    }
}

#' Helper function to identify files with equal to or lower given period
#' 
#' To be called from \code{\link{data_archive}}
#' 
#' @param files vector of files/folders
#' @inheritParams new_project
#' @family helper functions
#' @export
#' @examples 
#' files <- c("raw-2016-q2", "raw-2016-q4", "raw-2016-q4.sqlite3",
#'            "raw-2017-q2", "raw-2017-q4")
#' get_periods(files, "2016-q4")
get_periods <- function(files, period) {
    most_recent_match <- tail(grep(period, files), 1)
    files[1:most_recent_match]
}
