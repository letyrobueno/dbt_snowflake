{{ config(
    tags=["jaffle"]
) }}

with 

customers as (
    select * 
    from {{ ref('stg_customers')}}
),

orders as (
    select * 
    from {{ ref('fct_orders')}}
),

employees as (
    select * 
    from {{ ref('employees') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(amount) as lifetime_value
    from orders
    group by 1
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        e.employee_id is not null as is_employee,
        o.first_order_date,
        o.most_recent_order_date,
        coalesce(o.number_of_orders, 0) as number_of_orders,
        o.lifetime_value
    from customers as c
    left join customer_orders as o using (customer_id)
    left join employees as e using (customer_id)
)

select * from final
