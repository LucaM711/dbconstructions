-- ============================================
-- File: 03_constraints.sql
-- Description: Foreign key and CHECK constraints for the inventory management system.
--              Constraints are named following the conventions:
--              fk_<child_table>_<parent_table> for foreign keys
--              chk_<table>_<description> for CHECK constraints
-- ============================================

-- Add constraints to tables

-- employee
ALTER TABLE employee
    ADD CONSTRAINT chk_employee_role CHECK (role IN ('Division Manager', 'Site Manager', 'Staff'));

-- division
ALTER TABLE division
    ADD CONSTRAINT fk_division_employee FOREIGN KEY (division_manager_contact) REFERENCES employee (phone_number);

-- construction_site
ALTER TABLE construction_site
    ADD CONSTRAINT fk_construction_site_employee FOREIGN KEY (site_manager_contact) REFERENCES employee (phone_number),
    ADD CONSTRAINT fk_construction_site_division FOREIGN KEY (division_id) REFERENCES division (division_id);

-- warehouse
ALTER TABLE warehouse
    ADD CONSTRAINT fk_warehouse_division FOREIGN KEY (division_id) REFERENCES division (division_id);

-- request
ALTER TABLE request
    ADD CONSTRAINT chk_request_approval_date_after_request_date CHECK (approval_date >= request_date),
    ADD CONSTRAINT fk_request_construction_site FOREIGN KEY (site_id) REFERENCES construction_site (site_id),
    ADD CONSTRAINT fk_request_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse (warehouse_id),
    ADD CONSTRAINT chk_request_status CHECK (status IN ('Pending', 'Approved', 'Rejected'));

-- delivery
ALTER TABLE delivery
    ADD CONSTRAINT fk_delivery_construction_site FOREIGN KEY (site_id) REFERENCES construction_site (site_id),
    ADD CONSTRAINT chk_delivery_status CHECK (delivery_status IN ('In Transit', 'Delivered', 'Canceled'));

-- item
ALTER TABLE item
    ADD CONSTRAINT fk_item_supplier FOREIGN KEY (supplier_id) REFERENCES supplier (tax_code);

-- inventory_level
ALTER TABLE inventory_level
    ADD CONSTRAINT chk_inventory_level_not_negative CHECK (quantity >= 0),
    ADD CONSTRAINT fk_inventory_level_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouse (warehouse_id),
    ADD CONSTRAINT fk_inventory_level_item FOREIGN KEY (item_id) REFERENCES item (item_id);

--purchase_order
ALTER TABLE purchase_order
    ADD CONSTRAINT fk_purchase_order_supplier FOREIGN KEY (supplier_id) REFERENCES supplier (tax_code),
    ADD CONSTRAINT chk_purchase_order_status CHECK (status IN ('Pending', 'Processing', 'Completed', 'Canceled'));

-- delivery_fulfillment
ALTER TABLE delivery_fulfillment
    ADD CONSTRAINT fk_delivery_fulfillment_request FOREIGN KEY (request_number) REFERENCES request (request_number),
    ADD CONSTRAINT fk_delivery_fulfillment_delivery FOREIGN KEY (delivery_number) REFERENCES delivery (delivery_number);

--request_detail
ALTER TABLE request_detail
    ADD CONSTRAINT chk_request_detail_quantity_greater_than_zero CHECK (quantity > 0),
    ADD CONSTRAINT fk_request_detail_request FOREIGN KEY (request_number) REFERENCES request (request_number),
    ADD CONSTRAINT fk_request_detail_item FOREIGN KEY (item_id) REFERENCES item (item_id);

-- delivery_detail
ALTER TABLE delivery_detail
    ADD CONSTRAINT chk_delivery_detail_quantity_greater_than_zero CHECK (quantity_shipped > 0),
    ADD CONSTRAINT fk_delivery_detail_delivery FOREIGN KEY (delivery_number) REFERENCES delivery (delivery_number),
    ADD CONSTRAINT fk_delivery_detail_item FOREIGN KEY (item_id) REFERENCES item (item_id);

-- order_detail
ALTER TABLE order_detail
    ADD CONSTRAINT fk_order_detail_item FOREIGN KEY (item_id) REFERENCES item (item_id),
    ADD CONSTRAINT fk_order_detail_purchase_order FOREIGN KEY (order_number) REFERENCES purchase_order (order_number);