# functions for making template files/folders

#' Setup a new state dashboard with default directories and template scripts
#' 
#' This is intended to be run before data processing for a new state begins.
#' 
#' @param state character: Two letter state designation
#' @param time_period character: Time period for the first dashboard 
#' (e.g., "2019-q4", "2020-q4", etc.)
#' @param sa_path character: File path to the Southwick main folder 
#' (for analysis and data, etc.)
#' @family functions for making template files/folders
#' @export
#' @examples
#' # new_dashboard("YY", "2018-q4")
new_dashboard <- function(state, time_period, sa_path = "E:/SA") {
    # error handling to avoid running if relevant folders already exist
    
    # create analysis folders/files
    
    # create data folders/files
}
