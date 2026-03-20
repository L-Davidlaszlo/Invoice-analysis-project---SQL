/*

Koncentráció és kockázat

Spend koncentráció: top 20 szállító az összes spend hány százalékát teszi ki
Incoterms szerinti megoszlás (szállítási kockázat)

*/

--Spend koncentráció: top 20 szállító az összes spend hány százalékát teszi ki

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


--Incoterms szerinti megoszlás (szállítási kockázat)

SELECT
    payment_terms.own_explanation,
    COUNT(invoices_raw.terms_of_payment) AS count_of_payment_terms
FROM invoices_raw
LEFT JOIN payment_terms ON invoices_raw.terms_of_payment = payment_terms.pay_terms
WHERE payment_terms.own_explanation IS NOT NULL
GROUP BY payment_terms.own_explanation
ORDER BY count_of_payment_terms DESC
LIMIT 20;