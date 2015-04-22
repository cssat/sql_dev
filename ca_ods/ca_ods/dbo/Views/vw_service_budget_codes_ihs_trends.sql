

create view [dbo].[vw_service_budget_codes_ihs_trends] as 
select  refB.cd_budget_poc_frc,refB.tx_budget_poc_frc,count(*) as cnt_rows
from prtl.prtl_poc3ab p3
join prm_budg budg on budg.match_code=p3.filter_service_budget
join ref_service_cd_budget_poc_frc refB on refB.cd_budget_poc_frc=budg.cd_budget_poc_frc
where start_date >= (select min_date_any from ref_lookup_max_date where id=22)
group by  refB.cd_budget_poc_frc,refB.tx_budget_poc_frc


