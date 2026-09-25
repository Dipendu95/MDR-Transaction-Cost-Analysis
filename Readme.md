![MDR Transaction & Cost Analysis](dashboard/MDR_Project_Banner.png)

<div align="center">

# MDR Transaction & Cost Analysis

### Smarter Payments. Clearer Insights.

**SQL Server • Python • Power BI • DAX**

![SQL Server](https://img.shields.io/badge/SQL%20Server-Database-CC2927?style=flat-square)
![Python](https://img.shields.io/badge/Python-Data%20Preparation-3776AB?style=flat-square)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat-square)
![DAX](https://img.shields.io/badge/DAX-KPI%20Measures-0078D4?style=flat-square)

</div>

---

## 📌 Brief One-Line Summary

An end-to-end data analytics project that analyzes **Merchant Discount Rate (MDR)** costs across payment methods, merchants, cities, and time using **Python, SQL Server, Power BI, and DAX**.

---

## 📖 Overview

The **MDR Transaction & Cost Analysis** project analyzes payment transaction data to understand where Merchant Discount Rate costs are generated and how those costs vary across different business dimensions.

The project covers the complete analytics workflow:

**Raw Data → Python Cleaning → SQL Validation → MDR Business Logic → Star Schema → DAX Measures → Power BI Dashboard → Business Insights**

The final output is an interactive Power BI dashboard that allows users to investigate MDR performance by:

- Date
- City
- Merchant
- Payment Method
- MDR Applicability
- Transaction Value

The analysis covers **1,000 synthetic payment transactions from April to September 2026**.

---

## ❓ Problem Statement

Merchant Discount Rate represents a transaction processing cost that can directly affect merchant profitability.

The objective of this project was to answer key business questions:

- Which transactions are subject to MDR?
- What percentage of transactions are MDR applicable?
- Which payment method generates MDR cost?
- Which merchants contribute the highest MDR cost?
- Which cities show the highest MDR concentration?
- How does MDR cost change over time?
- Is there a relationship between transaction value and MDR cost?
- How can business users quickly investigate unusual MDR increases?

The goal was to convert transaction-level payment data into a **validated and interactive decision-support dashboard**.

---

## 🗂️ Dataset

The project uses a synthetic payment transaction dataset covering:

| Dataset Detail | Value |
|---|---|
| **Period** | April 1, 2026 – September 30, 2026 |
| **Total Transactions** | 1,000 |
| **Payment Methods** | UPI, Debit Card, Credit Card, Cash |
| **Reporting Level** | Transaction level |

### Main Transaction Fields

| Category | Example Fields |
|---|---|
| **Transaction** | Transaction ID, Transaction Date, Quantity |
| **Merchant** | Merchant ID, Merchant Size |
| **Customer** | Customer ID |
| **Product** | Product ID |
| **Location** | City ID |
| **Payment** | Payment Method, UPI Type |
| **Financial** | Transaction Amount, Cost of Goods, Gross Profit |
| **MDR** | MDR Eligibility, MDR Applicability, MDR Cost |
| **Status** | Transaction Status |

The data was cleaned and validated before being used for SQL analysis and Power BI reporting.

---

## 🛠️ Tools and Technologies

| Technology | Purpose |
|---|---|
| **Python** | Data cleaning, transformation and validation |
| **Pandas** | Transaction-level data preparation |
| **NumPy** | Data processing support |
| **SQL Server** | Querying, validation and MDR business-rule checks |
| **Power BI** | Data modeling and interactive dashboard development |
| **DAX** | KPI and MDR measure creation |
| **GitHub** | Project documentation and portfolio presentation |

---

# ⚙️ Methods

## 1. Data Preparation

Python was used to inspect, clean, and prepare the raw transaction data.

The preparation process included:

- Handling missing values
- Cleaning inconsistent category values
- Standardizing payment-method names
- Cleaning UPI P2M/P2P classifications
- Validating transaction dates
- Checking ID integrity
- Validating transaction status
- Preparing the data for SQL and Power BI analysis

---

## 2. MDR Business Logic

Transactions were evaluated using MDR eligibility and exemption rules.

The logic considered:

- Successful transactions
- UPI transactions
- P2M transactions
- Merchant eligibility
- Merchant qualification rules
- Transaction date
- MDR exemptions

After applying the final business rules:

**253 transactions were classified as MDR applicable.**

---

## 3. SQL Validation

SQL Server was used to validate the prepared dataset and reporting outputs.

Validation included:

- Transaction counts
- Transaction values
- MDR applicability
- Payment-method distribution
- Merchant-level results
- City-level results
- Final reporting totals

Power BI KPI results were cross-checked against SQL outputs before the dashboard was finalized.

---

## 4. Data Modeling

A **star schema** was created in Power BI with one central transaction reporting view and six dimension tables.

```text
                          dim_date
                             │
                             │
      dim_merchant ──────────┤
                             │
      dim_customer ── vw_mdr_transactions ── dim_product
                             │
                             ├──────────────── dim_city
                             │
                             └──────────────── dim_payment
