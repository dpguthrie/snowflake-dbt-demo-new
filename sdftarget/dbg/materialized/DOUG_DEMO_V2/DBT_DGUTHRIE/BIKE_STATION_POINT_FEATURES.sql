

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace table DOUG_DEMO_V2.DBT_DGUTHRIE.BIKE_STATION_POINT_FEATURES as (select st_collect(point) as point_features

-- https://docs.snowflake.com/en/sql-reference/functions/st_collect
from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_BIKES_STATION_INFO);

