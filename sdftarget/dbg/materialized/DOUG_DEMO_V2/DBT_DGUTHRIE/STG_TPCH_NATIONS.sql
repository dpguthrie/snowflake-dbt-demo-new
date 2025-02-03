

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_NATIONS as (with source as (

    select * from DOUG_DEMO_V2.TPCH.NATION

),

renamed as (

    select

        n_nationkey as nation_key,
        n_name as name,
        n_regionkey as region_key,
        n_comment as comment

    from source

)

select * from renamed);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_NATIONS IS 'staging layer for nations data';
