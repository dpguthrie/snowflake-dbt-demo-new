

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS as (with customer as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_CUSTOMERS

),

nation as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_NATIONS
),

region as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_REGIONS

),

final as (
    select
        customer.customer_key,
        customer.name,
        customer.address,
        nation.nation_key,
        nation.name as nation,
        region.region_key,
        region.name as region,
        customer.phone_number,
        customer.account_balance,
        customer.market_segment,
        customer.user_id
    from
        customer
    inner join nation
        on customer.nation_key = nation.nation_key
    inner join region
        on nation.region_key = region.region_key
)

select *
from
    final
order by
    customer_key);

comment if exists on table DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS IS 'Customer dimensions table';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."account_balance" IS 'raw account balance';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."address" IS 'address of the customer';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."customer_key" IS 'Primary key on the customers table';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."market_segment" IS 'market segment of the customer';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."name" IS 'customer id';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."nation" IS 'nation name';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."phone_number" IS 'phone number of the customer';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_CUSTOMERS."region" IS 'region name';
