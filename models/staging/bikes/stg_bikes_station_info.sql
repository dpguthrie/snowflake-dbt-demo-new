{{
    config(
        materialized='incremental',
        unique_key='station_id'
    )
}}

with source as (
    select * from {{ source('bikes', 'station_info_flatten') }}
    {% if is_incremental() %}
        where station_id not in (select station_id from {{ this }})
    {% endif %}
),

recast as (
    select
        short_name::varchar as short_name,
        station_type::varchar as station_type,
        name::varchar as name,
        electric_bike_surcharge_waiver,
        external_id::varchar as external_id,
        legacy_id::int as legacy_id,
        capacity,
        has_kiosk,
        station_id::varchar as station_id,
        region_id::int as region_id,
        eightd_station_services,
        lat as latitude,
        lon as longitude,

        -- https://docs.snowflake.com/en/sql-reference/functions/st_makepoint
        st_makepoint(lon, lat) as point,

        -- https://docs.snowflake.com/en/sql-reference/functions/h3_point_to_cell
        h3_point_to_cell(point, 12) as h3_index_12,
        h3_point_to_cell(point, 10) as h3_index_10
    from source
)

select * from recast
