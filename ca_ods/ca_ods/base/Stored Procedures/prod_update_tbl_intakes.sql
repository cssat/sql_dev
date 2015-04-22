
CREATE procedure [base].[prod_update_tbl_intakes] (@permission_key datetime)
as
if @permission_key = (select cutoff_date from dbo.ref_Last_DW_Transfer) 
begin

  update base.tbl_intakes
   set [fl_ooh_after_this_referral] = 1 
  from base.tbl_intakes intk 
  where exists (select *
							from base.rptPlacement rpt
							where intk.id_intake_fact= rpt.id_intake_fact
							and rpt.id_intake_fact is not null);


update tbl_intakes
set id_prsn_hh=mom_id,id_people_dim_hh=pd.ID_PEOPLE_DIM,tbl_intakes.cd_race_census=pd.cd_race_census
,tbl_intakes.census_hispanic_latino_origin_cd=pd.census_Hispanic_Latino_Origin_cd,tbl_intakes.fl_hh_is_mother=1
--select mom_id,ID_PEOPLE_DIM,cd_race_census
from base.tbl_intakes tbl_intakes
join (select distinct id_intake_fact,mom_id from base.rptPlacement where mom_id is not null and id_intake_fact is not null) rpt on tbl_intakes.id_intake_fact= rpt.id_intake_fact
join PEOPLE_DIM pd on pd.id_prsn=rpt.mom_id and pd.IS_CURRENT=1
where   tbl_intakes.id_prsn_hh !=mom_id
and rpt.mom_id is not null;




update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_update_tbl_intakes'

 end
 else
 begin 
	print 'NEED PERMISSION KEY TO EXECUTE STORED PROCEDURE'
 end




 