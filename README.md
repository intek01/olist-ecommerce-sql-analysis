# Olist E-Commerce SQL + Power BI Analysis

## Project Overview
End-to-end data analysis project on 100K+ real orders from Olist, 
Brazil's largest e-commerce marketplace. Built using SQL Server and 
Power BI to uncover revenue trends, customer retention issues, 
delivery performance gaps, and seller insights.

## Tools Used
- Microsoft SQL Server (SSMS 22)
- Power BI Desktop
- GitHub

## Dataset
- Source: [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- 9 relational tables
- 100K+ orders (2016–2018)
- 1.5M+ total records

## Database Schema
9 tables connected through foreign keys:
- customers (99,441 rows)
- sellers (3,095 rows)
- products (32,951 rows)
- category_translation (71 rows)
- orders (99,441 rows)
- order_items (112,650 rows)
- order_payments (103,886 rows)
- order_reviews (99,224 rows)
- geolocation (1,000,163 rows)

## Project Phases

### Phase 1 — Database Setup
Imported all 9 CSV files into SQL Server using Import Flat File wizard.
Defined appropriate data types (nvarchar, int, float, datetime) for 
each column. Kept date columns as nvarchar during import to handle 
NULL values safely, then converted using CONVERT() post-import.

### Phase 2 — Data Cleaning
- Verified zero duplicate primary keys across orders, customers, products
- Analyzed NULL patterns — confirmed 2,965 NULL delivery dates correspond 
  to non-delivered orders (cancelled, shipped, processing) not data errors
- Converted all date columns from nvarchar to DATETIME using CONVERT()
- Verified text columns for casing consistency
- Final quality check: zero NULLs in all critical columns across 400K+ rows

### Phase 3 — Business Analysis
7 queries answering real business questions:

| Query | Business Question |
|-------|------------------|
| Monthly Revenue Trend | How is revenue growing over time? |
| Customer Segmentation | What % of customers return? |
| Category Performance | Which categories drive revenue? |
| Delivery Performance | How many orders arrive on time? |
| Delivery vs Reviews | Does late delivery hurt ratings? |
| Seller Scorecard | Who are the top performing sellers? |
| RFM Segmentation | Who are our most valuable customers? |

### Phase 4 — SQL Views
Created 5 views as a clean interface layer for Power BI:
- vw_monthly_revenue
- vw_customer_segments
- vw_category_performance
- vw_delivery_review_impact
- vw_seller_scorecard

### Phase 5 — Power BI Dashboard
4-page interactive dashboard:
- Page 1: Executive Overview (KPIs + Revenue Trend)
- Page 2: Customer Retention (Segments + Top Categories)
- Page 3: Delivery & Review Impact
- Page 4: Seller Performance

## Key Business Insights

### 1. Revenue Growth
Revenue grew consistently from Oct 2016 through Nov 2017, 
peaking at 1M+ BRL/month before plateauing in 2018.
Average order value remained stable at ~148 BRL throughout,
meaning growth was driven by customer acquisition not higher spending.

### 2. Critical Retention Problem
Only 3% of customers make repeat purchases.
97% are one-time buyers — indicating a serious retention gap.
Customer acquisition is working; retention is the bottleneck.

### 3. Late Delivery Kills Satisfaction
- 8.11% of orders arrive late (avg 31 days vs 10 days on time)
- Late deliveries cause review scores to drop from 4.29 → 2.57
- This is a 40% drop in satisfaction from a single operational issue

### 4. Revenue Concentration
- São Paulo (SP) generates ~8M BRL — far exceeding all other states
- Health & Beauty is the top revenue category (1.23M BRL)
- Watches & Gifts has highest average order value (199 BRL)

### 5. High-Value Customers at Risk
RFM segmentation identified 993 "At Risk" customers with the 
highest average spend (293 BRL) — nearly double loyal customers.
These are the highest-priority targets for re-engagement campaigns.

## Business Recommendations
1. **Fix logistics first** — late delivery is the root cause of 
   low ratings and poor retention
2. **Launch win-back campaign** for 993 At Risk high-value customers
3. **Invest in SP region** — geographic concentration suggests 
   strong market fit there
4. **Premium positioning for Watches & Gifts** — highest AOV category

## Files in This Repository
| File | Description |
|------|-------------|
| data_cleaning.sql | Contains queries for duplicate detection, NULL analysis, date column conversion from nvarchar to DATETIME, text standardization checks, and final data quality validation across all 9 tables |
| business_analysis.sql | Contains 7 business queries covering monthly revenue trend, customer segmentation using customer_unique_id, top 10 product categories by revenue, delivery performance analysis, delivery vs review score correlation, seller performance scorecard using RANK() window function, and RFM customer segmentation using NTILE() and chained CTEs |
| views.sql | Contains 5 SQL views created as a clean interface layer between SQL Server and Power BI — vw_monthly_revenue, vw_customer_segments, vw_category_performance, vw_delivery_review_impact, vw_seller_scorecard |
| Olist_Ecommerce_Analysis.pbix | Power BI dashboard with 4 pages — Executive Overview, Customer Retention, Delivery & Review Impact, Seller Performance — built on top of SQL views |

## Author
**Intekab Alom**
M.Tech Data Science and Engineering — NIT Agartala
[LinkedIn](https://linkedin.com/in/intekab-alom-864726368) | [GitHub](https://github.com/intek01)
