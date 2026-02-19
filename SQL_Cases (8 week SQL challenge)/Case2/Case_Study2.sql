
/* Data cleaning*/
SELECT*
FROM pizza_runner.customer_orders;
SELECT*
FROM pizza_runner.runner_orders;

WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
SELECT * 
FROM clean_runner_orders;

WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT*
FROM clean_customer_orders;



--A. Pizza Metrics
--How many pizzas were ordered?
WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    COUNT(*) AS total_ordered_pizzas
FROM clean_customer_orders;

--How many unique customer orders were made?
WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    COUNT(DISTINCT order_id) AS unique_customer_orders
FROM clean_customer_orders;

--How many successful orders were delivered by each runner?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
SELECT
    runner_id,
    COUNT(DISTINCT order_id) AS completed_deliveries
FROM clean_runner_orders
WHERE pickup_time IS NOT NULL
GROUP BY runner_id
ORDER BY runner_id;

--How many of each type of pizza was delivered?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
, clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT 
    pn.pizza_name,
    COUNT(cco.pizza_id) AS ordered_pizza
FROM clean_customer_orders cco
LEFT JOIN pizza_runner.pizza_names pn
    ON cco.pizza_id = pn.pizza_id
LEFT JOIN clean_runner_orders cro
    ON cro.order_id = cco.order_id
WHERE cro.pickup_time IS NOT NULL
GROUP BY
    pn.pizza_name
ORDER BY
    pn.pizza_name;

--How many Vegetarian and Meatlovers were ordered by each customer?
WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    customer_id,
    pizza_name,
    COUNT(*) AS pizzas_ordered
FROM clean_customer_orders cco
LEFT JOIN pizza_runner.pizza_names pn
ON cco.pizza_id = pn.pizza_id
GROUP BY
    customer_id,
    pizza_name
ORDER BY
    customer_id,
    pizza_name;
--What was the maximum number of pizzas delivered in a single order?
WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
, clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
SELECT
    MAX(pizza_count)
FROM(
    SELECT
        cco.order_id,
        COUNT(*) AS pizza_count
    FROM clean_customer_orders cco
    INNER JOIN clean_runner_orders cro
        ON cro.order_id = cco.order_id
    WHERE cro.pickup_time IS NOT NULL
    GROUP BY cco.order_id
    )t;
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
, clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )


SELECT
    customer_id,
    CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 'change'
        ELSE  'no_change'
    END AS modifications,
    COUNT(*) AS total_pizzas
FROM clean_customer_orders cco
INNER JOIN clean_runner_orders cro
    ON cro.order_id = cco.order_id
WHERE pickup_time IS NOT NULL
GROUP BY 
    customer_id,
    modifications
ORDER BY
    customer_id,
    modifications;

--How many pizzas were delivered that had both exclusions and extras?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
, clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    COUNT(*) AS total_pizzas
FROM clean_runner_orders cro
INNER JOIN clean_customer_orders cco
    ON cco.order_id = cro.order_id
WHERE pickup_time IS NOT NULL
    AND exclusions IS NOT NULL
    AND extras IS NOT NULL;

--What was the total volume of pizzas ordered for each hour of the day?
WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    TO_CHAR (order_time,'HH12 AM') AS order_hour,
    COUNT(*) AS total_pizzas
 FROM clean_customer_orders
 GROUP BY order_hour
 ORDER BY order_hour;

--What was the volume of orders for each day of the week?
WITH clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    TO_CHAR (order_time, 'Day') AS order_day,
    COUNT(*) AS total_pizzas
FROM clean_customer_orders
GROUP BY order_day
ORDER BY order_day;

--B. Runner and Customer Experience

--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    DATE_TRUNC('week', registration_date - INTERVAL '4 days') + INTERVAL '4 days' AS week_start,
    COUNT(*) AS runner_signup
FROM pizza_runner.runners
GROUP BY week_start
ORDER BY week_start;

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
, clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT 
    runner_id,
    ROUND(
        AVG(pickup_speed)
        ,0) AS avg_pickup
FROM(
SELECT 
    runner_id,
    ROUND(
        EXTRACT(EPOCH FROM (pickup_time - order_time)) / 60
        ,0) AS pickup_speed
FROM clean_runner_orders cro
INNER JOIN clean_customer_orders cco
    ON cro.order_id = cco.order_id
WHERE cro.pickup_time IS NOT NULL
)t
GROUP BY runner_id;

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
, clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
, total_pizzas AS(
    SELECT
        cco.order_id,
        COUNT(*) AS pizza_count
    FROM clean_customer_orders cco
    INNER JOIN clean_runner_orders cro
        ON cco.order_id = cro.order_id
    GROUP BY cco.order_id
)
, prep_time AS(
    SELECT
        cco.order_id,
        ROUND(
        EXTRACT(EPOCH FROM (pickup_time - order_time)) / 60
        ,0) AS prep
    FROM clean_runner_orders cro
    INNER JOIN clean_customer_orders cco
        ON cro.order_id = cco.order_id
    WHERE pickup_time IS NOT NULL
)
SELECT
    tp.pizza_count,
    ROUND(
        AVG(pt.prep)
        ,0) AS AVG_prep
FROM total_pizzas tp
INNER JOIN prep_time pt
    ON tp.order_id = pt.order_id
GROUP BY tp.pizza_count
ORDER BY tp.pizza_count;

--What was the average distance travelled for each customer?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
, clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    customer_id,
    ROUND(
        AVG(distance)
        ,0) AS avg_distance
FROM clean_runner_orders cro
JOIN clean_customer_orders cco
    ON cro.order_id = cco.order_id
WHERE pickup_time IS NOT NULL
GROUP BY customer_id;

--What was the difference between the longest and shortest delivery times for all orders?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
    SELECT
        MAX(duration) - MIN(duration) AS delivery_difference
    FROM clean_runner_orders
    WHERE duration IS NOT NULL AND pickup_time IS NOT NULL;

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
/*From the data given, runner 1 is more consistent in their delivery speed with having some of the lowest distance 
needed to be traveled for each order while having the highest speeds.
*/
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
, clean_customer_orders AS(
    SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE WHEN TRIM(exclusions) IN ('','null') THEN NULL
            ELSE TRIM(exclusions)
        END AS exclusions,
        CASE WHEN TRIM(extras) IN ('','null') THEN NULL
            ELSE TRIM(extras)
        END AS extras,
        order_time
    FROM pizza_runner.customer_orders
    )
SELECT
    cro.runner_id,
    cco.order_id,
    ROUND(AVG((distance / duration) * 60),2) AS speed
FROM clean_runner_orders cro
INNER JOIN clean_customer_orders cco
    ON cro.order_id = cco.order_id
WHERE duration IS NOT NULL
GROUP BY
    runner_id,
    cco.order_id
ORDER BY 
    runner_id,
    cco.order_id;

--What is the successful delivery percentage for each runner?
WITH clean_runner_orders AS(
    SELECT
        order_id,
        runner_id,
        NULLIF(pickup_time, 'null')::timestamp AS pickup_time,
        CAST(REPLACE(NULLIF(distance, 'null'),'km','') AS numeric) AS distance,
        CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                    NULLIF(duration,'null')
                    ,'minutes',''),
                    'mins',''),
                    'min',''),
                    'ute','') 
                    AS integer) AS duration,
        CASE WHEN cancellation IN ('null','') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
    )
SELECT
    runner_id,
    SUM(delivery_status) AS successful_deliveries,
    COUNT(*) AS total_deliveries,
    ROUND(
        SUM(delivery_status)::numeric / COUNT(*) * 100,2 
    ) AS success_rate
FROM(
    SELECT
    runner_id,
        CASE WHEN pickup_time IS NOT NULL AND cancellation IS NULL THEN 1 
            ELSE 0
        END AS delivery_status
    FROM clean_runner_orders
)t
GROUP BY runner_id
ORDER BY runner_id;

--C. Ingredient Optimisation

--What are the standard ingredients for each pizza?

--What was the most commonly added extra?

--What was the most common exclusion?

/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?



--D. Pricing and Ratings

/*If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
how much money has Pizza Runner made so far if there are no delivery fees?*/
/*What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra*/

/*The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,\
how would you design an additional table for this new dataset 
generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
Using your newly generated table
can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas*/


/*If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled
- how much money does Pizza Runner have left over after these deliveries?*/



--E. Bonus Questions
/*If Danny wants to expand his range of pizzas - 
how would this impact the existing data design? 
Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?*/
=======







