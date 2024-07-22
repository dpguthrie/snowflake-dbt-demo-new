{{ config(materialized='table') }}

with daily_returns as (
    select * from {{ ref('daily_returns') }}
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
from volatility_calc