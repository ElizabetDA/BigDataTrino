SELECT 'postgres_raw' AS source_name, COUNT(*) AS row_count
FROM postgres.raw.mock_data
UNION ALL
SELECT 'clickhouse_raw' AS source_name, COUNT(*) AS row_count
FROM clickhouse.raw.mock_data;

SELECT COUNT(*) AS unified_row_count
FROM (
    SELECT * FROM postgres.raw.mock_data
    UNION ALL
    SELECT * FROM clickhouse.raw.mock_data
) t;

SELECT
    COUNT(DISTINCT sale_customer_id) AS customers,
    COUNT(DISTINCT sale_product_id)  AS products,
    COUNT(DISTINCT store_name)       AS stores,
    COUNT(DISTINCT supplier_email)   AS suppliers
FROM (
    SELECT * FROM postgres.raw.mock_data
    UNION ALL
    SELECT * FROM clickhouse.raw.mock_data
) t;

SELECT
    MIN(CAST(date_parse(sale_date, '%c/%e/%Y') AS date)) AS min_sale_date,
    MAX(CAST(date_parse(sale_date, '%c/%e/%Y') AS date)) AS max_sale_date
FROM (
    SELECT * FROM postgres.raw.mock_data
    UNION ALL
    SELECT * FROM clickhouse.raw.mock_data
) t;
