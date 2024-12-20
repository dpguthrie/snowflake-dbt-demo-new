{{ config(materialized='table') }}

select
    sum(total_retail_price) as the_total_retail_price
from {{ ref('agg_parts_price') }}
group by 1