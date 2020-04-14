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
#' 
#' @family functions to manage data
#' @export
data_archive <- function(
    state, period,
    current_drive = file.path("E:/SA/Data-sensitive/Data-Dashboards", state),
    archive_drive = file.path("H:/SA/Data-sensitive/Data-Dashboards", state),
    pattern = "raw-2...-q.",
    move_folders = TRUE,
    move_files = FALSE
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

#' (Not implemented) Backup databases to archive drive
data_backup <- function() {
    
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
