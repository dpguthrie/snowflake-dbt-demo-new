{% macro staging_model_template(source_name, source_table, column_mapping = {}) %}

{%- set rel = source(source_name, source_table) -%}
{%- set columns = adapter.get_columns_in_relation(rel) -%}

with source as (
    select * from {{ rel }}
),

standardized as (
    select
    {%- for col in columns %}
        {{ _staging_column(col, column_mapping.get(col.column, {})) }}
    {%- endfor %}
    from source
)

select * from standardized

{% endmacro %}


{% macro _staging_column(
    column,
    column_dict
) %}

{%- if column_dict.get("sql", none) -%}
{{ column_dict["sql"] }}
{%- else -%}
{{ _use_coalesce_func(column, column_dict) }}
{%- endif -%}
{% endmacro %}

{% macro _use_column_sql(sql) %}
{{ sql }}
{% endmacro %}

{% macro _use_coalesce_func(column, column_dict) %}

{%- if column_dict.get("default", none) -%}
    {%- set default = column_dict['default'] -%}
    {%- if column.dtype == "VARCHAR" %}
        {%- set default = "'" ~ default ~ "'" %}
    {%- endif -%}
{%- else -%}
    {%- set default = var("defaults")[column.dtype] -%}
{% endif -%}
coalesce({{ column.column }}, {{ default }}) as {{ column.column }},
{% endmacro %}