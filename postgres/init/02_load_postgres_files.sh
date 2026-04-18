#!/bin/bash
set -e

echo "Loading CSV files into PostgreSQL raw.mock_data..."

psql -v ON_ERROR_STOP=1 -U postgres -d bigdata <<'SQL'
TRUNCATE TABLE raw.mock_data;
COPY raw.mock_data FROM '/data/mock_data_6.csv' WITH (FORMAT csv, HEADER true);
COPY raw.mock_data FROM '/data/mock_data_7.csv' WITH (FORMAT csv, HEADER true);
COPY raw.mock_data FROM '/data/mock_data_8.csv' WITH (FORMAT csv, HEADER true);
COPY raw.mock_data FROM '/data/mock_data_9.csv' WITH (FORMAT csv, HEADER true);
COPY raw.mock_data FROM '/data/mock_data_10.csv' WITH (FORMAT csv, HEADER true);
SQL

echo "PostgreSQL load completed."
