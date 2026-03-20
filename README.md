# Invoice Analysis Practice Project

My next project is an analysis performed on a real invoice dataset, using data exported from my workplace.

**To preserve anonymity, I proportionally adjusted the figures and changed supplier names.**

## Background

The invoice dataset reflects 2025 expenditures, payment dates, and the distribution of payment terms. The analysis focuses on supplier performance, payment terms, spend analysis, invoice processing, and risk assessment.

## Tools I used
- Excel for cleaning the data
- SQL for querying and analyzing the invoices database
- PostgreSQL as the database management system
- VS Code for writing and executing queries
- Git and GitHub for version control and sharing

## 1. Area of Analysis: Supplier Performance

As a first step, supplier data was analyzed across four dimensions to gain a comprehensive view of the spending structure and supplier base composition.

### Total annual spend
The second query calculates the total annual spend. This serves as a baseline for interpreting all other metrics. It is used to express supplier concentration and savings opportunities in percentage terms.

```SQL
SELECT
    SUM(amount_local_curr) as total_year
From invoices_raw
ORDER BY total_year DESC
```
**Results:**
| Metric | Value |
| --- | --- |
| Total Annual Spend | 318,447,521 EUR |

### TOP 20 suppliers by total invoice value
The first query identifies the top 20 suppliers by total invoice volume. This is a classic spend concentration analysis. Based on the Pareto principle, a small portion of suppliers is expected to account for the majority of total spend. The results highlight where strategic negotiations should be prioritized, as these suppliers offer the highest savings potential.

``` SQL
WITH suppliers_total AS (
    SELECT
        s.supplier_code,
        s.supplier_name,
        SUM(i.amount_local_curr) AS total_amount
    FROM invoices_raw i
    INNER JOIN (
        SELECT DISTINCT supplier_code, supplier_name
        FROM suppliers
    ) s ON i.account = s.supplier_code
    GROUP BY s.supplier_code, s.supplier_name
)
SELECT *
FROM suppliers_total
ORDER BY total_amount asc
LIMIT 20;
```
**Results:**
| # | Supplier (anonymized) | Total Payment (EUR) |
| --- | --- | --- |
| 1 | Redwood Industrial Solutions Ltd. | 19,307,412 | 6.06% |
| 2 | Ironclad Parts & Components GmbH | 10,723,894 | 3.37% |
| 3 | Northgate Lighting Technologies UAB | 10,397,651 | 3.27% |
| 4 | Clearfield Manufacturing GmbH | 10,314,208 | 3.24% |
| 5 | Eastbrook Automotive Solutions s.r.o. | 8,782,541 | 2.76% |
| 6 | Harborview Chemical Group | 8,434,619 | 2.65% |
| 7 | Stonegate Services Europa GmbH | 7,662,387 | 2.41% |
| 8 | Maplewood Energy Nyrt. | 7,268,143 | 2.28% |
| 9 | Bridgepoint Vehicle Systems Kft. | 5,638,924 | 1.77% |
| 10 | Lakeview Production S.R.L. | 5,347,812 | 1.68% |
| 11 | Westfield Distribution Europe B.V. | 4,560,731 | 1.43% |
| 12 | Ferndale Sales & Trading Co. | 4,559,614 | 1.43% |
| 13 | Coldstream Logistics Kft. | 4,508,347 | 1.42% |
| 14 | Ashford Surface Coatings GmbH | 4,057,923 | 1.27% |
| 15 | Crestwood Climate Systems k.s. | 3,920,184 | 1.23% |
| 16 | Dunmore Coating Technologies GmbH | 3,912,647 | 1.23% |
| 17 | Millbrook Surface Engineering GmbH | 3,474,521 | 1.09% |
| 18 | Thornfield Industrial AG | 3,478,934 | 1.09% |
| 19 | Riverstone International SARL | 3,401,287 | 1.07% |
| 20 | Greenpark Nonprofit Ltd. | 3,270,541 | 1.03% |

### Invoice count and average invoice value per supplier
The third query shows the number of invoices and the average invoice value per supplier. A high invoice count combined with a low average value indicates process inefficiency. This may justify supplier consolidation or a redesign of ordering processes. The average invoice value is also a useful proxy for measuring accounts payable workload.

```SQL
SELECT
    suppliers.supplier_name,
    COUNT(invoices_raw.account) AS count_of_invoices,
    ROUND(AVG(amount_local_curr), 2) AS average_invoice_amount
FROM invoices_raw
INNER JOIN suppliers
    ON suppliers.supplier_code = invoices_raw.account
GROUP BY invoices_raw.account, suppliers.supplier_name
ORDER BY count_of_invoices DESC
LIMIT 20;
```
**Results:**
| # | Supplier (anonymized) | Invoice Count | Avg. Invoice Value (EUR) |
| --- | --- | --- | --- |
| 1 | Redwood Industrial Solutions Ltd. | 7,438 | 5,186 |
| 2 | Dunmore Coating Technologies GmbH | 2,364 | 6,623 |
| 3 | Silvergate Precision Austria GmbH | 2,236 | 1,850 |
| 4 | Bridgepoint Vehicle Systems Kft. | 1,431 | 3,942 |
| 5 | Stonegate Services Europa GmbH | 1,396 | 5,491 |
| 6 | Copperfield Plastics Tisza Kft. | 1,350 | 4,081 |
| 7 | Pinewood Process Industries GmbH | 1,268 | 554 |
| 8 | Fallbrook Tooling & Equipment GmbH | 1,254 | 1,984 |
| 9 | Ironclad Parts & Components GmbH | 1,175 | 9,147 |
| 10 | Brackenridge Transport Kft. | 1,069 | 2,063 |
| 11 | Foxhollow Plastics Technology GmbH | 1,028 | 2,771 |
| 12 | Summitview Services Kft. | 956 | 1,246 |
| 13 | Greenpark Nonprofit Ltd. | 707 | 4,629 |
| 14 | Greystone Polymer Solutions GmbH | 662 | 2,298 |
| 15 | Coldstream Logistics Kft. | 638 | 7,069 |
| 16 | Ravenbrook Precision Engineering GmbH | 592 | 3,229 |
| 17 | Lakeview Production S.R.L. | 558 | 19,174 |
| 18 | Cedarwood Fastening Systems GmbH | 504 | 2,208 |
| 19 | Clearfield Manufacturing GmbH | 463 | 22,284 |
| 20 | Valewood Handling Equipment Kft. | 403 | 4,296 |

> Pinewood Process Industries GmbH: 1,268 invoices at 554 EUR average. High AP processing burden relative to spend volume.

### Distribution of suppliers by payment terms
The fourth query examines the distribution of payment terms across suppliers. Short payment terms, such as 8 days, should be reviewed to assess whether they are justified. There may be opportunities to standardize terms or improve cash flow position through renegotiation.
```SQL
SELECT
    terms_of_payment,
    COUNT(DISTINCT account) AS number_of_suppliers
FROM invoices_raw
WHERE terms_of_payment IS NOT NULL
GROUP BY terms_of_payment
ORDER BY number_of_suppliers DESC
```
**Results:**
| Rank | Term Code | Number of Suppliers | % of Total Suppliers |
| --- | --- | --- | --- |
| 1 | AB06 | 349 | 17.9% |
| 2 | AB34 | 340 | 17.4% |
| 3 | AB03 | 260 | 13.3% |
| 4 | AB16 | 30 | 1.5% |
| 5 | AB05 | 30 | 1.5% |
| 6 | AB43 | 26 | 1.3% |
| 7 | AB96 | 25 | 1.3% |
| 8 | AB05 | 23 | 1.2% |
| 9 | AB93 | 20 | 1.0% |
| 10 | AB21 | 20 | 1.0% |


> 59 distinct payment term codes across the supplier base. Top 3 codes cover 949 suppliers (48.6%).

## 2. Area of Analysis: Payment Terms analysis
This section analyzes payment terms and payment discipline across two dimensions: identifying suppliers with consistently late payments, and evaluating whether early payment discounts are being captured on eligible transactions.

### Late Payment Analysis (avg_delay = payment_date - net_due_date)
My goal was to identify suppliers with high average payment delays to assess relationship risk, potential penalty exposure, and determine whether delays are process-driven or cash flow-driven.

Avg_delay is calculated as payment_date minus net_due_date. A negative value means payment was made after the due date (late). Zero means on time. The suppliers below are ordered by most severe average delay.

```SQL
SELECT
    suppliers.supplier_name,
    Round(AVG(payment_date - net_due_date), 2) AS avg_delay
FROM invoices_raw
LEFT JOIN suppliers on invoices_raw.account = suppliers.supplier_code
WHERE payment_date IS NOT NULL AND net_due_date IS NOT NULL AND supplier_name IS NOT NULL
GROUP BY account, suppliers.supplier_name
ORDER BY avg_delay ASC
```
**Results:**
| # | Supplier (anonymized) | Avg. Delay (days) |
| --- | --- | --- |
| 1 | Harborview Polymer Coatings GmbH | -49.58 | late |
| 2 | Ashford Industrial Finishes GmbH | -41.98 | late |
| 3 | Brackenridge Freight Solutions | -40.89 | late |
| 4 | Ferndale Component Supply GmbH | -30.00 | late |
| 5 | Crestwood Specialty Chemicals KG | -30.00 | late |
| 6 | Millbrook Acoustic Systems GmbH | -27.08 | late |
| 7 | Thornfield Process Engineering KG | -25.62 | late |
| 8 | Riverstone Polymer Systems KG | -22.00 | late |
| 9 | Valewood Surface Finishing GmbH | -22.00 | late |
| 10 | Ferndale Component Supply GmbH | -21.43 | late |
| 11 | Dunmore Precision Tooling GmbH | -20.22 | late |
| 12 | Silvergate Electronic Systems Kft. | -20.00 | late |
| 13 | Copperfield Sealing Products GmbH | -20.00 | late |
| 14 | Foxhollow Plastics Technology GmbH | -20.00 | late |
| 15 | Summitview Textile Solutions | -20.00 | late |
| 16 | Ravenbrook Technical Parts GmbH | -20.00 | late |
| 17 | Cedarwood Fastening Systems GmbH | -18.99 | late |
| 18 | Greystone IT Solutions GmbH | -18.94 | late |
| 19 | Lakeview Tooling s.r.o. | -16.00 | late |
| 20 | Coldstream Clamping Technology GmbH | -16.00 | late |

> Suppliers with avg_delay below -20 days have been consistently paid late. This creates supplier relationship risk and potential penalty exposure. The top 3 suppliers average nearly 44 days late. A root cause review per supplier is recommended to identify whether delays are process-driven or cash flow-driven.


### Early Payment Discount Utilization
My objective was to evaluate whether early payment discounts are being captured on payment term codes that carry a discount window, and estimate the total uncaptured savings opportunity.


Transactions where payment_delay = 0 (paid on the discount date) were matched against applicable discount rates per payment term code.

```SQL
WITH payment_discount AS (
    SELECT *
    FROM payment_terms
    WHERE own_explanation LIKE '%discount%'
),
payment_amount AS (
    SELECT
        clearing_date - posting_date AS payment_delay,
        terms_of_payment,
        SUM(amount_local_curr) AS total_amount
    FROM invoices_raw
    GROUP BY terms_of_payment, posting_date, clearing_date
)

SELECT
    pa.terms_of_payment,
    pa.total_amount,
    CASE
        WHEN pa.payment_delay = 0 THEN
            CASE pa.terms_of_payment
                WHEN '1436' THEN pa.total_amount * 0.97
                WHEN 'DJ07' THEN pa.total_amount * 0.96
                WHEN 'DJ20' THEN pa.total_amount * 0.98
                WHEN 'DJ21' THEN pa.total_amount * 0.96
                WHEN 'DJ43' THEN pa.total_amount * 0.98
                WHEN 'DJ46' THEN pa.total_amount * 0.98
                WHEN 'DK02' THEN pa.total_amount * 0.97
                WHEN 'DK07' THEN pa.total_amount * 0.98
                WHEN 'DK08' THEN pa.total_amount * 0.97
                WHEN 'DK10' THEN pa.total_amount * 0.99
                WHEN 'DK11' THEN pa.total_amount * 0.98
                WHEN 'DK12' THEN pa.total_amount * 0.98
                WHEN 'DK13' THEN pa.total_amount * 0.97
                WHEN 'DK14' THEN pa.total_amount * 0.97
                WHEN 'DK17' THEN pa.total_amount * 0.99
                WHEN 'DK18' THEN pa.total_amount * 0.98
                WHEN 'DK19' THEN pa.total_amount * 0.97
                WHEN 'DK20' THEN pa.total_amount * 0.96
                WHEN 'DK37' THEN pa.total_amount * 0.98
                WHEN 'DK38' THEN pa.total_amount * 0.97
                WHEN 'DK39' THEN pa.total_amount * 0.97
                WHEN 'DK59' THEN pa.total_amount * 0.97
                WHEN 'DK72' THEN pa.total_amount * 0.97
                WHEN 'DK73' THEN pa.total_amount * 0.98
                WHEN 'DK76' THEN pa.total_amount * 0.99
                WHEN 'DK90' THEN pa.total_amount * 0.97
                WHEN 'DK97' THEN pa.total_amount * 0.985
                ELSE pa.total_amount
            END
        ELSE pa.total_amount
    END AS discounted_amount,
    CASE
        WHEN pa.payment_delay = 0 THEN
            CASE pa.terms_of_payment
                WHEN '1436' THEN pa.total_amount * 0.03
                WHEN 'DJ07' THEN pa.total_amount * 0.04
                WHEN 'DJ20' THEN pa.total_amount * 0.02
                WHEN 'DJ21' THEN pa.total_amount * 0.04
                WHEN 'DJ43' THEN pa.total_amount * 0.02
                WHEN 'DJ46' THEN pa.total_amount * 0.02
                WHEN 'DK02' THEN pa.total_amount * 0.03
                WHEN 'DK07' THEN pa.total_amount * 0.02
                WHEN 'DK08' THEN pa.total_amount * 0.03
                WHEN 'DK10' THEN pa.total_amount * 0.01
                WHEN 'DK11' THEN pa.total_amount * 0.02
                WHEN 'DK12' THEN pa.total_amount * 0.02
                WHEN 'DK13' THEN pa.total_amount * 0.03
                WHEN 'DK14' THEN pa.total_amount * 0.03
                WHEN 'DK17' THEN pa.total_amount * 0.01
                WHEN 'DK18' THEN pa.total_amount * 0.02
                WHEN 'DK19' THEN pa.total_amount * 0.03
                WHEN 'DK20' THEN pa.total_amount * 0.04
                WHEN 'DK37' THEN pa.total_amount * 0.02
                WHEN 'DK38' THEN pa.total_amount * 0.03
                WHEN 'DK39' THEN pa.total_amount * 0.03
                WHEN 'DK59' THEN pa.total_amount * 0.03
                WHEN 'DK72' THEN pa.total_amount * 0.03
                WHEN 'DK73' THEN pa.total_amount * 0.02
                WHEN 'DK76' THEN pa.total_amount * 0.01
                WHEN 'DK90' THEN pa.total_amount * 0.03
                WHEN 'DK97' THEN pa.total_amount * 0.015
                ELSE 0
            END
        ELSE 0
    END AS discount_amount
FROM payment_amount pa
INNER JOIN payment_discount pd ON pa.terms_of_payment = pd.pay_terms
where pa.payment_delay = 0
ORDER BY pa.payment_delay DESC;
```
**Results:**

| # | Term Code | Total Amount (EUR) | Discounted Amount (EUR) | Discount Captured (EUR) |
| --- | --- | --- | --- | --- |
| 1 | 1436 | 6,816.00 | 6,611.52 | 204.48 | 3.0% |
| 2 | DJ07 | 50,000.00 | 48,000.00 | 2,000.00 | 4.0% |
| 3 | DJ07 | 4,579.00 | 4,395.84 | 183.16 | 4.0% |
| 4 | DJ46 | 42.41 | 41.56 | 0.85 | 2.0% |
| 5 | DJ46 | 2,905.00 | 2,846.90 | 58.10 | 2.0% |
| 6 | DK07 | 232.91 | 228.25 | 4.66 | 2.0% |
| 7 | DK11 | 718.00 | 703.64 | 14.36 | 2.0% |
| 8 | DK11 | -950.00 | -931.00 | -19.00 | 2.0% |
| 9 | DK13 | 1,962.10 | 1,903.24 | 58.86 | 3.0% |
| 10 | DK14 | 1,169.00 | 1,133.93 | 35.07 | 3.0% |
| 11 | DK14 | 3,105.00 | 3,011.85 | 93.15 | 3.0% |
| 12 | DK18 | 815.85 | 799.53 | 16.32 | 2.0% |
| 13 | DK18 | 2,550.60 | 2,499.59 | 51.01 | 2.0% |
| 14 | DK18 | -6,868.31 | -6,730.94 | -137.37 | 2.0% |
| 15 | DK39 | 418.80 | 406.24 | 12.56 | 3.0% |
| 16 | DK39 | 0.00 | 0.00 | 0.00 | 3.0% |
| 17 | DK39 | -350.00 | -339.50 | -10.50 | 3.0% |
| 18 | DK39 | 0.00 | 0.00 | 0.00 | 3.0% |
| 19 | DK59 | 0.00 | 0.00 | 0.00 | 3.0% |
| 20 | DK59 | 490.60 | 475.88 | 14.71 | 3.0% |
| 21 | DK76 | 0.00 | 0.00 | 0.00 | 1.0% |

> The sample above covers transactions where the discount window was met (payment_delay = 0). The data indicates that discount capture is occurring, but coverage across the full supplier base is partial. A systematic review of all discount-eligible payment terms against actual payment timing would quantify the total uncaptured discount opportunity.





## 3. Area of Analysis: Spend analysis
This section examines spend patterns across two dimensions: monthly distribution to identify seasonal or operational peaks, and currency breakdown to assess foreign exchange exposure and the share of non-EUR spend.

### Monthly Spend Trend
Objective is identify months with abnormally high or low spend volumes to support budget planning, detect posting anomalies, and flag periods that may require additional cash flow coverage.

```SQL
SELECT
    EXTRACT(MONTH FROM posting_date) AS month,
    CASE
        WHEN EXTRACT(MONTH FROM posting_date) = 1 THEN 'January'
        WHEN EXTRACT(MONTH FROM posting_date) = 2 THEN 'February'
        WHEN EXTRACT(MONTH FROM posting_date) = 3 THEN 'March'
        WHEN EXTRACT(MONTH FROM posting_date) = 4 THEN 'April'
        WHEN EXTRACT(MONTH FROM posting_date) = 5 THEN 'May'
        WHEN EXTRACT(MONTH FROM posting_date) = 6 THEN 'June'
        WHEN EXTRACT(MONTH FROM posting_date) = 7 THEN 'July'
        WHEN EXTRACT(MONTH FROM posting_date) = 8 THEN 'August'
        WHEN EXTRACT(MONTH FROM posting_date) = 9 THEN 'September'
        WHEN EXTRACT(MONTH FROM posting_date) = 10 THEN 'October'
        WHEN EXTRACT(MONTH FROM posting_date) = 11 THEN 'November'
        WHEN EXTRACT(MONTH FROM posting_date) = 12 THEN 'December'
    END AS month_name,
    SUM(amount_local_curr) AS total_amount
FROM invoices_raw
GROUP BY EXTRACT(MONTH FROM posting_date)
ORDER BY month ASC;
```
**Results:**
| # | Month     | Total Amount (EUR) |
| --- | --- | --- |
| 1  | January   | 27,143,613         | 9.9%              |
| 2  | February  | 24,496,908         | 8.9%              |
| 3  | March     | 25,162,840         | 9.2%              |
| 4  | April     | 18,781,886         | 6.9%              |
| 5  | May       | 16,979,699         | 6.2%              |
| 6  | June      | 16,878,703         | 6.2%              |
| 7  | July      | 32,905,266         | 12.0%             |
| 8  | August    | 15,218,233         | 5.6%              |
| 9  | September | 28,423,843         | 10.4%             |
| 10 | October   | 17,056,854         | 6.2%              |
| 11 | November  | 26,377,413         | 9.6%              |
| 12 | December  | 24,567,431         | 9.0%              |

>July (12.0%) and September (10.4%) are the two highest spend months. August is the lowest at 5.6%, likely reflecting a production shutdown period. The Q1 average (9.3%) is notably higher than Q2-Q3 summer months, which may indicate front-loaded procurement activity.


### Spend Distribution by Currency
Goal is to determine what share of total spend is invoiced in non-EUR currencies, quantify USD and HUF exposure, and assess whether currency hedging or local sourcing strategies are warranted.
```SQL
SELECT
    document_currency,
    SUM(amount_local_curr) AS total_amount
FROM invoices_raw
GROUP BY document_currency
ORDER BY total_amount DESC;
```

**Results:**

![Monthly Spend Trend](C:\Users\laszl\Desktop\Projects\Invoice analysis project\Assets\spend_by_currency.png)

>EUR dominates at 79.7%. HUF exposure at 18.2% is significant given HUF volatility; local HUF-denominated contracts should be reviewed for indexation clauses. USD exposure at 2.2% is moderate but warrants monitoring for commodity-linked purchases. The CNY value is negative, likely a credit note or reversal.