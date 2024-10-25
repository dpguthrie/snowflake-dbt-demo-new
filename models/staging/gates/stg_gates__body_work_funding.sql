with source as (
    select * from {{ source('gates', 'iceberg_v_body_of_work_funding__c') }}
),

renamed as (

    select
        funding_strategy__c as funding_strategy_id,
        group__c as funding_group,
        body_of_work__c as body_of_work,
        decision_as_requested__c as decision_as_requested,
        full_path_name__c as full_path_name,
        funding_allocation_type__c as funding_allocation_type,
        link_to_bow__c as link_to_bow,
        return_to__c as return_to,
        status__c as funding_status,
        subgroup__c as subgroup,
        x4_year_total__c as four_year_total,
        id as body_of_work_funding_source_row_id,
        ownerid as owner_id,
        isdeleted as logical_delete_ind,
        name as body_of_work_funding_id,
        currencyisocode as currency_iso_code,
        createddate as created_date,
        createdbyid as created_by_id,
        lastmodifieddate as last_modified_date,
        lastmodifiedbyid as last_modified_by_id,
        systemmodstamp as system_mod_stamp,

    from source

)

select * from renamed
