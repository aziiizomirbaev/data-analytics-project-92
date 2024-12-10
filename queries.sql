select COUNT(customer_id) as customers_count  
from customers 

-- Step N5
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


	
-- Step N6
-- Отчет №1. Агрегирование по возрастным категориям (16-25, 26-40 и 40+)
WITH tab AS (
	SELECT 
		age,
		CASE 
			WHEN age BETWEEN 16 AND 25 THEN '16-25'
			WHEN age BETWEEN 26 AND 40 THEN '26-40'
			WHEN age > 40 THEN '40+'
		END AS res
	FROM customers
) 
SELECT res AS age_category, COUNT(res) AS age_count
FROM tab 
GROUP BY res 
ORDER BY res 

-- Отчет №2. Расчет выручки и количества уникальных клиентов по месяцам (ГОД-МЕСЯЦ) 
SELECT 
	TO_CHAR(sale_date, 'YYYY-MM') AS selling_month, 
	COUNT(DISTINCT s.customer_id) AS total_customers, 
	FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s 
LEFT JOIN products AS p USING(product_id)
GROUP BY selling_month
ORDER BY selling_month

-- Отчет №3. Вывод покупателей, чья первая покупка была акционной (акционные товары стоимостью 0). 
WITH tab AS (
    SELECT
        s.sales_person_id,
        s.customer_id, 
        MIN(s.sale_date) AS min_date, 
		ROW_NUMBER() OVER(PARTITION BY customer_id)
    FROM sales AS s 
    INNER JOIN products AS p ON s.product_id = p.product_id 
    WHERE p.price = 0
    GROUP BY s.customer_id, s.sales_person_id
)
SELECT 
	c.first_name || ' ' || c.last_name AS customer, 
	tab.min_date AS sale_date, 
	e.first_name || ' ' || e.last_name AS seller
FROM tab 
INNER JOIN employees AS e ON tab.sales_person_id = e.employee_id 
INNER JOIN customers AS c ON tab.customer_id = c.customer_id
WHERE row_number = 1
ORDER BY tab.customer_id 
