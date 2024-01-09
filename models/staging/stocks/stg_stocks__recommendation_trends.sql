with 

source as (

    select * from {{ source('stocks', 'recommendation_trends') }}

),

renamed as (

    select
        symbol,
        period,
        strong_buy,
        buy,
        hold,
        sell,
        strong_sell

    from source

)

select * from renamed
