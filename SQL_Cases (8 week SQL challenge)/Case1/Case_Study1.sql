/* --------------------
   Case Study Questions
   --------------------*/




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
SELECT
   m.product_name,
   COUNT(m.product_id) AS times_purchased
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
   ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
SELECT
   ranked.customer_id,
   ranked.product_name,
   times_purchased
FROM(
   SELECT
      s.customer_id,
      m.product_name,
      COUNT(*) AS times_purchased,
      RANK() OVER (
         PARTITION BY s.customer_id 
         ORDER BY COUNT(*) DESC
      ) AS rnk
   FROM dannys_diner.sales as s
   JOIN dannys_diner.menu as m
      ON s.product_id = m.product_id
   GROUP BY s.customer_id,m.product_name
) ranked
WHERE rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT
   customer_id,
   order_date,
   join_date,
   product_name
FROM(
SELECT
   s.customer_id,
   s.order_date,
   m.join_date,
   menu.product_name,
   ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) OrderRank
FROM dannys_diner.sales s
JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
JOIN dannys_diner.menu menu
ON s.product_id = menu.product_id
WHERE s.order_date > join_date
)t WHERE OrderRank = 1;

-- 7. Which item was purchased just before the customer became a member?

SELECT 
   customer_id,
   order_date,
   join_date,
   product_name
FROM(
SELECT
   s.customer_id,
   s.order_date,
   m.join_date,
   menu.product_name,
   ROW_NUMBER () OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) OrderRank
FROM dannys_diner.sales s
JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
JOIN dannys_diner.menu menu
ON s.product_id = menu.product_id
WHERE order_date < join_date
)t WHERE OrderRank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
   s.customer_id,
   COUNT(*) AS TotalItemsOrdered,
   TO_CHAR(SUM(menu.price), '$FM999,999,990.00') AS total_amount_spent
FROM dannys_diner.sales s
JOIN dannys_diner.members m
ON s.customer_id = m.customer_id
JOIN dannys_diner.menu menu
ON s.product_id = menu.product_id
WHERE order_date < join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
--how many points would each customer have?
SELECT
   s.customer_id,
   SUM(
      CASE
         WHEN m.product_name = 'sushi' THEN m.price * 20
         ELSE m.price * 10
      END) TotalPoints
FROM dannys_diner.menu as m
JOIN dannys_diner.sales as s
ON m.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

/* 10. In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, 
not just sushi how many points do customer A and B have at the end of January? */
SELECT
   s.customer_id,
   SUM(
      CASE
         WHEN  s.order_date BETWEEN member.join_date AND member.join_date + INTERVAL '7 days'
            THEN m.price* 20 
         WHEN m.product_name = 'sushi'
            THEN m.price * 10
         ELSE m.price * 10
      END) TotalPoints
FROM dannys_diner.menu as m
JOIN dannys_diner.sales as s
ON m.product_id = s.product_id
JOIN dannys_diner.members as member
ON member.customer_id = s.customer_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

