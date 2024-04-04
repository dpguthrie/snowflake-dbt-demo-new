with page_views as (
    select * from {{ ref('upstream', 'int_segment__pages') }}
)

select
    date_trunc('day', timestamp) as date_day,
    src as page_source,
    title as page_title,
    count(*) as total_page_views,
from page_views
where page_title not like 'DaaC'
group by 1, 2, 3

