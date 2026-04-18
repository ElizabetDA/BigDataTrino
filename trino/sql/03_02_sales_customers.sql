DROP TABLE IF EXISTS clickhouse.report.sales_customers;

CREATE TABLE clickhouse.report.sales_customers AS
WITH customers AS (
    SELECT
        customer_id,
        from_utf8(customer_first_name) AS customer_first_name,
        from_utf8(customer_last_name) AS customer_last_name,
        from_utf8(customer_country) AS customer_country
    FROM clickhouse.dwh.dim_customer
),
agg AS (
    SELECT
        c.customer_id,
        CONCAT(
            COALESCE(NULLIF(TRIM(c.customer_first_name), ''), ''),
            ' ',
            COALESCE(NULLIF(TRIM(c.customer_last_name), ''), '')
        ) AS customer_name,
        COALESCE(NULLIF(TRIM(c.customer_country), ''), 'UNKNOWN') AS customer_country,
        SUM(f.sale_total_price) AS total_spent,
        COUNT(DISTINCT f.order_id) AS orders_count,
        AVG(f.sale_total_price) AS avg_check
    FROM clickhouse.dwh.fact_sales f
    JOIN customers c
        ON f.customer_id = c.customer_id
    GROUP BY
        c.customer_id,
        CONCAT(
            COALESCE(NULLIF(TRIM(c.customer_first_name), ''), ''),
            ' ',
            COALESCE(NULLIF(TRIM(c.customer_last_name), ''), '')
        ),
        COALESCE(NULLIF(TRIM(c.customer_country), ''), 'UNKNOWN')
)
SELECT
    customer_id,
    customer_name,
    customer_country,
    total_spent,
    orders_count,
    avg_check,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS customer_rank_by_spent,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY total_spent DESC) <= 10 THEN true ELSE false END AS is_top_10_customer
FROM agg;
