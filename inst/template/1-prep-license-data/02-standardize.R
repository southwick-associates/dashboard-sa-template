# standardize data
## much of the code needed here is state-specific

library(tidyverse)
library(DBI)
library(stringr)
library(lubridate)
library(salic)

source("params.R")

# Load Raw Data -----------------------------------------------------------

# only select columns will be needed in the standardized data

con <- dbConnect(RSQLite::SQLite(), db_raw)

lic <- tbl(con, "lic") %>% 
    rename(lic_id = ProductId, revenue = Price) %>%
    select(-ProductYear) %>%
    collect()

cust <- tbl(con, "cust") %>% 
    select(cust_id = CustomerId, name = FullName, dob = DateOfBirth, state = State, raw_cust_id) %>%
    collect()

sale <- tbl(con, "sale") %>% 
    select(cust_id = CustomerId, lic_id = ProductId, year = LicenseYear, dot = CreateDate,
           start_date = EffectiveDate, end_date = ExpirationDate, raw_sale_id) %>% 
    collect()

# License -----------------------------------------------------------------

# save as csv for by-hand editing
dir.create("data")
write_csv(lic, "data/lic.csv")

# Standardize Customers -----------------------------------------------------

# first & last name
cust <- cust %>%
    separate(name, c("first", "n2", "n3", "n4"), sep = " ") %>%
    mutate(last = case_when(
        nchar(n2) >= 3 ~ n2,
        nchar(n3) >= 3 ~ n3,
        TRUE ~ n4
    )) %>%
    select(-n2, -n3, -n4) %>%
    mutate_at(vars(first, last), function(x) str_to_lower(x) %>% str_trim())
    
# state
data(state_abbreviations)
cust <- recode_state(cust, state_abbreviations) %>%
    select(cust_id, dob, last, first, state = state_new, raw_cust_id)
count(cust, state) %>% arrange(desc(n))

# state residency
cust$cust_res <- ifelse(cust$state == state, 1L, 0L)
cust$cust_period <- period

# Standardize Sales -------------------------------------------------------

# dates
sale <- sale %>%
    mutate_at(vars(dot, start_date, end_date), function(x) str_sub(x, end = 10)) %>%
    mutate(sale_period = period)

# Write to Sqlite ---------------------------------------------------------

salic::data_check(cust, lic, sale) # TODO: more tailored data_check function

con <- dbConnect(RSQLite::SQLite(), db_standard)
dbWriteTable(con, "cust", cust, overwrite = TRUE)
dbWriteTable(con, "sale", sale, overwrite = TRUE)
dbDisconnect(con)
