SELECT
    suppliers.supplier_name,
    count(account) AS count_of_accounts,
    account
FROM invoices_raw
LEFT JOIN suppliers ON invoices_raw.account = suppliers.supplier_code
GROUP BY account, suppliers.supplier_name
ORDER BY count_of_accounts DESC

