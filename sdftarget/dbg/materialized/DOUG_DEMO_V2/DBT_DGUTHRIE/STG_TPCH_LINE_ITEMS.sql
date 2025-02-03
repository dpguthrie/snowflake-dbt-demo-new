

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_LINE_ITEMS as (with source as (

    select * from DOUG_DEMO_V2.TPCH.LINEITEM

),

renamed as (

    select
    
        md5(cast(coalesce(cast(l_orderkey as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(l_linenumber as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))
                as order_item_key,
        l_orderkey as order_key,
        l_partkey as part_key,
        l_suppkey as supplier_key,
        l_linenumber as line_number,
        l_quantity as quantity,
        l_extendedprice as extended_price,
        l_discount as discount_percentage,
        l_tax as tax_rate,
        l_returnflag as return_flag,
        l_linestatus as status_code,
        l_shipdate as ship_date,
        l_commitdate as commit_date,
        l_receiptdate as receipt_date,
        l_shipinstruct as ship_instructions,
        l_shipmode as ship_mode,
        l_comment as comment

    from source

)

select * from renamed);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_LINE_ITEMS IS 'staging layer for line items data';
