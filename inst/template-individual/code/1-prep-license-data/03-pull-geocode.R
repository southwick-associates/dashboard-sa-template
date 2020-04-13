# pull customer records to be geocoded
# - the output file (cust_addr) is sent to BulkMailer to identify county and zip4dp

library(tidyverse)
library(DBI)
source("code/params.R")

# Identify Customers to Geocode -------------------------------------------
# previously geocoded customers can be excluded

# identify previous geocode output files
# - to find out which customers have already been geocoded
dir_geocode <- file.path(dir_sensitive, state, "geocode_addresses")
files <- list.files(dir_geocode, pattern = "geocode", full.names = TRUE)

# identify customers who have already been geocoded
read_geocode <- function(f) {
    f %>% read_csv(
        skip = 1, col_names = c("zip4dp", "county_fips", "cust_id"),
        col_types = cols(.default = col_skip(), cust_id = col_integer())
    )
}

# note that cust_ids may have been truncated by BulkMailer, which causes import errors
# - they may be truncated with sci notation like "e3" at the end
# - storing cust_id as number (not text) in BulkMailer import should prevent this in the future
#   (unless the state cust_id really is an alphanumeric, which should be represented as text)
cust_coded <- list()
for (i in seq_along(files)) {
    cust_coded[[i]] <- read_geocode(files[i])
    cat("Number of rows where cust_id couldn't be stored as integer:\n")
    filter(cust_coded[[i]], row_number() %in% problems(cust_coded[[i]])$row) %>% 
        nrow() %>% 
        print()
}
cust_coded <- bind_rows(cust_coded) %>% filter(!is.na(cust_id))

# pull raw address data for current period customer data
# - using current period only since previous period customers should already be geocoded
con <- dbConnect(RSQLite::SQLite(), db_raw)
cust <- tbl(con, "cust") %>% 
    select(cust_id, addr, city, state, zip) %>%
    collect()
dbDisconnect(con)

# drop those that have already been geocoded
cust <- anti_join(cust, cust_coded, by = "cust_id")

# Write to CSV ----------------------------------------------------------

# some final cleaning
# - excluding rows with missing values should produce fewer errors in BulkMailer
# - focusing on USA since foreign addresses will likely cause problems
cust <- cust %>%
    filter(!is.na(cust_id), !is.na(addr), !is.na(city), !is.na(state), !is.na(zip)) %>%
    filter(toupper(state) %in% state.abb)

write_csv(cust, file.path(dir_geocode, paste0("cust_addr-", period, ".csv")))
