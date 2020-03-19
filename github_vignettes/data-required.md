
# Data Required from States

This document outlines Southwick data needs for the National/Regional dashboard. Each data pull should include all stand-alone license records for the given time period. These records should be sufficient to identify ALL licensed anglers and hunters (i.e., all annual, lifetime, multi-year, short-term, and combination hunting/fishing licenses). 

**Date Range**: Calendar years 2010-2019 (sales from Jan 1, 2010 thru Dec 31, 2019)

## Data Format

The raw data should preferably be separated into 3 related tables in delimited plain text files (alternative data structures are okay, but a related format is preferred because it reduces data duplication and total file size):

1.	License Sales (i.e., transactions): One row per license purchase
2.	Customers: One row per customer
3.	License Types (i.e., products): One row per license type

## Data Fields

Each data table should contain data fields (columns) sufficient to identify the characteristics of interest. The "primary key" refers to a column that uniquely identifies rows in a table, whereas "foreign key" refers to a column that acts as a relational join to another table.

### Customers

- Customer ID (primary key)
- First Name
- Last Name
- Date of birth
- Gender
- State of Residence
- [Any other customer fields deemed necessary by the state agency]

### License Types

- License ID (primary key)
- License Description
- License Type Residency (in-state vs. out-of-state)
- License Type Category (if available): a field to identify whether a license provides a hunting privilege, a fishing privilege, or both
- [Any other license type fields deemed necessary by the state agency]

### License Sales

- Customer ID (foreign key)
- License ID (foreign key)
- Purchase date
- Effective date (i.e., when license becomes valid)
- Expiration date
- [Any other sales fields deemed necessary by the state agency]
