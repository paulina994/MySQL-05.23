# 1. TABLE DESIGN
CREATE TABLE countries (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(45) NOT NULL
);

CREATE TABLE towns (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(45) NOT NULL ,
country_id INT NOT NULL,
CONSTRAINT fk_towns_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
);


CREATE TABLE stadiums (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(45) NOT NULL,
capacity INT NOT NULL ,
town_id INT NOT NULL,
CONSTRAINT fk_stadiums_towns
FOREIGN KEY (town_id)
REFERENCES towns(id)

);


CREATE TABLE skills_data (
id INT AUTO_INCREMENT PRIMARY KEY,
dribbling INT DEFAULT 0,
pace iNT DEFAULT 0,
passing iNT DEFAULT 0,
shooting iNT DEFAULT 0,
speed iNT DEFAULT 0,
strength iNT DEFAULT 0
 
); 

CREATE table coaches(
id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10, 2) NOT NULL DEFAULT 0,
coach_level INT NOT NULL DEFAULT 0
);


CREATE table players (
id INT PRIMARY KEY AUTO_INCREMENT ,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL DEFAULT 0,
position CHAR(1) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
hire_date DATETIME,
skills_data_id INT NOT NULL,
team_id INT  ,
CONSTRAINT fk_p_teams
FOREIGN KEY (team_id)
REFERENCES teams(id),
CONSTRAINT fk_p_skills
FOREIGN KEY(skills_data_id)
REFERENCES skills_data(id)
);
 
CREATE table player_coaches(
player_id INT ,
coach_id INT, 
CONSTRAINT fk_maping_player
FOREIGN KEY (player_id)
REFERENCES players(id),
CONSTRAINT fk_maping_coaches
foreign key (coach_id)
REFERENCES coaches(id)
);

# 2. INSERT

INSERT INTO coaches (first_name,last_name,salary,coach_level)
(SELECT first_name,last_name,salary *2 ,CHAR_LENGTH(first_name) as coach_level 
FROM players 
WHERE age >= 45 
);

# 3 UPDATE

UPDATE coaches
JOIN players_coaches AS pc ON pc.coach_id = coaches.id
SET coach_level  = coach_level + 1
WHERE first_name LIKE 'A%' ;

# 4 DELETE
DELETE FROM
players 
WHERE age >= 45;

# 5 PLAYERS
 SELECT (first_name, age, salaary) FROM players
 ORDER BY salary DESC;
 
# 6 YOUNG OFFENSE PLAYERS WITHOUT CONTRACT
SELECT p.id ,CONCAT(p.first_name, ' ', p.last_name), p.age, p.`position`, p.hire_date
FROM players AS p
LEFT JOIN skills_data AS sd
ON p.skills_data_id = sd.id
WHERE sd.strength > 50
AND position = 'A'
AND age <  23 
AND hire_date IS NULL
ORDER BY salary, age;

# 7 Detail info for all teams
SET sql_mode = 'ONLY_FULL_GROUP_BY';

SELECT  t.`name` as team_name, t.established, t.fan_base, COUNT(p.id) AS players_count
FROM teams AS t
LEFT JOIN players AS p 
ON t.id = p.team_id 
GROUP BY t.id
ORDER BY players_count DESC, fan_base DESC;

# 8 The fastest player by towns

SELECT  MAX(sd.speed) AS max_speed,
 tw.name AS town_name 
FROM towns AS tw
LEFT JOIN stadiums AS s ON s.town_id = tw.id
LEFT JOIN teams AS tm ON tm.stadium_id = s.id
LEFT JOIN players AS p ON p.team_id = tm.id
LEFT JOIN skills_data AS sd ON p.skills_data_id = sd.id
WHERE tm.name !=  'Devify' 
GROUP BY town_name
ORDER BY max_speed DESC, town_name 
; 

# 9 Total salaries and players by country


SELECT c.name, COUNT(p.id) AS total_count_of_players, 
SUM(salary) AS total_sum_of_salaries
FROM players AS p

RIGHT JOIN teams AS team
ON team.id = p.team_id

RIGHT JOIN stadiums AS s
ON s.id = team.stadium_id

RIGHT JOIN towns AS t
ON t.id = s.town_id

RIGHT JOIN countries AS c
ON t.country_id = c.id

GROUP BY c.id
ORDER BY total_count_of_players DESC, c.name
;
# 10 FIND ALL PLAYERS THAT PLAY ON STADIUM
DELIMITER $$

CREATE FUNCTION `udf_stadium_players_count` (stadiumname VARCHAR (44))
RETURNS INTEGER
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(p.id) AS cnt
FROM players AS p
RIGHT JOIN teams AS tm ON p.team_id = tm.id
RIGHT JOIN stadiums AS s ON tm.stadium_id = s.id
WHERE s.name = stadiumname );


END
$$

# 11. FIND GOOD PLAYMAKER BY TEAMS
CREATE PROCEDURE `udp_find_playmaker` (min_dribble_points INT, team_name VARCHAR (45))
BEGIN
SELECT 
CONCAT(p.first_name, ' ', p.last_name) AS full_name, 
p.age, p.salary , sd.dribbling, sd.speed, t.name
FROM skills_data AS sd
JOIN players AS p ON p.skills_data_id = sd.id
RIGHT JOIN teams AS t
ON  t.id = p.team_id
WHERE dribbling > min_dribble_points
AND t.name = team_name 
AND sd.speed > (SELECT AVG(speed) from skills_data)
ORDER BY sd.speed DESC
LIMIT 1;
END
