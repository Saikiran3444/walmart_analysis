SELECT * from walmart;

select 
  	payment_method,
	  count(*)
	  from walmart
group by payment_method


SELECT 
	COUNT(DISTINCT branch)
FROM walmart;

SELECT MIN(quantity) FROM walmart;

---business problems
-- Q.1 find different method and number of transaction ,number of qty sold

SELECT 
  	payment_method,
	  COUNT(*) as no_payments,
	  SUM(quantity) as no_qty_sold
	  FROM walmart
	 GROUP BY payment_method



---PROBLEM Q2
---identify the highest-rated category in each branch,display the branch,category
--AVG RATING

SELECT *
FROM
(SELECT 
	branch,
	category,
	AVG(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating)DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE RANK = 1

---Q3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM
(SELECT 
		branch,
		TO_CHAR(TO_DATE(date,'DD/MM/YY'),'DAY') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
  GROUP BY branch, TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY')
	)
WHERE RANK = 2;


--- Q4 Calculate the total quantity of times sold per payment method .list payment_method and total_quantity.


SELECT 
  	  payment_method,
	  ---COUNT(*) as no_payments,
	  SUM(quantity) as no_qty_sold
	  FROM walmart
	  GROUP BY payment_method

----Q5
----Determine the average ,minimum ,and maximum rating of a products(category) for each city.
---list the city ,average_rating ,min_rating,and max_rating

SELECT *FROM walmart;

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1,2

----Q6
--- Calculate the total for each category total profit as (unit_price*quqntity*profit_margin)
--list category and total_profit,ordered from highest to lowest profit.


SELECT 
	category,
	SUM(total) as total_revenue,
	sum(total * profit_margin)  as profit
FROM walmart
GROUP BY 1

--Q7
--Detemine the most common payment method for each branch.
--display branch and preferred_payment_method.
WITH cte
as
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank	
FROM walmart
GROUP BY 1,2
)
SELECT *
FROM cte
WHERE RANK =1

--Q.8
--- categorize sales into  3 groups MORNING,AFTERNOON,EVENING
--find out which of the shift and number of invoices
SELECT
	branch,
  CASE 
		WHEN EXTRACT (HOUR FROM (time::time))< 12 THEN 'morning'
		WHEN EXTRACT (HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'	
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER 1, 3 DESC

---Q9
---- identify 5 branch with highest ratio in
--revenue compare to last year(current year 2023 qnd last year 2022)

--rdr ==last_rev-cr_rev/ls_rev*100
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) as formated_date		
FROM walmart

---2022 SALES
WITH revenue_2022
as
(
SELECT 
	branch,
	SUM(total)as revenue
FROM walmart
 WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) =2022 ---PSQL
 ---WHERE EXTRACT(TO_DATE(date,'DD/MM/YY')) =2022 ---MYSQL
GROUP BY 1
),
revenue_2023
as
(

SELECT 
	branch,
	SUM(total)as revenue
FROM walmart
 WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) =2023	
GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND((ls.revenue - cs.revenue)::numeric/
	ls.revenue ::numeric * 100,
	2) as rev_dsc_ratio 
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5