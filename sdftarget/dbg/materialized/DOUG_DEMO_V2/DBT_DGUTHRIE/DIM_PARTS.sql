

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS as (with part as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_PARTS

),

final as (
    select
        part_key,
        manufacturer,
        name,
        brand,
        type,
        size*2 as size,
        container,
        retail_price
    from
        part
)

select *
from final
order by part_key);

comment if exists on table DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS IS 'Parts dimensions table';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."brand" IS 'brand of the part';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."container" IS 'container of the part';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."manufacturer" IS 'manufacturer of the part';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."name" IS 'name of the part';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."part_key" IS 'primary key of the model';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."retail_price" IS 'raw retail price';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."size" IS 'size of the part';
comment if exists on column DOUG_DEMO_V2.DBT_DGUTHRIE.DIM_PARTS."type" IS 'type of part including material';
