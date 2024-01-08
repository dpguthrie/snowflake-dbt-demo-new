with 

source as (

    select * from {{ source('stocks', 'sec_filings') }}

),

renamed as (

    select
        symbol,
        date as report_date,
        epoch_date,
        type as report_type,
        title as report_title,
        edgar_url

    from source

)

select * from renamed
