/* ============================================================================
   MDR TRANSACTION & COST ANALYSIS
   Portfolio-ready SQL Server analysis script

   Purpose
   -------
   Build a reusable transaction-level MDR reporting view and analyze MDR
   eligibility, small-merchant exemptions, the MDR cap, profitability impact,
   merchant concentration, city concentration, payment method, and monthly trend.

   Modeled business rules used in this project
   --------------------------------------------
   1. Transaction must be successful.
   2. Payment method must be UPI and UPI type must be P2M.
   3. Transaction amount must be greater than INR 2,000.
   4. A qualifying small merchant is exempt when Small_Merchant_Flag = 1 and
      Monthly_UPI_Volume <= INR 100,000.
   5. MDR rate = 0.4% of transaction value, capped at INR 300 per transaction.

   Key project result
   ------------------
   308 transactions are potentially MDR-eligible before exemption.
   55 of those transactions are exempt under the small-merchant rule.
   253 transactions are finally MDR-applicable.
   Total recorded MDR cost = INR 22,175.56.

   Notes
   -----
   - This script assumes the cleaned fact and dimension tables are already loaded.
   - The source analysis used SQL Server as the reporting/calculation layer.
   - Final transaction-value totals can differ by a few paise from an earlier
     notebook path because of upstream rounding order; final counts and MDR cost
     are unchanged.
   ============================================================================ */

USE UPI_MDR_Analytics;
GO

/* ============================================================================
   01. DATA QUALITY & MODEL VALIDATION
   ============================================================================ */

-- Core row-count, status, null, and uniqueness checks.
SELECT
    COUNT(*) AS Total_Transactions,
    COUNT(DISTINCT Transaction_ID) AS Unique_Transaction_IDs,
    SUM(CASE WHEN Transaction_Status = 'Success' THEN 1 ELSE 0 END)
        AS Successful_Transactions,
    SUM(CASE WHEN Transaction_Status = 'Failed' THEN 1 ELSE 0 END)
        AS Failed_Transactions,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END)
        AS Missing_Customer_ID,
    CAST(SUM(Transaction_Amount) AS DECIMAL(14,2))
        AS Total_Transaction_Value,
    CAST(SUM(Gross_Profit) AS DECIMAL(14,2))
        AS Total_Gross_Profit
FROM dbo.fact_transactions;

-- Validate fact-to-dimension key coverage.
SELECT 'Merchant' AS Dimension_Name, COUNT(*) AS Missing_Keys
FROM dbo.fact_transactions f
LEFT JOIN dbo.dim_merchant d
    ON f.Merchant_ID = d.Merchant_ID
WHERE d.Merchant_ID IS NULL

UNION ALL

SELECT 'Customer', COUNT(*)
FROM dbo.fact_transactions f
LEFT JOIN dbo.dim_customer d
    ON f.Customer_ID = d.Customer_ID
WHERE f.Customer_ID IS NOT NULL
  AND d.Customer_ID IS NULL

UNION ALL

SELECT 'Product', COUNT(*)
FROM dbo.fact_transactions f
LEFT JOIN dbo.dim_product d
    ON f.Product_ID = d.Product_ID
WHERE d.Product_ID IS NULL

UNION ALL

SELECT 'City', COUNT(*)
FROM dbo.fact_transactions f
LEFT JOIN dbo.dim_city d
    ON f.City_ID = d.City_ID
WHERE d.City_ID IS NULL

UNION ALL

SELECT 'Payment', COUNT(*)
FROM dbo.fact_transactions f
LEFT JOIN dbo.dim_payment d
    ON f.Payment_ID = d.Payment_ID
WHERE d.Payment_ID IS NULL

UNION ALL

SELECT 'Date', COUNT(*)
FROM dbo.fact_transactions f
LEFT JOIN dbo.dim_date d
    ON f.Date_Key = d.Date_Key
WHERE d.Date_Key IS NULL;

/* ============================================================================
   02. REUSABLE MDR REPORTING VIEW
   ============================================================================ */

CREATE OR ALTER VIEW dbo.vw_mdr_transactions
AS
SELECT
    f.Transaction_ID,
    f.Transaction_Date,
    f.Date_Key,
    f.Merchant_ID,
    f.Customer_ID,
    f.Product_ID,
    f.City_ID,
    f.Payment_ID,
    f.Payment_Method,
    f.UPI_Type,
    f.Transaction_Amount,
    f.Gross_Profit,
    m.Small_Merchant_Flag,
    m.Monthly_UPI_Volume,

    -- Potential eligibility before the merchant-level exemption.
    CASE
        WHEN f.Transaction_Status = 'Success'
         AND f.Payment_Method = 'UPI'
         AND f.UPI_Type = 'P2M'
         AND f.Transaction_Amount > 2000
        THEN 1
        ELSE 0
    END AS MDR_Eligible,

    -- Merchant-level qualification flag. Interpret as an actual exemption only
    -- when the transaction is also MDR_Eligible = 1.
    CASE
        WHEN m.Small_Merchant_Flag = 1
         AND m.Monthly_UPI_Volume <= 100000
        THEN 1
        ELSE 0
    END AS Small_Merchant_Exempt,

    -- Final transaction-level applicability after the exemption rule.
    CASE
        WHEN f.Transaction_Status = 'Success'
         AND f.Payment_Method = 'UPI'
         AND f.UPI_Type = 'P2M'
         AND f.Transaction_Amount > 2000
         AND NOT (
                m.Small_Merchant_Flag = 1
            AND m.Monthly_UPI_Volume <= 100000
         )
        THEN 1
        ELSE 0
    END AS Final_MDR_Applicable,

    -- 0.4% MDR with a per-transaction cap of INR 300.
    CASE
        WHEN f.Transaction_Status = 'Success'
         AND f.Payment_Method = 'UPI'
         AND f.UPI_Type = 'P2M'
         AND f.Transaction_Amount > 2000
         AND NOT (
                m.Small_Merchant_Flag = 1
            AND m.Monthly_UPI_Volume <= 100000
         )
        THEN CASE
                WHEN f.Transaction_Amount * 0.004 > 300
                    THEN 300
                ELSE f.Transaction_Amount * 0.004
             END
        ELSE 0
    END AS MDR_Amount

FROM dbo.fact_transactions AS f
INNER JOIN dbo.dim_merchant AS m
    ON f.Merchant_ID = m.Merchant_ID;
GO

/* ============================================================================
   03. FINAL MDR POPULATION & DASHBOARD KPI VALIDATION
   ============================================================================ */

SELECT
    COUNT(*) AS Total_Transactions,
    SUM(CASE WHEN MDR_Eligible = 1 THEN 1 ELSE 0 END)
        AS Potential_MDR_Eligible_Transactions,
    SUM(CASE
            WHEN MDR_Eligible = 1 AND Small_Merchant_Exempt = 1
            THEN 1 ELSE 0
        END) AS Small_Merchant_Exempt_Transactions,
    SUM(CASE WHEN Final_MDR_Applicable = 1 THEN 1 ELSE 0 END)
        AS Final_MDR_Applicable_Transactions,
    SUM(CASE WHEN Final_MDR_Applicable = 0 THEN 1 ELSE 0 END)
        AS Final_MDR_Not_Applicable_Transactions,
    CAST(
        SUM(CASE WHEN Final_MDR_Applicable = 1
                 THEN Transaction_Amount ELSE 0 END)
        AS DECIMAL(14,2)
    ) AS Final_MDR_Applicable_Value,
    CAST(SUM(MDR_Amount) AS DECIMAL(14,2))
        AS Total_MDR_Cost
FROM dbo.vw_mdr_transactions;

/* Expected project counts:
   Potential MDR eligible         = 308
   Small-merchant exempt          = 55
   Final MDR applicable           = 253
   Final MDR not applicable       = 747
   Total MDR cost                 = INR 22,175.56
*/

/* ============================================================================
   04. SMALL-MERCHANT EXEMPTION IMPACT
   ============================================================================ */

SELECT
    COUNT(*) AS Exempt_MDR_Transactions,
    CAST(SUM(Transaction_Amount) AS DECIMAL(14,2))
        AS Exempt_Transaction_Value,
    CAST(
        SUM(
            CASE
                WHEN Transaction_Amount * 0.004 > 300 THEN 300
                ELSE Transaction_Amount * 0.004
            END
        )
        AS DECIMAL(14,2)
    ) AS Potential_MDR_Avoided
FROM dbo.vw_mdr_transactions
WHERE MDR_Eligible = 1
  AND Small_Merchant_Exempt = 1;

/* ============================================================================
   05. MDR CAP ANALYSIS
   ============================================================================ */

SELECT
    COUNT(*) AS Capped_Transactions,
    CAST(SUM(Transaction_Amount) AS DECIMAL(14,2))
        AS Capped_Transaction_Value,
    CAST(SUM(MDR_Amount) AS DECIMAL(14,2))
        AS Actual_MDR,
    CAST(SUM(Transaction_Amount * 0.004) AS DECIMAL(14,2))
        AS MDR_Without_Cap,
    CAST(
        SUM((Transaction_Amount * 0.004) - MDR_Amount)
        AS DECIMAL(14,2)
    ) AS MDR_Saved_By_Cap
FROM dbo.vw_mdr_transactions
WHERE Final_MDR_Applicable = 1
  AND Transaction_Amount * 0.004 > 300;

/* ============================================================================
   06. PROFITABILITY IMPACT
   ============================================================================ */

SELECT
    CAST(SUM(Gross_Profit) AS DECIMAL(14,2))
        AS Gross_Profit_Before_MDR,
    CAST(SUM(MDR_Amount) AS DECIMAL(14,2))
        AS Total_MDR_Cost,
    CAST(SUM(Gross_Profit) - SUM(MDR_Amount) AS DECIMAL(14,2))
        AS Net_Profit_After_MDR,
    CAST(
        SUM(MDR_Amount) / NULLIF(SUM(Gross_Profit), 0) * 100
        AS DECIMAL(6,2)
    ) AS MDR_Impact_Percent
FROM dbo.vw_mdr_transactions
WHERE Final_MDR_Applicable = 1;

/* ============================================================================
   07. MERCHANT ANALYSIS
   ============================================================================ */

WITH Merchant_MDR AS
(
    SELECT
        Merchant_ID,
        COUNT(*) AS MDR_Transactions,
        SUM(Transaction_Amount) AS Transaction_Value,
        SUM(MDR_Amount) AS MDR_Cost,
        SUM(Gross_Profit) AS Gross_Profit
    FROM dbo.vw_mdr_transactions
    WHERE Final_MDR_Applicable = 1
    GROUP BY Merchant_ID
)
SELECT TOP 10
    Merchant_ID,
    MDR_Transactions,
    CAST(Transaction_Value AS DECIMAL(14,2)) AS Transaction_Value,
    CAST(MDR_Cost AS DECIMAL(14,2)) AS MDR_Cost,
    CAST(
        MDR_Cost / NULLIF(Gross_Profit, 0) * 100
        AS DECIMAL(6,2)
    ) AS MDR_Impact_Percent
FROM Merchant_MDR
ORDER BY MDR_Cost DESC, Merchant_ID;

-- Top-10 merchant concentration as a share of total MDR cost.
WITH Merchant_MDR AS
(
    SELECT
        Merchant_ID,
        SUM(MDR_Amount) AS MDR_Cost
    FROM dbo.vw_mdr_transactions
    WHERE Final_MDR_Applicable = 1
    GROUP BY Merchant_ID
),
Ranked_Merchants AS
(
    SELECT
        Merchant_ID,
        MDR_Cost,
        ROW_NUMBER() OVER (
            ORDER BY MDR_Cost DESC, Merchant_ID
        ) AS Merchant_Rank
    FROM Merchant_MDR
)
SELECT
    COUNT(*) AS Total_MDR_Merchants,
    CAST(
        SUM(CASE WHEN Merchant_Rank <= 10 THEN MDR_Cost ELSE 0 END)
        AS DECIMAL(14,2)
    ) AS Top_10_MDR_Cost,
    CAST(
        SUM(CASE WHEN Merchant_Rank <= 10 THEN MDR_Cost ELSE 0 END)
        / NULLIF(SUM(MDR_Cost), 0) * 100
        AS DECIMAL(6,2)
    ) AS Top_10_MDR_Share_Percent
FROM Ranked_Merchants;

/* ============================================================================
   08. CITY ANALYSIS
   ============================================================================ */

SELECT
    c.City,
    v.City_ID,
    COUNT(*) AS MDR_Transactions,
    CAST(SUM(v.Transaction_Amount) AS DECIMAL(14,2))
        AS Transaction_Value,
    CAST(SUM(v.MDR_Amount) AS DECIMAL(14,2))
        AS MDR_Cost,
    CAST(
        SUM(v.MDR_Amount) / NULLIF(SUM(v.Gross_Profit), 0) * 100
        AS DECIMAL(6,2)
    ) AS MDR_Impact_Percent
FROM dbo.vw_mdr_transactions AS v
INNER JOIN dbo.dim_city AS c
    ON v.City_ID = c.City_ID
WHERE v.Final_MDR_Applicable = 1
GROUP BY c.City, v.City_ID
ORDER BY MDR_Cost DESC, v.City_ID;

/* ============================================================================
   09. PAYMENT-METHOD VALIDATION
   ============================================================================ */

SELECT
    Payment_Method,
    COUNT(*) AS Transactions,
    CAST(SUM(Transaction_Amount) AS DECIMAL(14,2))
        AS Transaction_Value,
    CAST(SUM(MDR_Amount) AS DECIMAL(14,2))
        AS MDR_Cost
FROM dbo.vw_mdr_transactions
GROUP BY Payment_Method
ORDER BY MDR_Cost DESC, Transaction_Value DESC;

/* ============================================================================
   10. MONTHLY MDR TREND
   ============================================================================ */

SELECT
    YEAR(Transaction_Date) AS [Year],
    MONTH(Transaction_Date) AS Month_Number,
    DATENAME(MONTH, Transaction_Date) AS Month_Name,
    COUNT(*) AS MDR_Transactions,
    CAST(SUM(Transaction_Amount) AS DECIMAL(14,2))
        AS MDR_Transaction_Value,
    CAST(SUM(MDR_Amount) AS DECIMAL(14,2))
        AS MDR_Cost
FROM dbo.vw_mdr_transactions
WHERE Final_MDR_Applicable = 1
GROUP BY
    YEAR(Transaction_Date),
    MONTH(Transaction_Date),
    DATENAME(MONTH, Transaction_Date)
ORDER BY [Year], Month_Number;

/* ============================================================================
   11. TRANSACTION-SIZE ANALYSIS
   ============================================================================ */

WITH Transaction_Bands AS
(
    SELECT
        CASE
            WHEN Transaction_Amount <= 10000 THEN '01 <= INR 10K'
            WHEN Transaction_Amount <= 25000 THEN '02 INR 10K-25K'
            WHEN Transaction_Amount <= 50000 THEN '03 INR 25K-50K'
            WHEN Transaction_Amount <= 75000 THEN '04 INR 50K-75K'
            ELSE '05 > INR 75K'
        END AS Transaction_Band,
        Transaction_Amount,
        Gross_Profit,
        MDR_Amount
    FROM dbo.vw_mdr_transactions
    WHERE Final_MDR_Applicable = 1
)
SELECT
    Transaction_Band,
    COUNT(*) AS Transactions,
    CAST(SUM(Transaction_Amount) AS DECIMAL(14,2))
        AS Transaction_Value,
    CAST(SUM(MDR_Amount) AS DECIMAL(14,2))
        AS MDR_Cost,
    CAST(
        SUM(MDR_Amount) / NULLIF(SUM(Gross_Profit), 0) * 100
        AS DECIMAL(6,2)
    ) AS MDR_Impact_Percent
FROM Transaction_Bands
GROUP BY Transaction_Band
ORDER BY Transaction_Band;

/* ============================================================================
   END OF PORTFOLIO ANALYSIS

   Architecture:
   Raw data -> cleaned fact/dimensions -> MDR reporting view -> Power BI model
   ============================================================================ */
