/*
Top 20 szállító spend alapján OK
Szállítónkénti számla darabszám és átlagos számlaérték
Szállítók fizetési feltétel szerinti megoszlása
*/




--TOP 20 suppliers by total amount of invoices
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



--Total amount of invoices for the year
select
    SUM(amount_local_curr) as total_year
From invoices_raw
Order by total_year DESC


--Szállítónkénti számla darabszám és átlagos számlaérték

SELECT
    suppliers.supplier_name,
    COUNT(invoices_raw.account)         AS count_of_invoices,
    ROUND(AVG(amount_local_curr), 2)    AS average_invoice_amount
FROM invoices_raw
INNER JOIN suppliers
    ON suppliers.supplier_code = invoices_raw.account
GROUP BY invoices_raw.account, suppliers.supplier_name
ORDER BY count_of_invoices DESC
LIMIT 20;

--Szállítók fizetési feltétel szerinti megoszlása
SELECT
    terms_of_payment,
    COUNT(DISTINCT account) AS number_of_suppliers
FROM invoices_raw
WHERE terms_of_payment IS NOT NULL
GROUP BY terms_of_payment
ORDER BY number_of_suppliers DESC
