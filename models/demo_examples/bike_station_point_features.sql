{{
    config(
        materialized='table',
        post_hook='alter table {{ this }} add search optimization on geo(point_features);'
    )
}}

select

    -- https://docs.snowflake.com/en/sql-reference/functions/st_collect
    st_collect(point) as point_features
from {{ ref('stg_bikes_station_info') }}
