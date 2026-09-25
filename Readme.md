## Project Files

- [View Power BI Dashboard](dashboard/)
- [View Portfolio Case Study](docs/Dipendu_Roy_MDR_Portfolio_Case_Study.pdf)



MDR Transaction & Cost Analysis

End-to-end MDR transaction and cost analysis using SQL Server, Python, Power BI, and DAX, focused on understanding where Merchant Discount Rate (MDR) cost is generated and how it varies across merchants, cities, payment methods, and time.

Dashboard



Project Overview

This project analyzes 1,000 synthetic payment transactions from April to September 2026 and turns transaction-level MDR rules into a validated reporting model and interactive Power BI dashboard.

Key KPIs


| Metric | Result |
| --- | ---: |
| Total Transactions | 1,000 |
| Total Transaction Value | ₹1,64,68,596.48 |
| Total MDR Cost | ₹22,175.56 |
| Final MDR Applicable Transactions | 253 |
| MDR Applicable Share | 25.3% |
| MDR Not Applicable Share | 74.7% |

Business Problem

The analysis was designed to answer practical payment-cost questions:

Which transactions are ultimately subject to MDR?

How much MDR cost is recorded?

Which merchants and cities contribute the most MDR cost?

Which payment methods are associated with MDR cost?

How does MDR cost change over time?

How do exemption rules affect final MDR exposure?

MDR Business Logic

The analysis applies MDR eligibility rules in stages:

308 potentially MDR-eligible transactions → 55 small-merchant exemptions → 253 final MDR-applicable transactions

This distinction is important because the initial eligibility result is not the same as the final MDR-applicable population after exemption rules are applied.

Tools & Skills

SQL Server — validation, business-rule logic, reporting view, analytical queries

Python / Pandas / NumPy — data cleaning, validation, exploratory analysis, merchant-impact analysis

Power BI — data modeling, interactive dashboard design, slicers, visual analysis

DAX — KPI measures and final MDR applicability calculations

Star Schema — fact-centered dimensional model

Data Validation — reconciliation between SQL, Python, and Power BI outputs

Data Model

The Power BI model uses a star schema with a central transaction fact/reporting view and six primary dimensions:

dim_date

dim_merchant

dim_customer

dim_product

dim_city

dim_payment

Relationships are one-to-many, single-direction, from the dimensions to the transaction fact.

Analysis Workflow

Prepared and validated transaction and dimension data.

Standardized payment-method and UPI-type fields.

Checked date range, IDs, missing values, and transaction status.

Applied MDR eligibility rules.

Applied the small-merchant exemption.

Calculated final MDR applicability and MDR amount.

Validated results using SQL and Python.

Built a star-schema Power BI model.

Created DAX measures for core KPIs.

Designed an interactive dashboard for business analysis.

Key Findings

253 of 1,000 transactions (25.3%) are finally MDR applicable.

747 transactions (74.7%) are not finally MDR applicable.

Recorded MDR cost totals ₹22,175.56.

In this synthetic dataset, recorded MDR cost is associated with UPI, while Cash, Credit Card, and Debit Card show zero recorded MDR cost.

MDR cost varies by month, with a visible peak around August.

Merchant and city views reveal where MDR cost is concentrated.

The small-merchant exemption materially reduces the number of transactions ultimately exposed to MDR.

Business Recommendations

Monitor UPI MDR cost separately because it drives the recorded MDR cost in this dataset.

Review high-cost merchants and cities for unusual increases.

Track the final applicable/not-applicable mix over time.

Monitor the impact of merchant exemptions on total MDR exposure.

Use date, city, and payment-method slicers for root-cause analysis when costs spike.

Repository Structure

MDR-Transaction-Cost-Analysis/
│
├── dashboard/
│   ├── MDR_Transaction_Analysis_Dashboard.pbix
│   └── MDR_Final_Dashboard_SS.JPG
│
├── data/
│   └── raw/
│       ├── fact_transactions_raw.csv
│       ├── dim_date.csv
│       ├── dim_product.csv
│       ├── dim_customer.csv
│       ├── dim_merchant.csv
│       ├── dim_city.csv
│       ├── dim_payment.csv
│       └── dim_mdr_rules.csv
│
├── docs/
│   └── Dipendu_Roy_MDR_Portfolio_Case_Study_FINAL.pdf
│
├── python/
│   └── MDR_Merchant_Impact_Analysis.ipynb
│
├── sql/
│   └── MDR_Transaction_Cost_Analysis.sql
│
└── README.md

Project Files

Power BI Dashboard

Dashboard Screenshot

SQL Analysis

Python Analysis Notebook

Portfolio Case Study

Dataset Note

The dataset used in this portfolio project is synthetic and was created for analytical and learning purposes. Customer and merchant names do not represent real individuals or businesses.

What This Project Demonstrates

This project demonstrates an end-to-end data analyst workflow: preparing raw data, validating business rules, modeling data, creating reusable measures, reconciling results across tools, and communicating findings through an interactive dashboard.

Dipendu Roy
Data Analyst Portfolio Project
