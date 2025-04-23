{% macro incremental_template(
    rel,
    unique_key,
    timestamp_col = 'created_at'
) %}

{{
    config(
        materialized='incremental',
        unique_key=unique_key
    )
}}

select * from {{ rel }}
{% if is_incremental() %}
where {{ timestamp_col }} > (
    select max({{ timestamp_col }}) from {{ this }}
)
{% endif %}

{% endmacro %}
