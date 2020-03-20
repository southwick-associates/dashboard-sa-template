# load raw data into sqlite

library(tidyverse)
library(DBI)
library(salic)

source("params.R")
files <- list.files(dir_raw)

# License -----------------------------------------------------------

f <- file.path(dir_raw, files[4])
lic <- read_csv(f) %>% mutate(raw_lic_id = row_number())
glimpse(lic)

# Customer ----------------------------------------------------------------

f <- file.path(dir_raw, files[2])
cust <- read_csv(f, col_types = cols(.default = col_character()), progress = FALSE) %>%
    mutate(raw_cust_id = row_number())
salic::count_lines_textfile(f) == nrow(cust) + 1
glimpse(cust)

# Sale --------------------------------------------------------------------

f <- file.path(dir_raw, files[3])
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
