
## Overview

This document details the rules for storing data in a standardized fashion using [sqlite](https://www.sqlite.org/index.html), which allows standard procedures to be applied to any state's data. The file paths below refer to locations on the Data Server under "E:/SA/". Occurences of "[state]" refers to 2-letter abbreviations and "[period]" refers to the most recent time period covered (e.g., 2019-q2, 2019-q4, etc.).

## Standardized Data

File path: "./Data-sensitive/[state]/raw-[period].sqlite3"

Guidelines:

- Standard names should be used
- Standard coding should be used for categorical data (sex, residency, dates)
- Some fields might vary depending on the needs of individual states

### cust

| Column Name | Description | Allowed Values | Categorical Codes | Column type | Notes |
| --- | --- | --- | --- | --- | --- |
| cust_id | unique customer ID | | | int | |
| sex | | 1,2,NA | 1=Male, 2=Female | int | |
| | | | | | |
| | | | | | |
| | | | | | |

### sale

## Production Data

### License

### History

### Census