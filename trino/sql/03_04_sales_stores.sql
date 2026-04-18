DROP TABLE IF EXISTS clickhouse.report.sales_stores;

CREATE TABLE clickhouse.report.sales_stores AS
WITH stores AS (
    SELECT
        store_id,
        from_utf8(store_name) AS store_name,
        from_utf8(store_city) AS store_city,
        from_utf8(store_country) AS store_country
    FROM clickhouse.dwh.dim_store
),
agg AS (
    SELECT
        COALESCE(NULLIF(TRIM(s.store_name), ''), 'UNKNOWN') AS store_name,
        COALESCE(NULLIF(TRIM(s.store_city), ''), 'UNKNOWN') AS store_city,
        COALESCE(NULLIF(TRIM(s.store_country), ''), 'UNKNOWN') AS store_country,
        SUM(f.sale_total_price) AS total_revenue,
        COUNT(DISTINCT f.order_id) AS orders_count,
        AVG(f.sale_total_price) AS avg_check
    FROM clickhouse.dwh.fact_sales f
    JOIN stores s
        ON f.store_id = s.store_id
    GROUP BY
        COALESCE(NULLIF(TRIM(s.store_name), ''), 'UNKNOWN'),
        COALESCE(NULLIF(TRIM(s.store_city), ''), 'UNKNOWN'),
        COALESCE(NULLIF(TRIM(s.store_country), ''), 'UNKNOWN')
)
SELECT
    store_name,
    store_city,
    store_country,
    total_revenue,
    orders_count,
    avg_check,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS store_rank_by_revenue,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY total_revenue DESC) <= 5 THEN true ELSE false END AS is_top_5_store
FROM agg;
