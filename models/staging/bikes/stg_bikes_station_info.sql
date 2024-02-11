with source as (
    select * from {{ source('bikes', 'station_info_flatten') }}
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
        st_makepoint(lon, lat) as point
    from source
)

select * from recast
