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
        position as total_shares,
        value as total_value,
        pct_change as percent_change,

    from source

)

select * from renamed
