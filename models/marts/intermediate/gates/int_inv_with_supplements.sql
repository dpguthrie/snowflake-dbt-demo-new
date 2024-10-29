{{
    config(
        materialized='table'
    )
}}

with investment as (

    select * 
    from {{ ref('stg_gates__investment') }} inv
    where inv.is_deleted = 0
        and inv.status in ('Active', 'Closed')
        and inv.no_maximum_budget = 0
        and inv.record_type = 'Investment'

),

amendment as (

    select * 
    from {{ ref('stg_gates__investment') }} amd
    where amd.is_deleted = 0 
        and amd.status = 'Completed'
        and (
            amd.amendment_type is null
            or amd.amendment_type in ('Supplement', 'Investment - Prior to Amendment', 'Legacy Amendment', 'Reduction', 'Renewal')
        )

)

select 
    inv.investment_number,
    inv.investment_id
from investment inv
join amendment amd
    on inv.investment_id = amd.parent_investment
group by 1, 2
having count(*) > 1
