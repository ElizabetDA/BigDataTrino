SELECT 'postgres_raw' AS table_name, COUNT(*) AS row_count FROM postgres.raw.mock_data
UNION ALL
SELECT 'clickhouse_raw', COUNT(*) FROM clickhouse.raw.mock_data
UNION ALL
SELECT 'dwh_dim_date', COUNT(*) FROM clickhouse.dwh.dim_date
UNION ALL
SELECT 'dwh_dim_customer', COUNT(*) FROM clickhouse.dwh.dim_customer
UNION ALL
SELECT 'dwh_dim_product', COUNT(*) FROM clickhouse.dwh.dim_product
UNION ALL
SELECT 'dwh_dim_store', COUNT(*) FROM clickhouse.dwh.dim_store
UNION ALL
SELECT 'dwh_dim_supplier', COUNT(*) FROM clickhouse.dwh.dim_supplier
UNION ALL
SELECT 'dwh_fact_sales', COUNT(*) FROM clickhouse.dwh.fact_sales
UNION ALL
SELECT 'report_sales_products', COUNT(*) FROM clickhouse.report.sales_products
UNION ALL
SELECT 'report_sales_customers', COUNT(*) FROM clickhouse.report.sales_customers
UNION ALL
SELECT 'report_sales_time', COUNT(*) FROM clickhouse.report.sales_time
UNION ALL
SELECT 'report_sales_stores', COUNT(*) FROM clickhouse.report.sales_stores
UNION ALL
SELECT 'report_sales_suppliers', COUNT(*) FROM clickhouse.report.sales_suppliers
UNION ALL
SELECT 'report_product_quality', COUNT(*) FROM clickhouse.report.product_quality;

SELECT * FROM clickhouse.report.sales_products ORDER BY total_quantity_sold DESC LIMIT 10;
SELECT * FROM clickhouse.report.sales_customers ORDER BY total_spent DESC LIMIT 10;
SELECT * FROM clickhouse.report.sales_time ORDER BY year_num, month_num;
SELECT * FROM clickhouse.report.sales_stores ORDER BY total_revenue DESC LIMIT 5;
SELECT * FROM clickhouse.report.sales_suppliers ORDER BY total_revenue DESC LIMIT 5;
SELECT * FROM clickhouse.report.product_quality ORDER BY avg_rating DESC LIMIT 10;
