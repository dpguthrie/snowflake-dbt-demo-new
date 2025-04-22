WITH fct_order_items AS (
  /* order items fact table */
  SELECT
    ORDER_ITEM_KEY,
    ORDER_KEY,
    ORDER_DATE,
    CUSTOMER_KEY,
    SUPPLIER_KEY,
    RETURN_FLAG,
    LINE_NUMBER,
    SHIP_DATE,
    COMMIT_DATE,
    RECEIPT_DATE,
    SHIP_MODE,
    SUPPLIER_COST,
    BASE_PRICE,
    DISCOUNT_PERCENTAGE,
    DISCOUNTED_PRICE,
    TAX_RATE,
    ORDER_ITEM_COUNT,
    QUANTITY,
    DISCOUNTED_ITEM_SALES_AMOUNT,
    ITEM_DISCOUNT_AMOUNT,
    ITEM_TAX_AMOUNT,
    NET_ITEM_SALES_AMOUNT,
    GROSS_ITEM_SALES_AMOUNT
  FROM {{ ref('tpch', 'fct_order_items') }}
), aggregate_1 AS (
  SELECT
    CUSTOMER_KEY,
    SUM(GROSS_ITEM_SALES_AMOUNT) AS sum_GROSS_ITEM_SALES_AMOUNT
  FROM fct_order_items
  GROUP BY
    CUSTOMER_KEY
), agg_sales_by_customer_sql AS (
  SELECT
    *
  FROM aggregate_1
)
SELECT
  *
FROM agg_sales_by_customer_sql