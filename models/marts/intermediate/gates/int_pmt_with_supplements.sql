with investments_with_amendments as (
    select * from {{ ref('int_investments_with_supplements') }}
),
payments as (
    select
        temp.investment_number,
        temp.investment_id,
        pmt.name as payment_id,
        year(pmt.date) as payment_year,
        pmt.date as payment_date,
        pmt.amount as payment_amt,
        row_number() over (
            partition by temp.investment_number
            order by pmt.date
        ) as row_nr,
        pmt.amount as remaining_amt
    from investments_with_amendments temp
    join {{ ref('stg_gates__payment') }} pmt
        on pmt.investment = temp.investment_id
    where
        pmt.status <> 'Cancelled'
        and pmt.is_deleted = 0
)

select
    *,
    sum(payment_amt) over (
        partition by investment_id
        order by payment_date
    ) as cumulative_payment_amount
from payments
