SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', last_name),
    d.department_id,
    d.name
FROM
    employees AS e
        JOIN
    departments AS d ON e.employee_id = d.manager_id
ORDER BY e.employee_id
LIMIT 5;

SELECT 
    t.town_id, t.name, address_text
FROM
    addresses AS a
        JOIN
    towns AS t ON t.town_id = a.town_id
WHERE
    name IN ('San Francisco' , 'Sofia', 'Carnation')
ORDER BY t.town_id , address_id;

SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    department_id,
    salary
FROM
    employees AS e
WHERE
    manager_id IS NULL;


SELECT 
    COUNT(employee_id)
FROM
    employees
WHERE
    salary > (SELECT 
            AVG(salary)
        FROM
            employees);