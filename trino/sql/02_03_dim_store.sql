DROP TABLE IF EXISTS clickhouse.dwh.dim_store;

CREATE TABLE clickhouse.dwh.dim_store AS
WITH unified_source AS (
    SELECT
        to_utf8(CAST(store_name AS varchar)) AS store_name_bin,
        to_utf8(CAST(store_location AS varchar)) AS store_location_bin,
        to_utf8(CAST(store_city AS varchar)) AS store_city_bin,
        to_utf8(CAST(store_state AS varchar)) AS store_state_bin,
        to_utf8(CAST(store_country AS varchar)) AS store_country_bin,
        to_utf8(CAST(store_phone AS varchar)) AS store_phone_bin,
        to_utf8(CAST(store_email AS varchar)) AS store_email_bin
    FROM postgres.raw.mock_data

    UNION ALL

    SELECT
        store_name,
        store_location,
        store_city,
        store_state,
        store_country,
        store_phone,
        store_email
    FROM clickhouse.raw.mock_data
),
normalized AS (
    SELECT
        from_utf8(store_name_bin) AS store_name,
        from_utf8(store_location_bin) AS store_location,
        from_utf8(store_city_bin) AS store_city,
        from_utf8(store_state_bin) AS store_state,
        from_utf8(store_country_bin) AS store_country,
        from_utf8(store_phone_bin) AS store_phone,
        from_utf8(store_email_bin) AS store_email
    FROM unified_source
),
stores AS (
    SELECT DISTINCT
        NULLIF(TRIM(store_name), '') AS store_name,
        NULLIF(TRIM(store_location), '') AS store_location,
        NULLIF(TRIM(store_city), '') AS store_city,
        NULLIF(TRIM(store_state), '') AS store_state,
        NULLIF(TRIM(store_country), '') AS store_country,
        NULLIF(TRIM(store_phone), '') AS store_phone,
        NULLIF(TRIM(store_email), '') AS store_email
    FROM normalized
)
SELECT
    ROW_NUMBER() OVER (ORDER BY store_name, store_email, store_phone) AS store_id,
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM stores;
