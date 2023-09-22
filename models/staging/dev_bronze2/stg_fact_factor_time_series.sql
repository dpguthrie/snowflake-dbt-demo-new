with 

source as (

    select * from {{ source('dev_bronze2', 'fact_factor_time_series') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(
            ['id', 'bus_date', 'factor_name', 'ingestion_time']
        ) }} as ts_surrogate_key,
        {{ dbt_utils.generate_surrogate_key(
            ['id', 'bus_date', 'factor_name']
        ) }} as ts_unique_key,
        id,
        bus_date,
        factor_name,
        factor_value,
        ingestion_time

    from source

)

select * from renamed
