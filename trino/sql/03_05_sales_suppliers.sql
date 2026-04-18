DROP TABLE IF EXISTS clickhouse.report.sales_suppliers;

CREATE TABLE clickhouse.report.sales_suppliers AS
WITH suppliers AS (
    SELECT
        supplier_id,
        from_utf8(supplier_name) AS supplier_name,
        from_utf8(supplier_country) AS supplier_country
    FROM clickhouse.dwh.dim_supplier
),
agg AS (
    SELECT
        COALESCE(NULLIF(TRIM(s.supplier_name), ''), 'UNKNOWN') AS supplier_name,
        COALESCE(NULLIF(TRIM(s.supplier_country), ''), 'UNKNOWN') AS supplier_country,
        SUM(f.sale_total_price) AS total_revenue,
        AVG(f.unit_price) AS avg_product_price,
        SUM(f.sale_quantity) AS quantity_sold
    FROM clickhouse.dwh.fact_sales f
    JOIN suppliers s
        ON f.supplier_id = s.supplier_id
    GROUP BY
        COALESCE(NULLIF(TRIM(s.supplier_name), ''), 'UNKNOWN'),
        COALESCE(NULLIF(TRIM(s.supplier_country), ''), 'UNKNOWN')
)
SELECT
    supplier_name,
    supplier_country,
    total_revenue,
    avg_product_price,
    quantity_sold,
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS supplier_rank_by_revenue,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY total_revenue DESC) <= 5 THEN true ELSE false END AS is_top_5_supplier
FROM agg;
