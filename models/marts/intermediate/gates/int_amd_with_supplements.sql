with investments as (
    select * from {{ ref('stg_gates__investment') }}
),

parent_child as (

    select
        inv.investment_number,
        inv.id,
        amd.amendment_id,
        amd.amendment_increment,
        amd.amendment_amount_approved,
        year(amd.committed_date) as commitment_year
    from investments as inv
    join investments as amd on
        inv.id = amd.parent_investment
    where
        inv.status in ('Active', 'Closed')
        and inv.no_maximum_budget = 0
        and inv.record_type = 'Investment'
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
        partition by investment_number
        order by amendment_increment
    ) as cumulative_amendment_amount,
    sum(amendment_amount_approved) over (
        partition by investment_number
    ) as total_amendment_amount
from parent_child
