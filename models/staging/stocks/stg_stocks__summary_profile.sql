with

source as (

    select * from {{ source('stocks', 'summary_profile') }}

),

renamed as (

    select
        address1 as address_1,
        city,
        state,
        zip as zip_code,
        country,
        phone,
        website,
        industry,
        sector,
        long_business_summary,
        full_time_employees,
        symbol,
        address2 as address_2

    from source

)

select * from renamed
