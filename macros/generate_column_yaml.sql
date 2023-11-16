{% macro snowflake__generate_column_yaml(column, model_yaml, column_desc_dict, parent_column_name="") %}
    {% do log('HELLOOOOOOOOO', info=True) %}
    -- YOYOYO
    {% if parent_column_name %}
        {% set column_name = parent_column_name ~ "." ~ column.name %}
    {% else %}
        {% set column_name = column.name %}
    {% endif %}

    {% do model_yaml.append('      - namealskdjf: ' ~ column_name  | lower ) %}
    {% do model_yaml.append('        description: "' ~ column_desc_dict.get(column.name | lower,'') ~ '"') %}
    {% do model_yaml.append('') %}

    {% if column.fields|length > 0 %}
        {% for child_column in column.fields %}
            {% set model_yaml = codegen.generate_column_yaml(child_column, model_yaml, column_desc_dict, parent_column_name=column_name) %}
        {% endfor %}
    {% endif %}
    {% do return(model_yaml) %}
{% endmacro %}
