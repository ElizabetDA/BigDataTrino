DROP TABLE IF EXISTS clickhouse.report.sales_suppliers;

CREATE TABLE clickhouse.report.sales_suppliers AS
WITH suppliers AS (
    SELECT
        supplier_id,
        from_utf8(supplier_name) AS supplier_name,
        from_utf8(supplier_country) AS supplier_country
    FROM clickhouse.dwh.dim_supplier
)
SELECT
    s.supplier_id,
    s.supplier_name,
    s.supplier_country,
    SUM(f.sale_total_price) AS total_revenue,
    AVG(f.unit_price) AS avg_product_price,
    SUM(f.sale_quantity) AS quantity_sold,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sale_total_price) DESC) AS supplier_rank_by_revenue
FROM clickhouse.dwh.fact_sales f
JOIN suppliers s
    ON f.supplier_id = s.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_country;
