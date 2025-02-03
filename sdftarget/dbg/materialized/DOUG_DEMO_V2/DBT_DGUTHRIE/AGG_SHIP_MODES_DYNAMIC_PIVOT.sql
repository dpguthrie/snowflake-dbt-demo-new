

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.AGG_SHIP_MODES_DYNAMIC_PIVOT as (select
    date_part('year', order_date) as order_year,

    sum(case when ship_mode = 'FOB' then gross_item_sales_amount end) as "FOB_amount",
    sum(case when ship_mode = 'TRUCK' then gross_item_sales_amount end) as "TRUCK_amount",
    sum(case when ship_mode = 'AIR' then gross_item_sales_amount end) as "AIR_amount",
    sum(case when ship_mode = 'REG AIR' then gross_item_sales_amount end) as "REG_AIR_amount",
    sum(case when ship_mode = 'MAIL' then gross_item_sales_amount end) as "MAIL_amount",
    sum(case when ship_mode = 'SHIP' then gross_item_sales_amount end) as "SHIP_amount",
    sum(case when ship_mode = 'RAIL' then gross_item_sales_amount end) as "RAIL_amount"
    

from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS
group by 1);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.AGG_SHIP_MODES_DYNAMIC_PIVOT IS 'Example of creating a pivot table with hard-coded columns based on a query of the ship modes that are in the system';
