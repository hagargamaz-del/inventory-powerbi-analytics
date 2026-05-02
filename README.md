# End-to-End Inventory Analytics Dashboard Using Python, SQL Server, and Power BI

## 1. Project Overview

This project is an end-to-end inventory analytics solution built using **Python**, **SQL Server**, and **Power BI**.

The goal of the project is to analyze sales, profitability, inventory levels, product performance, stock risk, and store performance for a retail toy store chain.

Instead of connecting raw CSV files directly to Power BI, this project follows a complete analytics workflow:

```text
Raw CSV Files
    ↓
Python Data Cleaning and Validation
    ↓
SQL Server Relational Database
    ↓
T-SQL Analytical Views
    ↓
Power BI Data Model
    ↓
Interactive Power BI Dashboard
```

This structure makes the project stronger because it demonstrates data cleaning, database modeling, SQL analysis, DAX calculations, and dashboard storytelling.

---

## 2. Business Problem

Retail businesses need to monitor both sales performance and inventory health.

High revenue alone is not enough. A business also needs to understand:

- Which products generate the highest revenue?
- Which products generate the highest profit?
- Which stores perform best?
- Which product categories are strongest?
- Which products are out of stock?
- Which products are at risk of stockout?
- Which products have stock but no recent demand?
- Which stores have strong sales but possible inventory problems?

This dashboard was built to answer these questions and support data-driven inventory and sales decisions.

---

## 3. Business Objectives

The project aims to:

- Track total revenue, profit, profit margin, units sold, and inventory value.
- Analyze monthly revenue trends.
- Identify top-performing products by revenue and profit.
- Compare product categories by revenue and profitability.
- Detect out-of-stock, high-risk, medium-risk, and dead-stock items.
- Analyze stock coverage based on recent sales.
- Compare store performance by city and store location type.
- Provide an operational inventory action list for restocking and stock optimization.

---

## 4. Tools and Technologies

| Tool       | Purpose                                     |
| ---------- | ------------------------------------------- |
| Python     | Data cleaning and validation                |
| Pandas     | Data transformation and preprocessing       |
| SQL Server | Relational database storage                 |
| T-SQL      | Table creation, views, and business queries |
| Power BI   | Dashboard development                       |
| DAX        | KPI measures and analytical calculations    |
| GitHub     | Project documentation and version control   |

---

## 5. Dataset

The dataset used is a retail sales and inventory dataset for a toy store chain.

Main files:

```text
sales.csv
products.csv
stores.csv
inventory.csv
```

### Dataset Tables

| File            | Description                                       |
| --------------- | ------------------------------------------------- |
| `sales.csv`     | Daily sales transactions                          |
| `products.csv`  | Product names, categories, cost, and price        |
| `stores.csv`    | Store names, cities, locations, and opening dates |
| `inventory.csv` | Current stock on hand by store and product        |

The raw and cleaned CSV files are not included in this repository to avoid redistributing the original dataset.

Users should download the dataset separately and place the files inside:

```text
data/raw/
```

Expected raw files:

```text
data/raw/sales.csv
data/raw/products.csv
data/raw/stores.csv
data/raw/inventory.csv
```

---

## 6. Project Structure

```text
inventory-powerbi-analytics/
│
├── data/
│   ├── raw/
│   │   └── README.md
│   │
│   └── cleaned/
│       └── README.md
│
├── notebooks/
│   └── inventory_cleaning_eda.ipynb
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

## 7. Python Data Cleaning

Python was used to prepare the raw CSV files before loading them into SQL Server.

Main cleaning script:

```text
python/01_clean_data.py
```

### Cleaning Steps

The cleaning script performs the following tasks:

1. Loads raw CSV files.
2. Standardizes column names.
3. Converts column names to lowercase snake case.
4. Converts date columns to date format.
5. Cleans currency columns.
6. Removes duplicate rows.
7. Checks missing values.
8. Validates primary keys.
9. Validates foreign key relationships.
10. Checks business logic constraints.
11. Creates derived columns.
12. Exports cleaned CSV files.

### Main Validations

The script checks that:

- `product_id` is unique in the products table.
- `store_id` is unique in the stores table.
- `sale_id` is unique in the sales table.
- All product IDs in sales exist in the products table.
- All store IDs in sales exist in the stores table.
- All product IDs in inventory exist in the products table.
- All store IDs in inventory exist in the stores table.
- Sales units are not negative.
- Stock on hand is not negative.
- Product price is not lower than product cost.

### Derived Columns

The Python script creates:

| Column            | Description                            |
| ----------------- | -------------------------------------- |
| `unit_profit`     | Product price minus product cost       |
| `year`            | Sales year                             |
| `month`           | Sales month                            |
| `year_month`      | Year-month field for reporting         |
| `store_age_years` | Store age calculated from opening date |

---

## 8. SQL Server Database Design

The cleaned data is loaded into SQL Server using Python and SQLAlchemy.

Main loading script:

```text
python/02_load_to_sqlserver.py
```

The SQL Server database follows a star-schema style model.

### Fact Tables

| Table            | Description                          |
| ---------------- | ------------------------------------ |
| `fact_sales`     | Sales transaction data               |
| `fact_inventory` | Store-product inventory stock levels |

### Dimension Tables

| Table          | Description                      |
| -------------- | -------------------------------- |
| `dim_products` | Product attributes               |
| `dim_stores`   | Store attributes                 |
| `dim_date`     | Date dimension for time analysis |

---

## 9. SQL Server Schema

### `dim_products`

```text
product_id
product_name
product_category
product_cost
product_price
unit_profit
```

### `dim_stores`

```text
store_id
store_name
store_city
store_location
store_open_date
store_age_years
```

### `fact_sales`

```text
sale_id
sale_date
store_id
product_id
units
year
month
year_month
```

### `fact_inventory`

```text
store_id
product_id
stock_on_hand
```

### `dim_date`

```text
date_key
year
month_number
month_name
year_month
quarter_number
day_of_week_number
day_name
```

---

## 10. Data Model Relationships

The data model uses these relationships:

| Fact Table       | Column       | Dimension Table | Column       |
| ---------------- | ------------ | --------------- | ------------ |
| `fact_sales`     | `product_id` | `dim_products`  | `product_id` |
| `fact_sales`     | `store_id`   | `dim_stores`    | `store_id`   |
| `fact_sales`     | `sale_date`  | `dim_date`      | `date_key`   |
| `fact_inventory` | `product_id` | `dim_products`  | `product_id` |
| `fact_inventory` | `store_id`   | `dim_stores`    | `store_id`   |

Relationship type:

```text
Many-to-one
Single filter direction
```

This model allows Power BI slicers and visuals to filter sales and inventory measures correctly.

---

## 11. SQL Views

The project uses SQL views to simplify analysis and reporting.

### `vw_sales_detail`

Combines sales, products, stores, and date information.

Used for:

- Revenue analysis
- Profit analysis
- Product performance
- Store performance
- Monthly trend analysis

Main calculated fields:

```text
revenue = units * product_price
cost = units * product_cost
profit = units * unit_profit
```

---

### `vw_inventory_status`

Combines inventory, product, and store information.

Used for:

- Stock-on-hand analysis
- Inventory cost value
- Inventory retail value
- Low-stock analysis
- Out-of-stock analysis

Main calculated fields:

```text
inventory_cost_value = stock_on_hand * product_cost
inventory_retail_value = stock_on_hand * product_price
stock_status = Out of Stock / Low Stock / Available
```

---

### `vw_product_performance`

Aggregates sales performance by product.

Used for:

- Product revenue
- Product profit
- Units sold
- Product profit margin

---

### `vw_store_performance`

Aggregates sales performance by store.

Used for:

- Store revenue
- Store profit
- Store margin
- Store ranking

---

### `vw_stock_risk`

Calculates stock risk using current stock and units sold during the last 90 days.

Used for:

- Stock coverage days
- High-risk item detection
- Medium-risk item detection
- Dead-stock detection
- Inventory action list

---

## 12. Inventory Risk Logic

Inventory risk is calculated using stock on hand and sales activity during the last 90 days.

| Risk Status          | Logic                                     | Recommended Action         |
| -------------------- | ----------------------------------------- | -------------------------- |
| Out of Stock         | Stock on hand = 0                         | Immediate Restock          |
| High Risk            | Stock coverage < 7 days                   | Restock Soon               |
| Medium Risk          | Stock coverage < 14 days                  | Monitor Closely            |
| Dead Stock Candidate | Stock exists but no sales in last 90 days | Discount or Transfer Stock |
| Healthy              | Sufficient stock coverage                 | No Action Needed           |

### Stock Coverage Formula

```text
Stock Coverage Days = Stock On Hand / Average Daily Units Sold in Last 90 Days
```

Where:

```text
Average Daily Units Sold = Units Sold in Last 90 Days / 90
```

This logic converts raw inventory numbers into operational business actions.

---

## 13. Power BI Data Model

Power BI connects to SQL Server using **Import mode**.

Imported tables/views include:

```text
dim_products
dim_stores
dim_date
fact_sales
fact_inventory
vw_stock_risk
vw_inventory_status
```

The base Power BI model uses fact and dimension tables for most calculations.

The `vw_stock_risk` view is used for inventory risk pages because it already contains stock coverage and risk classification logic.

---

## 14. DAX Measures

### Sales Measures

```DAX
Total Units Sold =
SUM(fact_sales[units])
```

```DAX
Total Revenue =
SUMX(
    fact_sales,
    fact_sales[units] * RELATED(dim_products[product_price])
)
```

```DAX
Total Cost =
SUMX(
    fact_sales,
    fact_sales[units] * RELATED(dim_products[product_cost])
)
```

```DAX
Total Profit =
[Total Revenue] - [Total Cost]
```

```DAX
Profit Margin =
DIVIDE(
    [Total Profit],
    [Total Revenue]
)
```

```DAX
Average Selling Price =
DIVIDE(
    [Total Revenue],
    [Total Units Sold]
)
```

---

### Inventory Measures

```DAX
Total Stock =
SUM(fact_inventory[stock_on_hand])
```

```DAX
Inventory Cost Value =
SUMX(
    fact_inventory,
    fact_inventory[stock_on_hand] * RELATED(dim_products[product_cost])
)
```

```DAX
Inventory Retail Value =
SUMX(
    fact_inventory,
    fact_inventory[stock_on_hand] * RELATED(dim_products[product_price])
)
```

```DAX
Potential Inventory Profit =
[Inventory Retail Value] - [Inventory Cost Value]
```

---

### Product Analysis Measures

```DAX
Revenue Share % =
DIVIDE(
    [Total Revenue],
    CALCULATE(
        [Total Revenue],
        ALLSELECTED(dim_products[product_name])
    )
)
```

```DAX
Sales to Stock Ratio =
DIVIDE(
    [Total Units Sold],
    [Total Stock]
)
```

```DAX
Product Rank by Revenue =
RANKX(
    ALLSELECTED(dim_products[product_name]),
    [Total Revenue],
    ,
    DESC,
    DENSE
)
```

---

### Store Analysis Measures

```DAX
Number of Stores =
DISTINCTCOUNT(dim_stores[store_id])
```

```DAX
Store Rank by Revenue =
RANKX(
    ALLSELECTED(dim_stores[store_name]),
    [Total Revenue],
    ,
    DESC,
    DENSE
)
```

```DAX
Store Rank by Profit =
RANKX(
    ALLSELECTED(dim_stores[store_name]),
    [Total Profit],
    ,
    DESC,
    DENSE
)
```

---

### Inventory Risk Measures

```DAX
Inventory Item Count =
COUNTROWS(vw_stock_risk)
```

```DAX
Risk Page Total Stock =
SUM(vw_stock_risk[stock_on_hand])
```

```DAX
Out of Stock Items =
CALCULATE(
    COUNTROWS(vw_stock_risk),
    vw_stock_risk[stock_risk_status] = "Out of Stock"
)
```

```DAX
High Risk Items =
CALCULATE(
    COUNTROWS(vw_stock_risk),
    vw_stock_risk[stock_risk_status] = "High Risk"
)
```

```DAX
Medium Risk Items =
CALCULATE(
    COUNTROWS(vw_stock_risk),
    vw_stock_risk[stock_risk_status] = "Medium Risk"
)
```

```DAX
Dead Stock Candidates =
CALCULATE(
    COUNTROWS(vw_stock_risk),
    vw_stock_risk[stock_risk_status] = "Dead Stock Candidate"
)
```

```DAX
Critical Stock Items =
CALCULATE(
    COUNTROWS(vw_stock_risk),
    vw_stock_risk[stock_risk_status] IN {"Out of Stock", "High Risk"}
)
```

```DAX
Average Stock Coverage Days =
AVERAGE(vw_stock_risk[stock_coverage_days])
```

---

## 15. Power BI Dashboard Pages

The Power BI report contains seven pages.

---

### Page 1: Executive Overview

Purpose:

Provides a high-level business overview.

Main visuals:

- KPI cards
- Monthly revenue trend
- Revenue by product category
- Profit by store city
- Stock status overview

Main KPIs:

- Total Revenue
- Total Profit
- Profit Margin
- Total Units Sold
- Total Stock
- Inventory Cost Value
- Inventory Retail Value

Screenshot:

![Executive Overview](images/executive_overview.png)

---

### Page 2: Product Performance Analysis

Purpose:

Analyzes product and category performance.

Main visuals:

- Top 10 products by revenue
- Top 10 products by profit
- Revenue and profit by product category
- Product performance details matrix

Screenshot:

![Product Performance](images/product_performance.png)

---

### Page 3: Product Profitability

Purpose:

Analyzes the relationship between revenue and profit margin.

Main visuals:

- Product revenue vs profit margin scatter plot
- Low-margin product analysis
- High-revenue low-margin product analysis

Interpretation:

- High revenue and high margin products are strong performers.
- High revenue but low margin products may need cost or pricing review.
- Low revenue but high margin products may be growth opportunities.
- Low revenue and low margin products are weak performers.

Screenshot:

![Product Profitability](images/product_profitability.png)

---

### Page 4: Inventory Risk Analysis

Purpose:

Summarizes inventory health.

Main visuals:

- Inventory items by risk status
- Dead stock quantity by category
- Critical stock items by city
- Average stock coverage days by category

Main KPIs:

- Total Stock
- Critical Stock Items
- Out of Stock Items
- Dead Stock Candidates
- Average Stock Coverage Days

Screenshot:

![Inventory Risk Analysis](images/inventory_risk_analysis.png)

---

### Page 5: Inventory Risk Details

Purpose:

Provides an operational action list.

Main columns:

- Risk Status
- Recommended Action
- Store
- City
- Location
- Product
- Category
- Stock
- Units Sold in Last 90 Days
- Coverage Days

Screenshot:

![Inventory Risk Details](images/inventory_risk_details.png)

---

### Page 6: Store Performance Analysis

Purpose:

Summarizes store performance by revenue, profit, and location type.

Main visuals:

- Top 10 stores by revenue and profit
- Revenue and profit by store location

Main KPIs:

- Total Revenue
- Total Profit
- Profit Margin
- Number of Stores
- Inventory Cost Value

Screenshot:

![Store Performance](images/store_performance.png)

---

### Page 7: Store Details and Operational Review

Purpose:

Provides store-level drill-down and profitability review.

Main visuals:

- Store performance matrix
- Store revenue vs profit margin scatter plot

Scatter plot interpretation:

- High revenue and high margin stores are best-performing stores.
- High revenue but weaker margin stores may need cost review.
- Low revenue but strong margin stores may be growth opportunities.
- Low revenue and low margin stores may need operational review.

Screenshot:

![Store Details](images/store_details.png)

---

## 16. Key Business Insights

The dashboard provides the following insights:

- Total revenue reached 14.44M with a profit margin of 27.79%.
- Product performance varies significantly across categories.
- Some products generate high revenue but weaker profit margins.
- Inventory risk exists in the form of out-of-stock, high-risk, and dead-stock items.
- Dead stock candidates are products with stock available but no recent sales activity.
- Store performance differs across location types.
- Downtown stores generate the highest revenue and profit.
- Store-level scatter analysis helps identify high-performing and underperforming stores.
- Inventory risk analysis provides an operational list of products requiring restocking, monitoring, discounting, or transfer.

---

## 17. How to Run the Project

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/inventory-powerbi-analytics.git
cd inventory-powerbi-analytics
```

Replace `YOUR_USERNAME` with your GitHub username.

---

### Step 2: Create a Virtual Environment

```bash
python -m venv venv
venv\Scripts\activate
```

---

### Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

---

### Step 4: Add Raw Data

Download the dataset and place the files inside:

```text
data/raw/
```

Expected files:

```text
sales.csv
products.csv
stores.csv
inventory.csv
```

---

### Step 5: Clean the Data

```bash
python python/01_clean_data.py
```

This generates cleaned files inside:

```text
data/cleaned/
```

Expected cleaned files:

```text
clean_sales.csv
clean_products.csv
clean_stores.csv
clean_inventory.csv
```

---

### Step 6: Create SQL Server Database

Open SQL Server Management Studio and run:

```text
sql/01_create_database.sql
```

---

### Step 7: Create SQL Server Tables

Run:

```text
sql/02_create_tables.sql
```

---

### Step 8: Load Data into SQL Server

Update the SQL Server connection values inside:

```text
python/02_load_to_sqlserver.py
```

Example connection values:

```python
SERVER = r"localhost\SQLEXPRESS"
DATABASE = "inventory_analytics"
DRIVER = "ODBC Driver 17 for SQL Server"
```

Then run:

```bash
python python/02_load_to_sqlserver.py
```

---

### Step 9: Create Date Dimension

Run:

```text
sql/03_create_date_dimension.sql
```

---

### Step 10: Create SQL Views

Run:

```text
sql/04_create_views.sql
```

---

### Step 11: Run Business Queries

Optional validation queries are available in:

```text
sql/05_business_queries.sql
```

---

### Step 12: Open Power BI Dashboard

Open:

```text
powerbi/inventory_dashboard.pbix
```

Refresh the data connection if needed.

---

## 18. GitHub Notes

The full raw and cleaned CSV files are not included in the repository.

The `.gitignore` excludes:

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
- Power BI file
- Dashboard screenshots
- Project documentation
- Folder-level README files for data instructions

---


---

## 22. Author

**Hagar Tawfik**


