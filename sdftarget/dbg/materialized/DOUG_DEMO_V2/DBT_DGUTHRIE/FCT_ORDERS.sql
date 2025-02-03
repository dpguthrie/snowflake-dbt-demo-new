

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS as (with orders as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_ORDERS

),

order_item as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.ORDER_ITEMS

),

order_item_summary as (

    select
        order_key,
        sum(gross_item_sales_amount) as gross_item_sales_amount,
        sum(item_discount_amount) as item_discount_amount,
        sum(item_tax_amount) as item_tax_amount,
        sum(net_item_sales_amount) as net_item_sales_amount
    from order_item
    group by
        1
),

final as (

    select

        orders.order_key,
        orders.order_date,
        orders.customer_key,
        orders.status_code,
        orders.priority_code,
        orders.ship_priority,
        orders.clerk_name,
        1 as order_count,
        order_item_summary.gross_item_sales_amount * 2 as gross_item_sales_amount,
        order_item_summary.item_discount_amount,
        order_item_summary.item_tax_amount,
        order_item_summary.net_item_sales_amount
    from
        orders
    inner join order_item_summary
        on orders.order_key = order_item_summary.order_key
)

select *
from
    final

order by
    order_date);

comment if exists on table DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS IS 'orders fact table';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."clerk_name" IS 'id of the clerk';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."customer_key" IS 'foreign key for customers';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."gross_item_sales_amount" IS 'same as extended_price';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."item_discount_amount" IS 'item level discount amount. this is always a negative number';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."item_tax_amount" IS 'item level tax total';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."net_item_sales_amount" IS 'the net total which factors in discount and tax';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."order_count" IS 'count of order';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."order_date" IS 'date of the order';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."order_key" IS 'primary key of the model';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."priority_code" IS 'code associated with the order';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."ship_priority" IS 'numeric representation of the shipping priority, zero being the default';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS."status_code" IS 'status of the order';
