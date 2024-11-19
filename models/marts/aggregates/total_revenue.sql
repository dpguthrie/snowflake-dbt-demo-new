select
    date_trunc('month', order_date) as date_month,
    sum(gross_item_sales_amount) as total_revenue
from {{ ref('fct_orders') }}
group by 1
-- {{ env_var('DBT_CLOUD_ENVIRONMENT_TYPE') }}
