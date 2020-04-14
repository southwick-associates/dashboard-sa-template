# run license history for each permission
# note that code may need to be tweaked for state-specific needs

## State-specific Notes
# - 

library(tidyverse)
library(salic)
library(sadash)

source("code/params.R")
source("code/2-license-history/functions.R") # run_group()

# pull license data into a list
all <- load_license(db_license, yrs)
data_check_sa(all$cust, all$lic, all$sale)

# remove the "permission" table from db_license if it exists
# - this prevents between-period column type compatibility issues
remove_table(db_license, "permission")

# Run by Permission -------------------------------------------------------

run_group("hunt", 'type %in% c("hunt", "combo", "trap")')
run_group("fish", 'type %in% c("fish", "combo")')
run_group("all_sports", 'type %in% c("hunt", "trap", "fish", "combo")')

# see previous period code for permission runs
# and any state-specific needs (e.g., in functions.R)
