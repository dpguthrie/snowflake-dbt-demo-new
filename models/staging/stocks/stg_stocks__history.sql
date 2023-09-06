with 

source as (

    select * from {{ source('stocks', 'history') }}

),

renamed as (

    select
        symbol,
        date,
        close,
        volume,
        open,
        high,
        low,
        adjclose as adjusted_closed,
        dividends,
        splits

    from source

)

select * from renamed
