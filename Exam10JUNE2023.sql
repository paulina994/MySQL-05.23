#1
CREATE TABLE `countries`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL unique
);

CREATE TABLE `cities`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL unique,
`population` INT,
`country_id` INT NOT NULL,

constraint fk_cities_countries
FOREIGN KEY(`country_id`)
REFERENCES `countries`(`id`)
);
CREATE TABLE `universities`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(60) NOT NULL unique,
`address` VARCHAR(80) NOT NULL UNIQUE,
`tuition_fee` DECIMAL(19,2) NOT NULL,
`number_of_staff` INT,
`city_id` INT,

constraint fk_universities_cities
FOREIGN KEY(`city_id`)
REFERENCES `cities`(`id`)
);

CREATE TABLE `students`(
`id` INT PRIMARY KEY auto_increment,
`first_name` VARCHAR(40) NOT NULL,
`last_name` VARCHAR(40) NOT NULL,
`age` INT,
`phone` VARCHAR(20)  NOT NULL UNIQUE,
`email` VARCHAR(255) NOT NULL UNIQUE,
`is_graduated` TINYINT(1) NOT NULL,
`city_id` INT ,


constraint fk_students_cities
FOREIGN KEY(`city_id`)
REFERENCES `cities`(`id`)

);

CREATE TABLE `courses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(40) NOT NULL unique,
`duration_hours` DECIMAL(19,2),
`start_date` DATE,
`teacher_name` VARCHAR(60) NOT NULL UNIQUE,
`description` TEXT,
`university_id` INT,

constraint fk_courses_universities
FOREIGN KEY(`university_id`)
REFERENCES `universities`(`id`) 
);

CREATE TABLE `students_courses`(
`grade` DECIMAL(19,2) NOT NULL,
`student_id` INT NOT NULL,
`course_id` INT NOT NULL ,

constraint fk_students_courses_students
FOREIGN KEY(`student_id`)
REFERENCES `students`(`id`),


constraint fk_students_courses_courses
FOREIGN KEY(`course_id`)
REFERENCES `courses`(`id`)
);
#2
INSERT INTO `courses`
(`name`, `duration_hours`,`start_date`,`teacher_name`,`description`,`university_id`)
SELECT 
(CONCAT(`teacher_name`,' ','course')),
((char_length(`name`)) / 10 ),
(DATE_ADD(`start_date`, INTERVAL 5 DAY)),
(REVERSE(`teacher_name`)),
(CONCAT('Course ' ,`teacher_name`,REVERSE(`description`))),
(day(`start_date`))
FROM `courses` 
WHERE `id` <= 5;

#3

UPDATE `universities`
SET `tuition_fee` = `tuition_fee` + 300
WHERE id BETWEEN 5 AND 12;

#4

DELETE u FROM `universities`AS u
WHERE `number_of_staff` IS NULL;

#5
SELECT `id`, `name`, `population`,`country_id` 
FROM `cities`
ORDER BY `population`DESC;

#6
SELECT `first_name`, `last_name`,`age`,`phone`,`email` FROM `students`
WHERE `age` >=21
ORDER BY `first_name`DESC, `email`, `id`
LIMIT 10;

#7
SELECT 
CONCAT(s.`first_name`, ' ' ,s.`last_name`)as 'full_name',
SUBSTRING(s.`email`,2,10) as 'username',
REVERSE(s.`phone`) as 'password' 
FROM `students` AS s
left JOIN `students_courses` AS sc ON sc.`student_id` = s.`id`
WHERE sc.`course_id` IS NULL
order by password desc;

#8

SELECT
COUNT(sc.`student_id`)AS 'students_count',
u.`name` AS 'university_name'
FROM `universities` AS u
JOIN `courses` AS c ON c.`university_id` = u.`id`
JOIN `students_courses` AS sc ON sc.`course_id` = c.`id`
GROUP BY u.`name`
HAVING `students_count` >= 8
ORDER BY `students_count` DESC, `university_name` DESC;

#9

SELECT u.`name` as 'university_name',c.`name`, u.`address`,
(CASE 
WHEN tuition_fee < 800 THEN 'cheap'
WHEN tuition_fee >= 800 AND tuition_fee < 1200 THEN 'normal'
WHEN tuition_fee >= 1200 AND tuition_fee < 2500 THEN 'high'
ELSE 'expensive'
END
) 
  AS`price_rank`,
u.`tuition_fee`
FROM `universities` AS u
JOIN `cities` AS c ON u.`city_id` = c.`id`
ORDER BY `tuition_fee`;

#10

 CREATE FUNCTION udf_average_alumni_grade_by_course_name(course_name VARCHAR(60))
     RETURNS DECIMAL(19, 2)
     DETERMINISTIC
 BEGIN
     DECLARE average_grade DECIMAL(19, 2);
    SET average_grade := (
         SELECT AVG(sc.grade)
        FROM students s
                JOIN students_courses sc on s.id = sc.student_id
                JOIN courses c on c.id = sc.course_id
                WHERE s.is_graduated = 1
           AND c.name = course_name);
     RETURN average_grade;
 end 

#11


 CREATE PROCEDURE udp_graduate_all_students_by_year(year_started INT)
 BEGIN
     UPDATE students s
         JOIN students_courses sc on s.id = sc.student_id
         JOIN courses c on c.id = sc.course_id
     SET s.is_graduated=1
     WHERE YEAR(c.start_date) = year_started;
 END;