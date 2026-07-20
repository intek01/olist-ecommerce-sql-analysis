-- =============================================
-- OLIST E-COMMERCE DATA CLEANING
-- Author: Intekab Alom
-- Tool: SQL Server (SSMS 22)
-- =============================================

-- 1. Check for duplicate order IDs
SELECT order_id, COUNT(*) AS count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. Check for duplicate customer IDs
SELECT customer_id, COUNT(*) AS count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 3. Check for duplicate product IDs
SELECT product_id, COUNT(*) AS count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- 4. Check NULL values in orders table
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivery_date,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved_date
FROM orders;

-- 5. Order status breakdown
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 6. Add clean date columns to orders
ALTER TABLE orders
ADD purchase_date DATETIME,
    approved_date DATETIME,
    carrier_date DATETIME,
    delivery_date DATETIME,
    estimated_delivery_date DATETIME;

-- 7. Populate clean date columns
UPDATE orders
SET 
    purchase_date = CONVERT(DATETIME, order_purchase_timestamp),
    approved_date = CONVERT(DATETIME, order_approved_at),
    carrier_date = CONVERT(DATETIME, order_delivered_carrier_date),
    delivery_date = CONVERT(DATETIME, order_delivered_customer_date),
    estimated_delivery_date = CONVERT(DATETIME, order_estimated_delivery_date);

-- 8. Add clean date column to order_items
ALTER TABLE order_items
ADD shipping_limit_date_clean DATETIME;

UPDATE order_items
SET shipping_limit_date_clean = CONVERT(DATETIME, shipping_limit_date);

-- 9. Check city name casing consistency
SELECT DISTINCT customer_city
FROM customers
WHERE customer_city != LOWER(customer_city);

SELECT DISTINCT seller_city
FROM sellers
WHERE seller_city != LOWER(seller_city);

-- 10. Final data quality check
SELECT
    'orders' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_ids,
    SUM(CASE WHEN purchase_date IS NULL THEN 1 ELSE 0 END) AS null_dates
FROM orders
UNION ALL
SELECT
    'order_items',
    COUNT(*),
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN shipping_limit_date_clean IS NULL THEN 1 ELSE 0 END)
FROM order_items
UNION ALL
SELECT
    'order_payments',
    COUNT(*),
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END)
FROM order_payments
UNION ALL
SELECT
    'order_reviews',
    COUNT(*),
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END),
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END)
FROM order_reviews;