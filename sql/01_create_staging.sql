-- ============================================================
-- 01_create_staging.sql
-- Crea el esquema staging y la tabla que replica exactamente
-- el CSV. Todos los campos en VARCHAR para evitar errores
-- de tipo durante la importacion.
-- ============================================================

USE inventory;
GO

-- Crear schemas si no existen
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw');
GO

-- Tabla raw: espejo del CSV, sin transformacion
DROP TABLE IF EXISTS staging.sales_raw;
GO

CREATE TABLE staging.sales_raw (
    date               VARCHAR(20),
    store_id           VARCHAR(10),
    product_id         VARCHAR(10),
    category           VARCHAR(50),
    region             VARCHAR(50),
    inventory_level    VARCHAR(10),
    units_sold         VARCHAR(10),
    units_ordered      VARCHAR(10),
    price              VARCHAR(20),
    discount_pct       VARCHAR(10),
    weather_condition  VARCHAR(50),
    promotion          VARCHAR(5),
    competitor_pricing VARCHAR(20),
    seasonality        VARCHAR(20),
    epidemic           VARCHAR(5),
    demand             VARCHAR(10)
);
GO
