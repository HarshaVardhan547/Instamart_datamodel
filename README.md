# Instacart Market Basket Analysis

This project involves analyzing the Instacart Market Basket Analysis dataset, which is a relational set of files describing customers' orders over time. The goal of the project is to predict which products will be in a user's next order. The dataset is anonymized and contains a sample of over 3 million grocery orders from more than 200,000 Instacart users.

**Dataset Description**
The dataset contains the following tables:

1) aisles: This table provides information about the different aisles in the grocery store.
2) departments: This table provides information about the different departments in the grocery store.
3) ordered products: This table contains the sequence of products purchased in each order.
4) orders: This table provides information about each order, including the week and hour of day it was placed and the time between orders.
5) products: This table provides information about the products, including their department and aisle information.
The dataset consists of around 1,050,000 rows of data.

**SQL Queries and Questions**
The project involves solving five different questions using SQL queries in pgAdmin 4. Here are the questions and the corresponding SQL queries:

**Question 1:** Create a temporary table that joins the orders, order_products, and products tables to get information about each order, including the products that were purchased and their department and aisle information.

SQL Query: 

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

**Question 2:** Create a temporary table that groups the orders by product and finds the total number of times each product was purchased, the total number of times each product was reordered, and the average number of times each product was added to a cart.

SQL Query: 

CREATE TEMP TABLE  product_info AS(

SELECT 
	product_id,
	count(product_id) AS total_num_times_product,
	SUM(reordered) as total_reordered,
	AVG(add_to_cart_order) as avg_added_to_cart
	
FROM all_orders_products

GROUP BY product_id 

ORDER BY product_id ASC

)

**Question 3:** Create a temporary table that groups the orders by department and finds the total number of products purchased, the total number of unique products purchased, the total number of products purchased on weekdays vs weekends, and the average time of day that products in each department are ordered.

SQL Query: 

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

**Question 4:** Create a temporary table that groups the orders by aisle and finds the top 10 most popular aisles, including the total number of products purchased and the total number of unique products purchased from each aisle.

SQL Query: 

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

**Question 5:** Combine the information from the previous temporary tables into a final table that shows comprehensive information about each product, including the total number of times purchased, total number of times reordered, average number of times added to cart, total number of products purchased, total number of unique products purchased, total number of products purchased on weekdays, total number of products purchased on weekends, and average time of day products are ordered in each department.

SQL Query: 

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

**Process**
1)Downloaded the Instacart Market Basket Analysis dataset from Kaggle.
2)Set up a PostgreSQL database to store the dataset and perform SQL queries. You can use tools like pgAdmin 4 to manage the database.
3)Used Python and Jupyter Notebook to upload the dataset into the PostgreSQL database. The Psycopg2,sqlalchemy libraries was used to establish a connection to the database and import the data
4)Used pgAdmin 4 to execute SQL queries for solving five different questions. The queries were executed separately for each question and the results were stored in temporary tables within the PostgreSQL database.
5)Analyzed and interpreted the results obtained from the SQL queries to gain insights into customer behavior, product popularity, and other relevant aspects.

**Results**
The results of the SQL queries will be stored in temporary tables and can be accessed using SQL queries or exported to other formats for further analysis.
