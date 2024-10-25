with amendments as (
    select
        investment_id,
        investment_number,
        amendment_increment,
        amendment_amount_approved,
        committed_date,
        cumulative_amendment_amount,
        lag(cumulative_amendment_amount) over (
            partition by investment_id
            order by amendment_increment
        ) as cumulative_amendment_amount_prev
    from {{ ref('int_amd_with_supplements') }}
),
payments as (
    select
        investment_id,
        investment_number,
        payment_id,
        payment_date,
        payment_amt,
        cumulative_payment_amount,
        lag(cumulative_payment_amount) over (
            partition by investment_id
            order by payment_date
        ) as cumulative_payment_amount_prev
    from {{ ref('int_pmt_with_supplements') }}
),
allocation as (
    select
        a.investment_number,
        a.investment_id,
        a.amendment_increment,
        a.amendment_amount_approved,
        a.committed_date as amendment_date,
        a.cumulative_amendment_amount_prev,
        a.cumulative_amendment_amount,
        p.payment_id,
        p.payment_date,
        p.payment_amt,
        p.cumulative_payment_amount_prev,
        p.cumulative_payment_amount,
        greatest(
            least(a.cumulative_amendment_amount, p.cumulative_payment_amount)
            - greatest(a.cumulative_amendment_amount_prev, p.cumulative_payment_amount_prev),
            0
        ) as allocation_amount
    from amendments a
    join payments p
        on a.investment_id = p.investment_id
    where greatest(
            least(a.cumulative_amendment_amount, p.cumulative_payment_amount)
            - greatest(a.cumulative_amendment_amount_prev, p.cumulative_payment_amount_prev),
            0
        ) > 0
)

select
    investment_number,
    investment_id as id,
    payment_id,
    year(payment_date) as payment_year,
    payment_date,
    allocation_amount as payment_amt,
    year(amendment_date) as commitment_year
from allocation
