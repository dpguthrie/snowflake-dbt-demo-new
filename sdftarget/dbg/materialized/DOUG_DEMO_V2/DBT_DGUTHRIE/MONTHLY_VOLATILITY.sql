

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.MONTHLY_VOLATILITY as (with daily_returns as (
    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.DAILY_RETURNS
),
volatility_calc as (
    select
        symbol,
        date_trunc('month', date) as month,
        stddev(daily_return) as monthly_volatility
    from daily_returns
    group by 1, 2
)

select
    symbol,
    month,
    monthly_volatility,
    monthly_volatility * sqrt(252) as annualized_volatility
from volatility_calc);

