DROP TABLE IF EXISTS clickhouse.dwh.dim_supplier;

CREATE TABLE clickhouse.dwh.dim_supplier AS
WITH unified_source AS (
    SELECT
        to_utf8(CAST(supplier_name AS varchar)) AS supplier_name_bin,
        to_utf8(CAST(supplier_contact AS varchar)) AS supplier_contact_bin,
        to_utf8(CAST(supplier_email AS varchar)) AS supplier_email_bin,
        to_utf8(CAST(supplier_phone AS varchar)) AS supplier_phone_bin,
        to_utf8(CAST(supplier_address AS varchar)) AS supplier_address_bin,
        to_utf8(CAST(supplier_city AS varchar)) AS supplier_city_bin,
        to_utf8(CAST(supplier_country AS varchar)) AS supplier_country_bin
    FROM postgres.raw.mock_data

    UNION ALL

    SELECT
        supplier_name,
        supplier_contact,
        supplier_email,
        supplier_phone,
        supplier_address,
        supplier_city,
        supplier_country
    FROM clickhouse.raw.mock_data
),
normalized AS (
    SELECT
        from_utf8(supplier_name_bin) AS supplier_name,
        from_utf8(supplier_contact_bin) AS supplier_contact,
        from_utf8(supplier_email_bin) AS supplier_email,
        from_utf8(supplier_phone_bin) AS supplier_phone,
        from_utf8(supplier_address_bin) AS supplier_address,
        from_utf8(supplier_city_bin) AS supplier_city,
        from_utf8(supplier_country_bin) AS supplier_country
    FROM unified_source
),
suppliers AS (
    SELECT DISTINCT
        NULLIF(TRIM(supplier_name), '') AS supplier_name,
        NULLIF(TRIM(supplier_contact), '') AS supplier_contact,
        NULLIF(TRIM(supplier_email), '') AS supplier_email,
        NULLIF(TRIM(supplier_phone), '') AS supplier_phone,
        NULLIF(TRIM(supplier_address), '') AS supplier_address,
        NULLIF(TRIM(supplier_city), '') AS supplier_city,
        NULLIF(TRIM(supplier_country), '') AS supplier_country
    FROM normalized
)
SELECT
    ROW_NUMBER() OVER (ORDER BY supplier_name, supplier_email, supplier_phone) AS supplier_id,
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM suppliers;
