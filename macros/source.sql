{% macro source() %}

{% set rel = builtins.source(*varargs) %}

{% set limit = config.get('dev_source_limit', none) %}
{% set where = config.get('dev_source_where', none) %}

{% if env_var('DBT_TARGET_ENV', 'dev') == 'prod' %}

    {% do return(rel) %}

{% else %}

    {% set inner_sql %}
    select * from {{ rel }}
    {% if where %}
    where {{ where }}
    {% endif %}
    {% if limit %}
    limit {{ limit }}
    {% endif %}
    {% endset %}

    {% set sql %}
    (
        {{ inner_sql }}
    ) subq
    {% endset %}

    {% do return(sql) %}

{% endif %}

{% endmacro %}