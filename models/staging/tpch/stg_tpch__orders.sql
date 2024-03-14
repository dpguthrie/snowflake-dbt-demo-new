with 

source as (

    select * from {{ source('tpch', 'orders') }}

),

renamed as (

    select
        o_orderkey,
        o_custkey,
        o_orderstatus,
        o_totalprice,
        o_orderdate,
        o_orderpriority,
        o_shippriority,
        o_comment,
        _etl_updated_timestamp

    from source

)

select * from renamed
