with bowf as (

    select * from {{ ref('stg_gates__body_work_funding') }}

),

st as (

    select * from {{ ref('stg_gates__strategy') }}

),

joined as (

    select
        st.funding_division_name,
        st.funding_strategy_name,
        st.grant_purpose_desc,

        {{ join_snapshots(
            cte_join = 'bowf',
            cte_join_on = 'st',
            cte_join_id = 'funding_strategy_id',
            cte_join_on_id = 'funding_strategy_id'
        ) }}
),

renamed as (
    select
        body_of_work_funding_source_row_id,
        funding_division_name,
        funding_strategy_name,
        body_of_work_funding_id,
        grant_purpose_desc,
        logical_delete_ind,

        -- calculated
        case
            when add_st_valid_to = '{{ var("future_date") }}' then 1
            else 0
        end as current_record_ind,

        -- dates
        add_st_valid_from as effective_start_ts,
        add_st_valid_to as effective_end_ts,
    from joined
)

select * from renamed
