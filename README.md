# BigDataTrino

ETL-пайплайн на **Trino**: загрузка данных из CSV в **PostgreSQL** и **ClickHouse**, построение модели **звезда** в **ClickHouse** и формирование аналитических витрин в **ClickHouse**.

## Инструкция по запуску

### 1. Клонировать репозиторий
```bash
git clone https://github.com/ElizabetDA/BigDataTrino.git
cd BigDataTrino
```

### 2. Поднять контейнеры
```bash
docker compose up -d
```

### 3. Запустить полный пайплайн
```bash
bash scripts/run_all.sh
```

## Параметры подключения

### PostgreSQL
- Host: `localhost`
- Port: `15432`
- Database: `bigdata`
- User: `postgres`
- Password: `postgres`

### ClickHouse
- Host: `localhost`
- HTTP Port: `18123`
- Native Port: `19000`
- Databases: `raw`, `dwh`, `report`

### Trino
- Host: `localhost`
- Port: `18080`

## Что делает проект

### Этап 1. Raw layer
Исходные 10 CSV-файлов распределяются между двумя источниками:
- `mock_data_1.csv` ... `mock_data_5.csv` загружаются в **ClickHouse**
- `mock_data_6.csv` ... `mock_data_10.csv` загружаются в **PostgreSQL**

Создаются таблицы:
- `clickhouse.raw.mock_data`
- `postgres.raw.mock_data`

### Этап 2. DWH
С помощью **Trino** строится модель **звезда** в ClickHouse:
- `dwh.dim_date`
- `dwh.dim_customer`
- `dwh.dim_product`
- `dwh.dim_store`
- `dwh.dim_supplier`
- `dwh.fact_sales`

### Этап 3. Report marts
С помощью **Trino** формируются 6 аналитических витрин в ClickHouse:
- `report.sales_products`
- `report.sales_customers`
- `report.sales_time`
- `report.sales_stores`
- `report.sales_suppliers`
- `report.product_quality`


## Результаты выполнения

После запуска пайплайна были получены следующие результаты:

### Исходные данные
- PostgreSQL `raw.mock_data` — **5000** строк
- ClickHouse `raw.mock_data` — **5000** строк

### DWH-модель в ClickHouse
- `dim_date` — **364**
- `dim_customer` — **10000**
- `dim_product` — **10000**
- `dim_store` — **10000**
- `dim_supplier` — **10000**
- `fact_sales` — **10000**

### Отчётные таблицы в ClickHouse
- `sales_products` — **3233**
- `sales_customers` — **10000**
- `sales_time` — **12**
- `sales_stores` — **10000**
- `sales_suppliers` — **6295**
- `product_quality` — **3233**

### Пример: топ-10 продуктов по количеству продаж

| product_name | product_category | product_brand | total_revenue | total_quantity_sold | sales_count | avg_rating |
|---|---|---:|---:|---:|---:|---:|
| Bird Cage | Toy | Jayo | 33291.78 | 696 | 130 | 2.3385 |
| Bird Cage | Cage | Photobug | 32867.23 | 658 | 130 | 2.6923 |
| Dog Food | Toy | Npath | 26820.76 | 629 | 110 | 3.1727 |
| Cat Toy | Food | Jayo | 28867.72 | 612 | 110 | 2.9273 |
| Cat Toy | Food | Photobug | 24119.75 | 577 | 100 | 2.7000 |
| Bird Cage | Cage | Gigabox | 24147.83 | 561 | 100 | 2.6800 |
| Cat Toy | Toy | Skimia | 24788.67 | 550 | 100 | 2.9300 |
| Dog Food | Cage | Youspan | 26570.90 | 547 | 100 | 3.4800 |
| Bird Cage | Toy | Dynabox | 28122.54 | 545 | 110 | 3.2182 |
| Bird Cage | Food | Quinu | 23877.85 | 540 | 100 | 3.2700 |

### Пример: топ-10 поставщиков по выручке

| supplier_name | supplier_country | total_revenue | avg_product_price | quantity_sold |
|---|---|---:|---:|---:|
| Wikizz | Indonesia | 4955.94 | 45.9986 | 60 |
| Katz | China | 3944.05 | 51.4993 | 80 |
| Wikizz | China | 3684.54 | 56.7257 | 71 |
| Livetube | China | 3642.77 | 63.6827 | 55 |
| Jayo | China | 3336.92 | 63.8909 | 48 |
| Vidoo | China | 3329.53 | 53.1927 | 63 |
| Janyx | Indonesia | 3253.25 | 52.6244 | 49 |
| Eadel | China | 3231.90 | 61.0192 | 71 |
| Meevee | China | 3108.33 | 54.0530 | 55 |
| Voolia | China | 3055.66 | 61.6930 | 57 |
