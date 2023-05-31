--Create a temporary table that joins the orders, order_products, and products tables to get information about each order,  including the products that were purchased and their department and aisle information.


CREATE TEMP TABLE all_orders_products AS (
SELECT o.order_id,
	o.user_id,
	o.order_number,
	o.order_dow,
	o.order_hour_of_day,
	o.days_since_prior_order,
	op.add_to_cart_order,
	op.reordered,
	p.product_id,
	p.product_name,
	p.aisle_id,
	p.department_id
	FROM orders o
	LEFT JOIN order_products op ON o.order_id = op.order_id 
	LEFT JOIN products p ON op.product_id = p.product_id
)

--Create a temporary table that groups the orders by product and finds the total number of times each product was purchased, the total number of times each product was reordered, and the average number of times each product was added to a cart.
CREATE TEMP TABLE  product_info AS
(
SELECT 
	product_id,
	count(product_id) AS total_num_times_product,
	SUM(reordered) as total_reordered,
	AVG(add_to_cart_order) as avg_added_to_cart
FROM all_orders_products
GROUP BY product_id 
ORDER BY product_id ASC
)

--Create a temporary table that groups the orders by department and finds the total number of products purchased, the total number of unique products purchased, the total number of products purchased on weekdays vs weekends, and the average time of day that products in each department are ordered.

CREATE TEMP TABLE order_dep_info AS (

SELECT 
	department_id,
	COUNT(product_id) AS num_products_purchased,
	COUNT(DISTINCT product_id) AS unique_num_of_products,
	COUNT(CASE 
		  WHEN order_dow <5 THEN 1
		  ELSE NULL						
		  END) AS total_weekdays,
	COUNT(CASE 
		 WHEN order_dow >= 5 THEN 1
		 ELSE NULL
		 END) AS total_weekends,
	AVG(order_hour_of_day) AS avg_time_of_day
FROM all_orders_products
GROUP BY department_id
ORDER BY department_id ASC
)

--Create a temporary table that groups the orders by aisle and finds the top 10 most popular aisles, including the total number of products purchased and the total number of unique products purchased from each aisle.

CREATE TEMP TABLE orders_aisle_info AS(
SELECT 
	aisle_id,
	COUNT(order_id) AS total_orders_aisle,
	COUNT(product_id) as total_products_purchased_aisle,
	COUNT(DISTINCT product_id) AS total_unique_products_purchased_aisle
FROM all_orders_products
GROUP BY aisle_id
ORDER BY total_products_purchased_aisle DESC
)

--Combine the information from the previous temporary tables into a final table that shows the product ID, product name, department ID, department name, aisle ID, aisle name, total number of times purchased, total number of times reordered, average number of times added to cart, total number of products purchased, total number of unique products purchased, total number of products purchased on weekdays, total number of products purchased on weekends, and average time of day products are ordered in each department.


CREATE TEMPORARY TABLE product_behavior_analysis AS(
    SELECT pi.product_id, pi.product_name, pi.department_id, d.department, pi.aisle_id, a.aisle,
           pos.total_num_times_product, pos.total_reordered, pos.avg_added_to_cart,
           dos.num_products_purchased, dos.unique_num_of_products,
           dos.total_weekdays, dos.total_weekends, dos.avg_time_of_day
    FROM product_info AS pos
    JOIN products AS pi ON pos.product_id = pi.product_id
    JOIN departments AS d ON pi.department_id = d.department_id
    JOIN aisles AS a ON pi.aisle_id = a.aisle_id
    JOIN order_dep_info AS dos ON pi.department_id = dos.department_id
)