# functions to manage data

#' Move data to archive for a state (equal-to or before a period)
#' 
#' Probably most useful for moving in batches (e.g., looping across states). 
#' Othewise it can be done easily by hand. By default, moves relevant raw data 
#' files to the H drive.
#' 
#' @inheritParams new_project
#' @param current_drive drive from which to move
#' @param archive_drive destination drive
#' @param pattern matching pattern sent to \code{\link[base]{list.files}}
#' @param move_folders If TRUE, will move files within folders matching the pattern
#' @param move_files If TRUE, will move files matching the pattern (e.g., sqlite)
#' @param delete_after_copy If TRUE, the current_drive files will be deleted 
#' after copying (i.e., archived), otherwise not (i.e., backed-up)
#' 
#' @family functions to manage data
#' @export
data_archive <- function(
    state, period,
    current_drive = file.path("E:/SA/Data-sensitive/Data-Dashboards", state),
    archive_drive = file.path("H:/SA/Data-sensitive/Data-Dashboards", state),
    pattern = "raw-2...-q.",
    move_folders = TRUE,
    move_files = FALSE,
    delete_after_copy = TRUE
) {
    if (!dir.exists(current_drive)) {
        stop("The", current_drive, "drive doesn't exist", call. = FALSE)
    }
    
    # store the matching file/folder names in a vector
    files <- list.files(current_drive, pattern = pattern)
    files <- get_periods(files, period)
    
    # separate files from folders
    is_dir <- dir.exists(file.path(current_drive, files))
    dirs <- files[is_dir]
    files <- files[!is_dir]
    
    # define function to remove current_files after moving to archive
    files_remove <- function(current_files, archive_files) {
        if (all(file.exists(archive_files))) {
            file.remove(current_files)
        } else {
            stop("Error copying files. These weren't removed.", 
                 cat(current_files, sep = "\n"), call. = FALSE)
        }
    }
    
    # move files stored in matching folders
    if (move_folders && length(dirs) != 0) {
        for (i in dirs) {
            dir.create(file.path(archive_drive, i), recursive = TRUE, 
                       showWarnings = FALSE)
            file.copy(file.path(current_drive, i), archive_drive, 
                      recursive = TRUE)
        }
        current_files <- list.files(
            file.path(current_drive, dirs), full.names = TRUE, recursive = TRUE
        )
        archive_files <- sub(current_drive, archive_drive, current_files)
        files_remove(current_files, archive_files)
        
    }
    
    # move matching files
    if (move_files && length(files) != 0) {
        current_files <- file.path(current_drive, files)
        archive_files <- file.path(archive_drive, files)
        file.copy(current_files, archive_files)
        files_remove(current_files, archive_files)
    }
}

#' Backup select files for a state to archive drive
#' 
#' Intended for saving databases that will be overwritten during data updates 
#' (e.g., standard, license, history). Note that this is potentially destructive
#' to existing files in the archive drive (i.e., existing archived files will
#' be overwritten), and you will need to specify overwrite = TRUE in this case.
#' 
#' @param state 2-letter abbreviation for state
#' @param files vector of file paths that will be backed-up
#' @param archive_drive drive to which the files will be copied
#' @param overwrite If TRUE, existing files in the archive drive can be overwritten
#' @param ... additional arguments passed to \code{\link[base]{file.copy}}
#' 
#' @family functions to manage data
#' @export
data_backup <- function(
    state, 
    files = c(
        file.path("E:/SA/Data-sensitive/Data-Dashboards", state, "standard.sqlite3"),
        file.path("E:/SA/Data-production/Data-Dashboards", state, "license.sqlite3"),
        file.path("E:/SA/Data-production/Data-Dashboards", state, "history.sqlite3")
    ),
    archive_drive = "H:",
    overwrite = FALSE, 
    ...
) {
    files <- files[file.exists(files)] # restrict to existing files
    if (length(files) == 0) {
        cat("No files to be backed up in state", state, "\n")
        return(invisible())
    }
    
    get_target_file <- function(file) {
        drive <- unlist(strsplit(file, "/"))[1]
        sub(drive, archive_drive, file)
    }
    files_target <- sapply(files, get_target_file, USE.NAMES = FALSE)
    
    if (any(file.exists(files_target)) && !overwrite) {
        stop("You must specify 'overwrite = TRUE' if files already exist in archive.",
             call. = FALSE)
    } 
    
    for (i in seq_along(files)) {
        dir.create(dirname(files_target[i]), showWarnings = FALSE, recursive = TRUE)
        file.copy(files[i], files_target[i], overwrite = overwrite, ...)
        cat("Copied to:", files_target[i], "\n")
    }
}

#' (Not implemented) Permanently remove data
#' 
#' By default you will be prompted to enter "yes" to confirm that you want to
#' remove a specified set of files.
#' 
#' @inheritParams new_project
#' @param drive target location from which to remove files
#' @param force If TRUE, delete without prompt (potentially useful for
#' batch deletes). Use with caution.
#' 
#' @family functions to manage data
#' @export
data_destroy <- function(
    state, period,
    drive = file.path("H:/SA/Data-sensitive/Data-Dashboards", state),
    force = FALSE
) {
    if (!force) {
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
    
}
