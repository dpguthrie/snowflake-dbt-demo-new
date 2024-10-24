{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='md5(concat(body_of_work_funding_source_row_id, effective_start_ts))',
        full_refresh=false,
    )
}}

with latest_data as (

    select
        bowf.body_of_work_funding_source_row_id,
        st.funding_division_name,
        st.funding_strategy_name,
        bowf.body_of_work_funding_id,
        nvl(st.grant_purpose_desc, '') as grant_purpose_desc,
        bowf.logical_delete_ind,
        1 as current_record_ind,
        current_timestamp() as effective_start_ts,
        '2099-12-31' as effective_end_ts,
        md5_number_lower64(body_of_work_funding_source_row_id || effective_start_ts) as body_of_work_funding_skey,
        md5_number_lower64(body_of_work_funding_source_row_id || effective_start_ts) as body_of_work_funding_durable_skey,
    from {{ ref('stg_gates__body_work_funding') }} as bowf
    join {{ ref('stg_gates__strategy') }} as st
        on bowf.funding_strategy_id = st.funding_strategy_id

)

{% if is_incremental() %}

, current_data as (

    select *
    from {{ this }}

)

, changed_records AS (
    
    select
        latest_data.body_of_work_funding_source_row_id,
        latest_data.funding_division_name,
        latest_data.funding_strategy_name,
        latest_data.body_of_work_funding_id,
        latest_data.grant_purpose_desc,
        latest_data.logical_delete_ind,

        -- Expire record's indicator
        0 as current_record_ind,
        latest_data.effective_start_ts,

        -- Expire record's timestamp
        current_timestamp() as effective_end_ts,
        latest_data.body_of_work_funding_skey,

        -- Use the current durable_skey for the changed record
        current_data.body_of_work_funding_durable_skey,
    from latest_data
    left join current_data
        on latest_data.body_of_work_funding_source_row_id = current_data.body_of_work_funding_source_row_id
        and (
            latest_data.funding_division_name <> current_data.funding_division_name
            or latest_data.funding_strategy_name <> current_data.funding_strategy_name
            or latest_data.body_of_work_funding_id <> current_data.body_of_work_funding_id
            or latest_data.logical_delete_ind <> current_data.logical_delete_ind
            or latest_data.grant_purpose_desc <> latest_data.grant_purpose_desc
        )
    where current_data.current_record_ind = 1

)

, new_records as (

    -- These are completely net new records that don't exist in the target
    select
        latest_data.*
    from latest_data
    left join current_data
        on latest_data.body_of_work_funding_source_row_id = current_data.body_of_work_funding_source_row_id
    where current_data.body_of_work_funding_source_row_id is null

    union all

    -- These are the records that were changed that need to be inserted with the appropriate current record indicator of 1, durable_skey
    select
        latest_data.* exclude body_of_work_funding_durable_skey,

        -- Ensure the durable_skey remains what it is currently
        changed_records.body_of_work_funding_durable_skey
    from latest_data
    join changed_records
        on latest_data.body_of_work_funding_source_row_id = changed_records.body_of_work_funding_source_row_id

)

select * from changed_records
union all
select * from new_records

{% else %}

select * from latest_data

{% endif %}