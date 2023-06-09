create database instd;

# 1. TABLE DESIGN

CREATE table users(
id INT PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(30) NOT NULL UNIQUE,
password VARCHAR(30) NOT NULL,
email VARCHAR(50) NOT NULL,
gender CHAR(1) NOT NULL,
age INT NOT NULL,
job_title VARCHAR(40) NOT NULL,
ip VARCHAR(30) NOT NULL
);

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
address VARCHAR(30) NOT NULL,
town  VARCHAR(30) NOT NULL,
country VARCHAR(30) NOT NULL,
user_id INT NOT NULL,

CONSTRAINT fk_addresses_users
FOREIGN KEY (user_id)
REFERENCES users(id)
);

CREATE TABLE photos(
id INT PRIMARY KEY AUTO_INCREMENT,
`description` TEXT NOT NULL,
date DATETIME NOT NULL,
views INT NOT NULL DEFAULT 0
);

CREATE TABLE users_photos(
user_id INT NOT NULL,
photo_id INT NOT NULL,

CONSTRAINT fk_users_photos_users
FOREIGN KEY (user_id)
REFERENCES users(id),

CONSTRAINT fk_users_photos_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id)

);
CREATE TABLE likes(
id INT PRIMARY KEY AUTO_INCREMENT,
user_id INT ,
photo_id int,

CONSTRAINT fk_likes_users
FOREIGN KEY(user_id)
REFERENCES users(id),

CONSTRAINT fk_likes_photos
FOREIGN KEY(photo_id)
REFERENCES photos(id)

);

CREATE TABLE comments(
id INT PRIMARY KEY AUTO_INCREMENT,
comment VARCHAR(255),
`date` DATETIME NOT NULL,
photo_id INT NOT NULL,
CONSTRAINT fk_comments_photos
FOREIGN KEY(photo_id)
references photos(id)
);

# 2. INSERT

INSERT INTO addresses (address, town, country, user_id)
SELECT username, password, ip,age
FROM users
WHERE gender = 'M';

# 3. UPDATE

UPDATE addresses
SET country = (
CASE LEFT (country,1)
WHEN 'B' THEN 'Blocked'
WHEN 'T' THEN 'Test'
WHEN 'P' THEN 'In Progress'
ELSE country
END
);

# 4. DELETE
DELETE FROM addresses
WHERE id % 3 = 0;

# 5. USERS

SELECT 	username, gender, age 
FROM users
ORDER BY age DESC, username;

# 6. EXTRACT 5 MOST COMMENTED PHOTOS
SELECT p.id, p.date AS date_and_time, p.description, COUNT(c.id) AS commentsCount
FROM photos AS p
JOIN comments AS c
ON p.id = c.photo_id
GROUP BY p.id
ORDER BY commentsCount DESC , id
LIMIT 5;

# 7. LUCKY USERS
SELECT 
CONCAT_WS(" ", u.id, u.username) AS id_username, 
u.email FROM users AS u
JOIN users_photos AS up
ON u.id = up.user_id
JOIN photos AS p
ON up.photo_id = p.id
where u.id = p.id
ORDER BY u.id;

# 8. Count likes and comments
SELECT p.id , 
COUNT(DISTINCT l.id) AS 'likes_count',
COUNT(DISTINCT c.id) AS 'comments_count'
FROM photos AS p
LEFT JOIN likes AS l
ON p.id = l.photo_id
LEFT JOIN comments AS c
ON p.id = c.photo_id
group by p.id
ORDER BY likes_count DESC, comments_count DESC , p.id;

# 9. The photo on the tenth day of the month
SELECT 
CONCAT(LEFT(p.description, 30),"...") AS summery , 
p.date
FROM photos AS p
WHERE DAY(p.date) = 10
ORDER BY p.date DESC;

# 10. Get user’s photos count
DELIMITER $$
CREATE FUNCTION `udf_users_photos_count` (p_username VARCHAR(30))
RETURNS INTEGER
DETERMINISTIC
BEGIN
RETURN(
         SELECT COUNT(up.user_id)
         FROM users AS u
         LEFT JOIN users_photos AS up
         ON u.id = up.user_id
         WHERE u.username = p_username
         GROUP BY u.username
);
END
$$

# 11. Increase user age
DELIMITER $$
CREATE PROCEDURE udp_modify_user(p_address VARCHAR(30), p_town VARCHAR(30))
BEGIN
UPDATE users AS u
JOIN addresses AS a
ON u.id = a.user_id
SET age = age + 10
WHERE a.address = p_address AND a.town = p_town;

END
$$