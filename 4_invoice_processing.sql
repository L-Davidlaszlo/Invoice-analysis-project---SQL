/* 
Átlagos feldolgozási idő: document_date és posting_date különbsége
Felhasználónkénti (user_name) feldolgozott számlák száma és értéke
*/


-- Átlagos feldolgozási idő: document_date és posting_date különbsége
SELECT
    user_name,
    ROUND(AVG(clearing_date - posting_date), 2) AS avg_processing_time
FROM invoices_raw
WHERE clearing_date IS NOT NULL AND posting_date IS NOT NULL
GROUP BY user_name
ORDER BY avg_processing_time DESC;



-- Felhasználónkénti (user_name) feldolgozott számlák száma és értéke
SELECT
    user_name,
    COUNT(*) AS number_of_invoices,
    ROUND(SUM(amount_local_curr) / 1.27, 2) AS total_amount
FROM invoices_raw
GROUP BY user_name
ORDER BY number_of_invoices DESC;


--Kombinált lekérdezés: Átlagos feldolgozási idő, számlák száma és értéke felhasználónként
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


