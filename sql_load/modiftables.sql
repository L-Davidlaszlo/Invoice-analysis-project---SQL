COPY payment_terms
FROM 'C:\Users\laszl\Desktop\Projects\Invoice analysis project\csv_files\PaymentTerms.csv'
DELIMITER ';' CSV HEADER;

COPY suppliers (supplier_code, supplier_name, name_2, email_address, pay_terms, inco_terms, purchasing_group, created_on)
FROM 'C:\Users\laszl\Desktop\Projects\Invoice analysis project\csv_files\Suppliers_Master.csv'
DELIMITER ';' CSV HEADER;

COPY invoices_raw
FROM 'C:\Users\laszl\Desktop\Projects\Invoice analysis project\csv_files\invoices_raw.csv'
DELIMITER ';' CSV HEADER;