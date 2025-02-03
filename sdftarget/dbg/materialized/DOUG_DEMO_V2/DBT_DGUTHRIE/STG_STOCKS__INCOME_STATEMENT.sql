

use DOUG_DEMO_V2.DBT_DGUTHRIE;
create or replace view DOUG_DEMO_V2.DBT_DGUTHRIE.STG_STOCKS__INCOME_STATEMENT as (with 

source as (

    select * from DOUG_DEMO_V2.STOCKS.INCOME_STATEMENT

),

renamed as (

    select
        symbol,
        asofdate as date,
        periodtype as period_type,
        currencycode as currency_code,
        amortization as amortization,
        amortizationofintangiblesincomestatement as amortization_of_intangibles_income_statement,
        averagedilutionearnings as average_dilution_earnings,
        basicaverageshares as basic_average_shares,
        basiceps as basic_eps,
        costofrevenue as cost_of_revenue,
        depletionincomestatement as depletion_income_statement,
        depreciationamortizationdepletionincomestatement as depreciation_amortization_depletion_income_statement,
        depreciationandamortizationinincomestatement as depreciation_and_amortization_in_income_statement,
        depreciationincomestatement as depreciation_income_statement,
        dilutedaverageshares as diluted_average_shares,
        dilutedeps as diluted_eps,
        dilutedniavailtocomstockholders as diluted_ni_avail_to_com_stockholders,
        ebit,
        ebitda,
        earningsfromequityinterest as earnings_from_equity_interest,
        earningsfromequityinterestnetoftax as earnings_from_equity_interest_net_of_tax,
        excisetaxes as excise_taxes,
        gainonsaleofbusiness as gain_on_sale_of_business,
        gainonsaleofppe as gain_on_sale_of_ppe,
        gainonsaleofsecurity as gain_on_sale_of_security,
        generalandadministrativeexpense as general_and_administrative_expense,
        grossprofit as gross_profit,
        impairmentofcapitalassets as impairment_of_capital_assets,
        insuranceandclaims as insurance_and_claims,
        interestexpense as interest_expense,
        interestexpensenonoperating as interest_expense_non_operating,
        interestincome as interest_income,
        interestincomenonoperating as interest_income_non_operating,
        minorityinterests as minority_interests,
        netincome as net_income,
        netincomecommonstockholders as net_income_common_stockholders,
        netincomecontinuousoperations as net_income_continuous_operations,
        netincomediscontinuousoperations as net_income_discontinuous_operations,
        netincomeextraordinary as net_income_extraordinary,
        netincomefromcontinuinganddiscontinuedoperation as net_income_from_continuing_and_discontinued_operation,
        netincomefromcontinuingoperationnetminorityinterest as net_income_from_continuing_operation_net_minority_interest,
        netincomefromtaxlosscarryforward as net_income_from_tax_loss_carry_forward,
        netincomeincludingnoncontrollinginterests as net_income_including_non_controlling_interests,
        netinterestincome as net_interest_income,
        netnonoperatinginterestincomeexpense as net_non_operating_interest_income_expense,
        normalizedebitda as normalized_ebitda,
        normalizedincome as normalized_income,
        operatingexpense as operating_expense,
        operatingincome as operating_income,
        operatingrevenue as operating_revenue,
        otherganda as other_g_and_a,
        otherincomeexpense as other_income_expense,
        othernonoperatingincomeexpenses as other_non_operating_income_expenses,
        otheroperatingexpenses as other_operating_expenses,
        otherspecialcharges as other_special_charges,
        othertaxes as other_taxes,
        otherunderpreferredstockdividend as other_under_preferred_stock_dividend,
        preferredstockdividends as preferred_stock_dividends,
        pretaxincome as pretax_income,
        provisionfordoubtfulaccounts as provision_for_doubtful_accounts,
        reconciledcostofrevenue as reconciled_cost_of_revenue,
        reconcileddepreciation as reconciled_depreciation,
        rentandlandingfees as rent_and_landing_fees,
        rentexpensesupplemental as rent_expense_supplemental,
        researchanddevelopment as research_and_development,
        restructuringandmergernacquisition as restructuring_and_merger_acquisition,
        salariesandwages as salaries_and_wages,
        securitiesamortization as securities_amortization,
        sellingandmarketingexpense as selling_and_marketing_expense,
        sellinggeneralandadministration as selling_general_and_administration,
        specialincomecharges as special_income_charges,
        taxeffectofunusualitems as tax_effect_of_unusual_items,
        taxprovision as tax_provision,
        taxrateforcalcs as tax_rate_for_calcs,
        totalexpenses as total_expenses,
        totaloperatingincomeasreported as total_operating_income_as_reported,
        totalotherfinancecost as total_other_finance_cost,
        totalrevenue as total_revenue,
        totalunusualitems as total_unusual_items,
        totalunusualitemsexcludinggoodwill as total_unusual_items_excluding_goodwill,
        writeoff as write_off
    from source

)

select * from renamed);

