select * from E_commerce_project..orderDetails 
select * from E_commerce_project..List_of_order
select * from E_commerce_project..Sales_target

--Creating view for further visualisation

CREATE VIEW Combined_orders as
 select o.[Order ID], o.Profit, o.Quantity, o.Amount, o.Category, o.[Sub-Category],l.[Order Date],l.City, l.CustomerName, l.State from
 E_commerce_project..orderDetails O join E_commerce_project..List_of_order L on o.[Order ID]=l.[Order ID]
  
  drop view Combined_orders

select * from Combined_orders

--Find the number of orders, customers, cities, and states
select COUNT(Distinct([Order ID])) order_id, COUNT(Distinct(CustomerName)) Customers, COUNT(Distinct(City)) cities,  COUNT(Distinct(State)) states   from Combined_orders

--Find the new customers who made purchases in the year 2019.
--Order the result by the amount they spent.

select CustomerName, sum(Amount) Amt from Combined_orders where CustomerName not in
(select CustomerName from Combined_orders where [Order Date] like '%2018%')
group by CustomerName order by Amt desc




--Find the top profitable states & cities so that the company can expand its business. 
--Determine the number of products sold and the number of customers in these top profitable states & cities.

select  count(Distinct(CustomerName)) cust_count, count(quantity) quantity_count ,State,city, sum(Profit) profit from Combined_orders group by State ,City order by profit desc



CREATE VIEW Combined_orders as
 select o.[Order ID] , o.Profit, o.Quantity, o.Amount, o.Category, o.[Sub-Category],l.[Order Date],l.City, l.CustomerName, l.State from
 E_commerce_project..orderDetails O join E_commerce_project..List_of_order L on o.[Order ID]=l.[Order ID]

--Display the details (in terms of “order_date”, “order_id”, “State”, and “CustomerName”) for the first order in each state.
--Order the result by “order_id”.

select CustomerName, [Order Date], [Order ID],State
from( select *, ROW_NUMBER() over (partition by state order by state, [order id]) as rownumber_per_state 
from Combined_orders) firstOrder
where rownumber_per_state=1
order by [Order ID]

--Determine the number of orders (in the form of a histogram) and sales for different days of the week.



select weekdays, right(replicate('*',a.num_orders )+ '*',a.num_orders) as no_of_orders, sales  from
( select COUNT(distinct([Order ID])) as num_orders,sum(Amount) sales , 
DATENAME(WEEKDAY, [Order Date]) weekdays from Combined_orders group by DATENAME(WEEKDAY, [Order Date])  )a
  order by sales 


 -- Check the monthly profitability and monthly quantity sold 


select concat_ws('-',DATENAME(MONTH,[Order Date]) , DATENAME(YEAR, [Order Date])) as mon_year, sum(Profit) profitability , sum(Quantity) quantity_sold  from Combined_orders 
	  group by  concat_ws('-',DATENAME(MONTH,[Order Date]) , DATENAME(YEAR, [Order Date])) 


--Determine the number of times that salespeople hit or failed to hit the sales target for each category.

create view sales_vs_category as
select convert(nvarchar,concat_ws('-',substring(DATENAME(MONTH,[Order Date]),1,3) , substring(datename(YEAR, [Order Date]),3,2))) as mon_year, Category, sum(Amount) sales from Combined_orders 
group by Category, convert(nvarchar,concat_ws('-',substring(DATENAME(MONTH,[Order Date]),1,3) , substring(datename(YEAR, [Order Date]),3,2)))

drop view sales_vs_category


create view targethit as
select*, case 
    when s.sales>= s.Target then 'hit'
	else
	'fail'
	end as hit_or_fail
from (select a.mon_year, a.Category, a.sales, b.Target from sales_vs_category as a  join E_commerce_project..Sales_target as b on 
a.mon_year=b.[Month of Order Date] and a.Category=b.Category)s




select h.category, h.Hit, f.fail  from 
( select category,  count(*) as HIT 
from targethit
where hit_or_fail ='hit' 
group by Category 
)h join (select category,  count(*) as FAil 
from targethit
where hit_or_fail ='fail' 
group by Category)f on h.category= f.category


--Find the total sales, total profit, and total quantity sold for each category and sub-category.
--Return the maximum cost and maximum price for each sub-category too.



select z.Category,z.[Sub-Category], sum(z.Quantity) total_quantities, sum(z.Profit) total_profit, sum(z.Amount) total_sales, max(z.cost) as max_cost, max(z.price) max_price from
(select *, round(((Amount-Profit)/Quantity),3) as cost, round((Amount/Quantity),3) as price from E_commerce_project..orderDetails)z
group by z.Category,z.[Sub-Category]
order by total_quantities desc





