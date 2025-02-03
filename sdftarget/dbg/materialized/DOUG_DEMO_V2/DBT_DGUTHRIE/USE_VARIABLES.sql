

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.USE_VARIABLES as (select *
from DOUG_DEMO_V2.DBT_DGUTHRIE.FCT_ORDER_ITEMS
where order_date >= '1999-01-01');

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.USE_VARIABLES IS 'demo to show variables';
