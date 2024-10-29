with investments as (

    select * from {{ ref('stg_gates__investment') }}

),

payments as (

    select * from {{ ref('stg_gates__payment') }}

),

joined as (

    select
        inv.investment_number,
        inv.id,
        pmt.name as payment_id,
        year(pmt.date) as payment_year,
        pmt.amount as payment_amount,
        row_number() over (
            partition by inv.investment_number
            order by pmt.date
        ) as row_nr,
        sum(pmt.amount) over (
            partition by investment_number
            order by pmt.date
        ) as cumulative_payment_amount,
        sum(pmt.amount) over (
            partition by investment_number
        ) as total_payment_amount
    from investments as inv
    join payments as pmt on
        inv.id = pmt.investment_id

)

select * from joined
