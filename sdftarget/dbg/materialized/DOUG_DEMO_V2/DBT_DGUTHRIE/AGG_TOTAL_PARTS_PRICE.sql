

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.AGG_TOTAL_PARTS_PRICE as (select
    sum(total_retail_price) as the_total_retail_price
from DOUG_DEMO_V2.DBT_DGUTHRIE.AGG_PARTS_PRICE);

