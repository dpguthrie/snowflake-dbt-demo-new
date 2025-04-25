WITH order_items AS (
  SELECT
    *
  FROM {{ ref('order_items') }}
), part_suppliers AS (
  SELECT
    *
  FROM {{ ref('part_suppliers') }}
), join_1 AS (
  SELECT
    part_suppliers.COST AS SUPPLIER_COST,
    order_items.ORDER_ITEM_KEY,
    order_items.ORDER_KEY,
    order_items.ORDER_DATE,
    order_items.CUSTOMER_KEY,
    order_items.PART_KEY,
    order_items.SUPPLIER_KEY,
    order_items.ORDER_ITEM_STATUS_CODE,
    order_items.RETURN_FLAG,
    order_items.LINE_NUMBER,
    order_items.SHIP_DATE,
    order_items.COMMIT_DATE,
    order_items.RECEIPT_DATE,
    order_items.SHIP_MODE,
    order_items.BASE_PRICE,
    order_items.DISCOUNT_PERCENTAGE,
    order_items.DISCOUNTED_PRICE,
    order_items.TAX_RATE,
    order_items.QUANTITY,
    order_items.DISCOUNTED_ITEM_SALES_AMOUNT,
    order_items.ITEM_DISCOUNT_AMOUNT,
    order_items.ITEM_TAX_AMOUNT,
    order_items.NET_ITEM_SALES_AMOUNT,
    order_items.GROSS_ITEM_SALES_AMOUNT
  FROM order_items
  JOIN part_suppliers
    ON order_items.PART_KEY = part_suppliers.PART_KEY
    AND order_items.SUPPLIER_KEY = part_suppliers.SUPPLIER_KEY
), formula_1 AS (
  SELECT
    ORDER_ITEM_KEY,
    ORDER_KEY,
    ORDER_DATE,
    CUSTOMER_KEY,
    PART_KEY,
    SUPPLIER_KEY,
    ORDER_ITEM_STATUS_CODE,
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
    QUANTITY,
    DISCOUNTED_ITEM_SALES_AMOUNT,
    ITEM_DISCOUNT_AMOUNT,
    ITEM_TAX_AMOUNT,
    NET_ITEM_SALES_AMOUNT,
    ORDER_DATE + INTERVAL '3 MONTHS' AS ORDER_DATE_PLUS_3_MONTHS,
    1 AS ORDER_ITEM_COUNT,
    GROSS_ITEM_SALES_AMOUNT * 2 AS GROSS_ITEM_SALES_AMOUNT,
    GROSS_ITEM_SALES_AMOUNT / 2 AS half_of_sales
  FROM join_1
), order_1 AS (
  SELECT
    *
  FROM formula_1
  ORDER BY
    ORDER_DATE ASC
), fct_order_items AS (
  SELECT
    *
  FROM order_1
)
SELECT
  *
FROM fct_order_items