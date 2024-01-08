with source as (

    select * from {{ source('tpch', 'orders') }}

),

renamed as (

    select
    
        o_orderkey as order_key,
        o_custkey as customer_key,
        o_orderstatus as status_code,
        o_totalprice as total_price,
        o_orderdate as order_date,
<<<<<<< HEAD
=======
        o_clerk as clerk_name,
>>>>>>> dd342a6cb04e01255e16c6cdb1ed698a607abf06
        o_orderpriority as priority_code,
        o_shippriority as ship_priority,
        o_comment as comment

    from source

)

select * from renamed
