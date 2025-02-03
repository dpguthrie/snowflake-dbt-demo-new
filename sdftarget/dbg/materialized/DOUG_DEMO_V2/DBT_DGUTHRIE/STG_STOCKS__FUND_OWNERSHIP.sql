

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__FUND_OWNERSHIP as (with

source as (

    select * from DOUG_DEMO_V2.STOCKS.FUND_OWNERSHIP

),

renamed as (

    select
        symbol,
        report_date,
        organization,
        pct_held as percent_held,
        position as total_shares,
        value as total_value,
        pct_change as percent_change

    from source

)

select * from renamed);

