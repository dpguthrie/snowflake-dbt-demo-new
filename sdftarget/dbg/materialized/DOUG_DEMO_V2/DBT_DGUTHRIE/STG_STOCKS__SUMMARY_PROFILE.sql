

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__SUMMARY_PROFILE as (with

source as (

    select * from DOUG_DEMO_V2.STOCKS.SUMMARY_PROFILE

),

renamed as (

    select
        address1 as address_1,
        city,
        state,
        zip as zip_code,
        country,
        phone,
        website,
        industry,
        sector,
        long_business_summary,
        full_time_employees,
        symbol,
        address2 as address_2

    from source

)

select * from renamed);

