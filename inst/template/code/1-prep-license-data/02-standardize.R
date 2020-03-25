# standardize data
# - only select columns will be needed in the standardized data
# - much of the code needed here is state-specific

library(tidyverse)
library(DBI)
library(stringr)
library(lubridate)
library(salic)
library(salicprep)

source("code/params.R")

# License -----------------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_raw)

lic <- tbl(con, "lic") %>% 
    select(raw_lic_id) %>%
    collect()

# save as csv for by-hand editing
dir.create("data", showWarnings = FALSE)
write_csv(lic, "data/lic.csv")

# Standardize Customers -----------------------------------------------------

cust <- tbl(con, "cust") %>% 
    select(raw_cust_id) %>%
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
cust <- cust %>%
    select(-state) %>%
    rename(state = state_new)

# identify state residency
cust$cust_res <- ifelse(cust$state == state, 1L, 0L)
count(cust, cust_res)

# date of birth
cust <- mutate(cust, dob = str_sub(dob, end = 10) %>% mdy())

# gender

# Standardize Sales -------------------------------------------------------

sale <- tbl(con, "sale") %>% 
    select(raw_sale_id) %>% 
    collect()
dbDisconnect(con)

# convert date variables to date format
sale <- sale %>% mutate_at(
    vars(dot, start_date, end_date),  
    function(x) str_sub(x, end = 10) %>% mdy()
)

# Final Formatting ---------------------------------------------------------

# convert dates to character (for sqlite)
# this can take a couple minutes to run for large datasets
sale <- date_to_char(sale)
cust <- date_to_char(cust)

# add period for data provenance
cust$cust_period <- period
sale$sale_period <- period

# check the data standardization rules
data_check_standard(cust, lic, sale)

glimpse(lic)
glimpse(cust)
glimpse(sale)

# Write to Sqlite ---------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_standard)
dbWriteTable(con, "cust", cust, overwrite = TRUE)
dbWriteTable(con, "sale", sale, overwrite = TRUE)
dbDisconnect(con)
