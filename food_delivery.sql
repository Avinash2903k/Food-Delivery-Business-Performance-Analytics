CREATE DATABASE food_delivery;
USE food_delivery;


select * from orders;
select * from order_items;

-- CLEANING – restaurants Table
-- Check for:
-- ✔ duplicate restaurants
-- ✔ blank names
-- ✔ null values
-- ✔ spelling issues / inconsistent location
-- ✔ rating > 5 or < 1 (invalid values)

SELECT COUNT(*) FROM restaurants;

-- Check NULLs / Empty values
SELECT * FROM restaurants
WHERE name IS NULL OR name = ''
   OR location IS NULL OR location = ''
   OR rating IS NULL;

-- Check duplicate restaurant names
SELECT name, COUNT(*) 
FROM restaurants
GROUP BY name
HAVING COUNT(*) > 1;

SELECT *
FROM restaurants
WHERE name IN (
    SELECT name
    FROM restaurants
    GROUP BY name
    HAVING COUNT(*) > 1
)
ORDER BY name;


-- Check invalid ratings
SELECT * 
FROM restaurants
WHERE rating < 3.0 OR rating > 5.0;

-- space at end / beginning
UPDATE restaurants
SET name = TRIM(name);

-- Just check if SAME name + SAME location duplicate exists
SELECT name, location, COUNT(*)
FROM restaurants
GROUP BY name, location
HAVING COUNT(*) > 1;

UPDATE restaurants
SET name = TRIM(name), location = TRIM(location);

SELECT name, location, COUNT(*)
FROM restaurants
GROUP BY name, location
HAVING COUNT(*) > 1;

select * from restaurants;


-- --------------------------------------------------------------
-- CLEANING – menu_items Table
select * from menu_items;

SELECT COUNT(*) FROM menu_items;

SELECT * FROM menu_items
WHERE item_name = '' OR item_name IS NULL
   OR price IS NULL;

SELECT * FROM menu_items
WHERE price < 1 OR price > 1000;

-- Check duplicate items within same restaurant
SELECT restaurant_id, item_name, COUNT(*)
FROM menu_items
GROUP BY restaurant_id, item_name
HAVING COUNT(*) > 1;

SELECT *
FROM menu_items
WHERE (restaurant_id, item_name) IN (
    SELECT restaurant_id, item_name
    FROM menu_items
    GROUP BY restaurant_id, item_name
    HAVING COUNT(*) > 1
)
ORDER BY restaurant_id, item_name;

UPDATE menu_items
SET price = ROUND(price, 0);

-- ---------------------------------------------------------------------
-- CLEANING – users Table

select * from users;

SELECT *
FROM users
WHERE name LIKE 'Mr.%'
   OR name LIKE 'Ms.%'
   OR name LIKE 'Dr.%'
LIMIT 20;


SELECT COUNT(*) FROM users;
SELECT COUNT(DISTINCT address) FROM users;

UPDATE users
SET name = TRIM(name);

SELECT *
FROM users
WHERE name LIKE 'Mr.%'
   OR name LIKE 'Ms.%'
   OR name LIKE 'Dr.%'
LIMIT 20;

-- prefix ("Mr.", "Ms.", "Dr.") removeing
SELECT user_id,
       REPLACE(REPLACE(REPLACE(name, 'Mr. ', ''), 'Ms. ', ''), 'Dr. ', '') AS cleaned_name
FROM users;

-- permanent removing
UPDATE users
SET name = REPLACE(REPLACE(REPLACE(name, 'Mr. ', ''), 'Ms. ', ''), 'Dr. ', '')
WHERE name LIKE 'Mr.%'
   OR name LIKE 'Ms.%'
   OR name LIKE 'Dr.%';

-- Cleaning for phone
SELECT user_id,
       phone,
       REGEXP_REPLACE(phone, '[^0-9]', '') AS raw_digits,
       RIGHT(REGEXP_REPLACE(phone, '[^0-9]', ''), 10) AS final_clean_phone
FROM users;

-- permanent Cleaning for phone
UPDATE users
SET phone = RIGHT(REGEXP_REPLACE(phone, '[^0-9]', ''), 10);

-- -------------------------------------------------------------------------
-- cleaning for orders table
select * from orders;

SELECT *
FROM orders
WHERE user_id IS NULL
   OR restaurant_id IS NULL;
   
-- converting date and time    
SELECT order_id,
       order_date,
       DATE(order_date) AS order_only,
       TIME(order_date) AS time_only
FROM orders;   

ALTER TABLE orders
ADD COLUMN order_only_date DATE,
ADD COLUMN order_only_time TIME;

UPDATE orders
SET order_only_date = DATE(order_date),
    order_only_time = TIME(order_date);

SELECT COUNT(*) FROM orders WHERE order_only_date IS NULL OR order_only_time IS NULL;

ALTER TABLE orders
DROP COLUMN order_date;

-- changing the column name    
ALTER TABLE orders
CHANGE COLUMN order_only_date order_date DATE,
CHANGE COLUMN order_only_time order_time TIME;
   
DESCRIBE orders;
-- ------------------------------------------------------------------
-- cleaning order_item table
select * from order_items;

-- Check for NULL / missing values
SELECT *
FROM order_items
WHERE order_id IS NULL
   OR item_id IS NULL
   OR qty IS NULL;

-- Check weird qty values (less than 1 or too big)
SELECT *
FROM order_items
WHERE qty <= 0
   OR qty > 10;
   
-- --------------------------------------------------------------------   
-- 50 SQL Questions + Full Answers

-- A. Basic Select

-- 1- Display first 10 users.
SELECT * FROM users LIMIT 10;

-- 2- Display restaurant names & ratings.
SELECT name, rating FROM restaurants;

-- 3- List menu items with price sorted low → high.
SELECT item_name, price FROM menu_items ORDER BY price ASC;

-- 4️- Show all orders placed in 2025 only.
SELECT * FROM orders WHERE YEAR(order_date) = 2025;

-- 5️- Show users who live in "Chennai" (LIKE filter).
SELECT * FROM users WHERE address LIKE '%Chennai%';

-- 🟡 B. Single-table Aggregation

-- 6️- Count total number of users.
 SELECT COUNT(*) FROM users;
 
-- 7️- Count total number of restaurants.
SELECT COUNT(*) FROM restaurants;

-- 8️- Count total menu items.
 SELECT COUNT(*) FROM menu_items;

-- 9️- Count total orders.
SELECT COUNT(*) FROM orders;

-- 10- Count total order_items entries.
SELECT COUNT(*) FROM order_items;

-- 🔵 C. Joins (2-table joins)

-- 1️1- Show order_id + customer name (orders JOIN users).
SELECT o.order_id, u.name
    FROM orders o JOIN users u ON o.user_id = u.user_id;

-- 1️2- Show restaurant name + item name (menu_items JOIN restaurants).
SELECT m.item_name, r.name AS restaurant_name
    FROM menu_items m JOIN restaurants r ON m.restaurant_id = r.restaurant_id;

-- 1️3- Show order_id + item_name + qty (order_items JOIN menu_items).
SELECT oi.order_id, m.item_name, oi.qty
    FROM order_items oi JOIN menu_items m ON oi.item_id = m.item_id;

-- 1️4- Show orders with restaurant name + order_date.
SELECT o.order_id, r.name AS restaurant_name, o.order_date
    FROM orders o JOIN restaurants r ON o.restaurant_id = r.restaurant_id;

-- 1️5- Show user name + restaurant name for each order.
SELECT o.order_id, u.name, r.name AS restaurant
    FROM orders o
    JOIN users u ON o.user_id = u.user_id
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id;

-- 🟣 D. Multi-table joins (3+ tables)

-- 1️6- Show order_id, username, restaurant_name, total items (multi join).
SELECT o.order_id, u.name, r.name AS restaurant,
        COUNT(oi.order_item_id) AS total_items
    FROM orders o
    JOIN users u ON o.user_id = u.user_id
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id;
    
-- 1️7- Show each item ordered along with restaurant location.
SELECT u.name, m.item_name, r.location
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items m ON oi.item_id = m.item_id
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id;
    
-- 1️8- Show user phone + what item they ordered + time of order.
SELECT u.phone, m.item_name, o.order_time
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items m ON oi.item_id = m.item_id;
    
-- 1️9- For each restaurant → show all users who ordered from them (distinct).
SELECT DISTINCT r.name AS restaurant, u.name AS user
    FROM restaurants r
    JOIN orders o ON r.restaurant_id = o.restaurant_id
    JOIN users u ON o.user_id = u.user_id;
    
-- 2️0- Show restaurant name + item name + order_count.
SELECT m.item_name, r.name AS restaurant,
        COUNT(oi.item_id) AS total_orders
    FROM order_items oi
    JOIN menu_items m ON oi.item_id = m.item_id
    JOIN restaurants r ON m.restaurant_id = r.restaurant_id
    GROUP BY m.item_name, r.name;

-- 🧠 E. GROUP BY / Analytics

-- 2️1- Find most ordered item (by count).
SELECT item_id, COUNT(*) AS times
    FROM order_items GROUP BY item_id ORDER BY times DESC LIMIT 1;
    
-- 2️2- Find restaurant with highest number of orders.
SELECT restaurant_id, COUNT(*) AS total_orders
    FROM orders GROUP BY restaurant_id ORDER BY total_orders DESC LIMIT 1;
    
-- 2️3- Find top user who placed maximum orders.
SELECT user_id, COUNT(*) AS total
    FROM orders GROUP BY user_id ORDER BY total DESC LIMIT 1;
    
-- 2️4-  Find total orders per month (YEAR-MONTH).
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, COUNT(*) AS orders
    FROM orders GROUP BY month ORDER BY month;
    
-- 2️5- Find total orders per day of week (Mon/Tue…).
SELECT DAYNAME(order_date) AS weekday, COUNT(*)
    FROM orders GROUP BY weekday;
    
-- 2️6- Find total menu items available per restaurant.
SELECT restaurant_id, COUNT(*) AS total_items
    FROM menu_items GROUP BY restaurant_id ORDER BY total_items DESC;
    
-- 2️7- Count unique users who ordered at least once.
SELECT COUNT(DISTINCT user_id) FROM orders;

-- 2️8- List restaurants with average rating > 4.5.
SELECT * FROM restaurants WHERE rating > 4.5;

-- 2️9- Count items where price > 300 grouped by restaurant.
SELECT restaurant_id, COUNT(*)
    FROM menu_items
    WHERE price > 300
    GROUP BY restaurant_id;
    
-- 3️0-  Find items that appear in multiple restaurants (duplicate same name).
SELECT item_name, COUNT(*)
    FROM menu_items
    GROUP BY item_name
    HAVING COUNT(*) > 1;

-- 🧮 F. Subqueries

-- 3️1- Find restaurants whose rating is greater than average rating.
SELECT * FROM restaurants
    WHERE rating > (SELECT AVG(rating) FROM restaurants);
    
-- 3️2- Find users who ordered more times than avg orders.
SELECT user_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id
    HAVING order_count > (SELECT AVG(cnt) FROM
                          (SELECT COUNT(*) AS cnt FROM orders GROUP BY user_id) t);
                          
-- 3️3- Find items that were never ordered (not present in order_items).
SELECT * FROM menu_items
    WHERE item_id NOT IN (SELECT item_id FROM order_items);
    
-- 3️4- Find users who placed no orders.
SELECT * FROM users
    WHERE user_id NOT IN (SELECT DISTINCT user_id FROM orders);
    
-- 3️5- Find restaurants where no orders happened.
SELECT * FROM restaurants
    WHERE restaurant_id NOT IN (SELECT restaurant_id FROM orders);

-- 💸 G. Business Logic (Billing)

-- (Requires price join + qty calculation)

-- 3️6- Show subtotal = qty * price for all ordered items.
SELECT oi.order_id, m.item_name, oi.qty, (oi.qty * m.price) AS subtotal
    FROM order_items oi
    JOIN menu_items m ON oi.item_id = m.item_id;
    
-- 3️7- Show total bill per order (SUM(qty*price)).
SELECT o.order_id, SUM(oi.qty * m.price) AS total_bill
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items m ON oi.item_id = m.item_id
    GROUP BY o.order_id;
    
-- 3️8- Show highest bill order (ORDER BY total DESC).
SELECT o.order_id, SUM(oi.qty * m.price) AS total_bill
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items m ON oi.item_id = m.item_id
    GROUP BY o.order_id
    ORDER BY total_bill DESC LIMIT 1;
    
-- 3️9- Show total revenue earned by each restaurant.
SELECT r.name AS restaurant, SUM(oi.qty * m.price) AS revenue
    FROM restaurants r
    JOIN menu_items m ON r.restaurant_id = m.restaurant_id
    JOIN order_items oi ON m.item_id = oi.item_id
    GROUP BY r.name
    ORDER BY revenue DESC;
    
-- 4️0- Show monthly revenue trend for entire app.
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
           SUM(oi.qty * m.price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items m ON oi.item_id = m.item_id
    GROUP BY month
    ORDER BY month;

-- 🧑‍🤝‍🧑 H. Customer Insights

-- 4️1- Which user ordered from most different restaurants?
SELECT u.user_id, u.name, COUNT(DISTINCT o.restaurant_id) AS unique_restaurants
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id
    ORDER BY unique_restaurants DESC;
    
-- 4️2- Which user spent maximum total money?
SELECT u.user_id, u.name,
           SUM(oi.qty * m.price) AS total_spent
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items m ON oi.item_id = m.item_id
    GROUP BY u.user_id
    ORDER BY total_spent DESC;
    
-- 4️3- Find loyal customers (ordered every month for >= 3 months).
SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING COUNT(DISTINCT DATE_FORMAT(order_date,'%Y-%m')) >= 3;
    
-- 4️4- Show users who ordered more than 5 times.
SELECT user_id, COUNT(*) AS total_orders
    FROM orders GROUP BY user_id HAVING total_orders > 5;
    
-- 4️5- Show users who ordered only once (one-time users).
SELECT user_id, COUNT(*) AS total_orders
    FROM orders GROUP BY user_id HAVING total_orders = 1;

-- 🍔 Menu / Restaurant Insights

-- 4️6- Show cheapest menu item per restaurant.
SELECT restaurant_id, MIN(price) AS cheapest_item
    FROM menu_items GROUP BY restaurant_id;
    
-- 4️7- Show most expensive item in entire DB.
SELECT item_name, price FROM menu_items
    ORDER BY price DESC LIMIT 1;
    
-- 4️8- Show restaurant that has maximum dish variety.
SELECT restaurant_id, COUNT(*) AS dish_variety
    FROM menu_items
    GROUP BY restaurant_id
    ORDER BY dish_variety DESC LIMIT 1;
    
-- 4️9- Show number of veg/nonveg items (if category exists – optional).
SELECT item_name, COUNT(*) AS occurrences
    FROM menu_items
    GROUP BY item_name
    HAVING COUNT(*) > 1;
    
-- 5️0- Show item names appearing in > 3 restaurants (popular common dishes).
SELECT item_name
    FROM menu_items
    GROUP BY item_name
    HAVING COUNT(*) > 3;
    
SHOW TABLES;
select * from restaurants;
select * from orders;
select * from order_items;
select * from menu_items;
select * from users;

   
