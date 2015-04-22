
create view dbo.vw_service_budget_codes_ihs_safety as 
SELECT        refB.cd_budget_poc_frc, refB.tx_budget_poc_frc, COUNT(*) AS cnt_rows
FROM            prtl.prtl_pbcs3 AS p3 INNER JOIN
                         dbo.prm_budg AS budg ON budg.match_code = p3.filter_budget_type INNER JOIN
                         dbo.ref_service_cd_budget_poc_frc AS refB ON refB.cd_budget_poc_frc = budg.cd_budget_poc_frc
WHERE        (p3.cohort_begin_date >=
                             (SELECT        min_date_any
                               FROM            dbo.ref_lookup_max_date
                               WHERE        (id = 22)))
GROUP BY refB.cd_budget_poc_frc, refB.tx_budget_poc_frc

