from pathlib import Path
import pandas as pd
import numpy as np


# -----------------------------
# 1. Define project paths
# -----------------------------

BASE_DIR = Path(__file__).resolve().parents[1]

RAW_DIR = BASE_DIR / "data" / "raw"
CLEAN_DIR = BASE_DIR / "data" / "cleaned"

CLEAN_DIR.mkdir(parents=True, exist_ok=True)


# -----------------------------
# 2. Helper functions
# -----------------------------

def clean_column_names(df: pd.DataFrame) -> pd.DataFrame:
    """
    Convert column names to lowercase snake_case.
    Example: Product Name -> product_name
    """
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
        .str.replace("-", "_")
    )
    return df


def clean_money_column(series: pd.Series) -> pd.Series:
    """
    Clean currency columns such as '$2.99' or '2.99'.
    """
    return (
        series.astype(str)
        .str.replace("$", "", regex=False)
        .str.replace(",", "", regex=False)
        .str.strip()
        .replace("nan", np.nan)
        .astype(float)
    )


def print_quality_report(name: str, df: pd.DataFrame) -> None:
    """
    Print a simple data quality report.
    """
    print(f"\n========== {name.upper()} ==========")
    print("Shape:", df.shape)
    print("\nData types:")
    print(df.dtypes)
    print("\nMissing values:")
    print(df.isna().sum())
    print("\nDuplicate rows:", df.duplicated().sum())


# -----------------------------
# 3. Load raw CSV files
# -----------------------------

sales = pd.read_csv(RAW_DIR / "sales.csv")
products = pd.read_csv(RAW_DIR / "products.csv")
stores = pd.read_csv(RAW_DIR / "stores.csv")
inventory = pd.read_csv(RAW_DIR / "inventory.csv")


# -----------------------------
# 4. Standardize column names
# -----------------------------

sales = clean_column_names(sales)
products = clean_column_names(products)
stores = clean_column_names(stores)
inventory = clean_column_names(inventory)


# -----------------------------
# 5. Rename columns if needed
# -----------------------------
# This keeps the project consistent even if the original files have slightly different naming.

sales = sales.rename(columns={
    "sale_id": "sale_id",
    "date": "sale_date",
    "store_id": "store_id",
    "product_id": "product_id",
    "units": "units"
})

products = products.rename(columns={
    "product_id": "product_id",
    "product_name": "product_name",
    "product_category": "product_category",
    "product_cost": "product_cost",
    "product_price": "product_price"
})

stores = stores.rename(columns={
    "store_id": "store_id",
    "store_name": "store_name",
    "store_city": "store_city",
    "store_location": "store_location",
    "store_open_date": "store_open_date"
})

inventory = inventory.rename(columns={
    "store_id": "store_id",
    "product_id": "product_id",
    "stock_on_hand": "stock_on_hand"
})


# -----------------------------
# 6. Convert data types
# -----------------------------

sales["sale_date"] = pd.to_datetime(sales["sale_date"], errors="coerce")
stores["store_open_date"] = pd.to_datetime(stores["store_open_date"], errors="coerce")

sales["sale_id"] = sales["sale_id"].astype(int)
sales["store_id"] = sales["store_id"].astype(int)
sales["product_id"] = sales["product_id"].astype(int)
sales["units"] = sales["units"].astype(int)

products["product_id"] = products["product_id"].astype(int)
products["product_cost"] = clean_money_column(products["product_cost"])
products["product_price"] = clean_money_column(products["product_price"])

stores["store_id"] = stores["store_id"].astype(int)

inventory["store_id"] = inventory["store_id"].astype(int)
inventory["product_id"] = inventory["product_id"].astype(int)
inventory["stock_on_hand"] = inventory["stock_on_hand"].astype(int)


# -----------------------------
# 7. Remove duplicate rows
# -----------------------------

sales = sales.drop_duplicates()
products = products.drop_duplicates()
stores = stores.drop_duplicates()
inventory = inventory.drop_duplicates()


# -----------------------------
# 8. Data validation checks
# -----------------------------

# Primary key checks
assert products["product_id"].is_unique, "products.product_id has duplicates"
assert stores["store_id"].is_unique, "stores.store_id has duplicates"
assert sales["sale_id"].is_unique, "sales.sale_id has duplicates"

# Foreign key checks
invalid_product_ids = sales.loc[~sales["product_id"].isin(products["product_id"]), "product_id"].unique()
invalid_store_ids = sales.loc[~sales["store_id"].isin(stores["store_id"]), "store_id"].unique()

assert len(invalid_product_ids) == 0, f"Invalid product IDs in sales: {invalid_product_ids}"
assert len(invalid_store_ids) == 0, f"Invalid store IDs in sales: {invalid_store_ids}"

invalid_inventory_product_ids = inventory.loc[
    ~inventory["product_id"].isin(products["product_id"]), "product_id"
].unique()

invalid_inventory_store_ids = inventory.loc[
    ~inventory["store_id"].isin(stores["store_id"]), "store_id"
].unique()

assert len(invalid_inventory_product_ids) == 0, f"Invalid product IDs in inventory: {invalid_inventory_product_ids}"
assert len(invalid_inventory_store_ids) == 0, f"Invalid store IDs in inventory: {invalid_inventory_store_ids}"

# Business logic checks
assert (sales["units"] >= 0).all(), "Sales units contain negative values"
assert (inventory["stock_on_hand"] >= 0).all(), "Inventory contains negative stock"
assert (products["product_price"] >= products["product_cost"]).all(), "Some products have price lower than cost"


# -----------------------------
# 9. Add useful derived columns
# -----------------------------

products["unit_profit"] = products["product_price"] - products["product_cost"]

sales["year"] = sales["sale_date"].dt.year
sales["month"] = sales["sale_date"].dt.month
sales["year_month"] = sales["sale_date"].dt.to_period("M").astype(str)

stores["store_age_years"] = (
    (sales["sale_date"].max() - stores["store_open_date"]).dt.days / 365
).round(1)


# -----------------------------
# 10. Print quality reports
# -----------------------------

print_quality_report("sales", sales)
print_quality_report("products", products)
print_quality_report("stores", stores)
print_quality_report("inventory", inventory)


# -----------------------------
# 11. Export cleaned CSV files
# -----------------------------

sales.to_csv(CLEAN_DIR / "clean_sales.csv", index=False)
products.to_csv(CLEAN_DIR / "clean_products.csv", index=False)
stores.to_csv(CLEAN_DIR / "clean_stores.csv", index=False)
inventory.to_csv(CLEAN_DIR / "clean_inventory.csv", index=False)

print("\nCleaned files exported successfully.")