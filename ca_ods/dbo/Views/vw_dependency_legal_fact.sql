






CREATE view [dbo].[vw_dependency_legal_fact]
as
with cte_dep as (
select distinct  lf.ID_CASE,lf.ID_PRSN
,CD_LEGAL_ACTION,tx_legal_action
,CD_RESULT
,TX_RESULT
,case when cd_result in (17,18,19,130) then 1 else 2 end as result_priority
,lsd.CD_LGL_STAT
,lsd.TX_LGL_STAT
,dbo.INTDate_to_caldate(lf.ID_CALENDAR_DIM_EFFECTIVE) as eff_dt
,dbo.intDate_to_CalDate(lf.id_calendar_dim_hearing)  hearing_dt
, row_number() over (partition by lf.ID_CASE,lf.ID_PRSN
				,coalesce(dbo.intDate_to_CalDate(lf.ID_CALENDAR_DIM_EFFECTIVE)
									,dbo.intDate_to_CalDate(lf.id_calendar_dim_hearing))
 order by case when cd_result in (17,18,19,130) then 1 else 2 end  asc) as row_num
 from dbo.LEGAL_FACT LF
join dbo.LEGAL_ACTION_DIM lad on lf.ID_LEGAL_ACTION_DIM=lad.ID_LEGAL_ACTION_DIM
join dbo.LEGAL_RESULT_DIM lrd on lrd.ID_LEGAL_RESULT_DIM=lf.ID_LEGAL_RESULT_DIM
join dbo.LEGAL_STATUS_DIM lsd on lsd.ID_LEGAL_STATUS_DIM=lf.ID_LEGAL_STATUS_DIM
where  (lrd.CD_RESULT between 17 and 23 or
lrd.CD_RESULT  between 130 and 133) and 
lf.ID_CALENDAR_DIM_EFFECTIVE >= 20110101 )  


select  eps.id_removal_episode_fact,
dep.id_case,id_prsn
,cd_legal_action,tx_legal_action
,cd_result
,tx_result
,dep.cd_lgl_stat
,dep.tx_lgl_stat
,eps.removal_dt state_custody_start_date
,eps.discharge_dt as federal_discharge_date
,eff_dt
,hearing_dt
,  abs(datediff(dd,removal_dt,eff_dt)) as days_btwn_removal_eff_dt
, row_number() over (partition by eps.child,removal_dt
 order by  abs(datediff(dd,removal_dt,eff_dt))  asc) as filter_by_closest
from base.rptPlacement eps
join cte_dep dep on dep.ID_PRSN=eps.child
	and dep.ID_CASE=eps.id_case
	and dep.row_num=1
where eff_dt >= dateadd(yy,-1,removal_dt) and eff_dt < discharge_dt












