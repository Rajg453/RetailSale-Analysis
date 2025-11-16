-- Assuming the 'retail_sales' table is already created and populated.

-- ---
-- 1. INITIAL DATA EXPLORATION AND INSPECTION
-- ---

-- Retrieve the first 10 records (Syntax check)
SELECT * FROM retail_sales
LIMIT 10;

-- Count total number of sales records
SELECT COUNT(*) AS total_records
FROM retail_sales;

-- Data Quality Check: Records with NULL values in key columns
-- Identify records where critical fields are NULL (Using the correct transaction_id column)
SELECT *
FROM retail_sales
WHERE transaction_id IS NULL -- FIXED: Changed 'transactions_id' to 'transaction_id'
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR gender IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

-- How many unique customers do we have?
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers
FROM retail_sales;

-- List all unique categories
SELECT DISTINCT category
FROM retail_sales
ORDER BY category;

---
-- 2. SALES PERFORMANCE ANALYSIS
---

-- Q.1 Retrieve all columns for sales made on '2022-11-05'
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Retrieve all transactions where the category is 'Clothing', quantity > 4, and date is in November 2022
SELECT *
FROM retail_sales
WHERE
    category = 'Clothing'
    AND sale_date >= '2022-11-01'
    AND sale_date < '2022-12-01'
    AND quantity > 4;

-- Q.3 Calculate the total sales (total_sale) for each category.
SELECT
    category,
    SUM(total_sale) AS net_sale,
    COUNT(transaction_id) AS total_orders
FROM
    retail_sales
GROUP BY
    category
ORDER BY
    net_sale DESC;

-- Q.4 Find the average age of customers who purchased items from the 'Beauty' category.
SELECT
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5 Find all transactions where the total_sale is greater than 1000. (High-Value Sales)
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q.6 Find the total number of transactions made by each gender in each category.
SELECT
    category,
    gender,
    COUNT(transaction_id) AS total_transaction
FROM retail_sales
GROUP BY
    category,
    gender
ORDER BY
    category,
    total_transaction DESC;

-- Q.7 Calculate the average sale for each month and find the best-selling month in each year. (Window Function)
WITH MonthlySales AS (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS sale_year,
        EXTRACT(MONTH FROM sale_date) AS sale_month,
        AVG(total_sale) AS avg_sale,
        -- Rank average sales within each year
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS sales_rank
    FROM
        retail_sales
    GROUP BY
        EXTRACT(YEAR FROM sale_date),
        EXTRACT(MONTH FROM sale_date)
)
SELECT
    sale_year,
    sale_month,
    ROUND(avg_sale, 2) AS avg_sale
FROM
    MonthlySales
WHERE
    sales_rank = 1
ORDER BY
    sale_year;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales (in Electronics)
SELECT
    customer_id,
    ROUND(SUM(total_sale), 2) AS total_sales
FROM
    retail_sales
WHERE
    category = 'Electronics'
GROUP BY
    customer_id
ORDER BY
    total_sales DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT
    category,
    COUNT(DISTINCT customer_id) AS count_unique_customers
FROM
    retail_sales
GROUP BY
    category
ORDER BY
    count_unique_customers DESC;

-- Q.10 Write a SQL query to create each shift and number of orders (Morning <12, Afternoon 12-17, Evening >17)
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
FROM retail_sales
)
SELECT
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY
    CASE
        WHEN shift = 'Morning' THEN 1
        WHEN shift = 'Afternoon' THEN 2
        ELSE 3
    END;

---
-- 3. PROFIT AND MARGIN ANALYSIS (New Queries)
---

-- Q.11 Calculate Total Profit (Total Sale - COGS) and Profit Margin (Profit/Total Sale) per Category
SELECT
    category,
    ROUND(SUM(total_sale - cogs), 2) AS total_profit,
    ROUND(SUM(total_sale - cogs) / SUM(total_sale) * 100, 2) AS profit_margin_percent
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

-- Q.12 Find the average transaction value (ATV) across all sales
SELECT
    ROUND(AVG(total_sale), 2) AS average_transaction_value,
    COUNT(transaction_id) AS total_transactions
FROM retail_sales;