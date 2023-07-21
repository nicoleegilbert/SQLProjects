--Created By: Nicole Gilbert
--Date Created: 7/10/2023
-- Description: Generate a detailed data set in order to create a comprehensive sales dashboard for the executive team of the Bike Store. In order to 
--				create the table needed for the dash board, I first had to gather the columns of information I was interested in presenting using joins. 

SELECT 
	ord.order_id, 
	CONCAT(cus.first_name,'  ', cus.last_name) 'customers',
	cus.city, 
	cus.state, 
	ord.order_date,
	SUM(ite.quantity) AS 'total_units',
	SUM(ite.quantity * ite.list_price) AS 'revenue',
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name,' ', sta.last_name) 'sales_rep'
FROM bikestores.sales.orders ord
JOIN bikestores.sales.customers cus
ON ord.customer_id = cus.customer_id
JOIN bikestores.sales.order_items ite
ON ord.order_id = ite.order_id
JOIN bikestores.production.products pro
ON ite.product_id = pro.product_id
JOIN BikeStores.production.categories cat
ON pro.category_id = cat.category_id
JOIN BikeStores.sales.stores sto
ON ord.store_id = sto.store_id
JOIN bikestores.sales.staffs sta
ON ord.staff_id = sta.staff_id
GROUP BY 
	ord.order_id, 
	CONCAT(cus.first_name,'  ', cus.last_name),
	cus.city, 
	cus.state, 
	ord.order_date,
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name,' ', sta.last_name)