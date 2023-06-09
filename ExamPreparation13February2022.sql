create database online_store;
# 1. TABLE DESIGN
CREATE TABLE brands(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE

);

CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE reviews(
id INT PRIMARY KEY AUTO_INCREMENT,
content TEXT ,
rating DECIMAL(10,2) NOT NULL,
picture_url VARCHAR (80) NOT NULL,
published_at DATETIME NOT NULL
);

CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
price DECIMAL (19,2) NOT NULL,
quantity_in_stock INT,
description TEXT,
brand_id INT NOT NULL,
category_id INT NOT NULL,
review_id INT,

CONSTRAINT fk_products_brands
FOREIGN KEY (brand_id)
REFERENCES brands(id),

CONSTRAINT fk_products_categories
FOREIGN KEY (category_id)
REFERENCES categories(id),

CONSTRAINT fk_products_reviews
FOREIGN KEY (review_id)
REFERENCES reviews(id)
);

CREATE TABLE customers (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR (20) NOT NULL,
phone VARCHAR(30) NOT NULL UNIQUE, 
address VARCHAR(60) NOT NULL,
discount_card BIT(1) NOT NULL DEFAULT 0
);

CREATE TABLE orders(
id INT PRIMARY KEY AUTO_INCREMENT,
order_datetime DATETIME NOT NULL,
customer_id INT NOT NULL,

CONSTRAINT fk_orders_customers
FOREIGN KEY(customer_id)
REFERENCES customers(id)

);

CREATE TABLE orders_products(
order_id INT,
product_id INT,

CONSTRAINT fk_op_orders
FOREIGN KEY (order_id)
REFERENCES orders(id),

CONSTRAINT fk_op_products
FOREIGN KEY (product_id)
REFERENCES products(id)
);

# 2. INSERT
INSERT INTO reviews(content, picture_url, published_at, rating)
SELECT SUBSTRING(description, 1, 15), REVERSE(p.name), DATE('2010/10/10'), p.price / 8
FROM products AS p
WHERE p.id >= 5;

# 3. UPDATE
UPDATE products
SET  quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock between 60 AND 70;

# 4. DELETE 
DELETE c FROM customers AS c
LEFT JOIN orders AS o
ON o.customer_id = c.id
WHERE o.customer_id IS NULL; 

# 5. CATEGORIES
SELECT id, name
FROM categories
ORDER BY name DESC;

# 6. Quantity
SELECT id AS product_id, brand_id, name, quantity_in_stock AS quantity
FROM products
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock, id;

# 7. Review
SELECT id, content, rating, picture_url, published_at
FROM reviews
WHERE content LIKE 'My%' AND char_length(content) > 61
ORDER BY rating DESC;

# 8. FIRST CUSTOMERS
SELECT CONCAT_WS(' ',c.first_name,c.last_name) AS full_name, 
c.address, o.order_datetime as order_date
FROM orders as o
JOIN customers as c ON o.customer_id = c.id
WHERE YEAR(o.order_datetime) <= '2018'
ORDER BY full_name DESC;

# 9. BEST CATEGORIES
 SELECT COUNT(c.id) AS items_count, c.name, SUM(o.quantity_in_stock) AS total_quantity 
 FROM products AS o
 JOIN categories  as c ON c.id = o.category_id
 GROUP BY c.id
 ORDER BY items_count DESC, total_quantity 
 LIMIT 5;
 
 # 10. Extract client cards count
CREATE FUNCTION `udf_customer_products_count` (p_name VARCHAR(30))
RETURNS INT
RETURN(
SELECT COUNT(c.id)
FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id
JOIN orders_products AS op ON o.id = op.order_id
WHERE c.first_name = p_name 
GROUP BY c.id);

# 11. Reduce price
CREATE PROCEDURE `udp_reduce_price` (category_name VARCHAR(50))
BEGIN
UPDATE products as p
JOIN reviews as r ON p.review_id = r.id
JOIN categories c ON p.category_id = c.id
SET p.price = p.price * 0.7
WHERE c.name = category_name
AND r.rating < 4;
 END;