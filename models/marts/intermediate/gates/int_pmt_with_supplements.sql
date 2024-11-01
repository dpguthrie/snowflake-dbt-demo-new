{{
    config(
        materialized='table'
    )
}}

with investments as (

    select * from {{ ref('stg_gates__investment') }}

),

payments as (

    select * from {{ ref('stg_gates__payment') }}

),

joined as (
    
    select
        inv.investment_number,
        inv.investment_id,
        pmt.name as payment_id,
        pmt.date as payment_date,
        year(pmt.date) as payment_year,
        pmt.amount as payment_amount,
        row_number() over (
            partition by inv.investment_number
            order by pmt.date
        ) as row_nr,
        SUM(pmt.amount) OVER (
            PARTITION BY inv.investment_id 
            ORDER BY pmt.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as cumulative_payment_amount,
    from investments as inv
    join payments as pmt on
        inv.investment_id = pmt.investment_id
    where pmt.status <> 'Cancelled'

)

select * from joined
