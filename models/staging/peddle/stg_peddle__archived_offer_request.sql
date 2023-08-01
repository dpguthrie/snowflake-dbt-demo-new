with source as (

    select * from {{ source('stitch_peddle', 'archivedofferrequest') }}

),

renamed as (

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

)

select * from renamed
