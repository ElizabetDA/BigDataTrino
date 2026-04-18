DROP TABLE IF EXISTS clickhouse.report.sales_products;
DROP TABLE IF EXISTS clickhouse.report.sales_customers;
DROP TABLE IF EXISTS clickhouse.report.sales_time;
DROP TABLE IF EXISTS clickhouse.report.sales_stores;
DROP TABLE IF EXISTS clickhouse.report.sales_suppliers;
DROP TABLE IF EXISTS clickhouse.report.product_quality;

CREATE TABLE clickhouse.report.sales_products AS
SELECT
    p.product_id,
    p.product_name,
    p.product_category,
    SUM(f.sale_total_price) AS total_revenue,
    SUM(f.sale_quantity) AS total_quantity_sold,
    COUNT(*) AS sales_count,
    AVG(p.product_rating) AS avg_rating,
    SUM(COALESCE(p.product_reviews, 0)) AS total_reviews,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sale_quantity) DESC) AS product_rank_by_quantity
FROM clickhouse.dwh.fact_sales f
JOIN clickhouse.dwh.dim_product p
    ON f.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.product_category;

CREATE TABLE clickhouse.report.sales_customers AS
SELECT
    c.customer_id,
    CONCAT(COALESCE(c.customer_first_name, ''), ' ', COALESCE(c.customer_last_name, '')) AS customer_name,
    c.customer_country,
    SUM(f.sale_total_price) AS total_spent,
    COUNT(DISTINCT f.order_id) AS orders_count,
    AVG(f.sale_total_price) AS avg_check,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sale_total_price) DESC) AS customer_rank_by_spent
FROM clickhouse.dwh.fact_sales f
JOIN clickhouse.dwh.dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_first_name,
    c.customer_last_name,
    c.customer_country;

CREATE TABLE clickhouse.report.sales_time AS
WITH monthly AS (
    SELECT
        d.year_num,
        d.month_num,
        SUM(f.sale_total_price) AS total_revenue,
        COUNT(DISTINCT f.order_id) AS total_orders,
        AVG(f.sale_total_price) AS avg_order_size
    FROM clickhouse.dwh.fact_sales f
    JOIN clickhouse.dwh.dim_date d
        ON f.date_id = d.date_id
    GROUP BY
        d.year_num,
        d.month_num
)
SELECT
    year_num,
    month_num,
    CONCAT(CAST(year_num AS varchar), '-', LPAD(CAST(month_num AS varchar), 2, '0')) AS year_month,
    total_revenue,
    total_orders,
    avg_order_size,
    LAG(total_revenue) OVER (ORDER BY year_num, month_num) AS prev_month_revenue,
    total_revenue - COALESCE(LAG(total_revenue) OVER (ORDER BY year_num, month_num), 0) AS revenue_diff_vs_prev_month
FROM monthly;

CREATE TABLE clickhouse.report.sales_stores AS
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
JOIN clickhouse.dwh.dim_store s
    ON f.store_id = s.store_id
GROUP BY
    s.store_id,
    s.store_name,
    s.store_city,
    s.store_country;

CREATE TABLE clickhouse.report.sales_suppliers AS
SELECT
    s.supplier_id,
    s.supplier_name,
    s.supplier_country,
    SUM(f.sale_total_price) AS total_revenue,
    AVG(f.unit_price) AS avg_product_price,
    SUM(f.sale_quantity) AS quantity_sold,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sale_total_price) DESC) AS supplier_rank_by_revenue
FROM clickhouse.dwh.fact_sales f
JOIN clickhouse.dwh.dim_supplier s
    ON f.supplier_id = s.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_country;

CREATE TABLE clickhouse.report.product_quality AS
SELECT
    p.product_id,
    p.product_name,
    AVG(p.product_rating) AS avg_rating,
    SUM(COALESCE(p.product_reviews, 0)) AS total_reviews,
    SUM(f.sale_quantity) AS total_quantity_sold,
    SUM(f.sale_total_price) AS total_revenue
FROM clickhouse.dwh.fact_sales f
JOIN clickhouse.dwh.dim_product p
    ON f.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name;
