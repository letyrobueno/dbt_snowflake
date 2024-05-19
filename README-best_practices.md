# Best Practices

## Staging:

✅ Renaming
✅ Type casting
✅ Basic computations (e.g. cents to dollars)
✅ Categorizing (using conditional logic to group values into buckets or booleans, such as in the case when statements above)
❌ Joins 
❌ Aggregations
✅ Materialized as views.

**File names:**
✅ stg_[source]__[entity]s.sql
❌ stg_[entity].sql 
✅ Plural. 
