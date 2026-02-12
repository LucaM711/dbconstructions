-- ============================================
-- File: 06_functions.sql
-- Description: Stored procedures and functions for the inventory management system.
--              Procedures handle data modifications (INSERT, UPDATE).
--              Functions return query results for cross-division lookups.
-- ============================================
-- Procedure: Submit a new request
-- Description: Creates a new pending request from a construction site to a warehouse
CREATE OR REPLACE PROCEDURE submit_new_request(
    p_site_id INTEGER,          -- which construction site is requesting
    p_warehouse_id INTEGER      -- which warehouse should handle it
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert a new request with automatic defaults
    INSERT INTO request (
        approval_date,
        status,
        request_date,
        site_id,
        warehouse_id
    )
    VALUES (
        NULL,                   -- no approval yet
        'Pending',              -- all new requests start as pending
        CURRENT_DATE,           -- today's date
        p_site_id,
        p_warehouse_id
    );
END;
$$;

-- Procedure: Update inventory after delivery
-- Description: Decreases warehouse stock and marks delivery as completed
CREATE OR REPLACE PROCEDURE update_inventory_after_delivery(
    p_delivery_number INTEGER     -- which delivery just arrived
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Decrease warehouse stock for each item in the delivery
    UPDATE inventory_level il
    SET
        quantity = il.quantity - dd.quantity_shipped,
        last_update = NOW()
    FROM delivery_detail dd
    JOIN delivery_fulfillment df ON dd.delivery_number = df.delivery_number
    JOIN request r ON df.request_number = r.request_number
    WHERE dd.delivery_number = p_delivery_number
    AND il.item_id = dd.item_id
    AND il.warehouse_id = r.warehouse_id;

    -- Mark the delivery as completed
    UPDATE delivery
    SET
        delivery_status = 'Delivered',
        arrival_date = CURRENT_DATE
    WHERE delivery_number = p_delivery_number;
END;
$$;

-- Procedure: Supplier delivery item
-- Description: Update stock when items arrive from suppliers
CREATE OR REPLACE PROCEDURE process_supplier_delivery(
    p_item_id VARCHAR(20),              -- which item is being received
    p_warehouse_id INTEGER,         -- which warehouse receives it
    p_quantity INTEGER             -- how many units arrived
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if this item already exists in this warehouse's inventory
    IF EXISTS (
        SELECT 1 FROM inventory_level
        WHERE item_id = p_item_id
        AND warehouse_id = p_warehouse_id
    ) THEN
        -- Item exists: increase the quantity and update timestamp
        UPDATE inventory_level
        SET
            quantity = quantity + p_quantity,
            last_update = NOW()
        WHERE item_id = p_item_id
        AND warehouse_id = p_warehouse_id;
    ELSE
        -- Item is new to this warehouse: create a new inventory record
        INSERT INTO inventory_level (
            quantity,
            last_update,
            warehouse_id,
            item_id
        )
        VALUES (
            p_quantity,
            NOW(),
            p_warehouse_id,
            p_item_id
        );
    END IF;
END;
$$;

-- Function: Item availability check
-- Description: Check for an available item across divisions
CREATE OR REPLACE FUNCTION f_cross_division_item_check(
    f_item_id VARCHAR(20)
)
RETURNS TABLE (
    warehouse_name VARCHAR(100),
    warehouse_city VARCHAR(50),
    division_name VARCHAR(100),
    division_city VARCHAR(50),
    manager_contact VARCHAR(20),
    quantity INTEGER 
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        w.name,
        w.city,
        d.name,
        d.city,
        d.division_manager_contact,
        il.quantity
    FROM warehouse w
    JOIN inventory_level il ON il.warehouse_id = w.warehouse_id
    JOIN division d ON d.division_id = w.division_id
    WHERE il.item_id = f_item_id;
END;
$$;

-- Trigger Function: Validate site-warehouse consistency
-- Description: Enforces the business rule that all requests from the same construction site must be directed to the same warehouse.
CREATE OR REPLACE FUNCTION trg_validate_site_warehouse_consistency()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_warehouse INTEGER;
BEGIN
    -- Check if this construction site has any previous requests
    SELECT warehouse_id INTO v_existing_warehouse
    FROM request
    WHERE site_id = NEW.site_id
    LIMIT 1;

    -- If previous requests exist and the warehouse doesn't match, reject
    IF v_existing_warehouse IS NOT NULL 
       AND v_existing_warehouse != NEW.warehouse_id THEN
        RAISE EXCEPTION 
            'Site % is already assigned to warehouse %. Cannot use warehouse %.',
            NEW.site_id, v_existing_warehouse, NEW.warehouse_id;
    END IF;

    -- Allow the insert to proceed
    RETURN NEW;
END;
$$;

-- Bind the function to the request table
CREATE TRIGGER trg_request_site_warehouse_check
BEFORE INSERT ON request
FOR EACH ROW
EXECUTE FUNCTION trg_validate_site_warehouse_consistency();
