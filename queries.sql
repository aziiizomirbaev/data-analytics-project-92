select COUNT(customer_id) as customers_count  
from customers 

  
-- Отчет №1. Запрос на топ-10 селлеров с конкатенацией (first_name, last_name)
-- с указанием количества сделок (operations) и общей выручки за все время (income)
SELECT 
	(e.first_name || ' ' || e.last_name) AS seller, 
	COUNT(s.sales_person_id) AS operations, 
	FLOOR(SUM(s.quantity * p.price)) AS income 
FROM sales AS s 
LEFT JOIN employees AS e ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p USING(product_id)
GROUP BY e.first_name, e.last_name 
ORDER BY income DESC 
LIMIT 10

  
-- Отчет №2. Запрос на вывод селлеров со средней выручкой ниже общей средней выручки всех селлеров
WITH cte AS (
	SELECT
		e.first_name || ' ' || e.last_name AS seller,  
		AVG(s.quantity * p.price) AS average 
	FROM sales AS s 
	LEFT JOIN products AS p USING(product_id)
	LEFT JOIN employees AS e ON s.sales_person_id = e.employee_id
	GROUP BY e.first_name, e.last_name 
) 

SELECT seller, FLOOR(average) AS average_income
FROM cte 
WHERE average < (
	SELECT AVG(p.price * s.quantity)
	FROM sales AS s 
	LEFT JOIN products AS p USING(product_id)
)
ORDER BY 2;

-- Отчет №3. Отчет по дням на английском (monday, tuesday, and etc.)
SELECT 
	e.first_name || ' ' || e.last_name AS seller, 
	TO_CHAR(s.sale_date, 'day') AS day_of_week, 
	ROUND(SUM(s.quantity * p.price)) AS income 
FROM sales AS s 
LEFT JOIN employees AS e ON s.sales_person_id = e.employee_id
LEFT JOIN products AS p ON s.product_id = p.product_id 
GROUP BY s.sale_date, e.first_name, e.last_name 
