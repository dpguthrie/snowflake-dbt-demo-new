WITH payment_allocation AS (
    SELECT 
        p.investment_id,
        p.investment_number,
        p.payment_id,
        p.payment_year,
        p.payment_date,
        p.payment_amount,
        p.row_nr,
        a.amendment_id,
        a.amendment_increment,
        a.amendment_amount,
        a.commitment_year,
        a.cumulative_amendment_amount,
        p.cumulative_payment_amount,

        -- Calculate previous running totals
        LAG(a.cumulative_amendment_amount) OVER (
            PARTITION BY p.investment_id 
            ORDER BY a.amendment_increment
        ) as prev_cumulative_amendment_amount
    FROM {{ ref('int_pmt_with_supplements') }} p
    CROSS JOIN {{ ref('int_amd_with_supplements') }} a
    WHERE p.investment_id = a.investment_id
),

payment_chunks AS (
    SELECT 
        investment_id,
        investment_number,
        payment_id,
        payment_year,
        payment_date,
        amendment_id,
        amendment_increment,
        commitment_year,
        CASE
            -- First payment against first amendment
            WHEN row_nr = 1 AND amendment_increment = 0 THEN
                LEAST(payment_amount, amendment_amount)
            -- Payment amount fits within current amendment
            WHEN cumulative_payment_amount <= cumulative_amendment_amount THEN
                LEAST(
                    payment_amount,
                    amendment_amount - (
                        CASE 
                            WHEN prev_cumulative_amendment_amount IS NULL THEN 0 
                            ELSE prev_cumulative_amendment_amount 
                        END
                    )
                )
            -- Payment amount exceeds current amendment
            ELSE
                GREATEST(
                    0,
                    amendment_amount - (
                        CASE 
                            WHEN prev_cumulative_amendment_amount IS NULL THEN 0 
                            ELSE prev_cumulative_amendment_amount 
                        END
                    )
                )
        END as allocated_amount
    FROM payment_allocation
    WHERE cumulative_payment_amount <= cumulative_amendment_amount
      AND allocated_amount > 0
)

select * from payment_chunks

final_allocations AS (
    SELECT 
        pc.investment_id,
        pc.investment_number,
        pc.payment_id,
        pc.payment_year,
        pc.commitment_year,
        pc.allocated_amount as payment_amount,
        dim_inv.investment_skey,
        dim_inv.investment_durable_skey
    FROM payment_chunks pc
    LEFT JOIN {{ ref('dim_investment') }} dim_inv 
        ON pc.investment_id = dim_inv.source_system_row_id
        AND dim_inv.current_record_ind = 1
),

non_amended_investments AS (
    SELECT 
        dim_inv.investment_skey,
        dim_inv.investment_durable_skey,
        p.payment_id,
        p.payment_year,
        YEAR(i.committed_date) as commitment_year,
        p.payment_amount
    FROM {{ ref('int_inv_with_supplements') }} i
    LEFT JOIN {{ ref('dim_investment') }} dim_inv 
        ON i.investment_id = dim_inv.source_system_row_id
        AND dim_inv.current_record_ind = 1
    JOIN {{ ref('int_pmt_with_supplements') }} p 
        ON p.investment_id = i.investment_id
    WHERE i.has_amendments = FALSE
)

SELECT 
    investment_skey,
    investment_durable_skey,
    payment_id,
    commitment_year,
    payment_year,
    payment_amount
FROM final_allocations

UNION ALL

SELECT 
    investment_skey,
    investment_durable_skey,
    payment_id,
    commitment_year,
    payment_year,
    payment_amount
FROM non_amended_investments
