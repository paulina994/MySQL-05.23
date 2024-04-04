#1

CREATE TABLE `continents`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE

);
CREATE TABLE `countries`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL UNIQUE,
`country_code` VARCHAR(10) NOT NULL UNIQUE,
`continent_id` INT NOT NULL,

 constraint `fk_countries_continents`
    foreign key (`continent_id`)
    references `continents`(`id`)

);
CREATE TABLE `preserves`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(255) NOT NULL UNIQUE,
`latitude` DECIMAL (9,6),
`longitude` DECIMAL(9,6),
`area` INT,
`type` VARCHAR(20),
`established_on` DATE

);

CREATE TABLE `positions`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` varchar(40) NOT NULL UNIQUE,
`description` TEXT,
`is_dangerous` TINYINT(1) NOT NULL
);

CREATE TABLE `workers`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(40) not null,
`last_name` VARCHAR(40) NOT NULL,
`age` INT,
`personal_number` VARCHAR(20) NOT NULL UNIQUE,
`salary` DECIMAL(19,2),
`is_armed` TINYINT(1) NOT NULL,
`start_date` DATE,
`preserve_id` INT,
`position_id` INT,

 constraint `fk_workers_preserves`
    foreign key (`preserve_id`)
    references `preserves`(`id`),
    
     constraint `fk_workers_positions`
    foreign key (`position_id`)
    references `positions`(`id`)
);

CREATE TABLE `countries_preserves` (
    `country_id` INT,
    `preserve_id` INT,
    
    
    constraint `fk_contries_preserves_countries`
    foreign key (`country_id`)
    references `countries`(`id`) ,
    
    
    constraint `fk_contries_preserves_preserves`
    foreign key (`preserve_id`)
    references `preserves`(`id`)
);


#2

INSERT INTO `preserves` (`name`,`latitude`,`longitude`,`area`,`type`,`established_on`)
SELECT 
CONCAT(`name`,' ','is in South Hemisphere'),
`latitude`,
`longitude`,
`area` * `id`,
LOWER(`type`),
`established_on`
FROM `preserves`
WHERE `latitude` <0;

#3

UPDATE workers 
SET salary = salary + 500
WHERE position_id IN (5, 8, 11, 13);

#4

DELETE FROM `preserves`
WHERE `established_on` IS NULL;

#5
SELECT CONCAT(first_name, ' ', last_name) AS full_name,
    TIMESTAMPDIFF(DAY, start_date, '2024-01-01') AS days_of_experience
FROM
    workers
WHERE
    TIMESTAMPDIFF(YEAR, start_date, '2024-01-01') > 5
    ORDER BY days_of_experience desc
    LIMIT 10;
    
#6
SELECT w.`id`, w.`first_name`, w.`last_name`, p.`name` AS `preserve_name`,c.`country_code`
FROM `workers` AS w
JOIN `preserves` AS p ON w.`preserve_id` = p.`id`
JOIN `countries_preserves` AS cp ON cp.`preserve_id` = p. `id`
JOIN `countries` AS c ON c.`id` = cp. `country_id`
WHERE w.`salary` > 5000 AND w.`age` < 50
ORDER BY c.`country_code`;

#7
SELECT p.`name`,
COUNT(w.`is_armed` = 1) AS 'armed_workers'
FROM `preserves` as p
JOIN `workers` AS w ON p.`id` = w.`preserve_id`
WHERE w.`is_armed` = 1
GROUP BY p.`name`
ORDER BY `armed_workers` DESC,p.`name`

#8
SELECT p.`name`, c.`country_code`, 
YEAR(p.`established_on`) as 'founded_in'
FROM `preserves` AS p
JOIN `countries_preserves` AS cp ON  cp.`preserve_id` = p.`id`
JOIN `countries` AS c ON  cp.`country_id` = c.`id`
WHERE MONTH(p.`established_on`) = 05
ORDER BY established_on
LIMIT 5;

#9
SELECT `id`,`name`,
(CASE
WHEN `area` <= 100 THEN 'very small'
WHEN `area` > 100 AND `area` <= 1000 THEN 'small'
WHEN `area` > 1000 AND `area` <= 10000 THEN 'medium'
WHEN `area` > 10000 AND `area` <= 50000 THEN 'large'
ELSE 'very large'
END) AS 'category'
FROM `preserves`
ORDER BY `area` DESC;

#10

DELIMITER $$
 CREATE procedure udp_increase_salaries_by_country (country_name VARCHAR(40))
 BEGIN
    UPDATE `workers` as s
     JOIN preserves p on p.id = w.preserve_id
         join countries_preserves cp on p.id = cp.preserve_id
		 join countries c on c.id = cp.country_id
    set `salary` = `salary` * 1.05
    WHERE c.`name` = country_name;

 END $$
