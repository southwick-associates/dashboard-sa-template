# build dashboard summaries
# https://github.com/southwick-associates/dashboard-template

library(tidyverse)
library(DBI)
library(salic)
library(dashtemplate)
source("code/params.R")

# Load Data ---------------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_production)
lic <- tbl(con, "lic") %>% select(lic_id, type, duration) %>% collect()
cust <- tbl(con, "cust") %>% select(cust_id, sex, birth_year) %>% collect()
sale <- tbl(con, "sale") %>% select(cust_id, lic_id, year, month, res) %>% collect()
dbDisconnect(con)

data_check(cust, lic, sale)

# Build Summaries ----------------------------------------------------------

run_group <- function(group, lic_types) {
    build_history(cust, lic, sale, yrs, timeframe, lic_types) %>%
        calc_metrics() %>% 
        format_metrics(timeframe, group)
}
outdata <- list(
    run_group("hunt", c("hunt", "combo")),
    run_group("fish", c("fish", "combo")),
    run_group("all_sports", c("hunt", "fish", "combo")) 
)
outdata <- bind_rows(outdata)
glimpse(outdata)

# Write to CSV ----------------------------------------------------

outfile <- file.path(
    "out", paste0(timeframe, yrs[1], "to", yrs[length(yrs)], ".csv")
)
dir.create("out", showWarnings = FALSE)
write.csv(outdata, file = outfile, row.names = FALSE)
