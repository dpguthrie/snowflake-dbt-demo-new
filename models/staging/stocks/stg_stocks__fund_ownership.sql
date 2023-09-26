with 

source as (

    select * from {{ source('stocks', 'fund_ownership') }}

),

renamed as (

    select
        symbol,
        report_date,
        organization,
        pct_held as percent_held,
        position as position_total,
        value as position_value,
        pct_change as percent_change

    from source

)

select * from renamed
