# load raw data into sqlite

library(tidyverse)
library(DBI)
library(salic)

source("code/params.R")
files <- list.files(dir_raw)

lic_file <- files[1] ## state-specific
cust_file <- files[2] ## state-specific
sale_file <- files[3] ## state-specific

## all the read functions for pulling in data will be state-specific as well

# License -----------------------------------------------------------

f <- file.path(dir_raw, lic_file)
lic <- f %>%
    read_csv() %>%
    mutate(raw_lic_id = row_number())
glimpse(lic)

# Customer ----------------------------------------------------------------

f <- file.path(dir_raw, cust_file)
cust <- f %>% read_csv(
    progress = FALSE,
    col_types = cols(.default = col_character())
) %>%
    mutate(raw_cust_id = row_number())
salic::count_lines_textfile(f) == nrow(cust) + 1
glimpse(cust)

# Sale --------------------------------------------------------------------

f <- file.path(dir_raw, sale_file)
sale <- f %>% read_csv(
    progress = FALSE,
    col_types = cols(.default = col_character(), LicenseYear = col_integer())
) %>%
    mutate(raw_sale_id = row_number())
salic::count_lines_textfile(f) == nrow(sale) + 1
glimpse(sale)

# To Sqlite ---------------------------------------------------------------

con <- dbConnect(RSQLite::SQLite(), db_raw)
dbWriteTable(con, "lic", lic, overwrite = TRUE)
dbWriteTable(con, "cust", cust, overwrite = TRUE)
dbWriteTable(con, "sale", sale, overwrite = TRUE)
dbDisconnect(con)
