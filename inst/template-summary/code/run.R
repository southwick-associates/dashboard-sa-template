# run code for processing state summary data
# - this will be highly state-specific
#   for some states it may simply involve copying the file to the out folder

library(tidyverse)
library(salicprep)

# load
# - data from the state should be placed in "data/"
dat <- read_csv("data/")

# write to "out/"
dir.create("out", showWarnings = FALSE)
write_csv(dat, "out/dashboard.csv")

# check
dashtemplate::run_visual()
