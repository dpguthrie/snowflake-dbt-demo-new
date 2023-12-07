{% macro _private_sma(func, n, avg_field, symbol_field, date_field, alias) %}

    {{ func }}({{ avg_field }}) over (
        partition by {{ symbol_field }}
        order by {{ date_field }}
        rows between {{ n - 1 }} preceding and current row
    ) as {{ alias }}_{{ n }}

{% endmacro %}

{% macro sma(n, avg_field="close", symbol_field="symbol", date_field="date") %}

    {{ _private_sma('avg', n, avg_field, symbol_field, date_field, 'sma') }}

{% endmacro %}

{% macro std_sma(n, avg_field="close", symbol_field="symbol", date_field="date") %}

    {{ _private_sma('stddev', n, avg_field, symbol_field, date_field, 'std') }}

{% endmacro %}