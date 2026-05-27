-- ============================================================
-- 02_load_data.sql
-- Carga el CSV en staging.sales_raw via BULK INSERT.
-- CODEPAGE = '65001' garantiza lectura correcta en UTF-8.
-- FIRSTROW = 2 omite el encabezado del CSV.
--
-- INSTRUCCION: cambia @csv_path por la ruta absoluta de tu CSV.
-- El SQL Server debe tener acceso de lectura a esa ruta.
-- No subas esta variable con tu ruta personal a GitHub;
-- usa el template con el placeholder de abajo.
-- ============================================================

USE inventory;
GO

-- *** CAMBIA ESTA RUTA ANTES DE EJECUTAR ***
DECLARE @csv_path NVARCHAR(500) = N'C:\RUTA\A\TU\sales_data.csv';

DECLARE @sql NVARCHAR(2000) =
    N'BULK INSERT staging.sales_raw FROM ''' + @csv_path + N''' ' +
    N'WITH (FIRSTROW=2, FIELDTERMINATOR='','', ROWTERMINATOR=''\n'', CODEPAGE=''65001'', TABLOCK)';

TRUNCATE TABLE staging.sales_raw;
EXEC sp_executesql @sql;
GO

-- Verificacion de carga
SELECT COUNT(*) AS total_filas_cargadas FROM staging.sales_raw;
-- Esperado: 76000
