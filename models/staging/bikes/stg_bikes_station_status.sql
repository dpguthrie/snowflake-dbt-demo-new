with source as (
    select * from {{ source('bikes', 'station_status_flatten_full') }}
),

recast as (
    select
        station_id::varchar as station_id,
        station_status::varchar as station_status,
        num_ebikes_available,
        num_bikes_available,
        num_docks_available,
        num_docks_disabled,
        num_bikes_disabled,
        is_installed,
        num_ebikes_available_bool as is_ebikes_available,
        is_renting,
        is_returning,
        eightd_has_available_keys,
        legacy_id::varchar as legacy_id,
        last_updated,
        last_reported
    from source
)

select * from recast
