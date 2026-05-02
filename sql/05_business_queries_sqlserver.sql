USE inventory_analytics;
GO

-- 1. Total revenue, cost, and profit
SELECT
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(cost), 2) AS total_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    CAST(SUM(profit) / NULLIF(SUM(revenue), 0) AS DECIMAL(10,4)) AS profit_margin
FROM dbo.vw_sales_detail;
GO


-- 2. Monthly revenue trend
SELECT
    year_month,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(units) AS total_units_sold
FROM dbo.vw_sales_detail
GROUP BY year_month
ORDER BY year_month;
GO


-- 3. Top 10 products by revenue
SELECT TOP 10
    product_name,
    product_category,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(units) AS total_units_sold
FROM dbo.vw_sales_detail
GROUP BY
    product_name,
    product_category
ORDER BY total_revenue DESC;
GO


-- 4. Top 10 products by profit
SELECT TOP 10
    product_name,
    product_category,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(revenue), 2) AS total_revenue,
    CAST(SUM(profit) / NULLIF(SUM(revenue), 0) AS DECIMAL(10,4)) AS profit_margin
FROM dbo.vw_sales_detail
GROUP BY
    product_name,
    product_category
ORDER BY total_profit DESC;
GO


-- 5. Revenue by product category
SELECT
    product_category,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(units) AS total_units_sold
FROM dbo.vw_sales_detail
GROUP BY product_category
ORDER BY total_revenue DESC;
GO


-- 6. Store performance ranking
SELECT
    store_name,
    store_city,
    store_location,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(units) AS total_units_sold
FROM dbo.vw_sales_detail
GROUP BY
    store_name,
    store_city,
    store_location
ORDER BY total_revenue DESC;
GO


-- 7. Low stock and out of stock products
SELECT
    store_name,
    store_city,
    product_name,
    product_category,
    stock_on_hand,
    stock_status
FROM dbo.vw_inventory_status
WHERE stock_status IN ('Low Stock', 'Out of Stock')
ORDER BY
    stock_on_hand ASC,
    product_name;
GO


-- 8. Dead stock candidates
SELECT
    store_name,
    product_name,
    product_category,
    stock_on_hand,
    units_sold_90d,
    stock_risk_status
FROM dbo.vw_stock_risk
WHERE stock_risk_status = 'Dead Stock Candidate'
ORDER BY stock_on_hand DESC;
GO


-- 9. High-risk stock items
SELECT
    store_name,
    product_name,
    product_category,
    stock_on_hand,
    units_sold_90d,
    avg_daily_units_90d,
    stock_coverage_days,
    stock_risk_status
FROM dbo.vw_stock_risk
WHERE stock_risk_status IN ('Out of Stock', 'High Risk')
ORDER BY
    stock_risk_status,
    stock_coverage_days ASC;
GO


-- 10. High stock but low sales
SELECT
    store_name,
    product_name,
    product_category,
    stock_on_hand,
    units_sold_90d
FROM dbo.vw_stock_risk
WHERE stock_on_hand >= 50
  AND units_sold_90d <= 5
ORDER BY stock_on_hand DESC;
GO