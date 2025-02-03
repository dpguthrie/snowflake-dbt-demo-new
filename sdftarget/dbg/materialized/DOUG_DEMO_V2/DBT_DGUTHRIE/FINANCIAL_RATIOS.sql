

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.FINANCIAL_RATIOS as (with  __dbt__cte__latest_price as (


select
    symbol,
    close as latest_price
from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__HISTORY
where date = (select max(date) from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__HISTORY)
), income_data as (
    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__INCOME_STATEMENT
),
balance_data as (
    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__BALANCE_SHEET
),
latest_price as (
    select * from __dbt__cte__latest_price
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
join latest_price lp on i.symbol = lp.symbol);

