{% snapshot tpch_part_snapshot %}

{{ config(
    target_schema=generate_schema_name("snapshots_" ~ env_var('DBT_TARGET_ENV', 'dev')),
    unique_key='p_partkey',
    strategy='timestamp',
    updated_at='_etl_updated_timestamp',
)}}

select * from {{ source('tpch', 'part') }}

{% endsnapshot %}