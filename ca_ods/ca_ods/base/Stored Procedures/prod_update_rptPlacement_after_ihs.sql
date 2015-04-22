CREATE procedure [base].[prod_update_rptPlacement_after_ihs] 
as



update tce
set  bin_ihs_svc_cd =3
from  base.rptPlacement tce

update tce
set  bin_ihs_svc_cd =1
from  base.rptPlacement tce
join base.tbl_ihs_episodes eps on  tce.id_intake_fact=eps.id_intake_fact and eps.days_from_rfrd_date <=90
and tbl_origin_cd in (2,3)


update tce
set  bin_ihs_svc_cd =2
from  base.rptPlacement tce
join base.tbl_ihs_episodes eps on  tce.id_intake_fact=eps.id_intake_fact  and eps.days_from_rfrd_date <=90
and tbl_origin_cd = 1 and bin_ihs_svc_cd <> 1

update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_update_rptPlacement_after_ihs'