SET datestyle = 'MDY';

-- Date dimension
INSERT INTO dw.dim_date (date_key, full_date, year, quarter, month, day)
SELECT DISTINCT
  (EXTRACT(YEAR FROM sale_date)::int * 10000
    + EXTRACT(MONTH FROM sale_date)::int * 100
    + EXTRACT(DAY FROM sale_date)::int) AS date_key,
  sale_date AS full_date,
  EXTRACT(YEAR FROM sale_date)::int AS year,
  EXTRACT(QUARTER FROM sale_date)::int AS quarter,
  EXTRACT(MONTH FROM sale_date)::int AS month,
  EXTRACT(DAY FROM sale_date)::int AS day
FROM stage.mock_data
WHERE sale_date IS NOT NULL
ON CONFLICT (date_key) DO NOTHING;

-- Customer dimension
INSERT INTO dw.dim_customer (
  customer_id, first_name, last_name, age, email, country, postal_code,
  pet_type, pet_name, pet_breed
)
SELECT DISTINCT
  sale_customer_id,
  customer_first_name,
  customer_last_name,
  customer_age,
  customer_email,
  customer_country,
  customer_postal_code,
  customer_pet_type,
  customer_pet_name,
  customer_pet_breed
FROM stage.mock_data
WHERE sale_customer_id IS NOT NULL
ON CONFLICT (customer_id) DO NOTHING;

-- Seller dimension
INSERT INTO dw.dim_seller (seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT
  sale_seller_id,
  seller_first_name,
  seller_last_name,
  seller_email,
  seller_country,
  seller_postal_code
FROM stage.mock_data
WHERE sale_seller_id IS NOT NULL
ON CONFLICT (seller_id) DO NOTHING;

-- Product dimension
INSERT INTO dw.dim_product (
  product_id, name, category, pet_category, price, quantity_in_source,
  weight, color, size, brand, material, description, rating, reviews,
  release_date, expiry_date
)
SELECT DISTINCT
  sale_product_id,
  product_name,
  product_category,
  pet_category,
  product_price,
  product_quantity,
  product_weight,
  product_color,
  product_size,
  product_brand,
  product_material,
  product_description,
  product_rating,
  product_reviews,
  product_release_date,
  product_expiry_date
FROM stage.mock_data
WHERE sale_product_id IS NOT NULL
ON CONFLICT (product_id) DO NOTHING;

-- Store dimension (surrogate key)
INSERT INTO dw.dim_store (name, location, city, state, country, phone, email)
SELECT DISTINCT
  store_name, store_location, store_city, store_state, store_country, store_phone, store_email
FROM stage.mock_data
WHERE store_name IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_dim_store DO NOTHING;

-- Supplier dimension (surrogate key)
INSERT INTO dw.dim_supplier (name, contact, email, phone, address, city, country)
SELECT DISTINCT
  supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country
FROM stage.mock_data
WHERE supplier_name IS NOT NULL
ON CONFLICT ON CONSTRAINT uq_dim_supplier DO NOTHING;

-- Fact table
INSERT INTO dw.fact_sales (
  sale_id, date_key, customer_id, seller_id, product_id, store_key, supplier_key,
  sale_quantity, total_price
)
SELECT
  m.id AS sale_id,
  (EXTRACT(YEAR FROM m.sale_date)::int * 10000
    + EXTRACT(MONTH FROM m.sale_date)::int * 100
    + EXTRACT(DAY FROM m.sale_date)::int) AS date_key,
  m.sale_customer_id,
  m.sale_seller_id,
  m.sale_product_id,
  st.store_key,
  sp.supplier_key,
  m.sale_quantity,
  m.sale_total_price
FROM stage.mock_data m
JOIN dw.dim_store st
  ON st.name IS NOT DISTINCT FROM m.store_name
 AND st.location IS NOT DISTINCT FROM m.store_location
 AND st.city IS NOT DISTINCT FROM m.store_city
 AND st.state IS NOT DISTINCT FROM m.store_state
 AND st.country IS NOT DISTINCT FROM m.store_country
 AND st.phone IS NOT DISTINCT FROM m.store_phone
 AND st.email IS NOT DISTINCT FROM m.store_email
JOIN dw.dim_supplier sp
  ON sp.name IS NOT DISTINCT FROM m.supplier_name
 AND sp.contact IS NOT DISTINCT FROM m.supplier_contact
 AND sp.email IS NOT DISTINCT FROM m.supplier_email
 AND sp.phone IS NOT DISTINCT FROM m.supplier_phone
 AND sp.address IS NOT DISTINCT FROM m.supplier_address
 AND sp.city IS NOT DISTINCT FROM m.supplier_city
 AND sp.country IS NOT DISTINCT FROM m.supplier_country
WHERE m.id IS NOT NULL
ON CONFLICT (sale_id) DO NOTHING;

-- Result checks
DO $$
DECLARE
  n_fact bigint;
BEGIN
  SELECT COUNT(*) INTO n_fact FROM dw.fact_sales;
  RAISE NOTICE 'dw.fact_sales rowcount = %', n_fact;
END $$;
