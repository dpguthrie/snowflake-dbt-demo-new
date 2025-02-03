

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.TOTAL_REVENUE as (select
    date_trunc('month', order_date) as date_month,
    sum(gross_item_sales_amount) as total_revenue
from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS
group by 1);

