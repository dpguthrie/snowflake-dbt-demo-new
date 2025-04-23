{{ incremental_template(
    source('tpch', 'orders'),
    'o_orderkey',
    'o_orderdate',
) }}