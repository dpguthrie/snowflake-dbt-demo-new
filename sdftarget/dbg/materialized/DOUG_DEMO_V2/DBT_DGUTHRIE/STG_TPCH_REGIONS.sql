

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_REGIONS as (with source as (

    select * from DOUG_DEMO_V2.TPCH.REGION

),

renamed as (

    select
        r_regionkey as region_key,
        r_name as name,
        r_comment as comment

    from source

)

select * from renamed);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_REGIONS IS 'staging layer for regions data';
