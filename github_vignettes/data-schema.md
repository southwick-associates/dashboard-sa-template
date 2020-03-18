
# Data Schemas

This document details the rules for storing data in a standardized fashion using [sqlite](https://www.sqlite.org/index.html), which allows standard procedures to be applied to any state's data. The file paths below refer to locations on the Data Server under "E:/SA/". Occurences of "[state]" refers to 2-letter abbreviations and "[period]" refers to the most recent time period covered for a dataset (e.g., 2019-q2, 2019-q4, etc.).

## Overview

Each data pull is to be processed through three steps:

- raw data from the state is saved directly into a database
- an intermediate standard database is used for subsequent validation and deduplication 
- a final production dataset contains only those fields necessary for dashboard production

Ultimately, we will be creating production database with strict data formatting rules to facilitate dashboard production. The final production data requires only 9 variables, and all personally-identifiable information is excluded:

![](./img/relations.png)

*Note that although residency (res) is a customer-level variable, it can change over time; hence the recommended sale-level specification.*

## Raw Data

File path: `./Data-sensitive/[state]/raw-[period].sqlite3`

No schemas are included for raw data; states vary in how they store data and the raw data is intended to be pulled basically as-is into a sqlite database (with the addition of an ID for each table that corresponds to row number). The data requirements are [documented here](./data-required.md).

## Standardized Data

File path: `./Data-sensitive/[state]/standard.sqlite3`

The standardized database potentially includes multiple data pulls. For example, suppose a state sends 10 years of data from Jan 1, 2009 through Dec, 31 2018. This data pull would first go into a `raw-2018-q4.sqlite3` database, and then standardized in `standard.sqlite3`. An updated set of data covers Jan 1, 2018 through Dec 31, 2019 and goes into `raw-2019-q4.sqlite3`. The `standard.sqlite3` tables should then be appended with this new dataset. The data provenance is tracked in each table using the corresponding "period" column.


### Standardization Guidelines

- Standard names should be used
- Standard coding should be used for categorical data (sex, residency, dates)
- Some fields might vary depending on the needs of individual states

### Schema for "cust":

| Column Name | Description | Allowed Values | Categorical Codes | Column type | Notes | Key Status |
| --- | --- | --- | --- | --- | --- | --- |
| raw_cust_id | ID for linking to raw data | | | int | | composite key |
| cust_period | [period] | | | char | for use when data updates are needed | composite key |
| cust_id | unique customer ID | | | int | | |
| sex | | 1, 2, NA | 1=Male, 2=Female | int | | |
| dob | date of birth | yyy-mm-dd | | char | | |
| last | last name (trimmed & lowercase) | | | char | for cust_id validation | |
| first | first name (trimmed & lowercase) | | | char | for cust_id validation | |
| state | state residency (if available) | 2-character abbreviations for US/Canada | | char | | |
| cust_res | customer residency | 1, 0, NA | 1=Res, 0=Nonres | int | | |

### Schema for "sale":

| Column Name | Description | Allowed Values | Categorical Codes | Column type | Notes | Key Status |
| --- | --- | --- | --- | --- | --- | --- |
| raw_sale | ID for linking to raw data | | | int | | composite key |
| sale_period | [period] | | | char | for use when data updates are needed | composite key |
| cust_id | | | | | int |  | 
| lic_id | | | | | int | | 
| year | license/privilege calendar year | yyyy | | | int | | 
| dot | transaction (purchase) date | yyyy-mm-dd | | | char | | 
| start_date | when license becomes effective | yyyy-mm-dd | | | char | | 
| end_date | when license expires | yyyy-mm-dd | | | char | | 

## Production Data

### License

### History

### Census