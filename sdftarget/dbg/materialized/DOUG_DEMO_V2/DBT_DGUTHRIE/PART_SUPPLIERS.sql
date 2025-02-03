

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.PART_SUPPLIERS as (with part as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_PARTS

),

supplier as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_SUPPLIERS

),

part_supplier as (

    select * from DOUG_DEMO_V2.DBT_DGUTHRIE.STG_TPCH_PART_SUPPLIERS

),

final as (
    select

        part_supplier.part_supplier_key,
        part.part_key,
        part.name as part_name,
        part.manufacturer,
        part.brand,
        part.type as part_type,
        part.size as part_size,
        part.container,
        part.retail_price,

        supplier.supplier_key,
        supplier.supplier_name,
        supplier.supplier_address,
        supplier.phone_number,
        supplier.account_balance,
        supplier.nation_key,

        part_supplier.available_quantity,
        part_supplier.cost
    from
        part
    inner join
        part_supplier
        on part.part_key = part_supplier.part_key
    inner join
        supplier
        on part_supplier.supplier_key = supplier.supplier_key
    order by
        part.part_key
)

select * from final);

comment if exists on view DOUG_DEMO_V2.DBT_DGUTHRIE.PART_SUPPLIERS IS 'Intermediate model where we join part, supplier and part_supplier. This model is at the part supplier level.';
