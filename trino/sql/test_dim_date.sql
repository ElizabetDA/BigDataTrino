DROP TABLE IF EXISTS clickhouse.dwh.dim_date;

CREATE TABLE clickhouse.dwh.dim_date AS
WITH unified_source AS (
    SELECT
        to_utf8(CAST(sale_date AS varchar)) AS sale_date_bin
    FROM postgres.raw.mock_data

    UNION ALL

    SELECT
        sale_date AS sale_date_bin
    FROM clickhouse.raw.mock_data
),
normalized AS (
    SELECT
        from_utf8(sale_date_bin) AS sale_date
    FROM unified_source
),
dates AS (
    SELECT DISTINCT TRY(CAST(date_parse(sale_date, '%c/%e/%Y') AS date)) AS full_date
    FROM normalized
    WHERE sale_date IS NOT NULL
)
SELECT
    CAST(date_format(full_date, '%Y%m%d') AS bigint) AS date_id,
    full_date,
    year(full_date) AS year_num,
    month(full_date) AS month_num,
    day(full_date) AS day_num,
    quarter(full_date) AS quarter_num
FROM dates
WHERE full_date IS NOT NULL;
