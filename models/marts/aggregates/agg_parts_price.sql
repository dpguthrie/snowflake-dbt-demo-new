{{ config(materialized='table') }}


with cte as (
    select
        manufacturer,
        sum(retail_price) as total_retail_price
    from {{ ref('dim_parts') }}
    group by 1
)

select
    manufacturer,
    total_retail_price + 1 as total_retail_price
from cte