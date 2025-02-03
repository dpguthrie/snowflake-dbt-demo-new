

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_ORDERS as (with source as (

    select * from DOUG_DEMO_V2.TPCH.ORDERS

),

renamed as (

    select

        o_orderkey as order_key,
        o_custkey as customer_key,
        o_orderstatus as status_code,
        o_totalprice as total_price,
        o_orderdate as order_date,
        o_clerk as clerk_name,
        o_orderpriority as priority_code,
        o_shippriority as ship_priority,
        o_comment as comment

    from source

)

select * from renamed);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_ORDERS IS 'staging layer for orders data';
