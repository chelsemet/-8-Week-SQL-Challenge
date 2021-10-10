/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
DROP VIEW IF EXISTS SOLUTION1;
CREATE VIEW SOLUTION1 AS
(SELECT s.customer_id, sum(m.price) AS total_amount
FROM sales AS s, menu AS m
WHERE s.product_id = m.product_id
GROUP BY customer_id);

-- 2. How many days has each customer visited the restaurant?
DROP VIEW IF EXISTS SOLUTION2;
CREATE VIEW SOLUTION2 AS
(SELECT customer_id, count(distinct order_date) as `number_of_days`
FROM sales
GROUP BY customer_id);

-- 3. What was the first item from the menu purchased by each customer?
DROP VIEW IF EXISTS SOLUTION3;
CREATE VIEW SOLUTION3 AS
(WITH temp AS 
(SELECT customer_id, product_id, ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS r
FROM sales)

SELECT temp.customer_id, temp.product_id , m.product_name FROM temp, menu AS m WHERE r = 1 and temp.product_id = m.product_id);

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
DROP VIEW IF EXISTS SOLUTION4;
CREATE VIEW SOLUTION4 AS
(SELECT s.product_id, m.product_name, count(*) AS purchased_times
FROM sales AS s, menu AS m
WHERE s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY purchased_times DESC
LIMIT 1);

-- 5. Which item was the most popular for each customer?
DROP VIEW IF EXISTS SOLUTION5;
CREATE VIEW SOLUTION5 AS
(WITH temp as
(SELECT customer_id, product_id, count(*) AS bought_times
FROM sales
GROUP BY customer_id, product_id)

SELECT t.customer_id, t.product_id, m.product_name
FROM
(SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY bought_times DESC) AS r FROM temp) AS t
LEFT JOIN
menu AS m
ON
t.product_id = m.product_id
WHERE r = 1
ORDER BY t.customer_id);

-- 6. Which item was purchased first by the customer after they became a member?
DROP VIEW IF EXISTS SOLUTION6;
CREATE VIEW SOLUTION6 AS
(WITH temp AS(SELECT s.*
FROM sales AS s, members AS me
WHERE s.customer_id = me.customer_id and s.order_date > me.join_date)

SELECT t.customer_id, t.product_id, m.product_name
FROM
(SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS r FROM temp) AS t
LEFT JOIN
menu AS m
ON t.product_id = m.product_id
WHERE r = 1);

-- 7. Which item was purchased just before the customer became a member?
DROP VIEW IF EXISTS SOLUTION7;
CREATE VIEW SOLUTION7 AS
( SELECT t2.customer_id, t2.product_id, me.product_name
  FROM 
  (SELECT *, RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS r FROM
  (SELECT s.*
  FROM sales AS s, members AS m
  WHERE s.customer_id = m.customer_id AND s.order_date < m.join_date) AS t1) AS t2,
  menu AS me
  WHERE r = 1 and t2.product_id = me.product_id
  ORDER BY t2.customer_id
);

-- 8. What is the total items and amount spent for each member before they became a member?
DROP VIEW IF EXISTS SOLUTION8;
CREATE VIEW SOLUTION8 AS
( SELECT s.customer_id, count(*) AS total_items, SUM(me.price) AS amount_spent
	FROM sales AS s
	INNER JOIN
	members AS m
	ON s.customer_id = m.customer_id AND s.order_date < m.join_date
	LEFT JOIN
	menu AS me
	ON s.product_id = me.product_id
	GROUP BY s.customer_id
);
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
DROP VIEW IF EXISTS SOLUTION9;
CREATE VIEW SOLUTION9 AS
( SELECT customer_id, SUM(points) AS total_points
FROM
(SELECT s.customer_id, (CASE WHEN me.product_name = 'sushi' THEN price * 2 ELSE price END) AS points
FROM sales AS s, menu AS me
WHERE s.product_id = me.product_id) AS t
GROUP BY customer_id
);

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
DROP VIEW IF EXISTS SOLUTION10;
CREATE VIEW SOLUTION10 AS
( SELECT customer_id, SUM(points) AS total_points
	FROM
	(SELECT s.customer_id,
	(CASE WHEN datediff(order_date,join_date) < 7 OR me.product_name = 'sushi' THEN price * 2 ELSE price END) AS points
	FROM sales AS s, menu AS me, members as m
	WHERE s.product_id = me.product_id AND s.customer_id = m.customer_id AND s.order_date >= m.join_date AND s.order_date < '2021-02-01') AS t
	GROUP BY customer_id
	ORDER BY customer_id
);

-- BONUS
DROP VIEW IF EXISTS BONUS1;
CREATE VIEW BONUS1 AS
( SELECT s.customer_id,s.order_date,me.product_name,me.price, (CASE WHEN isnull(join_date) OR order_date < join_date THEN 'N' ELSE 'Y' END) AS `member`
	FROM sales AS s
	LEFT JOIN menu AS me
	ON s.product_id = me.product_id
	LEFT JOIN members AS m
	ON s.customer_id = m.customer_id
);

DROP VIEW IF EXISTS BONUS2;
CREATE VIEW BONUS2 AS
( WITH t1 AS (SELECT s.customer_id,s.order_date,me.product_name,me.price, 
	(CASE WHEN isnull(join_date) OR order_date < join_date THEN 'N' ELSE 'Y' END) AS `member`
	FROM sales AS s
	LEFT JOIN menu AS me
	ON s.product_id = me.product_id
	LEFT JOIN members AS m
	ON s.customer_id = m.customer_id)
    
    SELECT t1.*, (CASE WHEN t1.`member` = 'Y' THEN RANK() OVER(PARTITION BY customer_id, `member` ORDER BY order_date) END) AS ranking
    FROM t1
);

DROP VIEW IF EXISTS BONUS2;
CREATE VIEW BONUS2 AS
( WITH t1 AS (SELECT s.customer_id,s.order_date,me.product_name,me.price, 
	(CASE WHEN isnull(join_date) OR order_date < join_date THEN 'N' ELSE 'Y' END) AS `member`
	FROM sales AS s
	LEFT JOIN menu AS me
	ON s.product_id = me.product_id
	LEFT JOIN members AS m
	ON s.customer_id = m.customer_id)
    
    SELECT t1.*, (CASE WHEN t1.`member` = 'Y' THEN RANK() OVER(PARTITION BY customer_id, `member` ORDER BY order_date) END) AS ranking
    FROM t1
);
-- Example Query: