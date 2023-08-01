with source as (

    select * from {{ source('stitch_peddle', 'offerrequest') }}

),

remove_dupes_and_soft_deletes as (

    select
        createddatetime,
        lastmodifieddatetime,
        mileage,
        offerdatabaseid,
        offerrequestid,
        statecode,
        titletypeid,
        vehicleconditionid,
        vehicleid,
        vehicleuse,
        vin,
        zipcode,
        _sdc_batched_at,
        _sdc_received_at,
        _sdc_sequence,
        _sdc_table_version,
        instantofferid,
        selleraccountid,
        publisherid,
        _sdc_deleted_at

    from source
    where _sdc_deleted_at is null
    qualify row_number() over (
        partition by offerrequestid
        order by _sdc_batched_at
    ) = 1

)

select * from remove_dupes_and_soft_deletes
