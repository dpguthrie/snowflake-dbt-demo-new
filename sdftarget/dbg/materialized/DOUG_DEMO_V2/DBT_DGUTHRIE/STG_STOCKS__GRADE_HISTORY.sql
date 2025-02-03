

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__GRADE_HISTORY as (with

source as (

    select * from DOUG_DEMO_V2.STOCKS.GRADE_HISTORY

),

renamed as (

    select
        symbol,
        epoch_grade_date,
        firm,
        to_grade,
        from_grade,
        action as proposed_action

    from source

)

select * from renamed);

