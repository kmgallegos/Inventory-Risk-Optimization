-- ============================================================
-- 03_create_clean_view.sql
-- Vista con tipos corregidos y todas las columnas calculadas.
-- Es la fuente para cargar dimensiones y fact table.
-- ============================================================

USE inventory;
GO

CREATE OR ALTER VIEW staging.v_sales_clean AS
SELECT
    -- Identificadores
    CONVERT(DATE, date, 23)             AS date,
    TRIM(store_id)                      AS store_id,
    TRIM(product_id)                    AS product_id,
    TRIM(category)                      AS category,
    TRIM(region)                        AS region,
    TRIM(weather_condition)             AS weather_condition,
    TRIM(seasonality)                   AS seasonality,

    -- Metricas base tipadas
    CAST(inventory_level    AS INT)           AS inventory_level,
    CAST(units_sold         AS INT)           AS units_sold,
    CAST(units_ordered      AS INT)           AS units_ordered,
    CAST(price              AS DECIMAL(10,2)) AS price,
    CAST(discount_pct       AS INT)           AS discount_pct,
    CAST(competitor_pricing AS DECIMAL(10,2)) AS competitor_pricing,
    CAST(demand             AS INT)           AS demand,

    -- Flags (dimensiones degeneradas)
    CAST(promotion AS TINYINT) AS promotion_flag,
    CAST(epidemic  AS TINYINT) AS epidemic_flag,

    -- Columnas calculadas
    CAST(inventory_level AS INT) + CAST(units_ordered AS INT)
        AS available_stock,

    CAST(units_sold AS INT)
        * CAST(price AS DECIMAL(10,2))
        * (1.0 - CAST(discount_pct AS INT) / 100.0)
        AS revenue,

    CAST(price AS DECIMAL(10,2))
        * (CAST(discount_pct AS INT) / 100.0)
        AS discount_amount,

    CAST(price AS DECIMAL(10,2)) - CAST(competitor_pricing AS DECIMAL(10,2))
        AS price_gap_vs_competitor,

    -- Dias de cobertura (NULL cuando units_sold = 0)
    CASE
        WHEN CAST(units_sold AS INT) = 0 THEN NULL
        ELSE CAST(inventory_level AS FLOAT) / CAST(units_sold AS INT)
    END AS stock_coverage_days,

    -- Brecha demanda vs inventario disponible (incluye pedido)
    CAST(demand AS INT)
        - (CAST(inventory_level AS INT) + CAST(units_ordered AS INT))
        AS stock_demand_gap,

    -- Brecha demanda vs lo efectivamente vendido
    CAST(demand AS INT) - CAST(units_sold AS INT)
        AS sales_demand_gap,

    -- Alerta reabastecimiento: stock total < demanda
    CASE
        WHEN CAST(inventory_level AS INT) + CAST(units_ordered AS INT)
             < CAST(demand AS INT)
        THEN 1 ELSE 0
    END AS restock_flag,

    -- Alerta sobrestock: evita division cuando units_sold = 0
    CASE
        WHEN CAST(units_sold AS INT) > 0
         AND CAST(inventory_level AS INT) > CAST(units_sold AS INT) * 3
        THEN 1 ELSE 0
    END AS overstock_flag

FROM staging.sales_raw;
GO
