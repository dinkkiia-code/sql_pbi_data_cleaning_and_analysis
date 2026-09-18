# Project title: 
Data Cleaning and analysis of financial transaction 

# Project Description:
This repository contains a complete end‑to‑end workflow of me cleaning, transforming, analysing, and visualising financial transaction data using MySQL, Excel Power Query, and Power BI.
The project demonstrates practical data governance, data quality improvement, and analytical modelling techniques suitable for real‑world business reporting.

# Features:
- Data cleaning scripts & Worksheet
- Power Query transformations
- Before-and-after dataset comparisons
- Data Visulisation (PBI)
- Documentation of cleaning logic
- 
# Project Overview: 
This project starts with a raw CSV dataset containing:
- transaction_date
- vendor_name
- category
- amount
- transaction_year
The goal is to clean the dataset, standardise formats, remove inconsistencies, engineer new fields, and build analytical outputs such as:
- Total spend per category per year
- Previous‑year spend (LAG logic)
- Best‑selling category per year
- Category comparisons (e.g., Marketing vs Travel)
- Year with highest total spend
- Visual dashboards in Power BI
The project demonstrates how I have used SQL and Power Query together to produce reliable, analysis‑ready data.

# Data Cleaning and Standardisation: 
# Sql Cleaning steps:
The raw dataset contained inconsistent date formats, mixed numeric formats, blank fields, and unstandardised categories.
Key cleaning operations included:
- Converting transaction_date to proper DATE using STR_TO_DATE
- Standardising amount to DECIMAL(10,2)
- Creating transaction_year using YEAR(transaction_date)
- Fixing blank category and vendor_name values
- Removing temporary columns such as row_num
- Detecting and removing duplicates using window functions
  
# Key Insights Generated:
- Year‑over‑year spend patterns per category
- Categories with highest and lowest spend
- Marketing vs Travel spend comparison
- Total spend trends across multiple years

  # Techniques Used:
- MySQL 8.0
- Excel Power Query Editor
- Power BI Desktop
- SQL Window Functions
- M‑Language (Power Query)
- Data Governance & Data Quality Techniques

# Skills Demonstrated:
- SQL data cleaning
- SQL analytics (CTEs, LAG, GROUP BY, window functions)
- Power Query transformation logic
- Power BI visualisation and modelling
- Data governance and standardisation
- Building analysis‑ready datasets

  # Author:
  Ada Oguntodu
