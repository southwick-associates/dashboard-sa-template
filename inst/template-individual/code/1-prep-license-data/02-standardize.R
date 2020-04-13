# standardize data
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/data-schema.md
# - only select columns will be needed in the standardized data
# - much of the code needed here is state-specific

# - workflow::run_html() may produce an error after deduplication with data.table
#   sourcing the file should work fine, but no log file will be produced as a result

## State-specific Notes
# - 

library(tidyverse)
library(DBI)
library(stringr)
library(data.table) # for deduplication performance
library(lubridate)
library(salic)
library(salicprep)
library(sadash)
source("code/params.R")

# License -----------------------------------------------------------------

# previous period license types
# - which may need updating with new license types
con <- dbConnect(RSQLite::SQLite(), db_production)
lic <- tbl(con, "lic") %>%  collect()
dbDisconnect(con)

# current period license types
con <- dbConnect(RSQLite::SQLite(), db_raw)
lic_new <- tbl(con, "lic") %>% 
    collect() %>%
    mutate(lic_period = period)

# add any new license types
lic <- bind_rows(lic, lic_new) %>%
    arrange(lic_period) %>% # preferentially keep existing records
    group_by(lic_id) %>%
    slice(1L) %>%
    ungroup()
    
# save as csv for by-hand editing
dir.create("data", showWarnings = FALSE)
write_csv(lic, "data/lic.csv")

# Standardize Customers -----------------------------------------------------

# load raw data
cust <- tbl(con, "cust") %>% 
    select(raw_cust_id, and_other_columns) %>%
    collect()

# check for inconsistency in customer ID
count(cust, cust_id) %>% filter(n > 1)

# first & last name
cust <- cust %>%
    mutate_at(vars(last, first), function(x) str_to_lower(x) %>% str_trim())

# standardize state
data(state_abbreviations, package = "salic")
cust <- recode_state(cust, state_abbreviations)
# - check
cust %>%
    filter(toupper(state) != state_new) %>% 
    count(toupper(state), state_new)
# - replace
cust <- select(cust, -state) %>% rename(state = state_new)

# identify state residency
cust$cust_res <- ifelse(cust$state == state, 1L, 0L)
count(cust, cust_res)

# standardize date
# - you may want to use string parsing instead (e.g., substr) since converting back to
#   character (e.g., with date_to_char) is very slow 
cust <- recode_date(cust, "dob", function(x) str_sub(x, end = 10) %>% ymd())

# gender
count(cust, sex)
cust$sex_new <- ifelse(cust$sex == "M", 1L, 2L)
count(cust, sex_new, sex)
cust <- select(cust, -sex) %>% rename(sex = sex_new)

# Standardize Sales -------------------------------------------------------

# load raw
sale <- tbl(con, "sale") %>% 
    select(raw_sale_id) %>% 
    collect()
dbDisconnect(con)

# dates
sale <- recode_date(sale, "dot", function(x) str_sub(x, end = 10) %>% ymd())
sale <- recode_date(sale, "start_date", function(x) str_sub(x, end = 10) %>% ymd())
sale <- recode_date(sale, "end_date", function(x) str_sub(x, end = 10) %>% ymd())

# Final Formatting ---------------------------------------------------------

# add period for data provenance
cust$cust_period <- period
sale$sale_period <- period

# only keep columns of interest (need to be specified)
cust <- select(cust, cols_to_keep)
sale <- select(sale, cols_to_keep)

# check the data standardization rules
data_check_standard(cust, lic, sale)

# Add to Existing ---------------------------------------------------------

# pull old standard data and stack with new
# - preferably we want only want to be storing one standard.sqlite3
#   but there may be multiple standard databases from previous iterations
dbs <- list.files(dirname(dir_raw), pattern = "standard-2", full.names = TRUE)

cust <- lapply(dbs, load_cust_standard) %>% bind_rows(cust)
count(cust, cust_period)

sale <- lapply(dbs, load_sale_standard) %>% bind_rows(sale)
count(sale, sale_period)

# Deduplicate (if needed) -------------------------------------------------

# data.table is MUCH faster and more memory efficient than dplyr for this
# - dplyr will choke once you get in the tens of millions of rows

# check for customer ID duplicates
# - and make sure ID duplicates aren't actually different customers
dups <- count(cust, cust_id) %>% filter(n > 1)
dups %>% sample_n(10) %>% left_join(cust, by = "cust_id")

# we only want the most recent record for a given customer ID
# - grouping by customer ID and preferring more recent records
setDT(cust)
setorderv(cust, "cust_period")
cust <- cust[, tail(.SD, 1), by = "cust_id"]
setDF(cust)
count(cust, cust_period)

# note: deduplication of sales isn't necessary for the workflow
# although it can help if the size of the table is reduced

# final checks
data_check_standard(cust, lic, sale)
glimpse(cust)
glimpse(sale)

# Write to Sqlite ---------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_standard)
dbWriteTable(con, "cust", cust, overwrite = TRUE)
dbWriteTable(con, "sale", sale, overwrite = TRUE)
dbDisconnect(con)
