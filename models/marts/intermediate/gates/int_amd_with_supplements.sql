{{
    config(
        materialized='table'
    )
}}

with investments as (
    select * from {{ ref('stg_gates__investment') }}
),

joined as (
    select
        inv.investment_number,
        inv.investment_id,
        amd.amendment_id,
        amd.amendment_increment,
        amd.amendment_amount_approved as amendment_amount,
        year(amd.committed_date) as commitment_year,
        SUM(amd.amendment_amount_approved) OVER (
            PARTITION BY inv.investment_id 
            ORDER BY amd.amendment_increment
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) as cumulative_amendment_amount,
    from investments as inv
    join investments as amd on
        inv.investment_id = amd.parent_investment_id
    where amd.is_deleted = 0
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

select * from joined
