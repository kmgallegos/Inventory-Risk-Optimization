-- ============================================================
-- 06_validation_queries.sql
-- Validaciones post-carga para confirmar integridad del modelo.
-- ============================================================

USE inventory;
GO

-- 1. Conteo de filas por tabla
SELECT 'staging.sales_raw'       AS tabla, COUNT(*) AS filas FROM staging.sales_raw
UNION ALL
SELECT 'dw.dim_date',                       COUNT(*) FROM dw.dim_date
UNION ALL
SELECT 'dw.dim_store',                      COUNT(*) FROM dw.dim_store
UNION ALL
SELECT 'dw.dim_product',                    COUNT(*) FROM dw.dim_product
UNION ALL
SELECT 'dw.dim_weather',                    COUNT(*) FROM dw.dim_weather
UNION ALL
SELECT 'dw.fact_inventory_sales',           COUNT(*) FROM dw.fact_inventory_sales;
-- Esperado: fact = 76000, staging = 76000

-- --------------------------------------------------------
-- 2. Duplicados en staging por Date + Store ID + Product ID
-- --------------------------------------------------------
SELECT
    date,
    store_id,
    product_id,
    COUNT(*) AS total
FROM staging.sales_raw
GROUP BY date, store_id, product_id
HAVING COUNT(*) > 1
ORDER BY total DESC;
-- Esperado: 0 filas (sin duplicados)

-- Resumen rapido
SELECT
    COUNT(*) AS combinaciones_duplicadas
FROM (
    SELECT date, store_id, product_id
    FROM staging.sales_raw
    GROUP BY date, store_id, product_id
    HAVING COUNT(*) > 1
) AS dup;

-- --------------------------------------------------------
-- 3. Integridad referencial: registros de fact sin FK valida
-- --------------------------------------------------------
SELECT 'Orphan date_key'     AS check_name, COUNT(*) AS total
FROM dw.fact_inventory_sales f
LEFT JOIN dw.dim_date d ON f.date_key = d.date_key
WHERE d.date_key IS NULL
UNION ALL
SELECT 'Orphan store_key',   COUNT(*)
FROM dw.fact_inventory_sales f
LEFT JOIN dw.dim_store s ON f.store_key = s.store_key
WHERE s.store_key IS NULL
UNION ALL
SELECT 'Orphan product_key', COUNT(*)
FROM dw.fact_inventory_sales f
LEFT JOIN dw.dim_product p ON f.product_key = p.product_key
WHERE p.product_key IS NULL
UNION ALL
SELECT 'Orphan weather_key', COUNT(*)
FROM dw.fact_inventory_sales f
LEFT JOIN dw.dim_weather w ON f.weather_key = w.weather_key
WHERE w.weather_key IS NULL;
-- Esperado: 0 en todos

-- --------------------------------------------------------
-- 4. Nulos en columnas criticas de la fact
-- --------------------------------------------------------
SELECT
    SUM(CASE WHEN date_key    IS NULL THEN 1 ELSE 0 END) AS null_date_key,
    SUM(CASE WHEN store_key   IS NULL THEN 1 ELSE 0 END) AS null_store_key,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN weather_key IS NULL THEN 1 ELSE 0 END) AS null_weather_key,
    SUM(CASE WHEN revenue     IS NULL THEN 1 ELSE 0 END) AS null_revenue
FROM dw.fact_inventory_sales;

-- --------------------------------------------------------
-- 5. Distribucion de flags de negocio
-- --------------------------------------------------------
SELECT
    restock_flag,
    overstock_flag,
    COUNT(*)                                                    AS total_filas,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS pct
FROM dw.fact_inventory_sales
GROUP BY restock_flag, overstock_flag
ORDER BY restock_flag, overstock_flag;

-- --------------------------------------------------------
-- 6. Rango de fechas cubierto
-- --------------------------------------------------------
SELECT
    MIN(date)                              AS fecha_inicio,
    MAX(date)                              AS fecha_fin,
    DATEDIFF(DAY, MIN(date), MAX(date))    AS dias_cubiertos
FROM dw.dim_date;

-- --------------------------------------------------------
-- 7. Verificacion del calculo de revenue (muestra manual)
-- --------------------------------------------------------
SELECT TOP 5
    f.fact_key,
    f.units_sold,
    f.price,
    f.discount_pct,
    f.revenue                                                           AS revenue_almacenado,
    CAST(f.units_sold * f.price * (1.0 - f.discount_pct / 100.0)
         AS DECIMAL(14,2))                                              AS revenue_recalculado
FROM dw.fact_inventory_sales f;
