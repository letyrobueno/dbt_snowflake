# dbt sample project

Based on https://courses.getdbt.com

## Set structure and load data in Snowflake

-- 1. set structure
create warehouse transforming;
create database raw;
create database analytics;
create schema raw.jaffle_shop;
create schema raw.stripe;

create database dev;
create schema dev.jaffle_shop;

-- 2. create customers table and load data
create table raw.jaffle_shop.customers 
( id integer,
  first_name varchar,
  last_name varchar
);

copy into raw.jaffle_shop.customers (id, first_name, last_name)
from 's3://dbt-tutorial-public/jaffle_shop_customers.csv'
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
  );
  

-- 3. create orders table and load data
create table raw.jaffle_shop.orders
( id integer,
  user_id integer,
  order_date date,
  status varchar,
  _etl_loaded_at timestamp default current_timestamp
);

copy into raw.jaffle_shop.orders (id, user_id, order_date, status)
from 's3://dbt-tutorial-public/jaffle_shop_orders.csv'
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
  );
  
  
-- 4. create payments table and load data
create table raw.stripe.payment 
( id integer,
  orderid integer,
  paymentmethod varchar,
  status varchar,
  amount integer,
  created date,
  _batched_at timestamp default current_timestamp
);

copy into raw.stripe.payment (id, orderid, paymentmethod, status, amount, created)
from 's3://dbt-tutorial-public/stripe_payments.csv'
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
  );
  
  
-- validating data was correctly loaded
select * from raw.jaffle_shop.customers;
select * from raw.jaffle_shop.orders;
select * from raw.stripe.payment;