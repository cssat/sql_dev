
create view [dbo].[vw_service_codes_ihs_trends] as 
select refS.cd_subctgry_poc_frc,refS.tx_subctgry_poc_frc,count(*) as cnt_rows
from prtl.prtl_poc3ab p3
join prm_srvc srvc on srvc.match_code=p3.filter_service_category
join ref_service_cd_subctgry_poc refS on refS.cd_subctgry_poc_frc=srvc.cd_subctgry_poc_frc
where start_date >= (select min_date_any from ref_lookup_max_date where id=22)
group by refS.cd_subctgry_poc_frc,refS.tx_subctgry_poc_frc


