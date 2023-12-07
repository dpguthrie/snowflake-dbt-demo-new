with 

source as (

    select * from {{ source('stocks', 'grade_history') }}

),

renamed as (

    select
        symbol,
        epoch_grade_date as epoch_grade_datetime,
        firm,
        to_grade,
        from_grade,
        action as action_type

    from source

)

select * from renamed
