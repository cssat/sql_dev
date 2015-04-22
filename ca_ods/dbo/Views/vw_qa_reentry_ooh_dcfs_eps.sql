




create view [dbo].[vw_qa_reentry_ooh_dcfs_eps]
as 
with cte_reentry as (
select cohort_exit_year,id_removal_episode_fact,removal_dt,ROW_NUMBER() over (partition by cohort_exit_year,id_prsn_child order by removal_dt asc,ooh_dcfs_eps.[Federal_Discharge_Date] asc) [row_num]
from prtl.ooh_dcfs_eps
where  cd_discharge_type in (1,3,4)
  and ooh_dcfs_eps.fl_exit_over_17=0
  and cohort_exit_year >='2000-01-01')

 select  ooh_dcfs_eps.cohort_exit_year,cd_discharge_type,count(distinct id_prsn_child)  [cnt_cohort]
  ,sum(iif(nxt_reentry_within_min_month_mult3=3,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100  [reentry3]
	,sum(iif(nxt_reentry_within_min_month_mult3<=6,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry6]
	,sum(iif(nxt_reentry_within_min_month_mult3<=9,1, 0)) /(count(distinct id_prsn_child) * 1.00) * 100  [reentry9]
	,sum(iif(nxt_reentry_within_min_month_mult3<=12,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry12]
	,sum(iif(nxt_reentry_within_min_month_mult3<=15,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry15]
	,sum(iif(nxt_reentry_within_min_month_mult3<=18,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry18]
	,sum(iif(nxt_reentry_within_min_month_mult3<21,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry21]
	,sum(iif(nxt_reentry_within_min_month_mult3<=24,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry24]
	,sum(iif(nxt_reentry_within_min_month_mult3<=27,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry27]
	,sum(iif(nxt_reentry_within_min_month_mult3<=30,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry30]
	,sum(iif(nxt_reentry_within_min_month_mult3<=33,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry33]
	,sum(iif(nxt_reentry_within_min_month_mult3<=36,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry36]
	,sum(iif(nxt_reentry_within_min_month_mult3<=39,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry39]
	,sum(iif(nxt_reentry_within_min_month_mult3<=42,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry42]
	,sum(iif(nxt_reentry_within_min_month_mult3<=45,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry45]
	,sum(iif(nxt_reentry_within_min_month_mult3<=48,1, 0))/(count(distinct id_prsn_child) * 1.00) * 100   [reentry48]
	,sum(iif(nxt_reentry_within_min_month_mult3=3,1, 0)) [cnt_reentry3]
	,sum(iif(nxt_reentry_within_min_month_mult3<=6,1, 0)) [cnt_reentry6]
	,sum(iif(nxt_reentry_within_min_month_mult3<=9,1, 0)) [cnt_reentry9]
	,sum(iif(nxt_reentry_within_min_month_mult3<=12,1, 0)) [cnt_reentry12]
	,sum(iif(nxt_reentry_within_min_month_mult3<=15,1, 0)) [cnt_reentry15]
	,sum(iif(nxt_reentry_within_min_month_mult3<=18,1, 0)) [cnt_reentry18]
	,sum(iif(nxt_reentry_within_min_month_mult3<=21,1, 0)) [cnt_reentry21]
	,sum(iif(nxt_reentry_within_min_month_mult3<=24,1, 0)) [cnt_reentry24]
	,sum(iif(nxt_reentry_within_min_month_mult3<=27,1, 0)) [cnt_reentry27]
	,sum(iif(nxt_reentry_within_min_month_mult3<=30,1, 0)) [cnt_reentry30]
	,sum(iif(nxt_reentry_within_min_month_mult3<=33,1, 0)) [cnt_reentry33]
	,sum(iif(nxt_reentry_within_min_month_mult3<=36,1, 0)) [cnt_reentry36]
	,sum(iif(nxt_reentry_within_min_month_mult3<=39,1, 0)) [cnt_reentry39]
	,sum(iif(nxt_reentry_within_min_month_mult3<=42,1, 0)) [cnt_reentry42]
	,sum(iif(nxt_reentry_within_min_month_mult3<=45,1, 0)) [cnt_reentry45]
	,sum(iif(nxt_reentry_within_min_month_mult3<=48,1, 0)) [cnt_reentry48]
 from prtl.ooh_dcfs_eps 
 join cte_reentry cte on cte.id_removal_episode_fact=ooh_dcfs_eps.id_removal_episode_fact and cte.row_num=1 and cte.cohort_exit_year=ooh_dcfs_eps.cohort_exit_year
  where  ooh_dcfs_eps.cd_discharge_type in (1,3,4)
  and ooh_dcfs_eps.fl_exit_over_17=0
  and ooh_dcfs_eps.cohort_exit_year >='2000-01-01'
  group by ooh_dcfs_eps.cohort_exit_year,ooh_dcfs_eps.cd_discharge_type





