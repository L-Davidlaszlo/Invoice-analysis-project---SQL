-- 1. Fizetési feltételek
CREATE TABLE payment_terms (
    pay_terms       VARCHAR(255) NOT NULL PRIMARY KEY,
    own_explanation VARCHAR(255)
);

-- 2. Szállítói törzs
CREATE TABLE suppliers (
    supplier_code    BIGINT       NOT NULL PRIMARY KEY,
    supplier_name    VARCHAR(255) NOT NULL,
    name_2           VARCHAR(255),
    email_address    VARCHAR(255),
    pay_terms        VARCHAR(255) REFERENCES payment_terms(pay_terms),
    inco_terms       VARCHAR(255),
    purchasing_group VARCHAR(255),
    created_on       DATE
);

-- 3. Számlák (nyers)
CREATE TABLE invoices_raw (
    id                  INT          NOT NULL PRIMARY KEY,
    user_name           VARCHAR(50),
    reference           VARCHAR(255),
    account             BIGINT,
    posting_date        DATE,
    document_date       DATE,
    entry_date          DATE,
    net_due_date        DATE,
    document_number     BIGINT,
    amount_doc_curr     DECIMAL(18,2),
    document_currency   CHAR(3),
    amount_local_curr   DECIMAL(18,2),
    local_currency      CHAR(3),
    terms_of_payment    VARCHAR(255) REFERENCES payment_terms(pay_terms),
    text                VARCHAR(500),
    fiscal_year         SMALLINT,
    eff_exchange_rate   DECIMAL(10,5),
    clearing_date       DATE,
    year_month          VARCHAR(255),
    invoice_reference   VARCHAR(255),
    payment_date        DATE
);