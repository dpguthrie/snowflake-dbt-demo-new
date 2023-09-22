{{
    config(
        materialized='incremental',
        unique_key='ts_surrogate_key',
        incremental_strategy='merge',
    )
}}

with

{% if is_incremental() %}

incremental_cte as (
    select ts_unique_key
    from {{ ref('stg_fact_factor_time_series') }}
    where ingestion_time > (select max(ingestion_time) from {{ this }})
    group by 1
),

{% endif %}

original_source as (
    select *
    from {{ ref('stg_fact_factor_time_series') }} as src

    {% if is_incremental() %}

    where exists (
        select 1
        from incremental_cte as inc
        where inc.ts_unique_key = src.ts_unique_key
    )

    {% endif %}
),

final as (
    select
        *,
        row_number() over (partition by ts_unique_key order by ingestion_time desc) as version_number
    from original_source
)

select *
from final
