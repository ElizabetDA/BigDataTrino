DROP TABLE IF EXISTS clickhouse.report.sales_products;

CREATE TABLE clickhouse.report.sales_products AS
WITH products AS (
    SELECT
        product_id,
        from_utf8(product_name) AS product_name,
        from_utf8(product_category) AS product_category,
        from_utf8(product_brand) AS product_brand,
        product_rating,
        product_reviews
    FROM clickhouse.dwh.dim_product
),
agg AS (
    SELECT
        COALESCE(NULLIF(TRIM(p.product_name), ''), 'UNKNOWN') AS product_name,
        COALESCE(NULLIF(TRIM(p.product_category), ''), 'UNKNOWN') AS product_category,
        COALESCE(NULLIF(TRIM(p.product_brand), ''), 'UNKNOWN') AS product_brand,
        SUM(f.sale_total_price) AS total_revenue,
        SUM(f.sale_quantity) AS total_quantity_sold,
        COUNT(*) AS sales_count,
        AVG(p.product_rating) AS avg_rating,
        SUM(COALESCE(p.product_reviews, 0)) AS total_reviews
    FROM clickhouse.dwh.fact_sales f
    JOIN products p
        ON f.product_id = p.product_id
    GROUP BY
        COALESCE(NULLIF(TRIM(p.product_name), ''), 'UNKNOWN'),
        COALESCE(NULLIF(TRIM(p.product_category), ''), 'UNKNOWN'),
        COALESCE(NULLIF(TRIM(p.product_brand), ''), 'UNKNOWN')
)
SELECT
    product_name,
    product_category,
    product_brand,
    total_revenue,
    total_quantity_sold,
    sales_count,
    avg_rating,
    total_reviews,
    ROW_NUMBER() OVER (ORDER BY total_quantity_sold DESC) AS product_rank_by_quantity,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY total_quantity_sold DESC) <= 10 THEN true ELSE false END AS is_top_10_by_quantity
FROM agg;
