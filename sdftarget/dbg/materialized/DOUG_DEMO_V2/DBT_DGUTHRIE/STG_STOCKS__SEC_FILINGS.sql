

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__SEC_FILINGS as (with

source as (

    select * from DOUG_DEMO_V2.STOCKS.SEC_FILINGS

),

renamed as (

    select
        symbol,
        date as report_date,
        epoch_date,
        type,
        title,
        edgar_url

    from source

)

select * from renamed);

