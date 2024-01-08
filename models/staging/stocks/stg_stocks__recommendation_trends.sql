with 

source as (

    select * from {{ source('stocks', 'recommendation_trends') }}

),

renamed as (

    select
        symbol,
        period,
        strong_buy as strong_buy_total,
        buy as buy_total,
        hold as hold_total,
        sell as sell_total,
        strong_sell as strong_sell_total

    from source

)

select * from renamed
