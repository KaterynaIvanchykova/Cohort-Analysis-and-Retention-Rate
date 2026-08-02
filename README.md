# Cohort-Analysis-and-Retention-Rate
## 📌 Project Overview

This project demonstrates a complete cohort analysis workflow, starting with raw data preparation in SQL and ending with interactive cohort tables and retention analysis in Google Sheets.

The project focuses on measuring user retention over time, comparing users acquired organically with those acquired through promotional campaigns.

---

## 🎯 Project Goals

* Clean and standardize inconsistent date formats.
* Build user cohorts based on registration month.
* Calculate monthly cohort activity.
* Measure user retention.
* Compare retention between promotional and non-promotional users.
* Create interactive cohort tables for business analysis.

---

## 🛠️ Technologies

* **PostgreSQL**
* **DBeaver**
* **Google Sheets**
* SQL (CTE, JOIN, CASE, Regular Expressions, Date Functions)

---

## 📊 Dataset

The project uses two source tables:

### `cohort_users_raw`

Contains information about user registration.

Main fields:

* `user_id`
* `signup_datetime`
* `promo_signup_flag`

### `cohort_events_raw`

Contains user activity events.

Main fields:

* `user_id`
* `event_datetime`
* `event_type`
* `revenue`

---

## ⚙️ SQL Workflow

### 1. Data Cleaning

Registration and event dates were stored as text in multiple formats. The SQL script:

* removed extra spaces;
* removed time components;
* standardized date separators (`.`, `/`, `-`);
* converted text into valid SQL dates using `CASE` and `TO_DATE()`;
* handled different date patterns using regular expressions.

---

### 2. Data Preparation

The cleaned user and event datasets were created using Common Table Expressions (CTEs).

---

### 3. Joining Data

The datasets were joined by `user_id`.

Invalid records were removed:

* missing registration dates;
* missing event dates;
* NULL event types;
* `test_event` records.

Registration events were kept because they represent Month 0 activity.

---

### 4. Cohort Calculation

For every user the following fields were calculated:

* **cohort_month** – registration month;
* **activity_month** – event month;
* **month_offset** – number of months between registration and activity.

---

### 5. Aggregation

The final SQL query aggregates data by:

* `promo_signup_flag`
* `cohort_month`
* `month_offset`

and calculates:

* `users_total` – distinct active users.

---

## 📈 Google Sheets Dashboard

After exporting the SQL results to CSV, the data was imported into Google Sheets.

Three worksheets were created:

### 📄 Data

Raw SQL output.

### 📊 Cohort_tables

Contains:

* Cohort table with user counts.
* Retention Rate table.
* Conditional formatting (heatmap).
* Interactive slicer for `promo_signup_flag`.

## 📊 Key Features

* Data cleaning with SQL
* Date normalization
* Cohort analysis
* Retention analysis
* Interactive filtering
* Conditional formatting
* Business insights

---

Conclusions:
Cohort analysis shows that users recruited through promotional campaigns demonstrate stable 100% retention in the first periods and do not have behavioral dips, which indicates high quality or small sample size. Organic cohorts show a slight decrease in activity (dropping to 50% in the January cohort by 3 months), which may indicate less stable engagement in the long term. In general, promotional engagements demonstrate more uniform retention dynamics, while organic traffic has greater behavioral variability between cohorts.
