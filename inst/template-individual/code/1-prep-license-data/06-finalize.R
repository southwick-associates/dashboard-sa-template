# finalize production sqlite database
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/data-schema.md

## State-specific Notes
# 

library(tidyverse)
library(DBI)
library(lubridate)
library(salic)
library(salicprep)
library(sadash)
source("code/params.R")

# Pull Geocode ------------------------------------------------------------

dir_geocode <- file.path(dir_sensitive, state, "geocode_addresses")
files <- list.files(dir_geocode, pattern = "geocode", full.names = TRUE)

# identify customers who have already been geocoded
read_geocode <- function(f) {
    f %>% read_csv(
        skip = 1, col_names = c("zip4dp", "county_fips", "cust_id"),
        col_types = cols(.default = col_integer(), zip4dp = col_character()),
        progress = FALSE
    )
}
geocode <- lapply(files, read_geocode) %>% bind_rows()
if (length(unique(geocode$cust_id)) != nrow(geocode)) {
    geocode <- group_by(geocode, cust_id) %>% slice(1L) %>% ungroup()
}

# Load Data ---------------------------------------------------------------

lic <- read_csv("data/lic-clean.csv", col_types = cols(
    lic_id = col_integer(), duration = col_integer(),
    lic_res = col_integer(), raw_lic_id = col_integer(),
    .default = col_character()
))

# no need to bring non-hunting/fishing sales/customers into production db
lic_slct <- filter(lic, type %in% c("fish", "hunt", "combo", "trap"))

con <- dbConnect(RSQLite::SQLite(), db_standard)
sale <- tbl(con, "sale") %>% 
    select(cust_id, lic_id, year, dot, raw_sale_id, sale_period) %>%
    collect() %>%
    semi_join(lic_slct, by = "lic_id")
cust <- tbl(con, "cust") %>% 
    collect() %>%
    semi_join(sale, by = "cust_id")
dbDisconnect(con)

# Recode Customer Vars --------------------------------------------------

cust <- mutate(cust, birth_year = year(ymd(dob)))
summary(cust$birth_year)

cust$birth_year <- ifelse(cust$birth_year < 1900, NA_integer_, cust$birth_year)
summary(cust$birth_year)

# Customer Duplication Check -------------------------------------------------

# check for duplicates, and deduplicate if necessary
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/customer-deduplication.md

# add geocode & partial names
cust <- mutate(cust, first2 = str_sub(first, end = 2), last3 = str_sub(last, end = 3))
cust <- left_join(cust, geocode, by = "cust_id")
rm(geocode)

# check: cust_id repeats?
nrow(cust) == length(unique(cust$cust_id)) # should print TRUE (no cust_id repeats)

# check: one customer for multiple cust_ids? 
# - using full names 
select(cust, dob, last, first) %>% check_dups()

# check: one customer for multiple cust_ids? 
# - using partial name matches
select(cust, dob, last3, first2) %>% check_dups() 

# check: adding zip4dp
# - will produce fewer false positives, but more false negatives
select(cust, dob, last3, first2, zip4dp) %>% check_dups() 

# Customer Deduplication --------------------------------------------------
# deduplication may be worthwhile using cust_id, last3, first2, zip4dp

# identify duplicates
cust <- cust_dup_identify(cust, dob, last3, first2, zip4dp)

# check: issues with missing values
# - missing values can cause problems by increasing false positives
filter(cust, is.na(last3) | is.na(first2) | is.na(dob))
filter(cust, is.na(zip4dp)) # there could be quite a few of these

# correct issues with missing values
# - we should only deduplicate records with complete DOB/name data
# - allowing missing values in zip4dp loosens the matching criteria
#   (which is probably a reasonable tradeoff)
cust <- cust_dup_nomissing(cust, c("dob", "last3", "first2"))

# check: old customers per new customers, distribution
# - these typically should mostly be n=1 (no duplicates) or n=2 (one duplicate)
count(cust, cust_id) %>% count(n)

# save a duplicate relation table (for future reference)
# - enables downstream linking of deduplicated customers with original IDs
cust_dup <- cust_dup_pull(cust)

# check: a sample of duplicate customers and their sales
cust_dup_samp(cust_dup, sale) %>% knitr::kable()

# check: summarize duplication
cust_dup_pct(cust, cust_dup)
cust_dup_demo(cust, cust_dup) %>% cust_dup_demo_plot()
cust_dup_year(cust, cust_dup, sale)

# update customer IDs in the sale table
# - this ensures we don't lose transactions associated with the old cust_id
sale <- sale %>%
    rename(cust_id_raw = cust_id) %>%
    left_join(select(cust, cust_id, cust_id_raw), by = "cust_id_raw")

# - for customers in sales but not in customer table, keep original cust_id
filter(sale, is.na(cust_id)) %>% distinct(cust_id_raw)
sale <- sale %>%
    mutate(cust_id = ifelse(is.na(cust_id), cust_id_raw, cust_id))

# remove duplicates from the customer table
cust <- filter(cust, cust_id == cust_id_raw) # drop dups

# check: ensure correct deduplication
filter(cust, !is.na(dob), !is.na(last3), !is.na(first2)) %>%
    select(dob, last3, first2, zip4dp) %>% 
    check_dups() # should be zero
filter(sale, is.na(cust_id)) # should be zero rows

cust <- select(cust, cust_id, birth_year, sex, cust_res, county_fips, cust_period, raw_cust_id)
cust_dup <- select(cust_dup, cust_id_raw, cust_id)

# Identify Sale Residency -------------------------------------------------

# if not provided by state at the transaction level
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/residency-identification.md

sale <- res_id_type(sale, lic)
sale <- res_id_other(sale) # this can take some time to run
sale <- res_id_cust(sale, cust)

# Recoding Sale Vars ------------------------------------------------------

# create month variable
# - the specified month range will be state-specific (see ?recode_month)
sale <- recode_month(sale, -7:20)

# drop records without reliable dates
# - use caution, we don't want to drop non-negligible amounts of data we need
filter(sale, is.na(dot)) # check
sale <- filter(sale, !is.na(dot))
sale <- select(sale, cust_id, lic_id, year, month, dot, res, raw_sale_id, sale_period)

# Write to SQLite ---------------------------------------------------------

# final check
data_check_sa(cust, lic, sale)

glimpse(cust)
glimpse(cust_dup)
glimpse(lic)
glimpse(sale)

con <- dbConnect(RSQLite::SQLite(), db_production)
dbWriteTable(con, "cust", cust, overwrite = TRUE)
dbWriteTable(con, "cust_dup", cust_dup, overwrite = TRUE)
dbWriteTable(con, "lic", lic, overwrite = TRUE)
dbWriteTable(con, "sale", sale, overwrite = TRUE)
dbDisconnect(con)
