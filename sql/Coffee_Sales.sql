# Creating a Database
create database coffee_sales;
use coffee_sales;

# Creating a Table

create table sales
(
	dates date,
    date_time datetime,
    cash_type varchar(10),
    card varchar(20) null,
    money decimal(5,2),
    coffee_name varchar(20)
);

#Loading data from the CSV to the Table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/index_1.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


# Checking for null values

select dates, date_time, cash_type,card,money,coffee_name
from sales 
where dates is null or date_time is null or cash_type is null or card is null or money is null or coffee_name is null ;


# Checking for empty fields

select dates, date_time, cash_type,card,money,coffee_name
from sales 
where cash_type = "" or card = "" or money = "" or coffee_name = "" ;


# Replacing empty values with a placeholder

update sales 
set card = "NonCardCustomer"
where card = "";


# 01. Total sales

select sum(money) as total_earnings
from sales;


# 02. Top card customers

select card,count(*) as visits
from sales 
where card != ""
group by card
order by visits desc
limit 5;


# 03. Payment Type

select cash_type, count(*) as customers_count
from sales
group by cash_type;

select cash_type, sum(money) as total_revenue
from sales
group by cash_type;


# 04. best selling products

select coffee_name, count(*) as quantity_sold
from sales
group by coffee_name
order by quantity_sold desc
limit 5;


# 05. top revenue generating products

select coffee_name, sum(money) as Total_revenue
from sales
group by coffee_name
order by Total_revenue desc
limit 5;


# 06. monthly sales 

select distinct date_format(dates,'%y-%m') as month , sum(money) as total_revenue
from sales
group by date_format(dates,'%y-%m')
order by month;


# 07. month-on-month change

with month_trend as(
select distinct date_format(dates,'%y-%m') as month_year , sum(money) as revenue
from sales
group by month_year)

select month_year,revenue,
lag(revenue) over (order by month_year) as revenue_last_month,
revenue - lag(revenue) over (order by month_year) as month_change
from month_trend;


# 08. Ranking months with highest Sales

with month_trend as(
select distinct date_format(dates,'%y-%m') as month_year , sum(money) as revenue
from sales
group by month_year)

select month_year, revenue,
dense_rank() over (order by revenue desc) as Monthly_Sales_Rank
from month_trend
limit 5;


# 09. Find new vs returning customers (card holders) 

with Customer_Type as (
select card,
case 
	when count(*) > 1 then 'Returning Customer'
    else 'New Customer'
end as Customer
from sales
where card != "NonCardCustomer"
group by card
)
select Customer,count(*) from Customer_Type group by Customer;


# 10. Peak Hours

select hour(date_time) as peak_hours, sum(money) as total_revenue
from sales 
group by hour(date_time)
order by total_revenue desc;


# 11. Peak days

select dayname(dates) as day_of_the_week, sum(money) as total_revenue
from sales
group by dayname(dates)
order by total_revenue desc;

# 12. Total Products

with productslist as (
select distinct coffee_name as Products
from sales)

select count(*) from productslist;


# 13. Total orders

select count(*) from sales;
