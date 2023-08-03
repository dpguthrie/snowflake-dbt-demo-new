{{
    config(
        materialized='incremental',
        unique_key='offerrequestid',
        incremental_predicates = [
            "DBT_INTERNAL_DEST._sdc_received_at >= (
                select event_lookback_months from stg_peddle__offer_processing_times
            )"
        ],
    )
}}

with unioned_data as (
    select * from {{ ref('stg_peddle__offer_request') }}
    union
    select * from {{ ref('stg_peddle__archived_offer_request') }}
),

filtered_data as (
    select *
    from unioned_data
    where createddatetime < (
        select event_lookback_hours
        from {{ ref('stg_peddle__offer_processing_times') }}
    )
    {% if is_incremental() -%}
        and _sdc_received_at > (select max(_sdc_received_at) from {{ this }})
    {% endif %}
)

select *, current_timestamp as harmony_stage_created_at
from filtered_data