{% test dollars_spent_greater_than_one( model, column_name, group_by_column) %}

select 
    {{ group_by_column }},
    sum( {{ column_name }} ) as total_amount

from {{ model }}
group by 1
having total_amount < 1

{% endtest %}
