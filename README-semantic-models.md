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
