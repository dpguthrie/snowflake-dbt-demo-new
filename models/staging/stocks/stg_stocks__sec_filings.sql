with 

source as (

    select * from {{ source('stocks', 'sec_filings') }}

),

renamed as (

    select
        symbol,
        date as report_date,
        epoch_date,
        type,
        title,
        edgar_url

    from source

)

select * from renamed
