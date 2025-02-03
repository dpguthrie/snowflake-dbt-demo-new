

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.DAILY_RETURNS as (with daily_prices as (
    select
        symbol,
        date,
        close,
        lag(close) over (
            partition by symbol
            order by date
        ) as prev_close
    from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__HISTORY
    
    where date > (select max(date) from DOUG_DEMO_V2.DBT_DGUTHRIE.DAILY_RETURNS)
    
)

select
    symbol,
    date,
    (close - prev_close) / prev_close as daily_return
from daily_prices
where prev_close is not null);

