# prepare lic table for production
# - store in "data/lic-clean.csv"
# - likely will also require manual work in a spreadsheet

## State-specific Notes
# - 

library(tidyverse)

# You may be able to identify lic$type based on logic of a variable supplied by
#  the state (which we request). Otherwise, it will involve manually editing
#  a "data/lic-clean.csv" using, e.g., "E:\Program Files\Rons Editor\Editor.WinGUI.exe".
#  The lic$description column is helpful in this regard, although we would need
#  confirmation with someone from the agency.

# 1. load data
lic <- read_csv("data/lic.csv")

# 2. create lic$type

# 3. save to new file
write_csv(lic, "data/lic-clean.csv")
