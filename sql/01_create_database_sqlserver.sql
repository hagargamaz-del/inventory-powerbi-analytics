IF DB_ID('inventory_analytics') IS NULL
BEGIN
    CREATE DATABASE inventory_analytics;
END;


USE inventory_analytics;