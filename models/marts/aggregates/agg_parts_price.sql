{{ config(materialized='table') }}

select
    manufacturer,
    sum(retail_price) as total_retail_price
from {{ ref('dim_parts') }}
group by 1