-- ============================================
-- File: 04_indexes.sql
-- Description: Index definitions for the inventory management system.
--              Primary keys and UNIQUE columns are automatically indexed by PostgreSQL.
--              These indexes cover foreign keys and frequently queried columns
--              based on the table of operations analysis.
-- ============================================

-- employee (no additional indexes needed — phone_number PK and email UNIQUE are auto-indexed)

-- division
CREATE INDEX idx_division_division_manager_contact ON division (division_manager_contact);

-- construction_site
CREATE INDEX idx_construction_site_site_manager_contact ON construction_site (site_manager_contact);
CREATE INDEX idx_construction_site_division_id ON construction_site (division_id);

-- warehouse
CREATE INDEX idx_warehouse_division_id ON warehouse (division_id);

-- item
CREATE INDEX idx_item_category ON item (category);
CREATE INDEX idx_item_name ON item (name);
CREATE INDEX idx_item_supplier_id ON item (supplier_id);

-- request
CREATE INDEX idx_request_site_id ON request (site_id);
CREATE INDEX idx_request_warehouse_id ON request (warehouse_id);
CREATE INDEX idx_request_status ON request (status);

-- delivery
CREATE INDEX idx_delivery_site_id ON delivery (site_id);

-- inventory_level
CREATE INDEX idx_inventory_level_warehouse_id ON inventory_level (warehouse_id);
CREATE INDEX idx_inventory_level_item_id ON inventory_level (item_id);
CREATE INDEX idx_inventory_level_quantity ON inventory_level (quantity);

-- purchase_order
CREATE INDEX idx_purchase_order_supplier_id ON purchase_order (supplier_id);

-- delivery_fulfillment
CREATE INDEX idx_delivery_fulfillment_delivery_number ON delivery_fulfillment (delivery_number);

-- request_detail
CREATE INDEX idx_request_detail_item_id ON request_detail (item_id);

-- delivery_detail
CREATE INDEX idx_delivery_detail_item_id ON delivery_detail (item_id);

-- order_detail
CREATE INDEX idx_order_detail_order_number ON order_detail (order_number);