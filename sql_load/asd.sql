CREATE TEMP TABLE invoices_tmp (
    id                  VARCHAR(50),
    user_name           VARCHAR(50),
    reference           VARCHAR(255),
    account             VARCHAR(50),
    posting_date        VARCHAR(50),
    document_date       VARCHAR(50),
    entry_date          VARCHAR(50),
    net_due_date        VARCHAR(50),
    document_number     VARCHAR(50),
    amount_doc_curr     VARCHAR(50),
    document_currency   VARCHAR(10),
    amount_local_curr   VARCHAR(50),
    local_currency      VARCHAR(10),
    terms_of_payment    VARCHAR(255),
    text                VARCHAR(500),
    fiscal_year         VARCHAR(10),
    eff_exchange_rate   VARCHAR(50),
    clearing_date       VARCHAR(50),
    year_month          VARCHAR(255),
    invoice_reference   VARCHAR(255),
    payment_date        VARCHAR(50)
);

COPY invoices_tmp
FROM 'C:\Users\laszl\Desktop\Projects\Invoice analysis project\csv_files\invoices_raw.csv'
DELIMITER ';' CSV HEADER;

INSERT INTO invoices_raw
SELECT
    id::INT,
    user_name,
    reference,
    account::BIGINT,
    posting_date::DATE,
    document_date::DATE,
    entry_date::DATE,
    net_due_date::DATE,
    document_number::BIGINT,
    REPLACE(REPLACE(amount_doc_curr, ' ', ''), ',', '.')::DECIMAL(18,2),
    document_currency,
    REPLACE(REPLACE(amount_local_curr, ' ', ''), ',', '.')::DECIMAL(18,2),
    local_currency,
    terms_of_payment,
    text,
    fiscal_year::SMALLINT,
    REPLACE(REPLACE(eff_exchange_rate, ' ', ''), ',', '.')::DECIMAL(10,5),
    clearing_date::DATE,
    year_month,
    invoice_reference,
    payment_date::DATE
FROM invoices_tmp;

DROP TABLE invoices_tmp;

ALTER TABLE invoices_raw
DROP CONSTRAINT invoices_raw_terms_of_payment_fkey;