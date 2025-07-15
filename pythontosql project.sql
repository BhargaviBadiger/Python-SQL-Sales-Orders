create database if not exists pythontosql;
DROP TABLE `df_orders`;

CREATE TABLE `df_orders` (
  `order_id` int primary key,
  `order_date` date,
  `ship_mode` varchar(20),
  `segment` varchar(20),
  `country` varchar(20),
  `city` varchar(20),
  `state` varchar(20),
  `postal_code` varchar(20),
  `region` varchar(20),
  `category` varchar(20),
  `sub_category` varchar(20),
  `product_id` varchar(50),
  `quantity` int,
  `discount` decimal(7,2),
  `sales` decimal(7,2),
  `profit` decimal(7,2)
);

select * from df_orders;

-- find top 10 highest revenue generating products
select product_id,sum(sales) as sales
from df_orders
group by product_id
order by sales desc
limit 10;

-- find top 5 highest selling products in each region
with cte as(
select region, product_id,sum(sales) as sales
from df_orders
group by region, product_id)
select * from(
select *,
row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5;

-- find month over month growth comparison for 2022 and 2023 sales
with cte as(
select year(order_date) as order_year, month(order_date) as order_month, sum(sales) as sales
from df_orders
group by year(order_date) , month(order_date) 
order by year(order_date) , month(order_date))
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as order_2022,
sum(case when order_year = 2023 then sales else 0 end) as oder_2023
from cte
group by order_month
order by order_month;

-- for each category which month had highest sales
with cte as(
select category, date_format(order_date,'%Y%m') as order_year_month, sum(sales) as sales
from df_orders
group by category, date_format(order_date,'%Y%m')
order by category, date_format(order_date,'%Y%m'))
select * from(
select *,
row_number() over(partition by category order by sales desc) as rn
from cte) A
where rn =1;

-- which sub category had highest growth by profit in 2023 compared to 2022
with cte as(
select sub_category,year(order_date) as order_year, sum(sales) as sales
from df_orders
group by sub_category,year(order_date)  
order by sub_category,year(order_date)),
cte2 as(
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as order_2022,
sum(case when order_year = 2023 then sales else 0 end) as oder_2023
from cte
group by sub_category
order by sub_category)
select *,
((oder_2023-order_2022)*100/order_2022) as growth
from cte2
order by growth desc
limit 1;
