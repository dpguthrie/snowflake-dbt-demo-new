

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.AGG_SHIP_MODES_HARDCODED_PIVOT as (with merged as (
    select
        ship_mode,
        gross_item_sales_amount,
        date_part('year', order_date) as order_year
    from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS
)

select *
from
    merged
    -- have to manually map strings in the pivot operation
pivot (sum(gross_item_sales_amount) for ship_mode in (
    'AIR',
    'REG AIR',
    'FOB',
    'RAIL',
    'MAIL',
    'SHIP',
    'TRUCK'
)) as p

order by order_year);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.AGG_SHIP_MODES_HARDCODED_PIVOT IS 'Example of creating a pivot table with dynamic columns based on the ship modes that are in the system';
