#1. Departments Info
SELECT  `department_id`, COUNT(*) AS 'Number of employees'
FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id` , 'Number of employees'; 

# 2. Average Salaryc

SELECT `department_id` ,ROUND(AVG(salary),2) AS 'Average salary'
FROM `employees` 
GROUP BY `department_id`
ORDER BY department_id;

#3. Minimum Salary
SELECT `department_id` ,ROUND(MIN(`salary`),2) AS 'minsalary'
FROM restaurant.products
GROUP BY `department_id`
HAVING minsalary > 800;

# 4. Appetizers Count
SELECT COUNT(id)
FROM products
WHERE `category_id` = 2 AND `price` >8;

# 5. Menu Prices
SELECT category_id,ROUND(AVG(price),2) AS 'Average price' , ROUND(MIN(price),2),ROUND(MAX(price),2)
FROM products
GROUP BY category_id;