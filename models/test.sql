select
    priority_code,
    sum(gross_item_sales_amount) as total_sales
from {{ ref('fct_orders') }}
where status_code in ('O', 'F')
group by 1