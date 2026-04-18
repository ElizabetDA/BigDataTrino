DROP TABLE IF EXISTS clickhouse.report.sales_time;

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
