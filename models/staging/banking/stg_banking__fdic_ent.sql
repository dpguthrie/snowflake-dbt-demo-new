with 

source as (

    select * from {{ source('banking', 'fdic_ent') }}

),

renamed as (

    select
        RSSD9050 AS fdic_certificate_id,
        RSSD9220 AS zip_code,
        {{ banking_date('REPORT_DATE') }} AS report_date,
        TEXT4087 AS website,
        RSSD9017 AS legal_name,
        RCON9224 AS legal_entity_identifier,
        RSSD9130 AS city_town_text_name,
        IDRSSD AS bank_id,
        RSSD9200 AS abbreviated_state_name

    from source

)

select * from renamed
