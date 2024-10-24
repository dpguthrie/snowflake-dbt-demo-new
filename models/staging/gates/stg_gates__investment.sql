with 

source as (

    select * from {{ source('gates', 'iceberg_v_investment__c') }}

),

renamed as (

    select
        id as investment_id,
        investment_number__c as investment_number,
        parent_investment__c as parent_investment_id,
        amendment_id__c as amendment_id,
        amendment_increment__c as amendment_increment,
        amendment_amount_approved__c as amendment_amount_approved,
        committed_date__c as committed_date,
        status__c as status,
        isdeleted as is_deleted,
        amendment_type__c as amendment_type,
        no_maximum_budget__c as no_maximum_budget,
        record_type__c as record_type,
        remaining_amt as remaining_amount

    from source

)

select * from renamed
