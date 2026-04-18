DROP TABLE IF EXISTS clickhouse.dwh.dim_product;

CREATE TABLE clickhouse.dwh.dim_product AS
WITH unified_source AS (
    SELECT
        to_utf8(CAST(sale_product_id AS varchar)) AS sale_product_id_bin,
        to_utf8(CAST(product_name AS varchar)) AS product_name_bin,
        to_utf8(CAST(product_category AS varchar)) AS product_category_bin,
        to_utf8(CAST(product_price AS varchar)) AS product_price_bin,
        to_utf8(CAST(product_quantity AS varchar)) AS product_quantity_bin,
        to_utf8(CAST(product_weight AS varchar)) AS product_weight_bin,
        to_utf8(CAST(product_color AS varchar)) AS product_color_bin,
        to_utf8(CAST(product_size AS varchar)) AS product_size_bin,
        to_utf8(CAST(product_brand AS varchar)) AS product_brand_bin,
        to_utf8(CAST(product_material AS varchar)) AS product_material_bin,
        to_utf8(CAST(product_description AS varchar)) AS product_description_bin,
        to_utf8(CAST(product_rating AS varchar)) AS product_rating_bin,
        to_utf8(CAST(product_reviews AS varchar)) AS product_reviews_bin,
        to_utf8(CAST(product_release_date AS varchar)) AS product_release_date_bin,
        to_utf8(CAST(product_expiry_date AS varchar)) AS product_expiry_date_bin
    FROM postgres.raw.mock_data

    UNION ALL

    SELECT
        sale_product_id,
        product_name,
        product_category,
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
    FROM clickhouse.raw.mock_data
),
normalized AS (
    SELECT
        from_utf8(sale_product_id_bin) AS sale_product_id,
        from_utf8(product_name_bin) AS product_name,
        from_utf8(product_category_bin) AS product_category,
        from_utf8(product_price_bin) AS product_price,
        from_utf8(product_quantity_bin) AS product_quantity,
        from_utf8(product_weight_bin) AS product_weight,
        from_utf8(product_color_bin) AS product_color,
        from_utf8(product_size_bin) AS product_size,
        from_utf8(product_brand_bin) AS product_brand,
        from_utf8(product_material_bin) AS product_material,
        from_utf8(product_description_bin) AS product_description,
        from_utf8(product_rating_bin) AS product_rating,
        from_utf8(product_reviews_bin) AS product_reviews,
        from_utf8(product_release_date_bin) AS product_release_date,
        from_utf8(product_expiry_date_bin) AS product_expiry_date
    FROM unified_source
)
SELECT DISTINCT
    TRY_CAST(sale_product_id AS bigint) AS product_id,
    NULLIF(TRIM(product_name), '') AS product_name,
    NULLIF(TRIM(product_category), '') AS product_category,
    TRY_CAST(product_price AS double) AS product_price,
    TRY_CAST(product_quantity AS integer) AS product_quantity,
    TRY_CAST(product_weight AS double) AS product_weight,
    NULLIF(TRIM(product_color), '') AS product_color,
    NULLIF(TRIM(product_size), '') AS product_size,
    NULLIF(TRIM(product_brand), '') AS product_brand,
    NULLIF(TRIM(product_material), '') AS product_material,
    NULLIF(TRIM(product_description), '') AS product_description,
    TRY_CAST(product_rating AS double) AS product_rating,
    TRY_CAST(product_reviews AS integer) AS product_reviews,
    TRY(CAST(date_parse(product_release_date, '%c/%e/%Y') AS date)) AS product_release_date,
    TRY(CAST(date_parse(product_expiry_date, '%c/%e/%Y') AS date)) AS product_expiry_date
FROM normalized
WHERE TRY_CAST(sale_product_id AS bigint) IS NOT NULL;
