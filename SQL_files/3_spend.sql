/*

Spend analízis

Havi spend trend évenkénti összehasonlítással
Spend megoszlása devizánként (document_currency)

*/

--Havi spend trend

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

--Spend megoszlása devizánként
SELECT
    document_currency,
    SUM(amount_local_curr) AS total_amount
FROM invoices_raw
GROUP BY document_currency
ORDER BY total_amount DESC;

