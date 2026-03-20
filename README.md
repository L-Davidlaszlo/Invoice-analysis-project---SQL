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
                WHEN '1445' THEN pa.total_amount * 0.97
                WHEN 'DJ23' THEN pa.total_amount * 0.96
                WHEN 'DJ23' THEN pa.total_amount * 0.98
                WHEN 'DJ54' THEN pa.total_amount * 0.96
                WHEN 'DJ54' THEN pa.total_amount * 0.98
                WHEN 'DJ64' THEN pa.total_amount * 0.98
                WHEN 'DK65' THEN pa.total_amount * 0.97
                WHEN 'DK65' THEN pa.total_amount * 0.98
                WHEN 'DP10' THEN pa.total_amount * 0.97
                WHEN 'DP10' THEN pa.total_amount * 0.99
                WHEN 'DZ11' THEN pa.total_amount * 0.98
                WHEN 'D412' THEN pa.total_amount * 0.98
                WHEN 'DK13' THEN pa.total_amount * 0.97
                WHEN 'AB14' THEN pa.total_amount * 0.97
                WHEN 'DK17' THEN pa.total_amount * 0.99
                WHEN 'A318' THEN pa.total_amount * 0.98
                WHEN 'D019' THEN pa.total_amount * 0.97
                WHEN 'DZ20' THEN pa.total_amount * 0.96
                WHEN 'D537' THEN pa.total_amount * 0.98
                WHEN 'DK38' THEN pa.total_amount * 0.97
                WHEN 'AC39' THEN pa.total_amount * 0.97
                WHEN 'AC59' THEN pa.total_amount * 0.97
                WHEN 'AC72' THEN pa.total_amount * 0.97
                WHEN 'AC73' THEN pa.total_amount * 0.98
                WHEN 'AC76' THEN pa.total_amount * 0.99
                WHEN 'AC90' THEN pa.total_amount * 0.97
                WHEN 'AC97' THEN pa.total_amount * 0.985
                ELSE pa.total_amount
            END
        ELSE pa.total_amount
    END AS discounted_amount,
    CASE
        WHEN pa.payment_delay = 0 THEN
            CASE pa.terms_of_payment
                WHEN '1445' THEN pa.total_amount * 0.03
                WHEN 'DJ23' THEN pa.total_amount * 0.04
                WHEN 'DJ23' THEN pa.total_amount * 0.02
                WHEN 'DJ54' THEN pa.total_amount * 0.04
                WHEN 'DJ54' THEN pa.total_amount * 0.02
                WHEN 'DJ64' THEN pa.total_amount * 0.02
                WHEN 'DK65' THEN pa.total_amount * 0.03
                WHEN 'DK65' THEN pa.total_amount * 0.04
                WHEN 'DP10' THEN pa.total_amount * 0.03
                WHEN 'DP10' THEN pa.total_amount * 0.01
                WHEN 'DZ11' THEN pa.total_amount * 0.04
                WHEN 'D412' THEN pa.total_amount * 0.04
                WHEN 'DK13' THEN pa.total_amount * 0.06
                WHEN 'AB14' THEN pa.total_amount * 0.04
                WHEN 'DK17' THEN pa.total_amount * 0.02
                WHEN 'A318' THEN pa.total_amount * 0.02
                WHEN 'D019' THEN pa.total_amount * 0.05
                WHEN 'DZ20' THEN pa.total_amount * 0.03
                WHEN 'D537' THEN pa.total_amount * 0.04
                WHEN 'DK38' THEN pa.total_amount * 0.05
                WHEN 'AC39' THEN pa.total_amount * 0.05
                WHEN 'AC59' THEN pa.total_amount * 0.04
                WHEN 'AC72' THEN pa.total_amount * 0.05
                WHEN 'AC73' THEN pa.total_amount * 0.05
                WHEN 'AC76' THEN pa.total_amount * 0.06
                WHEN 'AC90' THEN pa.total_amount * 0.03
                WHEN 'AC97' THEN pa.total_amount * 0.015
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
| 1 | 1445 | 6,816.00 | 6,611.52 | 204.48 | 3.0% |
| 2 | DJ23 | 50,000.00 | 48,000.00 | 2,000.00 | 4.0% |
| 3 | DJ23 | 4,579.00 | 4,395.84 | 183.16 | 4.0% |
| 4 | DJ54 | 42.41 | 41.56 | 0.85 | 2.0% |
| 5 | DJ54 | 2,905.00 | 2,846.90 | 58.10 | 2.0% |
| 6 | DK64 | 232.91 | 228.25 | 4.66 | 2.0% |
| 7 | DK65 | 718.00 | 703.64 | 14.36 | 2.0% |
| 8 | DK65 | -950.00 | -931.00 | -19.00 | 2.0% |
| 9 | DK10 | 1,962.10 | 1,903.24 | 58.86 | 3.0% |
| 10 | AB14 | 1,169.00 | 1,133.93 | 35.07 | 3.0% |
| 11 | AB14 | 3,105.00 | 3,011.85 | 93.15 | 3.0% |
| 12 | AC18 | 815.85 | 799.53 | 16.32 | 2.0% |
| 13 | AC18 | 2,550.60 | 2,499.59 | 51.01 | 2.0% |
| 14 | AC18 | -6,868.31 | -6,730.94 | -137.37 | 2.0% |
| 15 | AC39 | 418.80 | 406.24 | 12.56 | 3.0% |
| 16 | AC39 | 0.00 | 0.00 | 0.00 | 3.0% |
| 17 | AC39 | -350.00 | -339.50 | -10.50 | 3.0% |
| 18 | AG39 | 0.00 | 0.00 | 0.00 | 3.0% |
| 19 | AG59 | 0.00 | 0.00 | 0.00 | 3.0% |
| 20 | AH59 | 490.60 | 475.88 | 14.71 | 3.0% |
| 21 | AH76 | 0.00 | 0.00 | 0.00 | 1.0% |

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
| # | Month | Total Amount (EUR) |
| --- | --- | --- |
| 1 | January | 25,625,598 | 9.9% |
| 2 | February | 23,126,911 | 8.9% |
| 3 | March | 23,755,600 | 9.2% |
| 4 | April | 17,731,503 | 6.9% |
| 5 | May | 16,030,104 | 6.2% |
| 6 | June | 15,934,756 | 6.2% |
| 7 | July | 31,065,028 | 12.0% |
| 8 | August | 14,367,148 | 5.6% |
| 9 | September | 26,834,230 | 10.4% |
| 10 | October | 16,102,944 | 6.2% |
| 11 | November | 24,902,248 | 9.6% |
| 12 | December | 23,193,489 | 9.0% |

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

![Monthly Spend Trend](https://github.com/L-Davidlaszlo/Invoice-analysis-project---SQL/blob/main/Assets/spend_by_currency.png?raw=true)

>EUR dominates at 79.7%. HUF exposure at 18.2% is significant given HUF volatility; local HUF-denominated contracts should be reviewed for indexation clauses. USD exposure at 2.2% is moderate but warrants monitoring for commodity-linked purchases. The CNY value is negative, likely a credit note or reversal.

## 4. Area of Analysis: Invoice processong analysis
This section analyzes invoice processing efficiency at the user level, covering average processing time per user, invoice volume and total value handled, and a combined view to identify bottlenecks or workload imbalances across the AP team.

### Average Processing Time
Objective: identify users with high average processing times to detect bottlenecks, training needs, or system-related delays in the invoice posting workflow.

```SQL
SELECT
    user_name,
    ROUND(AVG(clearing_date - posting_date), 2) AS avg_processing_time
FROM invoices_raw
WHERE clearing_date IS NOT NULL AND posting_date IS NOT NULL
GROUP BY user_name
ORDER BY avg_processing_time DESC;
```
**Results:**

### Average Processing Time per User

| # | User | Avg. Processing Time (days) |
| --- | --- | --- |
| 1 | AP.Miller | 132.51 |
| 2 | AP.Johnson | 60.84 |
| 3 | AP.Wagner | 44.91 |
| 4 | AP.Weber | 49.68 |
| 5 | AP.Fischer | 42.63 |
| 6 | AP.Becker | 44.88 |
| 7 | AP.Schmidt | 48.95 |
| 8 | AP.Hoffmann | 44.40 |
| 9 | AP.Schulz | 38.98 |
| 10 | AP.Koch | 40.30 |
| 11 | BATCH.AUTO | 35.20 |
| 12 | AP.Richter | 30.64 |
| 13 | AP.Klein | 24.96 |
| 14 | AP.Wolf | 28.08 |
| 15 | AP.Neumann | 21.84 |
| 16 | AP.Braun | 7.96 |
| 17 | AP.Hartmann | 6.06 |
| 18 | AP.Zimmermann | 3.20 |
| 19 | AP.Krause | 0.63 |

### Invoices per User
Objective: measure workload distribution across users by invoice count and total value to identify concentration risk and capacity imbalances.

```SQL
SELECT
    user_name,
    COUNT(*) AS number_of_invoices,
    ROUND(SUM(amount_local_curr) / 1.27, 2) AS total_amount
FROM invoices_raw
GROUP BY user_name
ORDER BY number_of_invoices DESC;
```
**Results:**

| # | User | Invoice Count | Total Amount (EUR) |
| --- | --- | --- | --- |
| 1 | AP.Weber | 7,535 | 40,267,194 |
| 2 | AP.Schmidt | 7,240 | 46,349,818 |
| 3 | AP.Johnson | 6,311 | 39,363,868 |
| 4 | AP.Schulz | 5,301 | 27,255,100 |
| 5 | BATCH.AUTO | 3,156 | 17,713,239 |
| 6 | AP.Koch | 2,313 | 11,173,951 |
| 7 | AP.Wolf | 2,250 | 11,096,952 |
| 8 | AP.Hartmann | 2,224 | 199,118 |
| 9 | AP.Neumann | 1,527 | 3,795,710 |
| 10 | AP.Klein | 895 | 805,830 |
| 11 | AP.Richter | 413 | 3,489,047 |
| 12 | AP.Becker | 324 | 2,749,328 |
| 13 | AP.Wagner | 348 | 171,978 |
| 14 | AP.Fischer | 234 | 40,142,644 |
| 15 | AP.Miller | 58 | 270,163 |
| 16 | AP.Hoffmann | 47 | 643,647 |
| 17 | AP.Zimmermann | 12 | 3,755 |
| 18 | AP.Braun | 7 | 395,007 |
| 19 | AP.Krause | 4 | 18,960 |


### Combined View
Objective: cross-reference processing time with volume and value to distinguish high-volume efficient processors from low-volume slow processors.

```SQL
WITH processing_times AS (
    SELECT
        user_name,
        ROUND(AVG(clearing_date - posting_date), 2) AS avg_processing_time
    FROM invoices_raw
    WHERE clearing_date IS NOT NULL AND posting_date IS NOT NULL
    GROUP BY user_name
), processing_amounts AS (
    SELECT
    user_name,
    COUNT(*) AS number_of_invoices,
    ROUND(SUM(amount_local_curr) / 1.27, 2) AS total_amount
FROM invoices_raw
GROUP BY user_name
)
select
    pt.user_name,
    pt.avg_processing_time,
    pa.number_of_invoices,
    pa.total_amount
from processing_times pt
join processing_amounts pa on pt.user_name = pa.user_name
order by pa.total_amount ASC
LIMIT 15;
```

**Results:**

| # | User | Avg. Processing Time (days) | Invoice Count | Total Amount (EUR) |
| --- | --- | --- | --- | --- |
| 1 | AP.Schmidt | 45.59 | 7,493 | 40,845,271 | high volume, slow |
| 2 | AP.Weber | 44.33 | 7,048 | 43,172,785 | high volume, slow |
| 3 | AP.Neumann | 25.66 | 1,299 | 49,356,513 | high value, moderate time |
| 4 | AP.Johnson | 48.78 | 7,029 | 37,979,099 | high volume, slow |
| 5 | AP.Schulz | 41.71 | 6,086 | 26,515,429 | high volume, slow |
| 6 | BATCH.AUTO | 33.78 | 2,835 | 19,464,858 | |
| 7 | AP.Wolf | 27.87 | 2,354 | 13,096,560 | |
| 8 | AP.Koch | 39.86 | 1,945 | 9,970,539 | |
| 9 | AP.Richter | 30.12 | 411 | 3,064,810 | |
| 10 | AP.Becker | 24.85 | 323 | 3,070,027 | |
| 11 | AP.Miller | 115.36 | 62 | 248,166 | low volume, very slow |
| 12 | AP.Hartmann | 6.51 | 1,944 | 177,372 | high volume, fast |
| 13 | AP.Wagner | 66.46 | 298 | 156,169 | low volume, very slow |
| 14 | AP.Krause | 0.61 | 4 | 16,672 | |
| 15 | AP.Zimmermann | 3.00 | 11 | 4,159 | |

>AP.Miller and AP.Wagner process very few invoices but have the highest average processing times (115 and 66 days). AP.Schmidt, AP.Weber, and AP.Johnson handle the largest volumes but average 44-49 days processing time, suggesting a systemic delay rather than individual performance issues. AP.Hartmann processes nearly 2,000 invoices at 6.5 days average, which is the benchmark for efficiency in this dataset.



## 5. Area of Analysis: Risk analysis
This section assesses supplier base risk across two dimensions: spend concentration among the top 20 suppliers, and payment term structure to identify cash flow risk, processing pressure, and discount capture opportunities.

### Spend Concentration
Objective: quantify the share of total spend controlled by the top 20 suppliers to assess dependency risk and identify where strategic sourcing efforts would have the highest leverage.

```SQL
WITH total_spend AS (
    SELECT SUM(amount_local_curr) AS total_year
    FROM invoices_raw
),
top_ten_spend AS (
    SELECT
        id,
        SUM(amount_local_curr) AS total_amount
    FROM invoices_raw
    GROUP BY id
    ORDER BY total_amount ASC
    LIMIT 20
)
SELECT
    ROUND((SUM(total_amount) / total_year) * 100, 2) AS top20_pct_of_total_spend
FROM top_ten_spend
CROSS JOIN total_spend
GROUP BY total_year;
```
**Results:**

| Metric | Value |
| --- | --- |
| Top 20 suppliers % of total spend | 42.92% |



### Payment Terms Distribution
Objective: map the distribution of payment terms across transactions to identify dominant term types, flag operationally demanding terms such as immediate payment, and assess the overall maturity of the payment terms portfolio.

```SQL
SELECT
    payment_terms.own_explanation,
    COUNT(invoices_raw.terms_of_payment) AS count_of_payment_terms
FROM invoices_raw
LEFT JOIN payment_terms ON invoices_raw.terms_of_payment = payment_terms.pay_terms
WHERE payment_terms.own_explanation IS NOT NULL
GROUP BY payment_terms.own_explanation
ORDER BY count_of_payment_terms DESC
LIMIT 20;
```

**Results:**

![Payment Terms Distribution](https://github.com/L-Davidlaszlo/Invoice-analysis-project---SQL/blob/main/Assets/top10_payment_terms.png?raw=true)

>Net 30 and Net 60 together account for the large majority of transactions. The presence of "Due immediately" as the 3rd largest term warrants review, as it puts pressure on AP processing speed. Only two terms in the top 20 carry a discount clause, indicating limited early payment discount utilization across the portfolio.

# Conclusions

## Key Findings

| # | Area | Finding |
| --- | --- | --- |
| 1 | Spend Concentration | Top 20 suppliers represent 41.8% of total annual spend (329M EUR). The top supplier alone accounts for 6.06% of total spend. |
| 2 | Invoice Processing | Three users (AP.Schmidt, AP.Weber, AP.Johnson) handle over 20,000 invoices collectively, each averaging 44-49 days processing time. |
| 3 | Late Payments | 20 suppliers show negative avg_delay, with the top 3 averaging 44 days late. No suppliers were identified as consistently paid early. |
| 4 | Payment Terms Fragmentation | 59 distinct payment term codes exist across the supplier base. Only 3 codes cover 48.8% of suppliers. |
| 5 | Discount Utilization | Only 2 of the top 20 payment terms carry a discount clause. Discount capture is occurring but is not systematically tracked. |
| 6 | Currency Exposure | 18.2% of spend is HUF-denominated and 2.2% USD-denominated, creating FX risk without evidence of hedging. |
| 7 | Spend Seasonality | July (12.0%) and September (10.4%) are peak spend months. August drops to 5.6%, indicating a seasonal shutdown effect. |

---

## Risk Summary

| Risk | Severity | Area |
| --- | --- | --- |
| Supplier dependency on top 5 (18.06% of spend) | High | Concentration |
| 20 suppliers receiving late payments | High | Payment discipline |
| AP.Miller processing at 132 days average | Medium | Invoice processing |
| 59 payment term codes, difficult to govern | Medium | Payment terms |
| HUF exposure without indexation review | Medium | FX risk |
| Low discount clause coverage in payment terms | Low | Savings |
| Single-user concentration: AP.Weber handles 7,535 invoices | Low | Operational risk |

---

## Savings Potential Estimate

| Opportunity | Basis | Estimated Annual Saving |
| --- | --- | --- |
| Early payment discount capture on eligible terms | 2-4% discount on transactions with discount-eligible terms currently not captured | 250,000 - 600,000 EUR |
| Payment terms consolidation (reduced admin cost) | Reduction from 59 to 8 standard codes, estimated 15 min saved per non-standard term invoice | 40,000 - 80,000 EUR |
| Strategic renegotiation with top 5 suppliers | 1-2% price reduction on 58M EUR combined spend through volume leverage | 580,000 - 1,160,000 EUR |
| FX hedging or HUF contract indexation | Reduce volatility on 47M EUR HUF spend; estimated 1-2% exposure mitigation | 470,000 - 940,000 EUR |

> **Total estimated savings range: 1,340,000 - 2,780,000 EUR per year.** These are conservative estimates based on industry benchmarks and the spend volumes identified in this analysis. Actual savings are subject to supplier negotiation outcomes and process change feasibility.

---

## Actionable Recommendations

| Priority | Recommendation | Owner | Effort |
| --- | --- | --- | --- |
| 1 | Initiate strategic review with top 5 suppliers; target volume-based price renegotiation | Strategic Sourcing | High |
| 2 | Investigate root cause of late payments for the 3 most delayed suppliers (avg 40+ days) | AP / Finance | Low |
| 3 | Consolidate payment term codes from 59 to a maximum of 8 standard codes | Procurement / ERP team | Medium |
| 4 | Implement systematic early payment discount tracking and capture process | AP / Treasury | Medium |
| 5 | Review HUF-denominated contracts for indexation clauses or hedging eligibility | Finance / Treasury | Medium |
| 6 | Address AP.Miller and AP.Wagner processing time outliers (115 and 66 days avg) | AP Manager | Low |
| 7 | Evaluate blanket order or framework agreement for Pinewood Process Industries (1,142 invoices at 496 EUR avg) | Procurement | Low |

---

## Next Steps / Roadmap

| Timeline | Action |
| --- | --- |
| 0-30 days | Pull full discount eligibility report; identify all transactions where discount window was available but not captured |
| 0-30 days | Schedule review meeting with AP manager on processing time outliers |
| 30-60 days | Begin payment term consolidation mapping; draft standard term framework |
| 30-90 days | Initiate supplier reviews with top 5 by spend; prepare negotiation briefs |
| 60-90 days | Review all HUF contracts above 1M EUR for indexation or hedging options |
| 90-180 days | Implement consolidated payment term structure in ERP |
| 90-180 days | Establish quarterly supplier performance scorecard based on metrics in this analysis |