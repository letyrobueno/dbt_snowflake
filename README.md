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
	$ sudo apt-get install python3-pip  # install pip first
	$ sudo pip3 install virtualenv      # now install virtualenv

	$ virtualenv -p python3 myvenv      # in Linux
	$ python3 -m venv myvenv            # in Mac
        $ virtualenv myvenv                 # in Windows
```

2. Activate/deactivate virtual environment:
```bash
	$ source myvenv/bin/activate

	$ deactivate
```

In Windows:
```bash
	$ myvenv\Scripts\activate.bat

	$ deactivate
```


3. Install dbt (according to the DB or data warehouse you'll be using):
```bash
	$ pip install dbt-snowflake
```
or if there is a list of packages that need to be installed:
```bash
	$ pip install -r requirements.txt
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
	$ dbt debug           # to test the connection
```

6. Some dbt commands:
```bash
	$ dbt deps            # install dependencies listed in packages.yml
	$ dbt compile         # to compile analyses from Jinja-SQL to pure SQL
	$ dbt run             # run the whole project
	$ dbt test            # execute tests for the whole project
	$ dbt seed            # to build seed (csv file) into data warehouse 
	$ dbt snapshot        # to build snapshots
	$ dbt build           # At once runs the previous 4 commands: run, test, snapshot, seed
	$ dbt docs generate   # generate documentation (with lineage graph)
	$ dbt docs serve      # see documentation in the browser locally

	# Variations:
	$ dbt run --select stg_payments  # run only one model
	$ dbt run --exclude stg_payments # run everything but one model
	$ dbt build --select tag:jaffle  # build, run, or test only a set of models with same tag
	$ dbt build --exclude tag:jaffle # build, run, or test all models except a set of them with a certain tag
	$ dbt run --select tag:jaffle --exclude tag:stripe # run all models tagged "daily", except those that are also tagged hourly

	# Check best practices use with dbt-project-evaluator:
	$ dbt build --select package:dbt_project_evaluator
```
7. Push changes to GitHub:
```bash
	$ git status
	$ git add --update
	$ git commit -m "feat: start a dbt project with snowflake"
	$ git push
  ```

## More:
  - Metrics: https://docs.getdbt.com/docs/build/metrics
  - Exposures: https://docs.getdbt.com/docs/build/exposures
  - Snapshots: https://docs.getdbt.com/docs/build/snapshots
  - Jinja Template Designer documentation: https://jinja.palletsprojects.com/page/templates/
  - dbt-utils (set of macros for tests, SQL generators, and others): https://github.com/dbt-labs/dbt-utils
  - dbt-audit-helper (to perform data audits): https://github.com/dbt-labs/dbt-audit-helper
  - dbt-expectations (to add tests): https://github.com/calogica/dbt-expectations
  - dbt-project-evaluator (check best practices): https://docs.getdbt.com/blog/align-with-dbt-project-evaluator
  - SQLFluff: https://github.com/sqlfluff/sqlfluff
  - SQLFluff rules: https://docs.sqlfluff.com/en/stable/rules.html
