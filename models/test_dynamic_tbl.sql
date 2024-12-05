{{
    config(
        materialized='dynamic_table',
        target_lag='downstream',
        snowflake_warehouse='transforming'
    )
}}

select * from {{ ref('fct_orders') }}