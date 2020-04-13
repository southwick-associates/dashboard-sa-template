# finalize production sqlite database
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/data-schema.md

# TODO: update with WI code (once complete)

## State-specific Notes
# - 

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

# Customer Duplication Check -------------------------------------------------

# check for duplicates, and deduplicate if necessary
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/customer-deduplication.md

# add geocode info
cust <- left_join(cust, geocode, by = "cust_id")
rm(geocode)

# check: exact dups?
nrow(cust) == length(unique(cust$cust_id)) # should print TRUE (i.e, no exact dups)

# check: one customer for multiple cust_ids? 
# - using full names 
select(cust, dob, last, first) %>% check_dups()

# check: one customer for multiple cust_ids? 
# - using partial name matches
cust <- cust %>%
    mutate(first2 = str_sub(first, end = 2), last3 = str_sub(last, end = 3))
select(cust, dob, last3, first2) %>% check_dups() 

# check: adding zip4dp
# - will produce fewer false positives, but more false negatives
select(cust, dob, last3, first2, zip4dp) %>% check_dups() 




cust <- select(cust, -last, -first, -last3, -first2)

# Recoding Customer Vars --------------------------------------------------

cust <- cust %>% mutate(
    dob = ymd(dob),
    birth_year = year(dob)
)
summary(cust$birth_year)

cust$birth_year <- ifelse(cust$birth_year < 1900, NA_integer_, cust$birth_year)
summary(cust$birth_year)

cust <- select(cust, cust_id, birth_year, sex, cust_res, cust_period, raw_cust_id)

# Identify Sale Residency -------------------------------------------------

# if not provided by state at the transaction level
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/residency-identification.md

sale <- res_id_type(sale, lic)
sale <- res_id_other(sale) # this can take some time to run
sale <- res_id_cust(sale, cust)

# Recoding Sale Vars ------------------------------------------------------

# check transaction dates
sale <- mutate(sale, dot = ymd(dot))
summary(year(sale$dot))
count(sale, year = year(dot)) %>% ggplot(aes(year, n)) + geom_col()

# set unreasonable transaction date values to missing
# - perform this operation with caution
sale <- sale %>%
    mutate(dot_new = case_when(year(dot) %in% yrs ~ dot))
# - check missings
sale %>%
    filter(is.na(dot_new)) %>% count(year(dot)) %>% 
    arrange(desc(n))
# - reset dot
sale <- sale %>%
    select(-dot) %>%
    rename(dot = dot_new)

# set year to ensure calendar year (and month)
sale <- sale %>% mutate(
    month = month(dot) %>% as.integer(),
    year = year(dot) %>% as.integer()
)

# drop records without reliable dates
# - again with caution, don't want to drop non-negligible amounts of data we need
sale <- filter(sale, !is.na(dot))
sale <- select(sale, cust_id, lic_id, year, month, dot, res, raw_sale_id, sale_period)

# Final Prepartion --------------------------------------------------------

# only lic$type hunt, fish, combo are needed
lic %>%
    filter(!type %in% c("fish", "hunt", "combo")) %>%
    knitr::kable(caption = "License sales to be excluded")

lic <- filter(lic, type %in% c("fish", "hunt", "combo"))
sale <- semi_join(sale, lic, by = "lic_id")
cust <- semi_join(cust, sale, by = "cust_id")

# ensure dates are stored as character (for SQLite)
sale <- date_to_char(sale)

# final check
data_check(cust, lic, sale)

glimpse(cust)
glimpse(lic)
glimpse(sale)

# Write to SQLite ---------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_production)
dbWriteTable(con, "cust", cust, overwrite = TRUE)
dbWriteTable(con, "lic", lic, overwrite = TRUE)
dbWriteTable(con, "sale", sale, overwrite = TRUE)
dbDisconnect(con)
