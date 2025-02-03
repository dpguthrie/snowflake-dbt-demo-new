

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS as (with order_item as (


    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.ORDER_ITEMS

),

part_supplier as (


    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.PART_SUPPLIERS

),

final as (
    select
        order_item.order_item_key,
        order_item.order_key,
        order_item.order_date,
        order_item.order_date + interval '3 months' as order_date_plus_3_months,
        order_item.customer_key,
        order_item.part_key,
        order_item.supplier_key,
        order_item.order_item_status_code,
        order_item.return_flag,
        order_item.line_number,
        order_item.ship_date,
        order_item.commit_date,
        order_item.receipt_date,
        order_item.ship_mode,
        part_supplier.cost as supplier_cost,
        
        order_item.base_price,
        order_item.discount_percentage,
        order_item.discounted_price,
        order_item.tax_rate,

        1 as order_item_count,
        order_item.quantity,
        order_item.discounted_item_sales_amount,
        order_item.item_discount_amount,
        order_item.item_tax_amount,
        order_item.net_item_sales_amount,
        order_item.gross_item_sales_amount*2 as gross_item_sales_amount

    from
        order_item
    inner join part_supplier
        on order_item.part_key = part_supplier.part_key
            and order_item.supplier_key = part_supplier.supplier_key
)

select *
from
    final
order by
    order_date);

comment if exists on table DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS IS 'order items fact table';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."base_price" IS 'since extended_price is the line item total, we back out the price per item';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."commit_date" IS 'the date the order item is being commited';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."customer_key" IS 'foreign key for customers';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."discount_percentage" IS 'percentage of the discount';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."discounted_item_sales_amount" IS 'line item (includes quantity) discount amount';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."discounted_price" IS 'factoring in the discount_percentage, the line item discount total';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."gross_item_sales_amount" IS 'same as extended_price';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."item_discount_amount" IS 'item level discount amount. this is always a negative number';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."item_tax_amount" IS 'item level tax total';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."line_number" IS 'sequence of the order items within the order';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."net_item_sales_amount" IS 'the net total which factors in discount and tax';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."order_date" IS 'date of the order';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."order_item_count" IS 'count of order items';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."order_item_key" IS 'surrogate key for the model -- combo of order_key + line_number';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."order_item_status_code" IS 'status of the order item';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."order_key" IS 'foreign key for orders';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."part_key" IS 'foreign key for part';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."quantity" IS 'total units';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."receipt_date" IS 'the receipt date of the order item';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."return_flag" IS 'letter determining the status of the return';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."ship_date" IS 'the date the order item is being shipped';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."ship_mode" IS 'method of shipping';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."supplier_cost" IS 'raw cost';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."supplier_key" IS 'foreign key for suppliers';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS."tax_rate" IS 'tax rate of the order item';
