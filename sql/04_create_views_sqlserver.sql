USE inventory_analytics;
GO

CREATE OR ALTER VIEW dbo.vw_sales_detail AS
SELECT
    fs.sale_id,
    fs.sale_date,
    dd.year,
    dd.month_number,
    dd.month_name,
    dd.year_month,

    fs.store_id,
    ds.store_name,
    ds.store_city,
    ds.store_location,

    fs.product_id,
    dp.product_name,
    dp.product_category,

    fs.units,
    dp.product_cost,
    dp.product_price,
    dp.unit_profit,

    fs.units * dp.product_price AS revenue,
    fs.units * dp.product_cost AS cost,
    fs.units * dp.unit_profit AS profit
FROM dbo.fact_sales fs
JOIN dbo.dim_products dp
    ON fs.product_id = dp.product_id
JOIN dbo.dim_stores ds
    ON fs.store_id = ds.store_id
JOIN dbo.dim_date dd
    ON fs.sale_date = dd.date_key;
GO


CREATE OR ALTER VIEW dbo.vw_inventory_status AS
SELECT
    fi.store_id,
    ds.store_name,
    ds.store_city,
    ds.store_location,

    fi.product_id,
    dp.product_name,
    dp.product_category,

    fi.stock_on_hand,

    fi.stock_on_hand * dp.product_cost AS inventory_cost_value,
    fi.stock_on_hand * dp.product_price AS inventory_retail_value,

    CASE
        WHEN fi.stock_on_hand = 0 THEN 'Out of Stock'
        WHEN fi.stock_on_hand <= 10 THEN 'Low Stock'
        ELSE 'Available'
    END AS stock_status
FROM dbo.fact_inventory fi
JOIN dbo.dim_products dp
    ON fi.product_id = dp.product_id
JOIN dbo.dim_stores ds
    ON fi.store_id = ds.store_id;
GO


CREATE OR ALTER VIEW dbo.vw_product_performance AS
SELECT
    dp.product_id,
    dp.product_name,
    dp.product_category,

    SUM(fs.units) AS total_units_sold,
    SUM(fs.units * dp.product_price) AS total_revenue,
    SUM(fs.units * dp.product_cost) AS total_cost,
    SUM(fs.units * dp.unit_profit) AS total_profit,

    CAST(
        SUM(fs.units * dp.unit_profit) / NULLIF(SUM(fs.units * dp.product_price), 0)
        AS DECIMAL(10,4)
    ) AS profit_margin
FROM dbo.fact_sales fs
JOIN dbo.dim_products dp
    ON fs.product_id = dp.product_id
GROUP BY
    dp.product_id,
    dp.product_name,
    dp.product_category;
GO


CREATE OR ALTER VIEW dbo.vw_store_performance AS
SELECT
    ds.store_id,
    ds.store_name,
    ds.store_city,
    ds.store_location,

    SUM(fs.units) AS total_units_sold,
    SUM(fs.units * dp.product_price) AS total_revenue,
    SUM(fs.units * dp.product_cost) AS total_cost,
    SUM(fs.units * dp.unit_profit) AS total_profit,

    CAST(
        SUM(fs.units * dp.unit_profit) / NULLIF(SUM(fs.units * dp.product_price), 0)
        AS DECIMAL(10,4)
    ) AS profit_margin
FROM dbo.fact_sales fs
JOIN dbo.dim_products dp
    ON fs.product_id = dp.product_id
JOIN dbo.dim_stores ds
    ON fs.store_id = ds.store_id
GROUP BY
    ds.store_id,
    ds.store_name,
    ds.store_city,
    ds.store_location;
GO


CREATE OR ALTER VIEW dbo.vw_stock_risk AS
WITH max_date AS (
    SELECT MAX(sale_date) AS latest_date
    FROM dbo.fact_sales
),

sales_last_90_days AS (
    SELECT
        fs.store_id,
        fs.product_id,
        SUM(fs.units) AS units_sold_90d
    FROM dbo.fact_sales fs
    CROSS JOIN max_date md
    WHERE fs.sale_date > DATEADD(DAY, -90, md.latest_date)
    GROUP BY
        fs.store_id,
        fs.product_id
)

SELECT
    fi.store_id,
    ds.store_name,
    ds.store_city,
    ds.store_location,

    fi.product_id,
    dp.product_name,
    dp.product_category,

    fi.stock_on_hand,

    ISNULL(s90.units_sold_90d, 0) AS units_sold_90d,

    CAST(ISNULL(s90.units_sold_90d, 0) / 90.0 AS DECIMAL(10,2)) AS avg_daily_units_90d,

    CASE
        WHEN ISNULL(s90.units_sold_90d, 0) = 0 THEN NULL
        ELSE CAST(fi.stock_on_hand / NULLIF((s90.units_sold_90d / 90.0), 0) AS DECIMAL(10,1))
    END AS stock_coverage_days,

    CASE
        WHEN fi.stock_on_hand = 0 THEN 'Out of Stock'
        WHEN ISNULL(s90.units_sold_90d, 0) = 0 AND fi.stock_on_hand > 0 THEN 'Dead Stock Candidate'
        WHEN fi.stock_on_hand / NULLIF((s90.units_sold_90d / 90.0), 0) < 7 THEN 'High Risk'
        WHEN fi.stock_on_hand / NULLIF((s90.units_sold_90d / 90.0), 0) < 14 THEN 'Medium Risk'
        ELSE 'Healthy'
    END AS stock_risk_status
FROM dbo.fact_inventory fi
JOIN dbo.dim_products dp
    ON fi.product_id = dp.product_id
JOIN dbo.dim_stores ds
    ON fi.store_id = ds.store_id
LEFT JOIN sales_last_90_days s90
    ON fi.store_id = s90.store_id
    AND fi.product_id = s90.product_id;
GO