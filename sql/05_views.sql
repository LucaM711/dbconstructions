-- View: Stock availability
-- Description: Current stock per item per warehouse
CREATE VIEW v_stock_availability AS
SELECT
    i.name AS item_name,
    i.category AS category,
    w.name AS warehouse_name,
    w.city AS warehouse_location,
    il.quantity AS current_stock,
    il.last_update AS last_update
FROM inventory_level il
JOIN item i ON il.item_id = i.item_id
JOIN warehouse w ON il.warehouse_id = w.warehouse_id
ORDER BY w.name, i.name;

-- View: Low stock alert
-- Description: Items below dynamic threshold based on consumption rate
CREATE VIEW v_low_stock_alert AS
WITH request_totals AS (
   SELECT rd.item_id,
       SUM(rd.quantity) AS total_requested,
       EXTRACT(MONTH FROM AGE(MAX(r.request_date), MIN(r.request_date))) + 1 AS months_span
    FROM request_detail rd
    JOIN request r ON rd.request_number = r.request_number
    GROUP BY rd.item_id
),
monthly_consumption AS (
    SELECT 
         item_id,
         total_requested,
         months_span,
         total_requested / months_span AS avg_monthly_consumption
   FROM request_totals
)
SELECT
    i.name AS item_name,
    w.name AS warehouse_name,
    w.city AS warehouse_location,
    il.quantity AS current_stock,
    mc.avg_monthly_consumption AS monthly_consumption,
    (il.quantity / mc.avg_monthly_consumption) * 30 AS estimated_days_remaining
FROM inventory_level il
JOIN item i ON i.item_id = il.item_id
JOIN warehouse w ON w.warehouse_id = il.warehouse_id
JOIN monthly_consumption mc ON mc.item_id = il.item_id
WHERE il.quantity < mc.avg_monthly_consumption / 2;

-- View: Pending requests
-- Description: List all requests not processed yet flagged as 'Pending'
CREATE VIEW v_pending_request_backlog AS
SELECT 
    r.request_number AS request_number,
    r.status AS request_status,
    w.name AS warehouse_name,
    w.city AS warehouse_location,
    d.name AS division_name,
    c.name AS site_name,
    CURRENT_DATE - r.request_date AS days_from_request
FROM request r 
JOIN warehouse w ON r.warehouse_id = w.warehouse_id
JOIN division d ON w.division_id = d.division_id
JOIN construction_site c ON c.site_id = r.site_id
WHERE r.status = 'Pending'
ORDER BY days_from_request DESC;

-- View: Delivery progress
-- Description: Check the progress of each delivery
CREATE VIEW v_delivery_fulfillment_progress AS
SELECT 
    r.request_number,
    df.fulfillment_date,
    r.request_date,
    r.status AS request_status,
    d.dispatch_date,
    d.arrival_date,
    d.delivery_status,
    cs.name AS site_name
FROM request r 
LEFT JOIN delivery_fulfillment df ON r.request_number = df.request_number
LEFT JOIN delivery d ON d.delivery_number = df.delivery_number
JOIN construction_site cs ON cs.site_id = r.site_id;

-- View: Inventory summary by division
-- Description: Check the current stock of items divided per division
CREATE VIEW v_inventory_summary_by_division AS
SELECT
    COUNT(DISTINCT il.item_id) AS items_number,
    SUM(il.quantity) AS total_stock,
    COUNT(DISTINCT w.warehouse_id) AS warehouse_number,
    d.name AS division_name,
    d.city AS division_location,
    d.division_manager_contact AS manager_contact
FROM inventory_level il
JOIN warehouse w ON il.warehouse_id = w.warehouse_id
JOIN division d ON w.division_id = d.division_id
GROUP BY d.name, d.city, d.division_manager_contact;

-- View: Deliveries delayed
-- Description: List all deliveries delayed 
CREATE VIEW v_delivery_delay_analysis AS
SELECT
    c.name AS site_name,
    d.dispatch_date AS dispatch_date,
    d.arrival_date AS arrival_date,
CASE
    WHEN d.arrival_date IS NOT NULL THEN d.arrival_date - d.dispatch_date
    WHEN d.arrival_date IS NULL THEN CURRENT_DATE - d.dispatch_date
END AS delay_days 
FROM delivery d
JOIN construction_site c ON c.site_id = d.site_id;

-- View: Site cost
-- Descritpion: Rapid analysis of sites cost based on item requestes
CREATE VIEW v_site_cost_analysis AS
WITH avg_unit_price_item AS (
    SELECT
        item_id,
        AVG(unit_price) AS avg_price
        FROM order_detail
        GROUP BY item_id
)
SELECT
    cs.site_id AS site_id,
    cs.name AS site_name,
    cs.city AS site_city,
    SUM(rd.quantity * au.avg_price) AS total_cost_item
FROM construction_site cs
JOIN request r ON cs.site_id = r.site_id
JOIN request_detail rd ON r.request_number = rd.request_number
JOIN avg_unit_price_item au ON au.item_id = rd.item_id
GROUP BY cs.site_id, cs.name, cs.city;

-- View: Supplier spend analysis
-- Description: Check the spending for each supplier
CREATE VIEW v_supplier_spend_analysis AS
SELECT
    s.name AS supplier_name,
    SUM(od.quantity) AS quantity_ordered,
    COUNT(DISTINCT od.item_id) AS unique_item_id,
    SUM(od.quantity * od.unit_price) AS total_spent,
    COUNT(DISTINCT CASE WHEN po.status = 'Completed' THEN po.order_number END) * 100.0 / COUNT(DISTINCT po.order_number) AS completion_rate
FROM supplier s 
JOIN purchase_order po ON s.tax_code = po.supplier_id
JOIN order_detail od ON po.order_number = od.order_number
GROUP BY s.name;





