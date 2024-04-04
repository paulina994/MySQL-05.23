#1

CREATE TABLE cities
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);
CREATE TABLE property_types
(
    id          INT AUTO_INCREMENT,
    type        VARCHAR(40) NOT NULL UNIQUE,
    description TEXT,
    PRIMARY KEY (id)
);
CREATE TABLE properties
(
    id               INT AUTO_INCREMENT,
    address          VARCHAR(80)    NOT NULL UNIQUE,
    price            DECIMAL(19, 2) NOT NULL,
    area             DECIMAL(19, 2),
    property_type_id INT,
    city_id          INT,
    PRIMARY KEY (id),
    FOREIGN KEY (property_type_id) REFERENCES property_types (id),
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
CREATE TABLE agents
(
    id         INT AUTO_INCREMENT,
    first_name VARCHAR(40)  NOT NULL,
    last_name  VARCHAR(40)  NOT NULL,
    phone      VARCHAR(20)  NOT NULL UNIQUE,
    email      VARCHAR(50) NOT NULL UNIQUE,
    city_id    INT,
    PRIMARY KEY (id),
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
CREATE TABLE buyers
(
    id         INT AUTO_INCREMENT,
    first_name VARCHAR(40)  NOT NULL,
    last_name  VARCHAR(40)  NOT NULL,
    phone      VARCHAR(20)  NOT NULL UNIQUE,
    email      VARCHAR(50) NOT NULL UNIQUE,
    city_id    INT,
    PRIMARY KEY (id),
    FOREIGN KEY (city_id) REFERENCES cities (id)
);
CREATE TABLE property_offers
(
    property_id    INT            NOT NULL,
    agent_id       INT            NOT NULL,
    price          DECIMAL(19, 2) NOT NULL,
    offer_datetime DATETIME,
    KEY `pk_properties_agents` (`property_id`, `agent_id`),
    CONSTRAINT `fk_properties_agents_properties` FOREIGN KEY (property_id) REFERENCES properties (`id`),
    CONSTRAINT `fk_properties_agents_agents` FOREIGN KEY (agent_id) REFERENCES agents (`id`)
);
CREATE TABLE property_transactions
(
    id               INT AUTO_INCREMENT,
    property_id      INT NOT NULL,
    buyer_id         INT NOT NULL,
    transaction_date DATE,
    bank_name        VARCHAR(30),
    iban             VARCHAR(40) UNIQUE,
    is_successful    BOOLEAN,
    PRIMARY KEY (id),
    FOREIGN KEY (property_id) REFERENCES properties (id),
    FOREIGN KEY (buyer_id) REFERENCES buyers (id)
);
#2

INSERT INTO `property_transactions`(`property_id`,`buyer_id`,
`transaction_date`, `bank_name`, `iban`,`is_successful`)
SELECT
po.`agent_id` + DAY(po.`offer_datetime`),
po.`agent_id` + MONTH(po.`offer_datetime`),
DATE(`offer_datetime`),
concat('Bank ',po.`agent_id`),
concat('BG',po.`price`,po.`agent_id`),
1
FROM`property_offers` AS po
WHERE po.`agent_id` <= 2;

#3

UPDATE `properties`
SET `price` = `price` -50000
WHERE `price` >= 800000;

#4
DELETE FROM `property_transactions`
WHERE `is_successful` = 0;

#5
SELECT * FROM `agents`
ORDER BY `city_id` DESC, `phone` DESC;

#6
select * from `property_offers`
WHERE YEAR(`offer_datetime`) = 2021
ORDER BY `price`
LIMIT 10;

#7
SELECT
substring(p.`address`,1,6) AS`agent_name`,
(char_length(`address`)) * 5430 `price` FROM `properties` AS p
left JOIN `property_offers` AS po ON po.`property_id` = p.`id`
WHERE po.`property_id` IS NULL
ORDER BY `agent_name` DESC, `price` DESC;

#8
SELECT `bank_name`, COUNT(`iban`) AS 'count'
FROM `property_transactions`
GROUP BY `bank_name`
HAVING `count` >= 9
ORDER BY `count` DESC, `bank_name`;

#9
SELECT `address`, `area`,
(CASE
WHEN `area` <= 100 THEN 'small'
WHEN `area` <= 200 THEN 'medium'
WHEN `area` <= 500 THEN 'large'
ELSE 'extra large'
END
)
AS `size` 
FROM `properties` 
ORDER BY `area`,`address`DESC;

#10
DELIMITER $$
CREATE FUNCTION udf_offers_from_city_name (cityName VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN

DECLARE offers_count int;
SET offers_count :=
(SELECT COUNT(`property_id`)
FROM `cities` AS c
JOIN `properties` AS p ON p.city_id = c.id
JOIN `property_offers` AS po ON po.property_id = p.id
WHERE c.`name` = cityName
);

RETURN offers_count;
END$$
#11

DELIMITER $$
CREATE PROCEDURE udp_special_offer(first_name VARCHAR(50))
BEGIN
UPDATE `property_offers`AS po
JOIN `agents`AS a ON a.`id` = po.`agent_id`
SET po.price = po.price - po.price * 0.10
WHERE a.`first_name`= first_name;

END$$
