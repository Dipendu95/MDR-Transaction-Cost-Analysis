![MDR Transaction & Cost Analysis](dashboard/MDR_Project_Banner.png)

# MDR Transaction & Cost Analysis

> **Smarter Payments. Clearer Insights.**

An end-to-end data analytics project using **SQL Server, Python, Power BI, and DAX** to analyze Merchant Discount Rate (MDR) costs across merchants, cities, payment methods, and time.

---

## 📊 Dashboard

![MDR Transaction & Cost Analysis Dashboard](dashboard/MDR_Final_Dashboard_SS.JPG)

The interactive Power BI dashboard provides analysis of:

- Transaction volume and value
- MDR applicable transactions
- Monthly MDR cost trends
- Merchant-level MDR concentration
- City-level transaction and MDR performance
- Payment-method MDR costs
- Transaction value vs MDR cost

📥 **Power BI File:**  
[Download the `.pbix` Dashboard](dashboard/MDR_Transaction_Analysis_Dashboard.pbix)

---

## 🔎 Interactive Filtering Example — UPI

The dashboard supports interactive filtering by **date, city, and payment method**.

The example below shows the dashboard filtered specifically for **UPI transactions**.

![UPI Filtered Dashboard](dashboard/UPI_MDR_Merchant_Impact_Analysis_UPI-SS.JPG)

With UPI selected:

| KPI | Result |
|---|---:|
| UPI Transactions | 549 |
| Transaction Value | ₹85,06,921.86 |
| MDR Cost | ₹22,175.56 |
| MDR Applicable Transactions | 253 |

This demonstrates how business users can dynamically isolate payment methods and investigate their MDR impact.

## 📄 Portfolio Case Study

A concise case study covering the business problem, methodology, data model, findings, and business recommendations is available here:

### 👉 [View MDR Portfolio Case Study](docs/Dipendu_Roy_MDR_Portfolio_Case_Study.pdf)

MDR-Transaction-Cost-Analysis/
│
├── dashboard/
│   ├── MDR_Project_Banner.png
│   ├── MDR_Final_Dashboard_SS.JPG
│   ├── UPI_MDR_Merchant_Impact_Analysis_UPI-SS.JPG
│   └── MDR_Transaction_Analysis_Dashboard.pbix
│
├── data/
│   └── raw/
│
├── docs/
│   └── Dipendu_Roy_MDR_Portfolio_Case_Study.pdf
│
├── python/
├── sql/
└── README.md
