WITH fct_order_items AS (
  SELECT
    *
  FROM {{ ref('tpch', 'fct_order_items') }}
), aggregate_1 AS (
  SELECT
    CUSTOMER_KEY,
    SUM(GROSS_ITEM_SALES_AMOUNT) AS total_revenue
  FROM fct_order_items
  GROUP BY
    CUSTOMER_KEY
), my_new_aggregation_sql AS (
  SELECT
    *
  FROM aggregate_1
)
SELECT
  *
FROM my_new_aggregation_sql