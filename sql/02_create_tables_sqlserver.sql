USE inventory_analytics;
GO

DROP TABLE IF EXISTS dbo.fact_inventory;
DROP TABLE IF EXISTS dbo.fact_sales;
DROP TABLE IF EXISTS dbo.dim_date;
DROP TABLE IF EXISTS dbo.dim_products;
DROP TABLE IF EXISTS dbo.dim_stores;
GO

CREATE TABLE dbo.dim_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category VARCHAR(100) NOT NULL,
    product_cost DECIMAL(10,2) NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    unit_profit DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE dbo.dim_stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    store_city VARCHAR(100) NOT NULL,
    store_location VARCHAR(100) NOT NULL,
    store_open_date DATE NOT NULL,
    store_age_years DECIMAL(5,2)
);
GO

CREATE TABLE dbo.fact_sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    store_id INT NOT NULL,
    product_id INT NOT NULL,
    units INT NOT NULL,
    year INT,
    month INT,
    year_month VARCHAR(7),

    CONSTRAINT fk_sales_store
        FOREIGN KEY (store_id) REFERENCES dbo.dim_stores(store_id),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id) REFERENCES dbo.dim_products(product_id)
);
GO

CREATE TABLE dbo.fact_inventory (
    store_id INT NOT NULL,
    product_id INT NOT NULL,
    stock_on_hand INT NOT NULL,

    CONSTRAINT pk_fact_inventory
        PRIMARY KEY (store_id, product_id),

    CONSTRAINT fk_inventory_store
        FOREIGN KEY (store_id) REFERENCES dbo.dim_stores(store_id),

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id) REFERENCES dbo.dim_products(product_id)
);
GO