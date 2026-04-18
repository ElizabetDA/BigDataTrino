DROP TABLE IF EXISTS clickhouse.report.product_quality;

CREATE TABLE clickhouse.report.product_quality AS
WITH products AS (
    SELECT
        product_id,
        from_utf8(product_name) AS product_name,
        product_rating,
        product_reviews
    FROM clickhouse.dwh.dim_product
)
SELECT
    p.product_id,
    p.product_name,
    AVG(p.product_rating) AS avg_rating,
    SUM(COALESCE(p.product_reviews, 0)) AS total_reviews,
    SUM(f.sale_quantity) AS total_quantity_sold,
    SUM(f.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales f
JOIN products p
    ON f.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name;
