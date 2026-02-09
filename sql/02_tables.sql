-- ============================================
-- File: 02_tables.sql
-- Description: Table definitions for the inventory management system.
--              Tables are ordered by dependency (independent tables first).
--              Foreign keys and CHECK constraints are defined in 03_constraints.sql.
-- ============================================

-- Create tables
CREATE TABLE employee (
    phone_number VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    PRIMARY KEY (phone_number)
);

CREATE TABLE supplier (
    tax_code VARCHAR(20),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (tax_code)
);

CREATE TABLE division (
    division_id INTEGER,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    division_manager_contact VARCHAR(20) NOT NULL,
    PRIMARY KEY (division_id)
);

CREATE TABLE construction_site (
    site_id INTEGER,
    name VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address VARCHAR(255) NOT NULL,
    site_manager_contact VARCHAR(20) NOT NULL,
    division_id INTEGER NOT NULL,
    PRIMARY KEY (site_id)
);

CREATE TABLE warehouse (
    warehouse_id INTEGER,
    name VARCHAR(100),
    address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    division_id INTEGER NOT NULL,
    PRIMARY KEY (warehouse_id)
);

CREATE TABLE request ( 
    request_number INTEGER GENERATED ALWAYS AS IDENTITY, 
    approval_date DATE, 
    status VARCHAR(50) NOT NULL, 
    request_date DATE NOT NULL, 
    site_id INTEGER NOT NULL, 
    warehouse_id INTEGER NOT NULL, 
    PRIMARY KEY (request_number)
);

CREATE TABLE delivery (
    delivery_number INTEGER GENERATED ALWAYS AS IDENTITY,
    dispatch_date DATE NOT NULL,
    delivery_status VARCHAR(50) NOT NULL,
    arrival_date DATE,
    site_id INTEGER NOT NULL,
    PRIMARY KEY (delivery_number)
);

CREATE TABLE item (
    item_id VARCHAR(20),
    description TEXT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    supplier_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (item_id)
);

CREATE TABLE inventory_level (
    inventory_level_id INTEGER GENERATED ALWAYS AS IDENTITY,
    quantity INTEGER NOT NULL,
    last_update TIMESTAMP NOT NULL,
    warehouse_id INTEGER NOT NULL,
    item_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (inventory_level_id)
);

CREATE TABLE purchase_order (
    order_number INTEGER GENERATED ALWAYS AS IDENTITY,
    total_amount DECIMAL(10,2) NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    supplier_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (order_number)
);

CREATE TABLE delivery_fulfillment (
    request_number INTEGER,
    delivery_number INTEGER,
    fulfillment_date DATE NOT NULL,
    PRIMARY KEY (request_number, delivery_number)
);

CREATE TABLE request_detail (
    request_number INTEGER,
    item_id VARCHAR(20) NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (request_number, item_id)
);

CREATE TABLE delivery_detail (
    delivery_number INTEGER,
    item_id VARCHAR(20) NOT NULL,
    quantity_shipped INTEGER NOT NULL,
    PRIMARY KEY (delivery_number, item_id)
);

CREATE TABLE order_detail (
    item_id VARCHAR(20) NOT NULL,
    order_number INTEGER,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL (10,2) NOT NULL,
    PRIMARY KEY (item_id, order_number)
);