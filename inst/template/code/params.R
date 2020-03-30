# state/period-specific parameters to be called in production code

state <- "__state__"
period <- "__period__"

# for data processing
dir_production <- "E:/SA/Data-production/Data-Dashboards"
dir_sensitive <- "E:/SA/Data-sensitive/Data-Dashboards"
dir_raw <- file.path(dir_sensitive, state, paste0("raw-", period))

db_raw <- file.path(dir_sensitive, state, paste0("raw-", period, ".sqlite3"))
db_standard <- file.path(dir_sensitive, state, paste0("standard-", period, ".sqlite3"))
db_production <- file.path(dir_production, state, "license.sqlite3")

# for building dashboard summary data
firstyr <- 2010                             # first year of data of interest
lastyr <- as.integer(substr(period, 1, 4))  # last year of data of interest
yrs <- firstyr:lastyr
quarter <- as.integer(substr(period, 7, 7)) # current quarter

if (quarter == 4) {
    timeframe <- "full-year"
} else {
    timeframe <- "mid-year"
}
