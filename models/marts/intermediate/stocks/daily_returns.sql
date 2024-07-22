{{ config(materialized='incremental', unique_key=['symbol', 'date']) }}

with daily_prices as (
    select
        symbol,
        date,
        close,
        lag(close) over (
            partition by symbol
            order by date
        ) as prev_close
    from {{ ref('stg_stocks__history') }}
    {% if is_incremental() %}
    where date > (select max(date) from {{ this }})
    {% endif %}
)

select
    symbol,
    date,
    (close - prev_close) / prev_close as daily_return
from daily_prices
where prev_close is not null
