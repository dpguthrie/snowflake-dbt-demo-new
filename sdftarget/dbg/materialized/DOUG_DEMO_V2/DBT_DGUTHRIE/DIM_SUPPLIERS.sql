

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS as (with supplier as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_SUPPLIERS

),

nation as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_NATIONS
),

region as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_REGIONS

),

final as (

    select
        supplier.supplier_key,
        supplier.supplier_name,
        supplier.supplier_address,
        nation.name as nation,
        region.name as region,
        supplier.phone_number,
        supplier.account_balance
    from
        supplier
    inner join nation
        on supplier.nation_key = nation.nation_key
    inner join region
        on nation.region_key = region.region_key
)

select * from final);

comment if exists on table DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS IS 'Suppliers dimensions table';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS."account_balance" IS 'raw account balance';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS."nation" IS 'nation name';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS."phone_number" IS 'phone number of the supplier';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS."region" IS 'region name';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS."supplier_address" IS 'address of the supplier';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS."supplier_key" IS 'primary key of the model';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_SUPPLIERS."supplier_name" IS 'id of the supplier';
