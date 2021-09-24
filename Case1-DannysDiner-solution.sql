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
DROP VIEW IF EXISTS SOLUTION5;
CREATE VIEW SOLUTION5 AS
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

-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query: