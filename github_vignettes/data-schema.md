
## Overview

This document details the rules for storing data in a standardized fashion using [sqlite](https://www.sqlite.org/index.html), which allows standard procedures to be applied to any state's data. The file paths below refer to locations on the Data Server under "E:/SA/". Occurences of "[state]" refers to 2-letter abbreviations and "[period]" refers to the most recent time period covered (e.g., 2019-q2, 2019-q4, etc.).

## Standardized Data

File path: "./Data-sensitive/[state]/raw-[period].sqlite3"

Guidelines:

- Standard names should be used
- Standard coding should be used for categorical data (sex, residency, dates)
- Some fields might vary depending on the needs of individual states

### Table Name = cust

| Column Name | Description | Allowed Values | Categorical Codes | Column type | Notes | Key Status |
| --- | --- | --- | --- | --- | --- | --- |
| raw_cust_id | ID for linking to raw data | | | int | | composite key |
| cust_period | [period] | | | char | for use when data updates are needed | composite key |
| cust_id | unique customer ID | | | int | | |
| sex | | 1,2,NA | 1=Male, 2=Female | int | | |
| dob | date of birth | yyy-mm-dd | | char | | |
| last | last name (trimmed & lowercase) | | | char | for cust_id validation | |
| first | first name (trimmed & lowercase) | | | char | for cust_id validation | |
| state | state residency (if available) | 2-character abbreviations for US/Canada | | char | | |
| cust_res | customer residency | 1,0,NA | 1=Res, 0=Nonres | int | | |

### Table Name = sale

## Production Data

### License

### History

### Census