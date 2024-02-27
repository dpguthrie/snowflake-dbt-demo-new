{% macro banking_date(col) %}

to_date(
    to_varchar(
        substring({{ col }}, 1, 2) || '-' ||
        substring({{ col }}, 3, 2) || '-' ||
        substring({{ col }}, 5, 4)
    ),
    'MM-DD-YYYY'
)

{% endmacro%}