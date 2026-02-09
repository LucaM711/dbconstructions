-- ============================================
-- File: 01_schema.sql
-- Description: schema of dbconstructions tracking all the inventory of the company and the flow of items from warehouses towards dedicated construction sites
-- ============================================

-- Create schema
CREATE SCHEMA IF NOT EXISTS inventory;

-- Set default search path
ALTER DATABASE dbconstructions SET search_path TO inventory, public;
SET search_path TO inventory, public;
