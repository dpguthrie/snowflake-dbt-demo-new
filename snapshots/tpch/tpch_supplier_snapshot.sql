{% snapshot tpch_supplier_snapshot %}

{{ config(
    target_schema=generate_schema_name("snapshots_" ~ env_var('DBT_TARGET_ENV', 'dev')),
    unique_key='s_suppkey',
    strategy='timestamp',
    updated_at='_etl_updated_timestamp',
)}}

select * from {{ source('tpch', 'supplier') }}

{% endsnapshot %}