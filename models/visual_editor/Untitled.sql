WITH fct_orders AS (
  SELECT
    ORDER_DATE,
    GROSS_ITEM_SALES_AMOUNT
  FROM {{ ref('fct_orders') }}
), formula_1 AS (
  SELECT
    ORDER_DATE,
    GROSS_ITEM_SALES_AMOUNT,
    DATE_TRUNC('MONTH', ORDER_DATE) AS date_month
  FROM fct_orders
), aggregate_1 AS (
  SELECT
    date_month AS date_month,
    SUM(GROSS_ITEM_SALES_AMOUNT) AS total_revenue
  FROM formula_1
  GROUP BY
    1
)
SELECT
  *
FROM aggregate_1