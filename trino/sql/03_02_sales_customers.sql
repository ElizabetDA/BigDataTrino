DROP TABLE IF EXISTS clickhouse.report.sales_customers;

CREATE TABLE clickhouse.report.sales_customers AS
WITH customers AS (
    SELECT
        customer_id,
        from_utf8(customer_first_name) AS customer_first_name,
        from_utf8(customer_last_name) AS customer_last_name,
        from_utf8(customer_country) AS customer_country
    FROM clickhouse.dwh.dim_customer
)
SELECT
    c.customer_id,
    CONCAT(
        COALESCE(NULLIF(TRIM(c.customer_first_name), ''), ''),
        ' ',
        COALESCE(NULLIF(TRIM(c.customer_last_name), ''), '')
    ) AS customer_name,
    c.customer_country,
    SUM(f.sale_total_price) AS total_spent,
    COUNT(DISTINCT f.order_id) AS orders_count,
    AVG(f.sale_total_price) AS avg_check,
    ROW_NUMBER() OVER (ORDER BY SUM(f.sale_total_price) DESC) AS customer_rank_by_spent
FROM clickhouse.dwh.fact_sales f
JOIN customers c
    ON f.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_first_name,
    c.customer_last_name,
    c.customer_country;
