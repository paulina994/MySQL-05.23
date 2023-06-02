# 01. Employee Address

SELECT e.employee_id, e.job_title, e.address_id, a.address_text
FROM employees AS e
JOIN addresses AS a
ON
e.address_id = a.address_id
ORDER BY address_id
LIMIT 5;

# 02. Addresses with Towns
SELECT e.first_name, e.last_name, name, address_text
FROM employees AS e
JOIN addresses AS a ON e.address_id = a.address_id
JOIN towns AS t ON a.town_id = t.town_id
ORDER BY e.first_name, e.last_name
LIMIT 5;

# 03. Sales Employee

SELECT e.employee_id, e.first_name, e.last_name,d.name
FROM employees AS e
JOIN departments AS d
ON e.department_id = d.department_id
WHERE d.name = 'Sales'
ORDER BY e.employee_id DESC ;

# 04. Employee Departments

SELECT e.employee_id, e.first_name, e.salary, d.name AS department_name
FROM employees AS e
JOIN departments AS d
ON e.department_id = d.department_id
WHERE salary > 15000
ORDER BY d.department_id DESC
LIMIT 5;

# 05. Employees Without Project

SELECT e.employee_id , e.first_name
FROM employees AS e
LEFT JOIN employees_projects AS ep
ON e.employee_id = ep.employee_id
WHERE ep.project_id IS NULL
ORDER BY e.employee_id DESC
LIMIT 3;
 
 # 06. Employees Hired After
 SELECT e.first_name, e.last_name, e.hire_date, d.name AS dept_name
 FROM employees AS e
 JOIN departments AS d
 ON e.department_id = d.department_id
 WHERE e.hire_date > '1999-01-01 00:00:00' AND d.name IN ('Sales', 'Finance')
 ORDER BY e.hire_date;
 
 # 07. Employees with Project
SELECT e.employee_id, e.first_name, p.name AS project_name
FROM employees AS e
JOIN employees_projects AS ep
ON e.employee_id = ep.employee_id
JOIN projects AS p
ON  ep.project_id = p.project_id
WHERE DATE(p.start_date) > '2002-08-13' AND p.end_date IS NULL
ORDER BY e.first_name, p.name
LIMIT 5;

# 08. Employee 24

SELECT 
    e.employee_id,
    e.first_name,
    IF(YEAR(p.start_date) >= 2005,
        NULL,
        p.name) AS project_name
FROM
    employees AS e
        JOIN
    employees_projects AS ep ON e.employee_id = ep.employee_id
        JOIN
    projects AS p ON ep.project_id = p.project_id
WHERE
    e.employee_id = 24
ORDER BY p.name;

# 09. Employee Manager
SELECT e.employee_id , e.first_name, e.manager_id, m.first_name
FROM employees e , employees m
WHERE e.manager_id = m.employee_id AND e.manager_id IN (3,7)
ORDER BY e.first_name; 

# 10. Employee Summary
SELECT e.employee_id , 
CONCAT(e.first_name , ' ', e.last_name) AS employee_name, 
CONCAT(m.first_name, ' ', m.last_name) AS manager_name, 
d.name AS department_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
JOIN departments d ON e.department_id = d.department_id
ORDER BY e.employee_id
LIMIT 5;

# 11. Min Average Salary
SELECT AVG(salary) AS min_average_salary FROM employees
GROUP BY department_id
ORDER BY min_average_salary
LIMIT 1;

# 12. Highest Peaks in Bulgaria
SELECT mc.country_code, m.mountain_range, p.peak_name, p.elevation
FROM peaks AS p
JOIN mountains AS m
ON p.mountain_id = m.id
JOIN mountains_countries AS mc ON m.id = mc.mountain_id
WHERE mc.country_code = 'BG' AND elevation > 2835
ORDER BY p.elevation DESC;
  
# 13. Count Mountain Ranges
SELECT mc.country_code, COUNT(m.mountain_range) AS 'mountain_range_count'
FROM mountains AS m
JOIN mountains_countries AS mc
ON m.id = mc.mountain_id
WHERE mc.country_code IN('BG', 'US', 'RU')
GROUP BY mc.country_code 
ORDER BY mountain_range_count DESC;

# 14. Countries with Rivers
SELECT c.country_name, r.river_name
FROM countries AS c
LEFT JOIN countries_rivers cr ON c.country_code = cr.country_code
LEFT JOIN rivers AS r ON r.id = cr.river_id 
WHERE c.continent_code = 'AF'
ORDER BY c.country_name
LIMIT 5;

# 16 Countries without any Mountains
SELECT COUNT(*)AS 'country_count'  FROM countries AS c
LEFT JOIN mountains_countries AS mc USING (country_code)
LEFT JOIN mountains AS m ON mc.mountain_id = m.id
WHERE m.id IS NULL;

# 17. Highest Peak and Longest River by Country
SELECT c.country_name , MAX(p.elevation) AS 'highest_peak_elevation',
MAX(r.`length`) AS 'longest_river_length'
FROM countries AS c
LEFT JOIN mountains_countries AS mc USING(`country_code`)
LEFT JOIN peaks AS p USING(mountain_id)
LEFT JOIN countries_rivers AS cr USING(`country_code`)
LEFT JOIN rivers AS r ON cr.river_id = r.id
GROUP BY c.country_name
ORDER BY `highest_peak_elevation` DESC, longest_river_length DESC, c.country_name
LIMIT 5; 