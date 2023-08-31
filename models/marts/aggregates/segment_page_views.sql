with source as (
    select * from {{ ref('upstream', 'int_segment__pages') }}
)

select
    src as site,
    date_trunc('week', sent_at) as date_visited,
    count(*) as total_visits
from source
group by 1, 2
