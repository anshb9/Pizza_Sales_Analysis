-- Creating DATABASE

create database pizzahut;

-- Creating table 

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id) );

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

-- OR we can import table by going to table data import wizard

-- If you want to combine all tables and then do the operations and answer the questions so we can use following quesry

CREATE TABLE combine AS SELECT orders.order_id AS ID,
    pizza_types.name AS Name,
    order_details.order_details_id AS OD_ID,
    pizza_types.category AS cat,
    pizzas.pizza_id AS P_ID,
    order_details.quantity AS QUAN,
    pizza_types.pizza_type_id AS PT_ID,
    pizzas.size AS SIZE,
    pizzas.price AS amount FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id;

-- or if we want to answer without combining all tables than following questions can be answered using following queries 

-- KEY BUSINESS QUESTIONS WITH SOLUTIONS 

-- 1. Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id)
FROM
    orders;
    
-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(order_details.quantity * pizzas.price)
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id;

-- 3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(order_details.quantity)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY COUNT(order_details.quantity) DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(order_details.quantity) DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, COUNT(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY COUNT(order_details.quantity) DESC;

-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(orders.time), COUNT(order_details.quantity)
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY HOUR(orders.time);

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pizza_types.category, COUNT(order_details.quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY COUNT(order_details.quantity) DESC;

-- 9. Group the ord)ers by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS w;

-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name, sum(order_details.quantity * pizzas.price)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY sum(order_details.quantity * pizzas.price) DESC limit 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    pizzas
                        JOIN
                    order_details ON order_details.pizza_id = pizzas.pizza_id) * 100),2) AS percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

-- 12. Analyze the cumulative revenue generated over time.

select date, sum(revenue) over (order by date) as cum_revenue from
(SELECT 
    orders.date,
    (SUM(order_details.quantity * pizzas.price)) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.date) as sales;	

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name, revenue, rank_num from
(select category,name, revenue, rank() over(partition by category order by revenue desc) as rank_num from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    (SUM(order_details.quantity * pizzas.price)) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as r) as b
where rank_num <=3;



