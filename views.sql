-- =============================================
-- OLIST E-COMMERCE SQL VIEWS FOR POWER BI
-- Author: Intekab Alom
-- Tool: SQL Server (SSMS 22)
-- =============================================

-- View 1: Monthly Revenue
CREATE VIEW vw_monthly_revenue AS
SELECT 
    FORMAT(o.purchase_date, 'yyyy-MM') AS month,
    MIN(CAST(o.purchase_date AS DATE)) AS month_sort,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    ROUND(AVG(p.payment_value), 2) AS avg_order_value
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY FORMAT(o.purchase_date, 'yyyy-MM');

-- View 2: Customer Segments
CREATE VIEW vw_customer_segments AS
WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END;

-- View 3: Category Performance
CREATE VIEW vw_category_performance AS
SELECT 
    ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english;

-- View 4: Delivery & Review Impact
CREATE VIEW vw_delivery_review_impact AS
SELECT 
    o.order_id,
    CASE 
        WHEN o.delivery_date <= o.estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    DATEDIFF(DAY, o.purchase_date, o.delivery_date) AS delivery_days,
    r.review_score,
    c.customer_state
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND o.delivery_date IS NOT NULL;

-- View 5: Seller Scorecard
CREATE VIEW vw_seller_scorecard AS
SELECT 
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_rating
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 10;