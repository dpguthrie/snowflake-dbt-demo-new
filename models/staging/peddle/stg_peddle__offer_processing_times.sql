with source as (

    select * from {{ source('stitch_peddle', 'offerprocessingtimes') }}

),

renamed as (

    select
        event_lookback_hours,
        event_lookback_days,
        event_lookback_months,
        event_lookback_years
    from source

)

select * from renamed