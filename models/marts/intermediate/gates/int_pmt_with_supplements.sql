with valid_investments as (

    select * from {{ ref('int_inv_with_supplements') }}

),

investments as (

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
        ) as row_nr
    from valid_investments as v
    join investments as inv on
        v.investment_id = inv.investment_id
    join payments as pmt on
        v.investment_id = pmt.investment_id
    where pmt.status <> 'Cancelled'

)

select * from joined
