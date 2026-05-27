-- ============================================================
-- 05_create_fact_inventory_sales.sql
-- Crea y pobla la tabla de hechos. Resuelve FKs via JOIN a
-- las cuatro dimensiones. La granularidad es Date + Store + Product.
-- ============================================================

USE inventory;
GO

DROP TABLE IF EXISTS dw.fact_inventory_sales;

CREATE TABLE dw.fact_inventory_sales (
    fact_key                INT           NOT NULL IDENTITY(1,1),

    -- Llaves foraneas
    date_key                INT           NOT NULL,
    store_key               INT           NOT NULL,
    product_key             INT           NOT NULL,
    weather_key             INT           NOT NULL,

    -- Flags (dimensiones degeneradas)
    promotion_flag          TINYINT       NOT NULL,
    epidemic_flag           TINYINT       NOT NULL,

    -- Metricas base
    inventory_level         INT           NOT NULL,
    units_sold              INT           NOT NULL,
    units_ordered           INT           NOT NULL,
    price                   DECIMAL(10,2) NOT NULL,
    discount_pct            INT           NOT NULL,
    competitor_pricing      DECIMAL(10,2) NOT NULL,
    demand                  INT           NOT NULL,

    -- Columnas calculadas
    available_stock         INT           NOT NULL,
    revenue                 DECIMAL(14,2) NOT NULL,
    discount_amount         DECIMAL(10,2) NOT NULL,
    price_gap_vs_competitor DECIMAL(10,2) NOT NULL,
    stock_coverage_days     FLOAT         NULL,
    stock_demand_gap        INT           NOT NULL,
    sales_demand_gap        INT           NOT NULL,
    restock_flag            TINYINT       NOT NULL,
    overstock_flag          TINYINT       NOT NULL,

    CONSTRAINT pk_fact          PRIMARY KEY (fact_key),
    CONSTRAINT fk_fact_date     FOREIGN KEY (date_key)    REFERENCES dw.dim_date    (date_key),
    CONSTRAINT fk_fact_store    FOREIGN KEY (store_key)   REFERENCES dw.dim_store   (store_key),
    CONSTRAINT fk_fact_product  FOREIGN KEY (product_key) REFERENCES dw.dim_product (product_key),
    CONSTRAINT fk_fact_weather  FOREIGN KEY (weather_key) REFERENCES dw.dim_weather (weather_key)
);
GO

-- Carga de la fact resolviendo FKs
INSERT INTO dw.fact_inventory_sales (
    date_key, store_key, product_key, weather_key,
    promotion_flag, epidemic_flag,
    inventory_level, units_sold, units_ordered,
    price, discount_pct, competitor_pricing, demand,
    available_stock, revenue, discount_amount,
    price_gap_vs_competitor, stock_coverage_days,
    stock_demand_gap, sales_demand_gap,
    restock_flag, overstock_flag
)
SELECT
    dd.date_key,
    ds.store_key,
    dp.product_key,
    dw_w.weather_key,
    v.promotion_flag,
    v.epidemic_flag,
    v.inventory_level,
    v.units_sold,
    v.units_ordered,
    v.price,
    v.discount_pct,
    v.competitor_pricing,
    v.demand,
    v.available_stock,
    v.revenue,
    v.discount_amount,
    v.price_gap_vs_competitor,
    v.stock_coverage_days,
    v.stock_demand_gap,
    v.sales_demand_gap,
    v.restock_flag,
    v.overstock_flag
FROM staging.v_sales_clean        v
JOIN dw.dim_date    dd ON dd.date_key          = CAST(FORMAT(v.date, 'yyyyMMdd') AS INT)
JOIN dw.dim_store   ds ON ds.store_id          = v.store_id
JOIN dw.dim_product dp ON dp.product_id        = v.product_id
                      AND dp.category          = v.category
JOIN dw.dim_weather dw_w ON dw_w.weather_condition = v.weather_condition;
GO
