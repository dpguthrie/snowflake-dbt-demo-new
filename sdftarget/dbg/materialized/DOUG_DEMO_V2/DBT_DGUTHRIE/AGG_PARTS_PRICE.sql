

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.AGG_PARTS_PRICE as (select
    manufacturer,
    sum(retail_price) as total_retail_price
from DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS
group by 1);

