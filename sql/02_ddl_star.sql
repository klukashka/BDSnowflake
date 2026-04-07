CREATE SCHEMA IF NOT EXISTS dw;

-- Dimensions

DROP TABLE IF EXISTS dw.dim_date CASCADE;
CREATE TABLE dw.dim_date (
  date_key    integer PRIMARY KEY, -- YYYYMMDD
  full_date   date UNIQUE NOT NULL,
  year        integer NOT NULL,
  quarter     integer NOT NULL,
  month       integer NOT NULL,
  day         integer NOT NULL
);

DROP TABLE IF EXISTS dw.dim_customer CASCADE;
CREATE TABLE dw.dim_customer (
  customer_id         integer PRIMARY KEY,
  first_name          text,
  last_name           text,
  age                 integer,
  email               text,
  country             text,
  postal_code         text,
  pet_type            text,
  pet_name            text,
  pet_breed           text
);

DROP TABLE IF EXISTS dw.dim_seller CASCADE;
CREATE TABLE dw.dim_seller (
  seller_id           integer PRIMARY KEY,
  first_name          text,
  last_name           text,
  email               text,
  country             text,
  postal_code         text
);

DROP TABLE IF EXISTS dw.dim_product CASCADE;
CREATE TABLE dw.dim_product (
  product_id          integer PRIMARY KEY,
  name                text,
  category            text,
  pet_category        text,
  price               numeric(12,2),
  quantity_in_source  integer,
  weight              numeric(12,2),
  color               text,
  size                text,
  brand               text,
  material            text,
  description         text,
  rating              numeric(4,2),
  reviews             integer,
  release_date        date,
  expiry_date         date
);

DROP TABLE IF EXISTS dw.dim_store CASCADE;
CREATE TABLE dw.dim_store (
  store_key      bigserial PRIMARY KEY,
  name           text NOT NULL,
  location       text,
  city           text,
  state          text,
  country        text,
  phone          text,
  email          text,
  CONSTRAINT uq_dim_store UNIQUE (name, location, city, state, country, phone, email)
);

DROP TABLE IF EXISTS dw.dim_supplier CASCADE;
CREATE TABLE dw.dim_supplier (
  supplier_key   bigserial PRIMARY KEY,
  name           text NOT NULL,
  contact        text,
  email          text,
  phone          text,
  address        text,
  city           text,
  country        text,
  CONSTRAINT uq_dim_supplier UNIQUE (name, contact, email, phone, address, city, country)
);

-- Fact

DROP TABLE IF EXISTS dw.fact_sales;
CREATE TABLE dw.fact_sales (
  sale_id         integer PRIMARY KEY, -- from source row id
  date_key        integer NOT NULL REFERENCES dw.dim_date(date_key),
  customer_id     integer NOT NULL REFERENCES dw.dim_customer(customer_id),
  seller_id       integer NOT NULL REFERENCES dw.dim_seller(seller_id),
  product_id      integer NOT NULL REFERENCES dw.dim_product(product_id),
  store_key       bigint  NOT NULL REFERENCES dw.dim_store(store_key),
  supplier_key    bigint  NOT NULL REFERENCES dw.dim_supplier(supplier_key),
  sale_quantity   integer,
  total_price     numeric(12,2)
);

CREATE INDEX IF NOT EXISTS ix_fact_sales_date_key ON dw.fact_sales(date_key);
CREATE INDEX IF NOT EXISTS ix_fact_sales_customer ON dw.fact_sales(customer_id);
CREATE INDEX IF NOT EXISTS ix_fact_sales_product ON dw.fact_sales(product_id);
