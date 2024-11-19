select
    date_trunc('month', order_date) as date_month,
    sum(gross_item_sales_amount) as total_revenue
from doug_demo_v2.analytics.fct_orders
group by 1
