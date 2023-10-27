{% macro create_mart_views(schemas) %}

    {% for schema in schemas %}

        {% set sql %}
        create or replace view {{ target.database }}.{{ schema }}.{{ this.identifier }} as
        select * from {{ this }}
        {% endset %}

        {% do run_query(sql) %}

    {% endfor %}

{% endmacro %}
