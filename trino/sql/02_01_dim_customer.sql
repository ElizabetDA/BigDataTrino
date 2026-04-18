DROP TABLE IF EXISTS clickhouse.dwh.dim_customer;

CREATE TABLE clickhouse.dwh.dim_customer AS
WITH unified_source AS (
    SELECT
        to_utf8(CAST(sale_customer_id AS varchar)) AS sale_customer_id_bin,
        to_utf8(CAST(customer_first_name AS varchar)) AS customer_first_name_bin,
        to_utf8(CAST(customer_last_name AS varchar)) AS customer_last_name_bin,
        to_utf8(CAST(customer_email AS varchar)) AS customer_email_bin,
        to_utf8(CAST(customer_age AS varchar)) AS customer_age_bin,
        to_utf8(CAST(customer_country AS varchar)) AS customer_country_bin,
        to_utf8(CAST(customer_postal_code AS varchar)) AS customer_postal_code_bin,
        to_utf8(CAST(customer_pet_type AS varchar)) AS customer_pet_type_bin,
        to_utf8(CAST(customer_pet_name AS varchar)) AS customer_pet_name_bin,
        to_utf8(CAST(customer_pet_breed AS varchar)) AS customer_pet_breed_bin,
        to_utf8(CAST(pet_category AS varchar)) AS pet_category_bin
    FROM postgres.raw.mock_data

    UNION ALL

    SELECT
        sale_customer_id,
        customer_first_name,
        customer_last_name,
        customer_email,
        customer_age,
        customer_country,
        customer_postal_code,
        customer_pet_type,
        customer_pet_name,
        customer_pet_breed,
        pet_category
    FROM clickhouse.raw.mock_data
),
normalized AS (
    SELECT
        from_utf8(sale_customer_id_bin) AS sale_customer_id,
        from_utf8(customer_first_name_bin) AS customer_first_name,
        from_utf8(customer_last_name_bin) AS customer_last_name,
        from_utf8(customer_email_bin) AS customer_email,
        from_utf8(customer_age_bin) AS customer_age,
        from_utf8(customer_country_bin) AS customer_country,
        from_utf8(customer_postal_code_bin) AS customer_postal_code,
        from_utf8(customer_pet_type_bin) AS customer_pet_type,
        from_utf8(customer_pet_name_bin) AS customer_pet_name,
        from_utf8(customer_pet_breed_bin) AS customer_pet_breed,
        from_utf8(pet_category_bin) AS pet_category
    FROM unified_source
)
SELECT DISTINCT
    TRY_CAST(sale_customer_id AS bigint) AS customer_id,
    NULLIF(TRIM(customer_first_name), '') AS customer_first_name,
    NULLIF(TRIM(customer_last_name), '') AS customer_last_name,
    NULLIF(TRIM(customer_email), '') AS customer_email,
    TRY_CAST(customer_age AS integer) AS customer_age,
    NULLIF(TRIM(customer_country), '') AS customer_country,
    NULLIF(TRIM(customer_postal_code), '') AS customer_postal_code,
    NULLIF(TRIM(customer_pet_type), '') AS customer_pet_type,
    NULLIF(TRIM(customer_pet_name), '') AS customer_pet_name,
    NULLIF(TRIM(customer_pet_breed), '') AS customer_pet_breed,
    NULLIF(TRIM(pet_category), '') AS pet_category
FROM normalized
WHERE TRY_CAST(sale_customer_id AS bigint) IS NOT NULL;
