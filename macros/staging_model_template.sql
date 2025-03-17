{% macro _staging_column(
    column,
    numeric_default = 0,
    varchar_default = '---',
    date_default = 'current_date()',
    timestamp_default = 'current_timestamp()',
    column_mapping = {}
) %}

{%- if column_mapping and column_mapping.get(column.column).get("default", none) -%}
    {%- set default = column_mapping[column.column]['default'] -%}
{% else %}
    {%- set default = var('coalesce_mapping')[column.dtype] %}
{% endif %}

coalesce({{ column.column }}, {{ default }}) as {{ column.column }}

{% endmacro %}

{% macro staging_model_template(source_name, source_table) %}

{%- set rel = source(source_name, source_table) -%}
{%- set columns = adapter.get_columns_in_relation(rel) -%}

with source as (
    select * from {{ rel }}
),

standardized as (
    select
    {%- for col in columns %}
        {{ _staging_column(col) }},
    {%- endfor %}
    from source
)

select * from standardized

{% endmacro %}
