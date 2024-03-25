{{
    config(
        enabled=true,
        severity='error',
        tags = ['finance'],
        error_if = '>200000'
    )
}}

with orders as ( select * from {{ ref('stg_tpch_orders') }} )

select *
from   orders 
where  total_price > 0
