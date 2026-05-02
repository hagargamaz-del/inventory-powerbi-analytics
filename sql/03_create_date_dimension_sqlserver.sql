USE inventory_analytics;
GO

DROP TABLE IF EXISTS dbo.dim_date;
GO

CREATE TABLE dbo.dim_date (
    date_key DATE PRIMARY KEY,
    year INT,
    month_number INT,
    month_name VARCHAR(20),
    year_month VARCHAR(7),
    quarter_number INT,
    day_of_week_number INT,
    day_name VARCHAR(20)
);
GO

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT
    @StartDate = MIN(sale_date),
    @EndDate = MAX(sale_date)
FROM dbo.fact_sales;

WITH date_range AS (
    SELECT @StartDate AS date_key

    UNION ALL

    SELECT DATEADD(DAY, 1, date_key)
    FROM date_range
    WHERE date_key < @EndDate
)
INSERT INTO dbo.dim_date (
    date_key,
    year,
    month_number,
    month_name,
    year_month,
    quarter_number,
    day_of_week_number,
    day_name
)
SELECT
    date_key,
    YEAR(date_key) AS year,
    MONTH(date_key) AS month_number,
    DATENAME(MONTH, date_key) AS month_name,
    CONVERT(CHAR(7), date_key, 120) AS year_month,
    DATEPART(QUARTER, date_key) AS quarter_number,
    DATEPART(WEEKDAY, date_key) AS day_of_week_number,
    DATENAME(WEEKDAY, date_key) AS day_name
FROM date_range
OPTION (MAXRECURSION 0);
GO

ALTER TABLE dbo.fact_sales
ADD CONSTRAINT fk_sales_date
FOREIGN KEY (sale_date) REFERENCES dbo.dim_date(date_key);
GO