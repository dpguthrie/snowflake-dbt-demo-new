WITH fct_orders AS (
  SELECT
    CUSTOMER_KEY,
    GROSS_ITEM_SALES_AMOUNT
  FROM {{ ref('fct_orders') }}
), aggregate_1 AS (
  SELECT
    CUSTOMER_KEY,
    SUM(GROSS_ITEM_SALES_AMOUNT) AS TOTAL_GROSS_ITEM_SALES_AMOUNT
  FROM fct_orders
  GROUP BY
    CUSTOMER_KEY
), order_1 AS (
  SELECT
    *
  FROM aggregate_1
  ORDER BY
    TOTAL_GROSS_ITEM_SALES_AMOUNT DESC
), limit_cb53 AS (
  SELECT
    *
  FROM order_1
  LIMIT 10
), generated AS (
  SELECT
    *
  FROM limit_cb53
)
SELECT
  *
FROM generated