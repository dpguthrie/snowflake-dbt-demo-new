{% macro create_unload_external_stage() %}
    {% if env_var('DBT_ENVIRONMENT', 'dev') == 'prod' %}
        {% set sql %}
            CREATE OR REPLACE STAGE dbt_ext_unload_stage
                url='s3://your-company-artifacts/snowflake-unload/dbt/'
                credentials=(aws_key_id='{{ env_var('DBT_SECRET_AWS_ACCESS_KEY_ID') }}', aws_secret_key='{{ env_var('DBT_SECRET_AWS_SECRET_ACCESS_KEY') }}')
                file_format = (type = csv, field_optionally_enclosed_by = '"', compression = gzip);
        {% endset %}
        {% set _ = run_query(sql) %}
    {% endif %}
{% endmacro %}

{% macro unload_to_s3() %}
    -- Another example here:  https://gist.github.com/jeremyyeo/f07dbe9a7687ffc4976e1488a8e35547

    {% if env_var('DBT_ENVIRONMENT', 'dev') == 'prod' %}

        {% set sql %}

        -- Unload (possibly multiple) data files into timestamped directory.
        COPY INTO @dbt_ext_unload_stage/{{ this.name }}/{{ run_started_at.date().isoformat() }}/{{ run_started_at.isoformat() }}/data
        FROM {{ this }}
        header = true;

        -- Add an indicator that the unload has completed.
        COPY INTO @dbt_ext_unload_stage/{{ this.name }}/{{ run_started_at.date().isoformat() }}/{{ run_started_at.isoformat() }}/done.csv
        FROM (SELECT 1 AS done)
        single = true;

        {% endset %}

        {% if execute %}

            {% do run_query(sql) %}

        {% endif %}

    {% endif %}
{% endmacro %}