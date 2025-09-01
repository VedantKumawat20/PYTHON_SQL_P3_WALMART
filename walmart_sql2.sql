create database walmart_db
use walmart_db
SELECT * FROM walmart
SELECT COUNT(*) FROM walmart

-- EDA exploratory data analysis --
  
SELECT 
	DISTINCT payment_method 
FROM walmart                         
-- Ewallet
-- Cash
-- Credit card

SELECT
	payment_method,
    COUNT(*)
FROM walmart
GROUP BY payment_method
-- Ewallet	3881
-- Cash	1832
-- Credit card	4256

SELECT 
	COUNT(DISTINCT branch)
FROM walmart
-- 100

SELECT 
	MAX(quantity)
FROM walmart
-- 10 

SELECT
	category,
    COUNT(*)
FROM walmart
GROUP BY category
-- Health and beauty	152
-- Electronic accessories	419
-- Home and lifestyle	4520
-- Sports and travel	166
-- Food and beverages	174
-- Fashion accessories	4538

SELECT
	city,
    COUNT(*)
FROM walmart
GROUP BY city


SELECT 
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM walmart
-- 01-01-2019	31-12-2023 

SELECT 
    MIN(rating),
    MAX(rating)
FROM walmart
-- 3	10

-- BUSINESS PROBLEMS | ADVANCE ANALYTICS --

-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method

SELECT
	payment_method,
    SUM(quantity) AS no_qty_sold,
    COUNT(*) AS no_payemts
FROM walmart
GROUP BY payment_method

--         qty_sold total_transactions
-- Ewallet	    8932  3881
-- Cash	        4984  1832
-- Credit card	9567  4256
-- maximum quantity is sold by or using credit card as well as maximum transactions are through credit card


-- Q2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
-- &
-- highest rated-category among all

SELECT branch, category, avg_rating
FROM (
	SELECT 
	branch,
    category,
    AVG(rating) AS avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank_
FROM walmart
GROUP BY branch, category
) AS ranked
WHERE rank_ = 1        
-- WHY 101 rows?  WALM066	Sports and travel	7.2
			   -- WALM066	Health and beauty	7.2

-- Q 2.2  highest-rated category count.
WITH cte AS
(
SELECT branch, category, avg_rating
FROM (
	SELECT 
	branch,
    category,
    AVG(rating) AS avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank_
FROM walmart
GROUP BY branch, category
) AS ranked
WHERE rank_ = 1 
)
SELECT category, COUNT(category)
FROM cte
GROUP BY 1
ORDER BY 2 DESC

-- Food and beverages	    26
-- Sports and travel	    26
-- Health and beauty	    25
-- Electronic accessories	19
-- Fashion accessories	    3
-- Home and lifestyle	    2

-- Food and beverages & Sports and travel are highest-rated category in majority of branches


-- Q3: Identify the busiest day for each branch based on the number of transactions

SELECT branch, date, no_transactions
FROM (
	SELECT
	branch,
	COUNT(invoice_id) AS no_transactions,
    date,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(invoice_id) DESC) AS rank_
FROM walmart
GROUP BY 1, 3
) AS busiest_day
WHERE rank_ = 1
-- here output is based on date not day(weekdays)


-- M2

SELECT 
	date,
    STR_TO_DATE(date, '%d/%m/%Y') as formated_date   -- error: date column format is incorrect. first correct format and then chage data type to date
FROM walmart

DESCRIBE walmart;  -- checking datatype of column

UPDATE walmart           -- here we are trying to update whole table by chaging date column datatype to date. 
SET walmart.date = STR_TO_DATE(date, '%m/%d/%Y');  -- error: safe mode ON 

-- explaination of above query 
-- Sometimes, dates are stored as text (strings) like "26-07-2025".
-- MySQL needs those to be in real date format (like 2025-07-26) to do proper date operations like sorting, filtering, or extracting day/month/year.
-- STR_TO_DATE(string, format)
-- string: Your date in text form.
-- format: The pattern that tells MySQL how to read the string.

-- so here now we are not changing whole table. just change datatype to do analysis. 
SELECT 
	STR_TO_DATE(date, '%d-%m-%Y') AS date,
	DAYNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS day        -- to extract DAYNAME
FROM walmart

-- to check datatype  
CREATE TEMPORARY TABLE temp_date_table AS 
SELECT 
  STR_TO_DATE(date, '%d-%m-%Y') AS date,             -- datatype is date
  DAYNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS day      -- datatype is varchar
FROM walmart;
DESCRIBE temp_date_table;


SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE rank_ = 1;



-- Q4: Determine the average, minimum, and maximum rating of categories for each city

SELECT 
	city, 
    category, 
    avg_rating, 
    min_rating, 
    max_rating
FROM(
SELECT 
	city,
    category,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
	RANK() OVER(PARTITION BY city ORDER BY AVG(rating) DESC) AS rank_  
FROM walmart
GROUP BY 1, 2
) AS sub_query

-- highest avg and mini rating cities and respective categories---
-- 	CITY            CATEGORY                    AVG_RATING   MIN_RATING
-- College Station	Health and beauty	        10          10
-- DeSoto	        Health and beauty	        9.9         9.9
-- Rosenberg	    Health and beauty	        9.9         9.9

-- top cities having maximum rating for catagories 
-- CITY              CATEGORY                    MAX_RATING
-- Alamo	          Sports and travel		        10
-- Angleton	          Electronic accessories		10
-- Bryan	          Sports and travel		        10
-- College Station	  Health and beauty		        10
-- League City	      Sports and travel		        10

-- cities having lowest avg_rating and max_rating
-- CITY            CATEGORY                 AVG_RATING  MIN_RATING       MAX_RATING
-- McKinney	        Food and beverages	     4	        4	             4
-- Corpus Christi 	Electronic accessories	 4.2	    4.2	             4.2
-- Denton	        Food and beverages	     4.2	    4.2	             4.2

-- cities having lowest min_rating 
-- CITY      CATEGORY                    MAX_RATING
-- Alamo	 Fashion accessories		 3	
-- Alamo	 Home and lifestyle		     3	
-- Alice	 Fashion accessories		 3	
-- Allen	 Fashion accessories		 3	
-- Amarillo	 Fashion accessories		 3	
-- Amarillo	 Home and lifestyle		     3	


-- M-2
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- here we get output without using RANK() OVER(PARTITION BY city ORDER BY AVG(rating) DESC) AS rank_, as we already group by city, category. If we want to rank avg_rating by city in desc order, then we have to use it.  

-- Q5: Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
-- list category and total_profit, ordered from highest to lowest. 

SELECT 
	category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC

-- These two catagories have higtest profit among all.
-- Fashion accessories	  192314.89320000037
-- Home and lifestyle	  192213.6380999999

-- Q6: Determine the most common payment method for each branch. Display Branch and the perferred_payment_method.


SELECT 
	branch,
    payment_method,
    no_transactions
FROM (
SELECT
	branch,
    payment_method,
    COUNT(payment_method) AS no_transactions,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(payment_method) DESC) AS rank_
FROM walmart
GROUP BY 1, 2
) AS sub_query
WHERE rank_ = 1

-- M-2
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank_ = 1;


-- Q7: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q8: Identify the 5 branches with the highest revenue decrease/increase ratio from last year to current year (last year 2022 to current year 2023).

-- DECREASE
WITH revenue_2022 AS (
	SELECT 
		branch,
        SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2022
    GROUP BY branch
    ),
revenue_2023 AS (
   	SELECT 
		branch,
        SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2023
    GROUP BY branch
    )
SELECT 
	r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_desc_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023
ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_desc_ratio DESC
LIMIT 5

-- the 5 branches with the highest revenue decrease ratio from last year to current year (last year 2022 to current year 2023) 
-- are WALM045 (-62.62%), WALM047 (-58.58%), WALM098 (-57.89%), WALM033 (-55.65%), WALM081 (-50.67%)

-- INCREASE
WITH revenue_2022 AS (
	SELECT 
		branch,
        SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2022
    GROUP BY branch
    ),
revenue_2023 AS (
   	SELECT 
		branch,
        SUM(total) AS revenue
	FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2023
    GROUP BY branch
    )
SELECT 
	r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2023.revenue - r2022.revenue) / r2022.revenue) * 100, 2) AS revenue_incr_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023
ON r2022.branch = r2023.branch
WHERE r2023.revenue > r2022.revenue
ORDER BY revenue_incr_ratio DESC
LIMIT 5

-- the 5 branches with the highest revenue increase ratio from last year to current year (last year 2022 to current year 2023) 
-- are WALM006 (172.94%), WALM010 (161.63%), WALM091 (148.86%), WALM072 (120.1%), WALM077 (118.56%)

-- Q9: total revenue in each year and month

SELECT year_, months_name, revenue
FROM (
SELECT
    YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS year_,
    MONTH(STR_TO_DATE(date, '%d-%m-%Y')) AS months_,
    MONTHNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS months_name,
    ROUND(SUM(total), 2) AS revenue,
    RANK() OVER(PARTITION BY YEAR(STR_TO_DATE(date, '%d-%m-%Y')) ORDER BY MONTH(STR_TO_DATE(date, '%d-%m-%Y')) ASC) AS rank_
FROM walmart
GROUP BY 1, 2, 3
) AS sub_query
    
-- months with least revenue
-- 2020	June	5434
-- 2022	April	5593
-- 2022	January	5679

-- months having highest revenue
-- 2019	January	    110754.16
-- 2019	March	    104243.34
-- 2019	February	92589.88
-- 2021	December	66930
-- 2023	December	66092



    
-- Q10: maximum and minmum total revenue in each month of years OR months with max and mini revenue in year

SELECT year_, months_name, revenue
FROM (
SELECT
    YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS year_,
    MONTH(STR_TO_DATE(date, '%d-%m-%Y')) AS months_,
    MONTHNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS months_name,
    ROUND(SUM(total), 2) AS revenue,
    RANK() OVER(PARTITION BY YEAR(STR_TO_DATE(date, '%d-%m-%Y')) ORDER BY ROUND(SUM(total), 2) DESC) AS rank_
FROM walmart
GROUP BY 1, 2, 3
) AS sub_query
WHERE rank_ IN (1, 12)  -- Limitation-- here we are not getting accurate lowest and highest revenue month of the year 2019 as there is only 3 months data available so it ranked in 1 to 3   (1 for max revenue and 12 for min revenue.)

-- M-2
WITH cte_max AS (
    SELECT
        YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS year_,
        MONTHNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS month_name,
        ROUND(SUM(total), 2) AS max_revenue,
        RANK() OVER(PARTITION BY YEAR(STR_TO_DATE(date, '%d-%m-%Y')) ORDER BY SUM(total) DESC) AS rank_
    FROM walmart
    GROUP BY year_, month_name
),
cte_min AS (
    SELECT
        YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS year_,
        MONTHNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS month_name,
        ROUND(SUM(total), 2) AS min_revenue,
        RANK() OVER(PARTITION BY YEAR(STR_TO_DATE(date, '%d-%m-%Y')) ORDER BY SUM(total) ASC) AS rank_
    FROM walmart
    GROUP BY year_, month_name
)
SELECT 
    max.year_ AS year,
    max.month_name AS highest_revenue_month,
    max.max_revenue,
    min.month_name AS lowest_revenue_month,
    min.min_revenue
FROM cte_max AS max
JOIN cte_min AS min ON max.year_ = min.year_
WHERE max.rank_ = 1 AND min.rank_ = 1
ORDER BY year;

-- year    highest_revenue_month    max_revnue   lowest_revnue_month  min_revenue
-- 2019	January	                 110754.16	  February	           92589.88
-- 2020	December	             60783	      June	               5434
-- 2021	December	             66930	      April	               6378
-- 2022	November	             61687	      April	               5593
-- 2023	December	             66092	      April	               6079


-- Q10.2 : maximum and minmum total profit_mardin in each month of years OR months with max and mini profit_margin in year

WITH cte_max AS (
    SELECT
        YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS year_,
        MONTHNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS month_name,
        ROUND(SUM(profit_margin), 2) AS max_profit_margin,
        RANK() OVER(PARTITION BY YEAR(STR_TO_DATE(date, '%d-%m-%Y')) ORDER BY SUM(profit_margin) DESC) AS rank_
    FROM walmart
    GROUP BY year_, month_name
),
cte_min AS (
    SELECT
        YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS year_,
        MONTHNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS month_name,
        ROUND(SUM(profit_margin), 2) AS min_profit_margin,
        RANK() OVER(PARTITION BY YEAR(STR_TO_DATE(date, '%d-%m-%Y')) ORDER BY SUM(profit_margin) ASC) AS rank_
    FROM walmart
    GROUP BY year_, month_name
)
SELECT 
    max.year_ AS year,
    max.month_name AS highest_profit_margin_month,
    max.max_profit_margin,
    min.month_name AS lowest_profit_margin_month,
    min.min_profit_margin
FROM cte_max AS max
JOIN cte_min AS min ON max.year_ = min.year_
WHERE max.rank_ = 1 AND min.rank_ = 1
ORDER BY year;

-- year  highest_profit_margin_month  max_profit-margin  lowest_profit_margin_month  min_profit_margin
-- 2019  January	                   139.77	          February	                  118.95
-- 2020  December	                   235.14	          June	                      24.54
-- 2021  December	                   248.28	          June	                      25.44
-- 2022  December	                   246.9	          April	                      25.5
-- 2023  December	                   248.34	          February	                  22.41



-- Q11: Write a query to display the top 5 cities with the most orders in the last 30 days.

SELECT 
    city,
    COUNT(*) AS total_orders
FROM walmart
WHERE STR_TO_DATE(date, '%d-%m-%Y') >= STR_TO_DATE('31-12-2023', '%d-%m-%Y') - INTERVAL 30 DAY    --  if date column is in date formt then we just have to write date as column name but here we don't so we have to write STR_TO_DATE(date, '%d-%m-%Y') instant.
GROUP BY city
ORDER BY total_orders DESC
LIMIT 5;

-- Weslaco	42
-- Waxahachie	31
-- Rockwall	25
-- Schertz	23
-- Richardson	21

-- --Q12: finding duplicates - cities are 98 but brnaches are 100

SELECT branch, city, count(DISTINCT(city))
FROM walmart
GROUP BY 1, 2
-- HAVING count(DISTINCT(city)) > 1




-- Q13: Moving Average of Daily Sales (7-day window)
-- Smooth out daily fluctuations to analyze underlying trends.

SELECT 
    order_date,
    AVG(daily_total) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7_days
FROM (
    SELECT 
        STR_TO_DATE(date, '%d-%m-%Y') AS order_date,
        SUM(total) AS daily_total
    FROM walmart
    GROUP BY order_date
) AS sub;

-- To get insights, we have to plot 7 - DMA against time to see if orders are rising, falling or stable.----
-- helps identify seasonality ( weekly, monthly cycle)
-- shows the week where demand was highest or lowest -- useful for inventory/supply planning.
-- claculate slope/change of the 7 - DMA to identify positive negative slop


-- Q14: Cumulative Customer Count by City

    SELECT 
        city,
--         branch,
        COUNT(DISTINCT(invoice_id)) AS total_customer
    FROM walmart
    GROUP BY city
    ORDER BY total_customer DESC

-- cities with highest customers
-- Weslaco	    396
-- Waxahachie	378

-- cities with lowest customers
-- Lake Jackson	51
-- Amarillo  	52

    SELECT 
        branch,
        COUNT(DISTINCT(invoice_id)) AS total_customer
    FROM walmart
    GROUP BY branch
    ORDER BY total_customer DESC
-- here why difference between city and branch ?
-- cities are 98 but branches are 100.
-- we have 2 branches in same city
-- -- Waxahachie	WALM087
-- -- Waxahachie	WALM055
-- --  Weslaco	    WALM074
-- --  Weslaco	    WALM082


-- Q15: High vs Low-Rated Transactions

SELECT 
    CASE 
        WHEN rating >= 7 THEN 'High Rated'
        WHEN rating >= 4 THEN 'Medium Rated'
        ELSE 'Low Rated'
    END AS rating_segment,
    COUNT(*) AS order_count,
    AVG(total) AS avg_order_value
FROM walmart
GROUP BY rating_segment;

-- High Rated	    3534	129.43580362195806
-- Medium Rated	    5481	118.85609377850756
-- Low Rated	    954	    105.71278825995807

-- Q16: Monthly Report Summary

SELECT 
    DATE_FORMAT(STR_TO_DATE(date, '%d-%m-%Y'), '%Y-%m') AS month,
    COUNT(DISTINCT invoice_id) AS total_orders,
    ROUND(SUM(total), 2) AS revenue,
    ROUND(AVG(rating), 3) AS avg_rating
FROM walmart
GROUP BY month
ORDER BY month;

-- December and Novenmver are months in years with majority of orders. considering it as a busiest months on the basis of order count--
-- month   total_order  revenue  avg_rating
-- 2021-12	  647	     66930	  5.298
-- 2023-12	  643	     66092	  5.224
-- 2022-12	  631	     58812	  5.474
-- 2022-11	  621	     61687	  5.324
-- 2020-11	  605	     60146	  5.283
-- 2020-12	  604	     60783	  5.358
-- 2021-11	  602	     59628	  5.425
-- 2023-11	  601	     63424	  5.306

-- months with lowest order count--
-- month    total_order  revenue  avg_rating
-- 2023-02	 56	          6567	   6.196
-- 2022-01	 62           5679	   5.742
-- 2020-06	 63	          5434	   5.889
-- 2021-06	 63	          6395	   5.698
-- 2022-04	 64	          5593	   5.766
-- 2020-03	 65	          6188	   6.169

-- highest revenue
-- month   total_order  revenue  avg_rating
-- 2019-01	352	         110754.16	7.018
-- 2019-03	345	         104243.34	6.84
-- 2019-02	303	         92589.88	7.071

-- lowest revenue
-- month   total_order  revenue  avg_rating
-- 2020-06	63	         5434	  5.889
-- 2022-04	64	         5593	  5.766
-- 2022-01	62	         5679	  5.742

-- highest avg rating
-- month   total_order  revenue  avg_rating
-- 2019-02	303	         92589.88	7.071
-- 2019-01	352	         110754.16	7.018
-- 2019-03	345	         104243.34	6.84

-- lowest avg rating
-- month   total_order  revenue  avg_rating
-- 2023-12	 643	     66092	   5.224
-- 2020-11	 605	     60146	   5.283
-- 2021-12	 647	     66930	   5.298

-- Q17: Revenue vs Profit Margin Matrix (Branch x Category)

SELECT 
    branch,
    category,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(AVG(profit_margin), 3) AS avg_margin,
    RANK() OVER(PARTITION BY branch ORDER BY ROUND(SUM(total), 2) DESC) AS rank_
FROM walmart
GROUP BY branch, category;

-- branch and categories with highest revenue-
-- branch   category              total_revnue  avg_margin rank
-- WALM029	 Home and lifestyle	   11998.46	     0.48      1
-- WALM058	 Fashion accessories   11994.28	     0.33	   1
-- WALM074	 Home and lifestyle	   11637.88	     0.33      1
-- WALM030	 Fashion accessories   11625.41	     0.48	   1
-- WALM009	 Home and lifestyle	   11509.46	     0.48      1

-- branch and categories with lowest revenue-
-- branch   category               total_revnue  avg_margin  rank
-- WALM040	    Health and beauty	   17.75	     0.48	     5
-- WALM063	    Health and beauty	   27.07	     0.33	     6
-- WALM066	    Sports and travel	   28.78	     0.33	     6
-- WALM074	    Health and beauty	   29.52	     0.33	     6
-- WALM024	    Electronic accessories 31.77	     0.48	     5

-- branch and categories with highest avg_margin-
-- branch      category               total_revnue  avg_margin rank
-- WALM052     Home and lifestyle	   3864.85	     0.57	   1
-- WALM052	   Fashion accessories	   3734	         0.57	   2
-- WALM053	   Home and lifestyle	   2476	         0.57	   2
-- WALM051	   Electronic accessories  281.34	     0.57	   6
-- WALM052	   Food and beverages	   1343.94	     0.57	   3

-- branch and categories with lowest avg_margin-
-- branch   category            total_revnue  avg_margin  rank
-- WALM099	Home and lifestyle	8757.04	      0.17	      1
-- WALM099	Fashion accessories	7840.3	      0.17	      2 
-- WALM096	Fashion accessories	5072.7	      0.17	      1
-- WALM097	Home and lifestyle	3168.02	      0.17	      1
-- WALM099	Electronic accessories	732.26	  0.17	      4

-- We can also get insights of branch and category by city
-----------------------

-- Q 18: Total revenue from sales — all cities, quarter-wise and year-wise

SELECT 
    city,
    YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS sales_year,
    QUARTER(STR_TO_DATE(date, '%d-%m-%Y')) AS sales_quarter,
    SUM(total) AS total_revenue
FROM walmart
GROUP BY city, sales_year, sales_quarter
ORDER BY city, sales_year, sales_quarter;

-- cities with highest revenue in a quarter of the year--
-- city        sales_year  sales_quarter  total_revenue
-- Weslaco	    2019	    1	           8786.789999999999
-- Weslaco	    2023	    4	           8572
-- Weslaco	    2021 	    4	           7761
-- Waxahachie	2020	    4	           7524
-- Waxahachie	2021	    4	           7422
-- Waxahachie	2023	    4	           7223
-- Weslaco	    2022	    4	           7170

-- cities with lowest revenue in a quarter of the year--
-- city        sales_year  sales_quarter  total_revenue
-- Farmers Branch	2021	   3	          15
-- Fort Worth	    2022	   2	          15
-- Lewisville	    2023	   1	          17
-- Plano	        2022	   2	          17

-- only year and quarter sales
SELECT 
    YEAR(STR_TO_DATE(date, '%d-%m-%Y')) AS sales_year,
    QUARTER(STR_TO_DATE(date, '%d-%m-%Y')) AS sales_quarter,
    SUM(total) AS total_revenue
FROM walmart
GROUP BY sales_year, sales_quarter
ORDER BY sales_year, sales_quarter;

-- limitation -- year 2019 have limited data
-- quarter 4 & 3 in every year have highest revenue- 
-- sales_year  sales_quarer   total_revenue
-- 2019	        1	          307587.38000000035
-- 2023	        4	          147663
-- 2021	        4	          147351
-- 2020	        4	          139187
-- 2022	        4	          137913
-- 2023	        3	          43147
-- 2021	        3	          42837
-- 2020	        3	          39042
-- 2022	        3	          38491


--  Q19. Each city – avg sale per customer & avg rating per customer
SELECT 
    city,
    COUNT(DISTINCT invoice_id) AS total_customers,
    SUM(total) / COUNT(DISTINCT invoice_id) AS avg_sale_per_customer,
    SUM(rating) / COUNT(DISTINCT invoice_id) AS avg_rating_per_customer
FROM walmart
GROUP BY city
ORDER BY avg_sale_per_customer DESC;


-- WHAT AVG SALES PER CUSTOMER AND AVG RATING PER CUSTOMERS SHOWS TOGETHER -- we can see whether our highest-spending customers are also the most satisfied customer(or not).
-- AVG VS AVG PER CUSTOMER DIFFERENCE? --
-- Avg Revenue = Total Revenue / Total Number of Transactions    (average earnings per transaction/ordee to understand the size of an average order)
-- Avg Revenue Per Customer = Total Revenue / Number of Unique Customers    (average contribution of each customer overall to understand customer value)
	​
-- cities with highest avg_rating per customer      
-- city        total_customer  avg_rating_per_customer
-- Austin	      60		    7.001666666666667
-- Huntsville	  74		    6.812162162162163
-- Pflugerville   79		    6.732911392405063

-- cities with lowest avg_rating per customer     
-- city        total_customer  avg_rating_per_customer
-- Rowlett	       169		       4.989349112426035
-- Texas City	   176             5.0420454545454545
-- Sherman	       175		       5.064571428571428

-- cities with highest avg_sales_per_customer-
-- city      total_customer  avg_sales_per_customer
-- McKinney   76	          182.73302631578946
-- Bryan	  64	          174.05796875
-- Galveston  75	          163.2296

-- cities with lowest avg_sales_per_customer-
-- city          total_customer  avg_sales_per_customer
-- Lake Jackson  51	             98.80196078431372
-- Lewisville	 56	             99.44357142857143
-- Port Arthur	 239             102.61242677824268


-- Q20. Monthly sales growth — with percentage change

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(date, '%d-%m-%Y'), '%Y-%m') AS sales_month,
        SUM(total) AS total_monthly_sales
    FROM walmart
    GROUP BY sales_month
),
growth AS (
    SELECT 
        sales_month,
        total_monthly_sales,
        LAG(total_monthly_sales) OVER (ORDER BY sales_month) AS prev_month_sales
    FROM monthly_sales
)
SELECT 
    sales_month,
    total_monthly_sales,
    prev_month_sales,
    ROUND(
        (total_monthly_sales - prev_month_sales) / prev_month_sales * 100, 
        2
    ) AS sales_growth_pct
FROM growth;

-- November and August are the months which shows highest sales growth (compare to previous month) over the year.
-- sales_month  total_monthly_sales  prev_month_sales  sales_growth_pct
-- 2022-11	     61687	               17414	        254.24
-- 2023-11	     63424	               18147	        249.5
-- 2020-11	     60146	               18258	        229.42
-- 2021-11	     59628	               20793	        186.77
-- 2023-08	     18606	               6938	            168.18
-- 2020-08	     16817	               6880	            144.43
-- 2022-08	     16788	               6895	            143.48
-- 2021-08	     16683 	               8367	            99.39

-- January is the month with lowest or negative sales growth % in every year-
-- sales_month  total_monthly_sales  prev_month_sales    sales_growth_pct
-- 2020-01	    6771	             104243.33999999997	 -93.5
-- 2022-01	    5679	             66930	             -91.52
-- 2023-01	    6709	             58812	             -88.59
-- 2021-01	    7568	             60783	             -87.55
-- 2020-06	    5434	             8548	             -36.43
-- 2022-04	    5593	             7108	             -21.31
-- 2022-06	    6356	             7789	             -18.4
-- 2019-02	    92589.88	         110754.16	         -16.4



-- Q21. Unique customer count per city

SELECT 
    city,
    COUNT(DISTINCT invoice_id) AS unique_customers
FROM walmart
GROUP BY city
ORDER BY unique_customers DESC;

-- cities with highest customer-
-- Weslaco	    396
-- Waxahachie	378
-- Port Arthur	239
-- Plano	    235

-- cities with lowest customer count-
-- Lake Jackson	51
-- Amarillo	    52
-- Lewisville	    56
-- College Station	56




