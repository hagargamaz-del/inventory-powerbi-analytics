# Inventory Analytics Dashboard Using Python, SQL Server, and Power BI

## Project Overview

This project is an end-to-end inventory analytics dashboard built using **Python**, **SQL Server**, and **Power BI**.

The project analyzes retail sales and inventory data for a toy store chain to track revenue, profit, product performance, inventory risk, stock coverage, and store performance.

Instead of connecting raw CSV files directly to Power BI, the project follows a complete analytics workflow:

```text
Raw CSV Files
    ↓
Python Data Cleaning
    ↓
SQL Server Database
    ↓
T-SQL Views
    ↓
Power BI Dashboard
```

---

## Business Objectives

The dashboard was built to answer key business questions:

- What are the total revenue, profit, profit margin, and units sold?
- Which products and categories generate the highest revenue and profit?
- Which products are out of stock or at risk of stockout?
- Which products are dead stock candidates?
- Which stores and locations perform best?
- Which store-product combinations require inventory action?

---

## Tools Used

| Tool | Purpose |
|---|---|
| Python | Data cleaning and preprocessing |
| Pandas | Data transformation |
| SQL Server | Relational database storage |
| T-SQL | Tables, views, and business queries |
| Power BI | Dashboard and reporting |
| DAX | Measures and KPIs |
| GitHub | Version control and documentation |

---

## Dataset

The dataset contains retail sales and inventory data for a toy store chain.

Main files:

```text
sales.csv
products.csv
stores.csv
inventory.csv
```

The full raw and cleaned CSV files are **not included** in this repository to avoid redistributing the original dataset.

Place the raw files inside:

```text
data/raw/
```

Expected files:

```text
data/raw/sales.csv
data/raw/products.csv
data/raw/stores.csv
data/raw/inventory.csv
```

---

## Project Structure

```text
inventory-powerbi-analytics/
│
├── data/
│   ├── raw/
│   │   └── README.md
│   └── cleaned/
│       └── README.md
│
├── python/
│   ├── 01_clean_data.py
│   └── 02_load_to_sqlserver.py
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_create_date_dimension.sql
│   ├── 04_create_views.sql
│   └── 05_business_queries.sql
│
├── powerbi/
│   ├── inventory_dashboard.pbix
│   └── README.md
│
├── images/
│   ├── executive_overview.png
│   ├── product_performance.png
│   ├── product_profitability.png
│   ├── inventory_risk_analysis.png
│   ├── inventory_risk_details.png
│   ├── store_performance.png
│   └── store_details.png
│
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Data Cleaning

Python was used to clean and validate the raw CSV files before loading them into SQL Server.

Main script:

```text
python/01_clean_data.py
```

Cleaning steps included:

- Standardizing column names
- Converting date columns
- Cleaning currency columns
- Removing duplicates
- Checking missing values
- Validating primary keys and foreign keys
- Creating derived columns such as `unit_profit`, `year`, `month`, and `year_month`
- Exporting cleaned CSV files

---

## SQL Server Database

The cleaned data was loaded into SQL Server using:

```text
python/02_load_to_sqlserver.py
```

The database uses a star-schema style model.

### Fact Tables

- `fact_sales`
- `fact_inventory`

### Dimension Tables

- `dim_products`
- `dim_stores`
- `dim_date`

### Main Relationships

| Fact Table | Column | Dimension Table | Column |
|---|---|---|---|
| `fact_sales` | `product_id` | `dim_products` | `product_id` |
| `fact_sales` | `store_id` | `dim_stores` | `store_id` |
| `fact_sales` | `sale_date` | `dim_date` | `date_key` |
| `fact_inventory` | `product_id` | `dim_products` | `product_id` |
| `fact_inventory` | `store_id` | `dim_stores` | `store_id` |

---

## SQL Views

The project includes analytical SQL views used for reporting and business analysis:

| View | Purpose |
|---|---|
| `vw_sales_detail` | Detailed sales, revenue, cost, and profit analysis |
| `vw_inventory_status` | Stock status, inventory value, and stock availability |
| `vw_product_performance` | Product-level revenue, profit, and units sold |
| `vw_store_performance` | Store-level revenue, profit, and margin |
| `vw_stock_risk` | Stock coverage, stock risk, and dead-stock detection |

---

## Inventory Risk Logic

Inventory risk is calculated using current stock and sales activity during the last 90 days.

| Risk Status | Logic | Recommended Action |
|---|---|---|
| Out of Stock | Stock on hand = 0 | Immediate Restock |
| High Risk | Stock coverage < 7 days | Restock Soon |
| Medium Risk | Stock coverage < 14 days | Monitor Closely |
| Dead Stock Candidate | Stock exists but no sales in last 90 days | Discount or Transfer Stock |
| Healthy | Sufficient stock coverage | No Action Needed |

Stock coverage formula:

```text
Stock Coverage Days = Stock On Hand / Average Daily Units Sold in Last 90 Days
```

---

## Power BI Dashboard

The Power BI dashboard contains seven pages.

---

### 1. Executive Overview

High-level view of sales, profit, inventory value, monthly trends, category revenue, city profit, and stock status.

<img width="1373" height="744" alt="Inventory   Sales Performance Dashboard" src="https://github.com/user-attachments/assets/1f799fd4-cd8d-4037-bd7b-d111d8a74609" />


---

### 2. Product Performance Analysis

Analysis of top products by revenue, top products by profit, and revenue/profit by product category.
<img width="1377" height="755" alt="Product Performance Analysis" src="https://github.com/user-attachments/assets/74850d4a-0cc3-4d88-a5ce-728641e8361d" />

---

### 3. Product Profitability

Scatter analysis of product revenue vs profit margin to identify strong products, low-margin products, and growth opportunities.

<img width="1371" height="751" alt="Product Profitability Analysis" src="https://github.com/user-attachments/assets/af1f4849-6d5e-42f3-b711-8c6af1c2278d" />

---

### 4. Inventory Risk Analysis

Summary of stock risk, critical stock items, dead stock, and average stock coverage by category.

<img width="1371" height="750" alt="Inventory Risk Analysis" src="https://github.com/user-attachments/assets/2ce31f01-5773-4b39-8c78-87b8a05cafb5" />

---

### 5. Inventory Risk Details

Operational action list showing exact products and stores that require restocking, monitoring, discounting, or stock transfer.

<img width="1383" height="729" alt="Inventory Risk Details (2)" src="https://github.com/user-attachments/assets/75aece14-57d8-4953-b09f-14af50dc0998" />

---

### 6. Store Performance Analysis

Store-level summary comparing revenue, profit, and performance by store location.

<img width="1368" height="748" alt="Store Performance Analysis" src="https://github.com/user-attachments/assets/b1cf96b0-6e1a-4df2-b034-66c31e9d073d" />

---

### 7. Store Details and Operational Review

Store-level drill-down with a matrix and scatter plot comparing store revenue vs profit margin.

<img width="1373" height="751" alt="Store Details" src="https://github.com/user-attachments/assets/6fdf7ab2-b85d-4eff-b815-23fd8ff265c9" />

---

## Key Insights

- Total revenue reached **14.44M** with a profit margin of **27.79%**.
- Product performance varies significantly across categories.
- Some products generate high revenue but weaker profit margins.
- Inventory risk exists through out-of-stock, high-risk, and dead-stock items.
- Dead stock candidates are products with stock available but no recent sales.
- Store performance differs by city and location type.
- Downtown stores generate the highest revenue and profit.
- The dashboard supports both executive monitoring and operational inventory actions.

---

## How to Run the Project

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/inventory-powerbi-analytics.git
cd inventory-powerbi-analytics
```

### 2. Create and activate virtual environment

```bash
python -m venv venv
venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Add raw data

Place the raw CSV files inside:

```text
data/raw/
```

### 5. Clean the data

```bash
python python/01_clean_data.py
```

### 6. Create SQL Server database and tables

Run the SQL scripts in SQL Server Management Studio in this order:

```text
sql/01_create_database.sql
sql/02_create_tables.sql
```

### 7. Load data into SQL Server

Update the SQL Server connection values in:

```text
python/02_load_to_sqlserver.py
```

Example:

```python
SERVER = r"localhost\SQLEXPRESS"
DATABASE = "inventory_analytics"
DRIVER = "ODBC Driver 17 for SQL Server"
```

Then run:

```bash
python python/02_load_to_sqlserver.py
```

### 8. Create date dimension and SQL views

Run:

```text
sql/03_create_date_dimension.sql
sql/04_create_views.sql
sql/05_business_queries.sql
```

### 9. Open Power BI file

Open:

```text
powerbi/inventory_dashboard.pbix
```

Refresh the data connection if needed.

---

## GitHub Notes

The repository excludes raw and cleaned CSV files using `.gitignore`:

```text
data/raw/*.csv
data/cleaned/*.csv
venv/
__pycache__/
.ipynb_checkpoints/
```

The repository includes:

- Python scripts
- SQL scripts
- Power BI dashboard file
- Dashboard screenshots
- Project documentation

---



## Author

**Hagar Tawfik**
