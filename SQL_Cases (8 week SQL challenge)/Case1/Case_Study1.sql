/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:
SELECT* 
FROM dannys_diner.members;

SELECT* 
FROM dannys_diner.menu;

SELECT* 
FROM dannys_diner.sales;

--1 What is the total amount each customer spent at the restaurant?
SELECT
   m.customer_id,
   SUM(menu.price) AS total_amount_spent
FROM dannys_diner.members AS m
LEFT JOIN dannys_diner.sales AS s
ON m.customer_id = s.customer_id
LEFT JOIN dannys_diner.menu AS menu
ON menu.product_id = s.product_id
GROUP BY m.customer_id;

--2 How many days has each customer visited the restaurant?
SELECT
   m.customer_id,
   COUNT(DISTINCT s.order_date) AS days_visited
FROM dannys_diner.members AS m
LEFT JOIN dannys_diner.sales AS s
ON m.customer_id = s.customer_id
GROUP BY m.customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT
   members.customer_id,
   MIN(sales.order_date)
FROM dannys_diner.members AS members
LEFT JOIN dannys_diner.sales AS sales
ON members.customer_id = sales.customer_id
GROUP BY members.customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT*
FROM dannys_diner.menu AS m
LEFT JOIN dannys_diner.sales AS s
   ON m.