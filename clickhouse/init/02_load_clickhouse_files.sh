#!/bin/bash
set -e

echo "Waiting for ClickHouse to start..."
sleep 10

echo "Loading CSV files into ClickHouse raw.mock_data..."

clickhouse-client --query "TRUNCATE TABLE raw.mock_data"

for file in /data/mock_data_1.csv /data/mock_data_2.csv /data/mock_data_3.csv /data/mock_data_4.csv /data/mock_data_5.csv
do
  echo "Loading $file"
  clickhouse-client --query="INSERT INTO raw.mock_data FORMAT CSVWithNames" < "$file"
done

echo "ClickHouse load completed."
