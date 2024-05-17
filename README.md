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

## Review on Semantic Models:

### Semantic models:

- Where we define everything we need to construct our metrics.

- Contain object types like entities, measures, and dimensions.

- Semantic models are 1:1 with a dbt SQL or Python model.

### Entities:

ID columns in our semantic models that serve as join keys to other semantic models.

4 types of entities:
- **Primary:** only one record for each row and it includes every record in the data platform.
- **Unique:** only one record per row in the table but it may have a subset of records in the data warehouse. It can include nulls.
- **Foreign:** include zero, one, or multiple instances of the same record. It can include nulls.
- **Natural:** column or combination of columns that uniquely identify a record.

Each semantic model contains at most 1 primary or natural entity (like how a model has 1 primary key).

Each semantic model contains zero, one, or many foreign or unique entities used to connect to other entities.

### Dimensions:

- Help you group/filter your data.
- They are columns in your models that contain categorical or time-related information.

Two types of dimensions:
- Categorical.
- Time (Includes slowly changing dimensions).

### Measures:

- They are SQL aggregations performed on columns in your model.
- A lot of the time, measures themselves can serve as metrics. Or, measures can serve as building blocks for more complicated metrics.

## Metrics:

1. **Simple metrics:** directly reference a single measure, without any additional measures involved. **Example:**

<img src="https://github.com/letyrobueno/dbt_snowflake/assets/3430584/c68acff0-5774-417d-a1b9-5133c5c05e2c" width="450" height="180">

<img src="https://github.com/letyrobueno/dbt_snowflake/assets/3430584/81dc5ad2-bca6-4c37-83aa-0b0062700c93" width="400" height="160">

2. **Ratio metrics:** Creates a ratio between two metrics. **Example:**

<img src="https://github.com/letyrobueno/dbt_snowflake/assets/3430584/81de5619-b86a-47b0-bcfe-66fa997c9030" width="600" height="180">

3. **Cumulative metrics:** aggregate a measure over a given window (or over everything if no window is provided). **Example:**

<img src="https://github.com/letyrobueno/dbt_snowflake/assets/3430584/b8be37ea-4610-4f2e-9cf0-c5d6a5e76418" width="580" height="250">

4. **Derived metrics:** calculations on top of metrics. **Example:**

<img src="https://github.com/letyrobueno/dbt_snowflake/assets/3430584/54ec3d31-443b-427e-a53e-e65734ec031d" width="540" height="230">

<img src="https://github.com/letyrobueno/dbt_snowflake/assets/3430584/bb838e1e-b2ee-4bf1-aeaf-d3c5ffff9151" width="540" height="230">

## Saved queries and exports:

<img src="https://github.com/letyrobueno/dbt_snowflake/assets/3430584/b457e386-7041-437f-b020-6b1d8f6808ad" width="480" height="260">

