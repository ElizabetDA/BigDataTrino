#!/usr/bin/env bash
set -e

echo "[1/3] Waiting for services to become ready..."
sleep 12

echo "[2/3] Building DWH in ClickHouse via Trino..."
docker exec -i bigdata_trino_trino trino --file /scripts/test_dim_date.sql
docker exec -i bigdata_trino_trino trino --file /scripts/02_01_dim_customer.sql
docker exec -i bigdata_trino_trino trino --file /scripts/02_02_dim_product.sql
docker exec -i bigdata_trino_trino trino --file /scripts/02_03_dim_store.sql
docker exec -i bigdata_trino_trino trino --file /scripts/02_04_dim_supplier.sql
docker exec -i bigdata_trino_trino trino --file /scripts/02_05_fact_sales.sql

echo "[3/3] Building report marts in ClickHouse via Trino..."
docker exec -i bigdata_trino_trino trino --file /scripts/03_01_sales_products.sql
docker exec -i bigdata_trino_trino trino --file /scripts/03_02_sales_customers.sql
docker exec -i bigdata_trino_trino trino --file /scripts/03_03_sales_time.sql
docker exec -i bigdata_trino_trino trino --file /scripts/03_04_sales_stores.sql
docker exec -i bigdata_trino_trino trino --file /scripts/03_05_sales_suppliers.sql
docker exec -i bigdata_trino_trino trino --file /scripts/03_06_product_quality.sql

echo "Done."
echo "DWH tables: clickhouse.dwh.*"
echo "Report tables: clickhouse.report.*"
