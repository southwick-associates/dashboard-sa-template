# state/period-specific parameters to be called in production code

state <- "XX"
period <- "yyyy-qn"
firstyr <- 2010 # first year to include in dashboard results

dir_sensitive <- "E:/SA/Data-sensitive/Data-Dashboards"
dir_raw <- file.path(dir_sensitive, state, paste0("raw-", period))
db_raw <- file.path(dir_sensitive, state, paste0("raw-", period, ".sqlite3"))
db_standard <- file.path(dir_sensitive, state, paste0("standard-", period, ".sqlite3"))

dir_production <- "E:/SA/Data-production/Data-Dashboards"
db_license <- file.path(dir_production, state, "license.sqlite3")
db_history <- file.path(dir_production, state, "history.sqlite3")
db_census <- file.path(dir_production, "_Shared", "census.sqlite3")

# for building license histories & dashboard summaries
lastyr <- as.integer(substr(period, 1, 4))
quarter <- as.integer(substr(period, 7, 7))
yrs <- firstyr:lastyr
dashboard_yrs <- lastyr # focus years to be available in dashboard dropdown menu
