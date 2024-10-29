with investments as (
    select * from {{ ref('stg_gates__investment') }}
),

valid_investments as (
    select * from {{ ref('int_inv_with_supplements') }}
),

joined as (
    select
        inv.investment_number,
        inv.investment_id,
        amd.amendment_id,
        amd.amendment_increment,
        amd.amendment_amount_approved,
        year(amd.committed_date) as commitment_year,
    from valid_investments as v
    join investments as inv on
        v.investment_id = inv.investment_id
    join investments as amd on
        v.investment_id = amd.parent_investment_id
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
