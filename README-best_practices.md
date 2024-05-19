## Best Practices

### Staging:

**Purpose:** prepare atomic building blocks.

#### Operations:

✅ Renaming

✅ Type casting

✅ Basic computations (e.g. cents to dollars)

✅ Categorizing (using conditional logic to group values into buckets or booleans, such as in the case when statements above)

❌ Joins 

❌ Aggregations

✅ Materialized as views.


#### Folders:

✅ Subdirectories based on the source system.

❌ Subdirectories based on loader.

❌ Subdirectories based on business grouping.


#### File names:

✅ stg_[source]__[entity]s.sql

❌ stg_[entity].sql 

✅ Plural. 

### Intermediate: 

**Purpose:** purpose-built transformation steps

#### Folders:

✅ Subdirectories based on business groupings.

#### File names:

✅ int_[entity]s_[verb]s.sql

#### Models:

❌ Exposed to end users. 

✅ Materialized ephemerally. 

✅ Materialized as views in a custom schema with special permissions. 

#### Use cases:

✅ Structural simplification.

✅ Re-graining.

✅ Isolating complex operations.
