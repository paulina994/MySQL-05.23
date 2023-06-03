# 01. Employees with Salary Above 35000
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
SELECT first_name, last_name FROM employees
	WHERE salary > 35000
    ORDER BY first_name, last_name, employee_id;
END
$$

#02. Employees with Salary Above Number
DELIMITER $$
CREATE PROCEDURE `usp_get_employees_salary_above` (`salary_param` DECIMAL(10,4))
BEGIN
SELECT 
    first_name, last_name
FROM
    employees
WHERE
    salary >= salary_param
ORDER BY first_name , last_name , employee_id;
END
$$

# 03. Town Names Starting With
DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with (starting_text VARCHAR(50))
BEGIN
SELECT `name` FROM towns
WHERE `name` LIKE CONCAT(starting_text,'%')
ORDER BY name;
END 
$$

# 04. Employees from Town
DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town(searched_town VARCHAR(50))
BEGIN
SELECT first_name, last_name FROM employees
JOIN addresses AS a USING(address_id)
JOIN towns AS t USING(town_id)
WHERE t.name = searched_town
ORDER BY first_name, last_name;
END
$$

# 05. Salary Level Function
DELIMITER $$
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19, 4))
RETURNS VARCHAR (10)
DETERMINISTIC
BEGIN
DECLARE salary_level VARCHAR (10) # ТЕКСТ С НИВОТО НА ЗАПЛАТАТА
IF salary < 30000 THEN SET salary_level := 'Low';
ELSEIF salary BETWEEN (30000 AND 50000) THEN SET salary_level := 'Average';
ELSE SET salary_level := 'High';
END IF;
RETURN salary_level;
END
$$

# 06. Employees by Salary Level
DELIMITER $$
CREATE PROCEDURE usp_get_salary_level(salary_level VARCHAR(10))
BEGIN
SELECT first_name, last_name FROM employees
WHERE ufn_get_salary_level(salary) = salary_level
ORDER BY first_name, last_name DESC;
 END
 $$
 
 # 07. Define Function
 DELIMITER $$
 CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
 RETURNS INT # 0 -> думата не е съставена от set_of_letters
             # 1 -> думата е съставена от set_of_letters
             DETERMINISTIC
             BEGIN
 RETURN word REGEXP (CONCAT('^[', set_of_letters, ']+$'));
 END
 $$
 
 # 08. Find Full Name
 
 DELIMITER $$ 
 CREATE PROCEDURE usp_get_holders_full_name()
 BEGIN 
 SELECT CONCAT(first_name, ' ', last_name) AS full_name 
 FROM account_holders
 ORDER BY full_name, id;
 END
 $$
 
 # 9. People with Balance Higher Than
 
 DELIMITER $$
	CREATE  PROCEDURE `usp_get_holders_with_balance_higher_than`(salary_param INT)
BEGIN
  SELECT 
     ah.first_name, ah.last_name
FROM
    accounts AS a
    JOIN 
    account_holders AS ah
    ON a.account_holder_id = ah.id
GROUP BY a.account_holder_id
HAVING SUM(a.balance) > salary_param
ORDER BY ah.id;
END
    $$

# 10. Future Value Function
DELIMITER $$
CREATE FUNCTION `ufn_calculate_future_value`(initial_sum DECIMAL(19, 4), interest_rate DECIMAL(19, 4), years INT) RETURNS DECIMAL(19,4)
    DETERMINISTIC
BEGIN
    RETURN initial_sum * POW((1 + interest_rate), years);
END$$

SELECT UFN_CALCULATE_FUTURE_VALUE(1000, 0.5, 5);

# 11. Calculating Interest
DELIMITER $$
CREATE PROCEDURE `usp_calculate_future_value_for_account`(id_param INT, interest_rate DECIMAL(19,4) )
BEGIN
SELECT 
     a.id, ah.first_name, ah.last_name, a.balance AS current_balance,
     (SELECT ufn_calculate_future_value( a.balance,interest_rate, 5) ) AS balance_in_5_years
FROM
account_holders AS ah
      JOIN 
       accounts AS a
    ON a.account_holder_id = ah.id
    WHERE a.id=id_param;
END$$

# 12. Deposit Money
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL (19,4))
BEGIN
START TRANSACTION;
IF (money_amount <= 0 )
THEN ROLLBACK;
ELSE 
UPDATE accounts SET balance = balance + money_amount
WHERE id = account_id;
END IF;
END
$$

# 13. Withdraw Money
DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL (19, 4))
BEGIN
START TRANSACTION;
IF (money_amount <= 0 OR (SELECT balance FROM accounts WHERE id = account_id) < money_amount)
THEN ROLLBACK;
ELSE 
UPDATE accounts SET balance = balance - money_amount
WHERE id = account_id;
END IF;
END
$$

# 14. Money Transfer
DELIMITER $$ 
CREATE PROCEDURE usp_transfer_money(from_id INT, to_id INT, amount DECIMAL(19,4))
BEGIN

# 1. валидно accountId -> from_id и to_id
# 2. from_id = to_id
# 3. amount > 0
# 4. от сметката from_id трябва да има баланс >= amount

IF from_id = to_id OR
amount <= 0 O R
(SELECT balance FROM accounts WHERE id = from_id) < amount OR
(SELECT COUNT(id) FROM accounts WHERE id = from_id) <> 1 
 THEN ROLLBACK;
 ELSE
UPDATE accounts SET balance = balance - amount
WHERE id = from_id;
UPDATE accounts SET balance = balance + amount
WHERE id = to_id;
COMMIT;
END IF;
END
$$

# 15. Log Accounts Trigger
DELIMITER $$
CREATE TABLE logs(
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT NOT NULL,
old_sum DECIMAL(19,4) NOT NULL,
new_sum DECIMAL(19,4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_change_balance_account
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
INSERT INTO logs (account_id, old_sum, new_sum)
VALUES (OLD.id, OLD.balance, NEW.balance);
END
$$

# 16. Emails Trigger
CREATE TABLE `logs`
(log_id INT PRIMARY KEY AUTO_INCREMENT, 
account_id INT NOT NULL,
 old_sum DECIMAL(19,4), 
 new_sum DECIMAL(19,4));
 
CREATE TRIGGER `accounts_AFTER_UPDATE` AFTER UPDATE ON `accounts` FOR EACH ROW
BEGIN
INSERT INTO `logs`(account_id, old_sum, new_sum)
VALUES(old.id,old.balance,new.balance);
END;

 
CREATE TABLE `notification_emails` (
id INT PRIMARY KEY AUTO_INCREMENT, 
recipient INT NOT NULL,
 `subject` VARCHAR(100), 
 body VARCHAR(255));


CREATE TRIGGER `logs_AFTER_INSERT` BEFORE INSERT ON `logs` FOR EACH ROW BEGIN
INSERT INTO `notification_emails`( `recipient`, `subject`, `body`)
VALUES( new.account_id,
concat( 'Balance change for account: ',new.account_id),
CONCAT('On ', NOW(), ' your balance was changed from ', ROUND(NEW.old_sum, 0), ' to ', ROUND(NEW.new_sum, 0), '.')
);
END
