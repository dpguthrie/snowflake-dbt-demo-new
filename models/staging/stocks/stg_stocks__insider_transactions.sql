with

source as (

    select * from {{ source('stocks', 'insider_transactions') }}

),

renamed as (

    select
        symbol,
        shares,
        filer_url,
        transaction_text,
        filer_name,
        filer_relation,
        money_text,
        start_date,
        ownership,
        value as total_value

    from source

)

select * from renamed
