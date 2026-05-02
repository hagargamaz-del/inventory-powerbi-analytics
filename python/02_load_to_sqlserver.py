from pathlib import Path
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine, text


# -----------------------------
# 1. SQL Server connection
# -----------------------------

SERVER = r"localhost\SQLEXPRESS"
DATABASE = "inventory_analytics"
DRIVER = "ODBC Driver 17 for SQL Server"


connection_string = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    f"Trusted_Connection=yes;"
)

connection_url = quote_plus(connection_string)

engine = create_engine(
    f"mssql+pyodbc:///?odbc_connect={connection_url}",
    fast_executemany=True
)


# -----------------------------
# 2. Project paths
# -----------------------------

BASE_DIR = Path(__file__).resolve().parents[1]
CLEAN_DIR = BASE_DIR / "data" / "cleaned"


# -----------------------------
# 3. Load cleaned CSV files
# -----------------------------

products = pd.read_csv(CLEAN_DIR / "clean_products.csv")
stores = pd.read_csv(CLEAN_DIR / "clean_stores.csv")
sales = pd.read_csv(CLEAN_DIR / "clean_sales.csv")
inventory = pd.read_csv(CLEAN_DIR / "clean_inventory.csv")


# -----------------------------
# 4. Convert dates
# -----------------------------

sales["sale_date"] = pd.to_datetime(sales["sale_date"]).dt.date
stores["store_open_date"] = pd.to_datetime(stores["store_open_date"]).dt.date


# -----------------------------
# 5. Clear existing data
# -----------------------------

with engine.begin() as conn:
    conn.execute(text("DELETE FROM dbo.fact_inventory;"))
    conn.execute(text("DELETE FROM dbo.fact_sales;"))
    conn.execute(text("DELETE FROM dbo.dim_products;"))
    conn.execute(text("DELETE FROM dbo.dim_stores;"))


# -----------------------------
# 6. Insert data
# -----------------------------

products.to_sql(
    "dim_products",
    con=engine,
    schema="dbo",
    if_exists="append",
    index=False,
    chunksize=5000
)

stores.to_sql(
    "dim_stores",
    con=engine,
    schema="dbo",
    if_exists="append",
    index=False,
    chunksize=5000
)

sales.to_sql(
    "fact_sales",
    con=engine,
    schema="dbo",
    if_exists="append",
    index=False,
    chunksize=5000
)

inventory.to_sql(
    "fact_inventory",
    con=engine,
    schema="dbo",
    if_exists="append",
    index=False,
    chunksize=5000
)

print("Data loaded successfully into SQL Server.")