# finalize production sqlite database
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/data-schema.md

## State-specific Notes
# - 

library(tidyverse)
library(DBI)
library(lubridate)
library(salic)
library(salicprep)
source("code/params.R")

# Load Data ---------------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_standard)
cust <- tbl(con, "cust") %>% collect()
sale <- tbl(con, "sale") %>% 
    select(cust_id, lic_id, year, dot, raw_sale_id) %>%
    collect()
dbDisconnect(con)

lic <- read_csv("data/lic-clean.csv", col_types = cols(
    lic_id = col_integer(), 
    duration = col_integer(),
    .default = col_character()
))

# Customer Duplication -----------------------------------------------------

# check for duplicates, and deduplicate if necessary
# https://github.com/southwick-associates/salicprep/blob/master/github_vignettes/customer-deduplication.md

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

sale <- sale %>% mutate(
    dot = ymd(dot),
    month = month(dot) %>% as.integer()
)

sale <- select(sale, cust_id, lic_id, year, month, res, raw_sale_id)

# Final Prepartion --------------------------------------------------------

# only lic$type hunt, fish, combo are needed
filter(lic, !type %in% c("fish", "hunt", "combo")) %>%
    knitr::kable(caption = "License sales to be excluded")
lic <- filter(lic, type %in% c("fish", "hunt", "combo"))
sale <- semi_join(sale, lic, by = "lic_id")
cust <- semi_join(cust, sale, by = "cust_id")

data_check(cust, lic, sale)

glimpse(cust)
glimpse(lic)
glimpse(sale)

# Write to SQLite ---------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_license)
dbWriteTable(con, "cust", cust, overwrite = TRUE)
dbWriteTable(con, "lic", lic, overwrite = TRUE)
dbWriteTable(con, "sale", sale, overwrite = TRUE)
dbDisconnect(con)

