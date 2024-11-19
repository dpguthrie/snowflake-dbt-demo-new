{% snapshot tpch_customer_snapshot %}

{{ config(
    unique_key='c_custkey',
    strategy='timestamp',
    updated_at='_etl_updated_timestamp',
)}}

select * from {{ source('tpch', 'customer') }}

{% endsnapshot %}