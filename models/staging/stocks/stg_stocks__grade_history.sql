with 

source as (

    select * from {{ source('stocks', 'grade_history') }}

),

renamed as (

    select
        symbol,
        epoch_grade_date,
        firm,
        to_grade,
        from_grade,
        action as grade_action

    from source

)

select * from renamed
