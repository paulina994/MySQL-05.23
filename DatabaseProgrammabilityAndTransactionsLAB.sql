#1. Count Employees by Town

DELIMITER ###
CREATE function ufn_count_employees_by_town(cityname VARCHAR(100))
RETURNS INT
DETERMINISTIC

BEGIN
DECLARE x INT;
SET x := (SELECT COUNT(*)
FROM towns AS t
LEFT JOIN addresses AS a ON t.town_id = a.town_id
LEFT JOIN employees AS e ON e.address_id = a.address_id
WHERE t.name = cityname);

RETURN x; 
END
###

# 2. Employees Promotion

DELIMITER $$
CREATE PROCEDURE usp_raise_salaries(department_name VARCHAR(100))
BEGIN
UPDATE employees AS e
RIGHT JOIN departments AS d ON e.department_id = d.department_id
SET salary = salary * 1.05
WHERE d.name = department_name;
END
$$

# 3. Employees Promotion By ID

DELIMITER $$
CREATE PROCEDURE usp_raise_salary_by_id(id INT)
BEGIN
START TRANSACTION;
	IF((SELECT count(employee_id) FROM employees WHERE employee_id like id)<>1) THEN
	ROLLBACK;
	ELSE
		UPDATE employees AS e SET salary = salary + salary*0.05 
		WHERE e.employee_id = id;
	END IF; 
END$$
DELIMITER ;

call usp_raise_salary_by_id(15932);

#4
CREATE TABLE IF NOT EXISTS `deleted_employees` (
  `employee_id` int(10) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `job_title` varchar(50) NOT NULL,
  `department_id` int(10) NOT NULL,
  `salary` decimal(19,4) NOT NULL,
   PRIMARY KEY (`employee_id`)
     );
  
  -- Triger--
DELIMITER $$
CREATE TRIGGER `employees_BEFORE_DELETE` BEFORE DELETE ON `employees` FOR EACH ROW
BEGIN
INSERT INTO `deleted_employees` (first_name,last_name,middle_name,job_title,department_id,salary)
	VALUES(OLD.first_name,OLD.last_name,OLD.middle_name, OLD.job_title,OLD.department_id,OLD.salary);
END$$


