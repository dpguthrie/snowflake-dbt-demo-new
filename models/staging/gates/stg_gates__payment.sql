with 

source as (

    select * from {{ source('gates', 'iceberg_v_payment__c') }}

),

renamed as (

    select
        id,
        investment__c as investment_id,
        name as payment_id,
        date__c as date,
        amount__c as amount,
        status__c as status,
        isdeleted as is_deleted,
        payment_year,
        remaining_amt as remaining_amount

    from source

)

select * from renamed
