
# Workflow Overview

This document outlines the workflow for processing data for dashboards. It is an R-based workflow and utilizes custom R packages developed by Southwick ([salic](https://github.com/southwick-associates/salic), [salicprep](https://github.com/southwick-associates/salicprep)). This analysis is intended to be performed using the Southwick Data Server, which (1) keeps all sensitive data confined to a single location, and (2) ensures a consistent (shared) software environment to facilitate collaboration and reproducibility.

0. [Initialize New State](#initialize-new-state)
1. [Load Raw date into SQLite](#load-raw-data-into-sqlite)
2. [Standardize Data](#standardize-data)
3. [Prep License Type Categories](#prep-license-type-categories)
4. [Initial Validation](#initial-validation)
5. [Finalize Production Data](#finalize-production-data)
6. [Final Validation](#final-validation)

## Data Server

TODO: Give an overview here and brief login instructions.

### Software

A number of software applications are available on the Data Server in `E:/SA/Program Files/`. These don’t (currently) have shortcuts and file associations, so you might need to add those manually by finding the file exe (e.g., right click > open with > browse for program). Notable applications:

- RStudio: An IDE for R. I recommend [some modifications](rstudio-settings.md) to the default user settings.
- DB Browser for SQLite. Provides an interactive way of exploring the SQLite datbases.
- Gedit: A text editor
- Ron's Editor: A spreadsheet-like csv editor, potentially useful for manual operations on license type tables

### File Organization

The dashboard analysis files are separated from data files:

| File Path | Function |
| --- | ---|
| E:/SA/Projects/Data-Dashboards/ | Analysis (code, etc.) by state |
| E:/SA/Data-sensitive/Data-Dashboards/ | License Data with personally-identifiable info |
| E:/SA/Data-production/Data-Dashboards/ | Anonymized License Data for producing dashboards |

## Analysis Steps

Template code is yet to be populated in this repository. It will live in "1-prep-license-data". Rather than needing to clone or download the repo, I'll likely write an `salicprep::new_state(state, period)` to pull the necessary files from the repo into the relevant state-period folder.

### Initialize new state

TODO

### Load Raw data into SQLite

The purpose is to pull the raw license data into a format that is easily usable in analysis. [SQLite](https://db.rstudio.com/databases/sqlite/) databases are useful because they are easily queriable with R. The raw data should be pulled in mostly as-is, to provide an accurate (and complete) representation of the raw data in a database that is easily queried if necessary. 

**Check**: At this stage you should also check that none of the columns (variables) specified in the Data Request are missing from the raw data. 

**Note about row IDs**: Adding a unique row ID ensures a means of joining production data back to raw data in the future.

**Typical Data Tables:**

- lic: The state will usually provide a license type table, typically with a few hundred rows and several columns that describe each available license type. These should be joinable to the sales table with a license ID.

- cust: The state typically provides a fairly large file (often in the millions of rows) with information about each customer. These datasets contain highly sensitive personally-identifiable information. This should be joinable to the sales table with a customer ID.

- sale: State license/permit sales (transactions) over 10 years are often in the tens of millions of rows. Sometimes the state will separate these into multiple files, but we will usually want to store sales as a single table.

### Standardize Data

Saving a standardized intermediate database simplifies downstream validation and final preparation. The [Database Schema](./data-schema.md) provides details about variables to include and how categorical variables should be coded.

**Check:**: This step naturally involves a certain amount of data validation, and recoding summaries for relevant variables (gender, residency, etc.) should be documented for future reference. Of particular interest are values that get stored as NA (missing) in the final table. These may be junk data (e.g., data entry errors) or stand-ins for missing values (e.g., "U" for unknown gender).

### Prep License Type Categories

The license type table from the state will require some manual editing. At the very least we will need to create a "type" variable which provides logic for identifying hunters and anglers based on license purchases:

- An angler is anyone who buys a license with `lic$type` "fish" or "combo" in a given year
- An hunter is anyone who buys a license with `lic$type` "hunt" or "combo" in a given year

### Initial Validation

This step is intended to catch any obvious data problems early. Most data issues can be revealed by looking at how counts change year-to-year (the customer counts in particular don’t usually change much). Several checks are useful:

- Total customer counts by year, overall and separately for hunters and anglers. Comparing to the [USFWS Historical License Sales]() can be useful for a new state.
- Standardized data rules can be checked with a function: `salic::data_check()`

### Finalize Production Data

The anonymized production data is created at this stage.

**Deduplication:** No duplicates should be included in the production customer table, and we will want to check the state-supplied customer ID at this stage by using first name, last name, and date of birth (if provided by the agency).

### Final Validation

This step involves summarizing the data in various ways to gain confidence in the trends it presents, and potentially identify any problems in the data (which may require discussion with state agency folks to sort out). 

TODO

- demographic distributions and trends, etc.
