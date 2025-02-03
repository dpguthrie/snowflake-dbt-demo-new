

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_CUSTOMERS as (with source as (

    select * from DOUG_DEMO_V2.TPCH.CUSTOMER

),

cleanup as (

    select

        c_custkey as customer_key,
        c_name as name,
        c_address as address,
        c_nationkey as nation_key,
        c_phone as phone_number,
        c_acctbal as account_balance,
        c_mktsegment as market_segment,
        c_comment as comment,
        user_id

    from source

)

select * from cleanup);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_CUSTOMERS IS 'staging layer for customers data';
