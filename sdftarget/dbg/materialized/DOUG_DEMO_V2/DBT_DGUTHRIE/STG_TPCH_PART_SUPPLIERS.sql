

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_PART_SUPPLIERS as (with source as (

    select * from DOUG_DEMO_V2.TPCH.PARTSUPP

),

renamed as (

    select
    
        md5(cast(coalesce(cast(ps_partkey as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ps_suppkey as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) 
                as part_supplier_key,
        ps_partkey as part_key,
        ps_suppkey as supplier_key,
        ps_availqty as available_quantity,
        ps_supplycost as cost,
        ps_comment as comment

    from source

)

select * from renamed);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_PART_SUPPLIERS IS 'staging layer for suppliers data';
