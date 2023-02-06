# dbt sample project

Based on https://courses.getdbt.com

## Setting structure and loading data into Snowflake

``` sql
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
```


## Setting up a new dbt core project with Snowflake:
Refer to: https://docs.getdbt.com/docs/get-started/getting-started-dbt-core		(the tutorial is using BigQuery tho)

1. Create a Python virtual environment in the local machine:

```bash
	$ sudo apt-get install python3-pip 	# install pip first
	$ sudo pip3 install virtualenv 		# now install virtualenv

	$ virtualenv -p python3 myvenv 		# in Linux
	$ python3 -m venv myvenv 			# in Mac
```

2. Activate/deactivate virtual environment:
```bash
	$ source myvenv/bin/activate

	$ deactivate
```


3. Install dbt (according to the DB or data warehouse you'll be using):
```bash
	$ pip install dbt-snowflake
```

4. Create a new dbt project:
```bash
	$ dbt --version 			# to be sure dbt-core is installed

	$ dbt init jaffle_shop

	$ cd jaffle_shop
```

5. Set the profile file with the needed info about the data warehouse:
```bash
	$ mkdir ~/.dbt 				# if it doesn't exist yet
	$ vi ~/.dbt/profiles.yml
```

Inside profiles.yml (to set Snowflake):

```yml
jaffle_shop:
  outputs:
    dev:
      account: snowflake_account
      database: dev
      schema: jaffle_shop
      type: snowflake
      user: username
      password: typed-password-here 
      # or replace previous line with the next: 
      authenticator: externalbrowser
      warehouse: warehouse_name
      threads: 8
  target: dev
```

Then: 
```bash
  	$ dbt debug         # to test the connection
```

6. Some dbt commands to test:
```bash
	$ dbt deps            # install dependencies listed in packages.yml
	$ dbt run             # run the whole project
	# or run only one model:
	$ dbt run --select stg_payments 
	$ dbt compile         # to compile analyses from Jinja-SQL to pure SQL
	$ dbt test
	$ dbt docs generate   # generate documentation (and lineage graph)
	$ dbt docs serve      # see documentation in the browser locally
	$ dbt seed            # to build seed (csv file) into data warehouse 
```
7. Push changes to GitHub:
```bash
	$ git status
	$ git add --update
	$ git commit -m "feat: start a dbt project with snowflake"
	$ git push
  ```

## More:
  - Jinja Template Designer documentation: https://jinja.palletsprojects.com/page/templates/
  - dbt-project-evaluator: https://docs.getdbt.com/blog/align-with-dbt-project-evaluator
  - Exposures: https://docs.getdbt.com/docs/build/exposures
  - Metrics: https://docs.getdbt.com/docs/build/metrics
  - Snapshots: https://docs.getdbt.com/docs/build/snapshots
  - SQLFluff: https://github.com/sqlfluff/sqlfluff
