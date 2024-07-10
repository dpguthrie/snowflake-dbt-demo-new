{{
    config(
        materialized='ephemeral'
    )
}}

select
    symbol,
    close as latest_price
from {{ ref('stg_stocks__history') }}
where date = (select max(date) from {{ ref('stg_stocks__history') }})