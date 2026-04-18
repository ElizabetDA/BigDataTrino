DROP TABLE IF EXISTS clickhouse.dwh.fact_sales;

CREATE TABLE clickhouse.dwh.fact_sales AS
WITH unified_source AS (
    SELECT
        to_utf8(CAST(id AS varchar)) AS id_bin,
        to_utf8(CAST(sale_date AS varchar)) AS sale_date_bin,
        to_utf8(CAST(sale_customer_id AS varchar)) AS sale_customer_id_bin,
        to_utf8(CAST(sale_product_id AS varchar)) AS sale_product_id_bin,
        to_utf8(CAST(sale_seller_id AS varchar)) AS sale_seller_id_bin,
        to_utf8(CAST(seller_first_name AS varchar)) AS seller_first_name_bin,
        to_utf8(CAST(seller_last_name AS varchar)) AS seller_last_name_bin,
        to_utf8(CAST(seller_email AS varchar)) AS seller_email_bin,
        to_utf8(CAST(seller_country AS varchar)) AS seller_country_bin,
        to_utf8(CAST(sale_quantity AS varchar)) AS sale_quantity_bin,
        to_utf8(CAST(product_price AS varchar)) AS product_price_bin,
        to_utf8(CAST(sale_total_price AS varchar)) AS sale_total_price_bin,
        to_utf8(CAST(store_name AS varchar)) AS store_name_bin,
        to_utf8(CAST(store_email AS varchar)) AS store_email_bin,
        to_utf8(CAST(store_phone AS varchar)) AS store_phone_bin,
        to_utf8(CAST(supplier_name AS varchar)) AS supplier_name_bin,
        to_utf8(CAST(supplier_email AS varchar)) AS supplier_email_bin,
        to_utf8(CAST(supplier_phone AS varchar)) AS supplier_phone_bin
    FROM postgres.raw.mock_data

    UNION ALL

    SELECT
        id,
        sale_date,
        sale_customer_id,
        sale_product_id,
        sale_seller_id,
        seller_first_name,
        seller_last_name,
        seller_email,
        seller_country,
        sale_quantity,
        product_price,
        sale_total_price,
        store_name,
        store_email,
        store_phone,
        supplier_name,
        supplier_email,
        supplier_phone
    FROM clickhouse.raw.mock_data
),
normalized AS (
    SELECT
        from_utf8(id_bin) AS id,
        from_utf8(sale_date_bin) AS sale_date,
        from_utf8(sale_customer_id_bin) AS sale_customer_id,
        from_utf8(sale_product_id_bin) AS sale_product_id,
        from_utf8(sale_seller_id_bin) AS sale_seller_id,
        from_utf8(seller_first_name_bin) AS seller_first_name,
        from_utf8(seller_last_name_bin) AS seller_last_name,
        from_utf8(seller_email_bin) AS seller_email,
        from_utf8(seller_country_bin) AS seller_country,
        from_utf8(sale_quantity_bin) AS sale_quantity,
        from_utf8(product_price_bin) AS product_price,
        from_utf8(sale_total_price_bin) AS sale_total_price,
        from_utf8(store_name_bin) AS store_name,
        from_utf8(store_email_bin) AS store_email,
        from_utf8(store_phone_bin) AS store_phone,
        from_utf8(supplier_name_bin) AS supplier_name,
        from_utf8(supplier_email_bin) AS supplier_email,
        from_utf8(supplier_phone_bin) AS supplier_phone
    FROM unified_source
),
store_map AS (
    SELECT
        store_id,
        from_utf8(store_name) AS store_name,
        from_utf8(store_location) AS store_location,
        from_utf8(store_city) AS store_city,
        from_utf8(store_state) AS store_state,
        from_utf8(store_country) AS store_country,
        from_utf8(store_phone) AS store_phone,
        from_utf8(store_email) AS store_email
    FROM clickhouse.dwh.dim_store
),
supplier_map AS (
    SELECT
        supplier_id,
        from_utf8(supplier_name) AS supplier_name,
        from_utf8(supplier_contact) AS supplier_contact,
        from_utf8(supplier_email) AS supplier_email,
        from_utf8(supplier_phone) AS supplier_phone,
        from_utf8(supplier_address) AS supplier_address,
        from_utf8(supplier_city) AS supplier_city,
        from_utf8(supplier_country) AS supplier_country
    FROM clickhouse.dwh.dim_supplier
)
SELECT
    TRY_CAST(n.id AS bigint) AS fact_id,
    TRY_CAST(n.id AS bigint) AS order_id,
    CAST(date_format(TRY(CAST(date_parse(n.sale_date, '%c/%e/%Y') AS date)), '%Y%m%d') AS bigint) AS date_id,
    TRY_CAST(n.sale_customer_id AS bigint) AS customer_id,
    TRY_CAST(n.sale_product_id AS bigint) AS product_id,
    s.store_id AS store_id,
    sup.supplier_id AS supplier_id,
    TRY_CAST(n.sale_seller_id AS bigint) AS seller_id,
    NULLIF(TRIM(n.seller_first_name), '') AS seller_first_name,
    NULLIF(TRIM(n.seller_last_name), '') AS seller_last_name,
    NULLIF(TRIM(n.seller_email), '') AS seller_email,
    NULLIF(TRIM(n.seller_country), '') AS seller_country,
    TRY_CAST(n.sale_quantity AS integer) AS sale_quantity,
    TRY_CAST(n.product_price AS double) AS unit_price,
    TRY_CAST(n.sale_total_price AS double) AS sale_total_price
FROM normalized n
LEFT JOIN store_map s
    ON COALESCE(NULLIF(TRIM(n.store_name), ''), '') = COALESCE(NULLIF(TRIM(s.store_name), ''), '')
   AND COALESCE(NULLIF(TRIM(n.store_email), ''), '') = COALESCE(NULLIF(TRIM(s.store_email), ''), '')
   AND COALESCE(NULLIF(TRIM(n.store_phone), ''), '') = COALESCE(NULLIF(TRIM(s.store_phone), ''), '')
LEFT JOIN supplier_map sup
    ON COALESCE(NULLIF(TRIM(n.supplier_name), ''), '') = COALESCE(NULLIF(TRIM(sup.supplier_name), ''), '')
   AND COALESCE(NULLIF(TRIM(n.supplier_email), ''), '') = COALESCE(NULLIF(TRIM(sup.supplier_email), ''), '')
   AND COALESCE(NULLIF(TRIM(n.supplier_phone), ''), '') = COALESCE(NULLIF(TRIM(sup.supplier_phone), ''), '')
WHERE TRY_CAST(n.id AS bigint) IS NOT NULL;
