{{
    config(
        enabled=false
    )
}}
with source as (
    select * from {{ ref('gates_strategy_snapshot') }}
),

renamed as (

    select
        lastreferenceddate as last_referenced_date,
        lastvieweddate as last_viewed_date,
        name,
        ownerid as owner_id,
        parent_strategy__c as parent_strategy,
        parent_strategy_name__c as parent_strategy_name,
        parent_strategy_source_id__c as parent_strategy_source_id,
        sort_sequence_number__c as sort_sequence_number,
        source_created_by_username__c as source_created_by_username,
        source_created_date__c as source_created_date,
        source_id__c as source_id,
        source_last_modified_date__c as source_last_modified_date,
        source_updated_by_username__c as source_updated_by_username,
        source_updated_date__c as source_updated_date,
        strategy_name__c as strategy_name,
        strategy_source_id__c as strategy_source_id,
        sub_initiative_name__c as sub_initiative_name,
        sub_initiative_source_id__c as sub_initiative_source_id,
        systemmodstamp as system_mod_stamp,
        createdbyid as created_by_id,
        createddate as created_date,
        currencyisocode as currency_iso_code,
        division_name__c as division_name,
        division_source_id__c as division_source_id,
        effective_end_date__c as effective_end_date,
        effective_start_date__c as effective_start_date,
        full_path_name__c as full_path_name,
        full_path_name_search__c as full_path_name_search,
        grant_purpose__c as grant_purpose,
        id as funding_strategy_id,
        initiative_name__c as initiative_name,
        initiative_source_id__c as initiative_source_id,
        is_active__c as is_active,
        isdeleted as is_deleted,
        key_element_name__c as key_element_name,
        key_element_source_id__c as key_element_source_id,
        lastmodifiedbyid as last_modified_by_id,
        lastmodifieddate as last_modified_date,
        effective_start_ts,
        nvl(effective_end_ts, cast('{{ var("future_date") }}' as timestamp)) as effective_end_ts,
        dbt_scd_id,
        dbt_updated_at,
        effective_end_ts is null as is_current_record,

    from source

)

select * from renamed
