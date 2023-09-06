with dates as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2024-01-01' as date)"
    ) }}
)

select
    date_day as date,
    date_trunc('week', date_day) as week,
    date_trunc('month', date_day) as month,
    date_trunc('quarter', date_day) as quarter,
    date_trunc('year', date_day) as year
from dates