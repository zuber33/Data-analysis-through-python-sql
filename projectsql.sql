select * from df_orders;

Alter table df_orders
rename column selling_price to sale_price;

#-----Find top 10 highest revenue generating products

select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales DESC
limit 10;


#---------Find top 5 highest sellling products in each region

with cte as (

select region, product_id, sum(sale_price) as sales
from df_orders
group by 1,2)

select * from (
select *, row_number () over (partition by region order by sales desc) as rn 
from cte) A 
where rn <=5;


#-----find month over month growth comparion for 2022 and 2023 sales eg: jan 2022 vs jan 2023

with cte as (
select year(order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales
 from df_orders
  group by 1,2
)  

select order_month,
sum( case when order_year = 2022 then sales else 0 end) as sales_2022,
sum( case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by 1
order by 1;

#---for each category which month has highest sales
with cte as (
select category, month(order_date) as month, year(order_date), sum(sale_price) as sales
from df_orders
group by 1,2,3)

select * from(
select *, row_number () over (partition by category order by sales  desc) as rn
from cte) a 
where rn = 1;


#---which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category, year(order_date) as order_year, sum(sale_price) as sales
from df_orders
group by 1,2),

cte2 as 
(select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by 1)
select  *, (sales_2023 - sales_2022)*100/sales_2022 as growth
from cte2
order by growth desc
limit 1;