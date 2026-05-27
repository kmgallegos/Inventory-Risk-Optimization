-- ============================================================
-- 04_create_dimensions.sql
-- Crea y pobla las 4 dimensiones a partir de v_sales_clean.
-- Orden requerido: dim_date, dim_store, dim_product, dim_weather.
--
-- NOTA DE DATOS: product_id no tiene categoria fija entre tiendas
-- (ej. P0001 es Electronics en S001 y Groceries en S002).
-- La clave natural de dim_product es (product_id, category).
-- El JOIN en la fact se resuelve sobre ambas columnas.
-- ============================================================

USE inventory;
GO

-- --------------------------------------------------------
-- dim_date
-- --------------------------------------------------------
DROP TABLE IF EXISTS dw.dim_date;

CREATE TABLE dw.dim_date (
    date_key    INT         NOT NULL,
    date        DATE        NOT NULL,
    year        INT         NOT NULL,
    quarter     INT         NOT NULL,
    month       INT         NOT NULL,
    month_name  VARCHAR(20) NOT NULL,
    week_number INT         NOT NULL,
    day_of_week INT         NOT NULL,
    day_name    VARCHAR(20) NOT NULL,
    seasonality VARCHAR(20) NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

-- date_key como entero YYYYMMDD (smart key).
-- GROUP BY en lugar de SELECT DISTINCT para evitar violacion de PK
-- si una fecha aparece con mas de un valor de seasonality en el CSV.
INSERT INTO dw.dim_date
SELECT
    CAST(FORMAT(date, 'yyyyMMdd') AS INT) AS date_key,
    date,
    YEAR(date)                            AS year,
    DATEPART(QUARTER, date)               AS quarter,
    MONTH(date)                           AS month,
    DATENAME(MONTH, date)                 AS month_name,
    DATEPART(WEEK, date)                  AS week_number,
    DATEPART(WEEKDAY, date)               AS day_of_week,
    DATENAME(WEEKDAY, date)               AS day_name,
    MAX(seasonality)                      AS seasonality
FROM staging.v_sales_clean
GROUP BY
    date,
    YEAR(date),
    DATEPART(QUARTER, date),
    MONTH(date),
    DATENAME(MONTH, date),
    DATEPART(WEEK, date),
    DATEPART(WEEKDAY, date),
    DATENAME(WEEKDAY, date);
GO

-- --------------------------------------------------------
-- dim_store
-- --------------------------------------------------------
DROP TABLE IF EXISTS dw.dim_store;

CREATE TABLE dw.dim_store (
    store_key INT         NOT NULL IDENTITY(1,1),
    store_id  VARCHAR(10) NOT NULL,
    region    VARCHAR(50) NOT NULL,
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
);

-- GROUP BY store_id con MAX(region) para garantizar un unico surrogate
-- por tienda y evitar un fan trap en la fact si un store_id aparece
-- con mas de una region en el CSV.
INSERT INTO dw.dim_store (store_id, region)
SELECT store_id, MAX(region) AS region
FROM staging.v_sales_clean
GROUP BY store_id
ORDER BY store_id;
GO

-- --------------------------------------------------------
-- dim_product
-- Clave natural compuesta: (product_id, category)
-- Un mismo product_id puede pertenecer a distintas categorias
-- segun la tienda; el surrogate product_key los distingue.
-- --------------------------------------------------------
DROP TABLE IF EXISTS dw.dim_product;

CREATE TABLE dw.dim_product (
    product_key INT         NOT NULL IDENTITY(1,1),
    product_id  VARCHAR(10) NOT NULL,
    category    VARCHAR(50) NOT NULL,
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

INSERT INTO dw.dim_product (product_id, category)
SELECT DISTINCT product_id, category
FROM staging.v_sales_clean
ORDER BY product_id, category;
GO

-- --------------------------------------------------------
-- dim_weather
-- --------------------------------------------------------
DROP TABLE IF EXISTS dw.dim_weather;

CREATE TABLE dw.dim_weather (
    weather_key       INT         NOT NULL IDENTITY(1,1),
    weather_condition VARCHAR(50) NOT NULL,
    CONSTRAINT pk_dim_weather PRIMARY KEY (weather_key)
);

INSERT INTO dw.dim_weather (weather_condition)
SELECT DISTINCT weather_condition
FROM staging.v_sales_clean
ORDER BY weather_condition;
GO
