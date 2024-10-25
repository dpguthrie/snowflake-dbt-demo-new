with investments_with_amendments as (
    select * from {{ ref('int_investments_with_supplements') }}
),
amendments as (
    select
        temp.investment_number,
        temp.investment_id,
        amd.amendment_id,
        amd.amendment_increment,
        amd.amendment_amount_approved,
        year(amd.committed_date) as commitment_year,
        amd.amendment_amount_approved as remaining_amt,
        amd.committed_date
    from investments_with_amendments temp
    join {{ ref('stg_gates__investment') }} amd
        on temp.investment_id = amd.parent_investment
    where
        amd.is_deleted = 0
        and amd.status = 'Completed'
        and (
            amd.amendment_type is null
            or amd.amendment_type in (
                'Supplement',
                'Investment - Prior to Amendment',
                'Legacy Amendment',
                'Reduction',
                'Renewal'
            )
        )
)

select
    *,
    sum(amendment_amount_approved) over (
        partition by investment_id
        order by amendment_increment
    ) as cumulative_amendment_amount
from amendments
