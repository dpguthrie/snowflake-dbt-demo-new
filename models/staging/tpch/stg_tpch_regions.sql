with source as (

    select * from {{ source('tpch', 'region') }}

),

renamed as (

    select
        r_regionkey as region_key,
        r_name as name,
        r_comment as comment,
        'hello world' as col

    from source

)

select * from renamed
