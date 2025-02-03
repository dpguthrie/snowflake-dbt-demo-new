

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__INSIDER_TRANSACTIONS as (with

source as (

    select * from DOUG_DEMO_V2.STOCKS.INSIDER_TRANSACTIONS

),

renamed as (

    select
        symbol,
        shares,
        filer_url,
        transaction_text,
        filer_name,
        filer_relation,
        money_text,
        start_date,
        ownership,
        value as total_value

    from source

)

select * from renamed);

