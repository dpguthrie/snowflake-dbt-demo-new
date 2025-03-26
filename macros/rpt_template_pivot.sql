{% macro rpt_template_pivot(model_name, group_by_columns, pivot_column, agg='sum', column_to_agg=none) %}

{% set rel = ref(model_name) %}
{% set values = dbt_utils.get_column_values(rel, pivot_column) %}
{% set then_value = column_to_agg or 1 %}
{% set len_group_by = group_by_columns | length %}

select
{%- for column in group_by_columns %}
    {{ column }},
{%- endfor -%}
{{ dbt_utils.pivot(pivot_column, values, agg=agg, then_value=then_value) }}
from {{ rel }}
{{ dbt_utils.group_by(n=len_group_by) }}
{% endmacro %}
