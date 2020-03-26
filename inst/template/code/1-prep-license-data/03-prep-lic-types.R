# prepare lic table for production
# - store in "data/lic-clean.csv"
# - likely will also require manual work in a spreadsheet

library(tidyverse)

lic <- read_csv("data/lic.csv")
