{{
    config(
        materialized='incremental',
        unique_key='offerrequestid',
    )
}}

with all_data as (
    select *
    from {{ ref('stg_peddle__offer_request') }}
    where createddatetime < (
        select event_lookback_hours
        from {{ ref('stg_peddle__offer_processing_times') }}
    )
    {% if is_incremental() %}
        and _sdc_received_at >= (
            select event_lookback_months
            from {{ ref('stg_peddle__offer_processing_times') }}
        )
    {% else %}
    union all
    select *
    from {{ ref('stg_peddle__archived_offer_request')}}
    {% endif %}
)

select
    *,
    current_timestamp as harmony_stage_created_at
from all_data