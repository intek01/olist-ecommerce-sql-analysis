-- =============================================
-- OLIST E-COMMERCE BUSINESS ANALYSIS
-- Author: Intekab Alom
-- Tool: SQL Server (SSMS 22)
-- =============================================

-- Query 1: Monthly Revenue Trend
SELECT 
    FORMAT(o.purchase_date, 'yyyy-MM') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    ROUND(AVG(p.payment_value), 2) AS avg_order_value
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY FORMAT(o.purchase_date, 'yyyy-MM')
ORDER BY month;

-- Query 2: Customer Segmentation (One-Time vs Repeat)
-- Note: customer_unique_id used instead of customer_id
-- because Olist generates new customer_id per order
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
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM customer_orders
GROUP BY 
    CASE 
        WHEN total_orders = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END;

-- Query 3: Top 10 Product Categories by Revenue
SELECT TOP 10
    ct.product_category_name_english AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY total_revenue DESC;

-- Query 4: Delivery Performance Analysis
SELECT 
    CASE 
        WHEN delivery_date <= estimated_delivery_date THEN 'On Time'
        WHEN delivery_date > estimated_delivery_date THEN 'Late'
        ELSE 'Not Delivered'
    END AS delivery_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(AVG(DATEDIFF(DAY, purchase_date, delivery_date)), 1) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
GROUP BY 
    CASE 
        WHEN delivery_date <= estimated_delivery_date THEN 'On Time'
        WHEN delivery_date > estimated_delivery_date THEN 'Late'
        ELSE 'Not Delivered'
    END;

-- Query 5: Does Late Delivery Hurt Review Scores?
SELECT 
    CASE 
        WHEN o.delivery_date <= o.estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_reviews,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered' AND o.delivery_date IS NOT NULL
GROUP BY 
    CASE 
        WHEN o.delivery_date <= o.estimated_delivery_date THEN 'On Time'
        ELSE 'Late'
    END;

-- Query 6: Seller Performance Scorecard
SELECT 
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_rating,
    RANK() OVER(ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
JOIN orders o ON oi.order_id = o.order_id
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) >= 10
ORDER BY total_revenue DESC;

-- Query 7: RFM Customer Segmentation
WITH rfm_base AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(DAY, MAX(o.purchase_date), '2018-10-01') AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(p.payment_value), 2) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER(ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER(ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER(ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT 
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customer'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customer'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        ELSE 'Lost'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary), 2) AS avg_spend
FROM rfm_scored
GROUP BY 
    CASE
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champion'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customer'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customer'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        ELSE 'Lost'
    END
ORDER BY avg_spend DESC;