

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS_STATS_SQL as (with 

orders as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS

),

described as (

    
    
    
        
            
        
    
        
    
        
            
        
    
        
    
        
    
        
            
        
    
        
    
        
            
        
    
        
            
        
    
        
            
        
    
        
            
        
    
        
            
        
    
    
    
    
    
    
    select
    'stddev' as metric,
    
        stddev(ORDER_KEY) as ORDER_KEY,
    
        stddev(CUSTOMER_KEY) as CUSTOMER_KEY,
    
        stddev(SHIP_PRIORITY) as SHIP_PRIORITY,
    
        stddev(ORDER_COUNT) as ORDER_COUNT,
    
        stddev(GROSS_ITEM_SALES_AMOUNT) as GROSS_ITEM_SALES_AMOUNT,
    
        stddev(ITEM_DISCOUNT_AMOUNT) as ITEM_DISCOUNT_AMOUNT,
    
        stddev(ITEM_TAX_AMOUNT) as ITEM_TAX_AMOUNT,
    
        stddev(NET_ITEM_SALES_AMOUNT) as NET_ITEM_SALES_AMOUNT
    
    
    from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS
      
    union all
    
    
    
    select
    'min' as metric,
    
        min(ORDER_KEY) as ORDER_KEY,
    
        min(CUSTOMER_KEY) as CUSTOMER_KEY,
    
        min(SHIP_PRIORITY) as SHIP_PRIORITY,
    
        min(ORDER_COUNT) as ORDER_COUNT,
    
        min(GROSS_ITEM_SALES_AMOUNT) as GROSS_ITEM_SALES_AMOUNT,
    
        min(ITEM_DISCOUNT_AMOUNT) as ITEM_DISCOUNT_AMOUNT,
    
        min(ITEM_TAX_AMOUNT) as ITEM_TAX_AMOUNT,
    
        min(NET_ITEM_SALES_AMOUNT) as NET_ITEM_SALES_AMOUNT
    
    
    from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS
      
    union all
    
    
    
    select
    'mean' as metric,
    
        avg(ORDER_KEY) as ORDER_KEY,
    
        avg(CUSTOMER_KEY) as CUSTOMER_KEY,
    
        avg(SHIP_PRIORITY) as SHIP_PRIORITY,
    
        avg(ORDER_COUNT) as ORDER_COUNT,
    
        avg(GROSS_ITEM_SALES_AMOUNT) as GROSS_ITEM_SALES_AMOUNT,
    
        avg(ITEM_DISCOUNT_AMOUNT) as ITEM_DISCOUNT_AMOUNT,
    
        avg(ITEM_TAX_AMOUNT) as ITEM_TAX_AMOUNT,
    
        avg(NET_ITEM_SALES_AMOUNT) as NET_ITEM_SALES_AMOUNT
    
    
    from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS
      
    union all
    
    
    
    select
    'count' as metric,
    
        count(ORDER_KEY) as ORDER_KEY,
    
        count(CUSTOMER_KEY) as CUSTOMER_KEY,
    
        count(SHIP_PRIORITY) as SHIP_PRIORITY,
    
        count(ORDER_COUNT) as ORDER_COUNT,
    
        count(GROSS_ITEM_SALES_AMOUNT) as GROSS_ITEM_SALES_AMOUNT,
    
        count(ITEM_DISCOUNT_AMOUNT) as ITEM_DISCOUNT_AMOUNT,
    
        count(ITEM_TAX_AMOUNT) as ITEM_TAX_AMOUNT,
    
        count(NET_ITEM_SALES_AMOUNT) as NET_ITEM_SALES_AMOUNT
    
    
    from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS
      
    union all
    
    
    
    select
    'max' as metric,
    
        max(ORDER_KEY) as ORDER_KEY,
    
        max(CUSTOMER_KEY) as CUSTOMER_KEY,
    
        max(SHIP_PRIORITY) as SHIP_PRIORITY,
    
        max(ORDER_COUNT) as ORDER_COUNT,
    
        max(GROSS_ITEM_SALES_AMOUNT) as GROSS_ITEM_SALES_AMOUNT,
    
        max(ITEM_DISCOUNT_AMOUNT) as ITEM_DISCOUNT_AMOUNT,
    
        max(ITEM_TAX_AMOUNT) as ITEM_TAX_AMOUNT,
    
        max(NET_ITEM_SALES_AMOUNT) as NET_ITEM_SALES_AMOUNT
    
    
    from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS
      
    
    
    
  
)

select * from described);

comment if exists on table DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDERS_STATS_SQL IS 'Descriptive stats from the fct_orders table';
