/*
Fizetési feltételek elemzése

Átlagos fizetési határidő szállítónként (terms_of_payment alapján)
Késedelmes fizetések: net_due_date vs payment_date összehasonlítása
DPO (Days Payable Outstanding) kalkuláció szállítónként
Korai fizetési kedvezmények kihasználtsága (a payment_terms táblában látható a discount %)
*/

--Késedelmes fizetések: net_due_date vs payment_date összehasonlítása

SELECT
    suppliers.supplier_name,
    Round(AVG(payment_date - net_due_date), 2) AS avg_delay
FROM invoices_raw
LEFT JOIN suppliers on invoices_raw.account = suppliers.supplier_code
WHERE payment_date IS NOT NULL AND net_due_date IS NOT NULL AND supplier_name IS NOT NULL
GROUP BY account, suppliers.supplier_name
ORDER BY avg_delay ASC




--Korai fizetési kedvezmények kihasználtsága (a payment_terms táblában látható a discount %)
With payment_discount AS (
select*
from payment_terms
where own_explanation like '%discount%'
), payment_amount AS (
Select
    clearing_date - posting_date AS payment_delay,
    terms_of_payment,
    sum(amount_local_curr) as total_amount
from invoices_raw
group by terms_of_payment,posting_date, clearing_date
order by total_amount desc
)

select
    payment_amount.terms_of_payment,
    payment_amount.total_amount,
    payment_discount.own_explanation,
    payment_amount.payment_delay
from payment_amount
inner join payment_discount on payment_amount.terms_of_payment = payment_discount.pay_terms
order by payment_amount.payment_delay desc


--itt

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