/*
CODEBASICS RESUME PROJECT CHALLENGE 4 
MONTH - Feb.
Challenge - Provide Insights to the Management in Consumer Goods Domain
*/


USE gdb023;

/*Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region.*/

SELECT  DISTINCT market
FROM dim_customer
WHERE customer = 'Atliq Exclusive' AND region = 'APAC'



/*What is the percentage of unique product increase in 2021 vs. 2020?*/

WITH total_product_count AS 
	(WITH product_count AS
			(SELECT
			product_code,
			CASE WHEN cost_year = '2020' THEN  '1' END AS  year20,
			CASE WHEN cost_year = '2021' THEN  '1'  END AS  year21
			FROM fact_manufacturing_cost)  
	SELECT  count(year20) AS year2020 , count(year21) AS year2021
	FROM product_count
	GROUP BY product_code)
SELECT sum(year2020) AS unique_products_2020, sum(year2021) AS unique_products_2021, (sum(year2021) - sum(year2020)) / sum(year2020) * 100   AS percentage_change
FROM total_product_count




/* Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts*/

SELECT segment, COUNT(DISTINCT(product)) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC



/* Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? */

  WITH product_count AS 
		(SELECT
		product_code,
		CASE WHEN cost_year = '2020' THEN  '1' END AS  product_count_2020,
		CASE WHEN cost_year = '2021' THEN  '1' END AS product_count_2021
		FROM fact_manufacturing_cost)  
SELECT  dp.segment, SUM(product_count_2020) AS product_count_2020 , SUM(product_count_2021) AS product_count_2021 , 
SUM(product_count_2021) - SUM(product_count_2020) AS diffrence
FROM product_count AS c
INNER JOIN dim_product AS dp
ON c.product_code = dp.product_code
GROUP BY dp.segment
ORDER BY diffrence DESC



-- Get the products that have the highest and lowest manufacturing costs.

SELECT fact_manufacturing_cost.product_code, product, manufacturing_cost
FROM fact_manufacturing_cost  
INNER JOIN  dim_product  
ON fact_manufacturing_cost.product_code =   dim_product.product_code
WHERE manufacturing_cost = (SELECT max(manufacturing_cost) FROM fact_manufacturing_cost )
UNION ALL
SELECT  fact_manufacturing_cost.product_code, product, manufacturing_cost
FROM fact_manufacturing_cost  
INNER JOIN dim_product  
ON fact_manufacturing_cost.product_code =   dim_product.product_code
WHERE manufacturing_cost = (SELECT min(manufacturing_cost) FROM fact_manufacturing_cost )

 
 
/*Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market.*/
  
SELECT dc.customer_code, dc.customer, ROUND(pre_invoice_discount_pct,2) AS avg_discount_percentage
FROM  dim_customer AS dc
INNER JOIN  fact_pre_invoice_deductions AS fmc
on dc.customer_code = fmc.customer_code
WHERE market = 'India' AND fiscal_year = '2021'  
ORDER BY  pre_invoice_discount_pct DESC 
LIMIT 5



/*Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.*/

SELECT
YEAR(date) AS year,
MONTHNAME(date) AS month,
Round(SUM(sold_quantity * gross_price),0) AS gross_sales_amount
FROM fact_sales_monthly AS fsm 
INNER JOIN fact_gross_price AS fgp
ON fgp.Product_code =  fsm.product_code 
INNER JOIN dim_customer AS dc
ON fsm.customer_code = dc.customer_code
WHERE customer = 'Atliq Exclusive'
GROUP BY date
ORDER BY date 

 
 

/*In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity.*/

with total_sold_quantity as (select year(date) as year , quarter (date) as quarter , sum(sold_quantity) as total_sold_quantity
from fact_sales_monthly
group by year, quarter 
order by total_sold_quantity desc)
select * from total_sold_quantity
where year = '2020'



/*Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? */
 
WITH fy21 AS
	(SELECT  dm.channel, SUM( sold_quantity * gross_price) AS gross_sales
	FROM dim_customer as dm
	INNER JOIN fact_sales_monthly as fsm 
	ON fsm.customer_code = dm.customer_code
	INNER JOIN fact_gross_price as fgp 
	ON fsm.product_code = fgp.product_code
	WHERE fgp.fiscal_year = '2021'
	GROUP BY dm.channel)
SELECT channel, ROUND(gross_sales / 1000000 ,2) AS  gross_sales_mln,
100 * SUM(gross_sales) / (SELECT SUM(gross_sales) FROM fy21 ) AS percentage
FROM fy21
GROUP BY channel 
ORDER BY percentage DESC




/*Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021?*/

SELECT division, product_code, product, total_sold_quantity, rank_order
FROM (
  SELECT division, product_code, product, total_sold_quantity,
         DENSE_RANK() OVER (PARTITION BY division ORDER BY total_sold_quantity DESC) AS rank_order
  FROM (
    SELECT division, fsm.product_code, product, SUM(sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly AS fsm 
	INNER JOIN dim_product AS dp 
	ON fsm.product_code = dp.product_code
    WHERE fiscal_year = 2021
    GROUP BY division, product_code, product
  ) t1
) t2
WHERE rank_order <= 3
ORDER BY division, rank_order
