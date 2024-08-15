Create database Pizza;

use Pizza;

-- Retrieve the total number of orders placed.-- 
select count(order_id) as 'Total_Orders' from orders;

-- Calculate the total revenue generated from pizza sales.
select 
round(sum(order_details.quantity * pizzas.price),2) as Total_revenue
from order_details join pizzas 
on pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
-- select max(price) as 'Most_Expensive_Pizza' from pizzas;
select pizza_types.name,pizzas.price from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price 
desc limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as Count_of_Orders
from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by Count_of_Orders desc;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,
sum(order_details.quantity) as 'Quantity'
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by Quantity desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) as 'Quantity'
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by Quantity desc;

-- Determine the distribution of orders by hour of the day.
select hour(orders.time) as hour,count(orders.order_id) as order_count from orders
group by hour(orders.time)
order by hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) as 'number of pizzas' from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
select	round(avg(quantity),0) as avg_pizza_per_day from 
(select orders.date, sum(order_details.quantity) as quantity
from orders 
join order_details on orders.order_id = order_details.order_id
group by orders.date) as order_Quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category, 
    round((SUM(order_details.quantity * pizzas.price) / 
        (SELECT SUM(order_details.quantity * pizzas.price) 
         FROM pizzas 
         JOIN order_details ON order_details.pizza_id = pizzas.pizza_id)
    ) * 100,2) AS revenue
FROM 
    pizzas 
JOIN 
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category 
ORDER BY 
    revenue DESC;

-- Analyze the cumulative revenue generated over time.
select date,
	sum(revenue) over (order by date) as cum_revenue
    from
		(select 
			orders.date ,
			sum(order_details.quantity * pizzas.price) as revenue
			from orders
			join order_details on orders.order_id = order_details.order_id
			join pizzas on pizzas.pizza_id = order_details.pizza_id
			group by date
			order by revenue) as Sales;
            
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue
from
	(select category,name,revenue,
	rank() over(partition by category order by revenue desc) as rn
		from
			(select pizza_types.category,pizza_types.name,
				sum(order_details.quantity * pizzas.price) as revenue
				from pizza_types
					join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
					join order_details on pizzas.pizza_id = order_details.pizza_id
				group by pizza_types.category,pizza_types.name
				order by revenue) as tabale1) as table2
	where rn <= 3;

