DROP TABLE IF EXISTS clickhouse.report.sales_stores;

CREATE TABLE clickhouse.report.sales_stores AS
WITH stores AS (
    SELECT
        store_id,
        from_utf8(store_name) AS store_name,
        from_utf8(store_city) AS store_city,
        from_utf8(store_country) AS store_country
    FROM clickhouse.dwh.dim_store
)
SELECT
    s.store_id,
    s.store_name,
    s.store_city,
    s.store_country,
    SUM(f.sale_total_price) AS total_revenue,
    COUNT(DISTINCT f.order_id) AS orders_count,
    AVG(f.sale_total_price) AS avg_check,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sale_total_price) DESC) AS store_rank_by_revenue
FROM clickhouse.dwh.fact_sales f
JOIN stores s
    ON f.store_id = s.store_id
GROUP BY
    s.store_id,
    s.store_name,
    s.store_city,
    s.store_country;
