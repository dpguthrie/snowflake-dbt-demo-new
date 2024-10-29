with 

source as (

    select * from {{ source('gates', 'iceberg_v_payment__c') }}

),

renamed as (

    select
        amount__c as amount,
        amount_outstanding__c as amount_outstanding,
        amount_paid__c as amount_paid,
        compliance_completed__c as compliance_completed,
        createdbyid as created_by_id,
        createddate as created_date,
        currencyisocode as currency_iso_code,
        date__c as date,
        hold_payment__c as hold_payment,
        id,
        investment__c as investment,
        investment_record_type__c as investment_record_type,
        isdeleted as is_deleted,
        lastactivitydate as last_activity_date,
        lastmodifiedbyid as last_modified_by_id,
        lastmodifieddate as last_modified_date,
        lastreferenceddate as last_referenced_date,
        lastvieweddate as last_viewed_date,
        legal_entity__c as legal_entity,
        name,
        parent_payment__c as parent_payment,
        parent_payment_amount__c as parent_payment_amount,
        payee__c as payee,
        payee_relationship__c as payee_relationship,
        payment_delta_amount__c as payment_delta_amount,
        payment_external_id__c as payment_external_id,
        payment_sequence__c as payment_sequence,
        posted_payment_number__c as posted_payment_number,
        recordtypeid as record_type_id,
        revolving_funds_indicator__c as revolving_funds_indicator,
        special_instructions__c as special_instructions,
        status__c as status,
        systemmodstamp as system_mod_stamp,
        type__c as type,
        subtype__c as subtype,
        year__c as year,
        gl_account__c as gl_account,
        transaction_key__c as transaction_key,
        debt_to_equity_conversion__c as debt_to_equity_conversion

    from source
    where is_deleted = 0

)

select * from renamed
