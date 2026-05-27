-- ============================================================
-- 00_create_database.sql
-- Crea la base de datos del proyecto si no existe.
-- Ejecutar conectado a master con permisos sysadmin o dbcreator.
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'inventory')
    CREATE DATABASE inventory;
GO

USE inventory;
GO

PRINT 'Base de datos inventory lista.';
GO
