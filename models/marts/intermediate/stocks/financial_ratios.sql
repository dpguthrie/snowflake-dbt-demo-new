{{ config(materialized='table') }}

with income_data as (
    select * from {{ ref('stg_stocks__income_statement') }}
),
balance_data as (
    select * from {{ ref('stg_stocks__balance_sheet') }}
),
latest_price as (
    select * from {{ ref('latest_price') }}
)

select
    i.symbol,
    i.date,
    i.net_income / nullif(b.stockholders_equity, 0) as roe,
    i.net_income / nullif(b.total_assets, 0) as roa,
    i.net_income / nullif(i.total_revenue, 0) as net_profit_margin,
    lp.latest_price / nullif(i.net_income / nullif(b.stockholders_equity, 0), 0) as pe_ratio
from income_data i
join balance_data b on
    i.symbol = b.symbol
    and i.date = b.date
join latest_price lp on i.symbol = lp.symbol