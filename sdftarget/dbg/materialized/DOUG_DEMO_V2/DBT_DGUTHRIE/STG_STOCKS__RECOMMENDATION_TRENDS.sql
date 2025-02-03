

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__RECOMMENDATION_TRENDS as (with

source as (

    select * from DOUG_DEMO_V2.STOCKS.RECOMMENDATION_TRENDS

),

renamed as (

    select
        symbol,
        period,
        strong_buy,
        buy,
        hold,
        sell,
        strong_sell

    from source

)

select * from renamed);

