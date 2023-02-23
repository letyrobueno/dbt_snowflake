{{ config(
    tags=["jaffle", "stripe"]
) }}

with 

dates as (
    {{ dbt_date.get_date_dimension("2010-01-01", "2100-12-30") }}
),

final as (
    select 
        *,
        concat(year_number, '-', month_name_short) as year_month,
        concat(year_number, lpad(month_of_year, 2, '0')) as year_month_sorting
    from dates
)

select * from final
