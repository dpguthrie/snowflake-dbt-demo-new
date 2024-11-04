{% macro _internal_get_columns_in_relation(relation) -%}
  {%- set sql -%}
    describe table {{ relation }}
  {%- endset -%}
  {%- set result = run_query(sql) -%}

  {% set maximum = 10000 %}
  {% if (result | length) >= maximum %}
    {% set msg %}
      Too many columns in relation {{ relation }}! dbt can only get
      information about relations with fewer than {{ maximum }} columns.
    {% endset %}
    {% do exceptions.raise_compiler_error(msg) %}
  {% endif %}

  {% set columns = [] %}
  {% for row in result %}
    {% set comment = row['comment'] or '' %}
    {% do columns.append((api.Column.from_description(row['name'], row['type']), comment)) %}
  {% endfor %}
  {% do return(columns) %}
{% endmacro %}

{% macro generate_source(schema_name, database_name=target.database, generate_columns=False, include_descriptions=False, include_data_types=True, table_pattern='%', exclude='', name=schema_name, table_names=None, include_database=False, include_schema=False) %}

{% set sources_yaml=[] %}
{% do sources_yaml.append('version: 2') %}
{% do sources_yaml.append('') %}
{% do sources_yaml.append('sources:') %}
{% do sources_yaml.append('  - name: ' ~ name | lower) %}

{% if include_descriptions %}
    {% do sources_yaml.append('    description: ""' ) %}
{% endif %}

{% if database_name != target.database or include_database %}
{% do sources_yaml.append('    database: ' ~ database_name | lower) %}
{% endif %}

{% if schema_name != name or include_schema %}
{% do sources_yaml.append('    schema: ' ~ schema_name | lower) %}
{% endif %}

{% do sources_yaml.append('    tables:') %}

{% if table_names is none %}
{% set tables=codegen.get_tables_in_schema(schema_name, database_name, table_pattern, exclude) %}
{% else %}
{% set tables = table_names %}
{% endif %}

{% for table in tables %}
    {% do sources_yaml.append('      - name: ' ~ table | lower ) %}
    {% if include_descriptions %}
        {% do sources_yaml.append('        description: ""' ) %}
    {% endif %}
    {% if generate_columns %}
    {% do sources_yaml.append('        columns:') %}

        {% set table_relation=api.Relation.create(
            database=database_name,
            schema=schema_name,
            identifier=table
        ) %}

        {% set columns=_internal_get_columns_in_relation(table_relation) %}
        {% for column, comment in columns %}
            {% do sources_yaml.append('          - name: ' ~ column.name | lower ) %}
            {% if include_data_types %}
                {% do sources_yaml.append('            data_type: ' ~ codegen.data_type_format_source(column)) %}
            {% endif %}
            {% if include_descriptions %}
                {% do sources_yaml.append('            description: "' ~ comment ~ '"' ) %}
            {% endif %}
        {% endfor %}
            {% do sources_yaml.append('') %}

    {% endif %}

{% endfor %}

{% if execute %}

    {% set joined = sources_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
