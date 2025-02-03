

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__HISTORY as (with

source as (

    select * from DOUG_DEMO_V2.STOCKS.HISTORY

),

renamed as (

    select
        symbol,
        date,
        close,
        volume,
        open,
        high,
        low,
        adjclose as adjusted_closed,
        dividends,
        splits

    from source

)

select * from renamed);

