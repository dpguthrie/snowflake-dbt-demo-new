with counts as (
    select
        c_custkey,
        count(*) as customer_count
    from {{ ref('tpch_customer_snapshot') }}
    group by 1
    having customer_count > 1
)

select a.*
from {{ ref('tpch_customer_snapshot') }} as a
inner join counts on a.c_custkey = counts.c_custkey
order by c_custkey, dbt_valid_from
