
create view dbo.vw_ref_dependency_lag
as
select dep.bin_dep_cd AS bin_dep_cd
,dep.bin_dep_desc AS bin_dep_desc
,dep.diff_days_from AS diff_days_from
,dep.diff_days_thru AS diff_days_thru
,dep.fl_dep_exist AS fl_dep_exist
,dep.lag AS lag
,dep.min_filter_date AS min_filter_date
,1 AS date_type
,iif(dep.bin_dep_cd = 0, dw.cutoff_date, dateadd(mm,-3,dateadd(dd,(-1* abs(dep.lag)),dw.cutoff_date))) [ max_filter_date]
,iif(dep.bin_dep_cd = 0, dw.cutoff_date,dateadd(mm,-12,dateadd(dd,(-1* abs(dep.lag)),dw.cutoff_date))) [cohort_max_filter_date]
from (ref_filter_dependency dep 
join ref_last_dw_transfer dw on 1=1) 
union all
select dep.bin_dep_cd AS bin_dep_cd
,dep.bin_dep_desc AS bin_dep_desc
,dep.diff_days_from AS diff_days_from
,dep.diff_days_thru AS diff_days_thru
,dep.fl_dep_exist AS fl_dep_exist
,dep.lag AS lag
,dep.min_filter_date AS min_filter_date
,2 AS date_type
,iif(dep.bin_dep_cd = 0,dw.cutoff_date,dateadd(mm,-12,dateadd(dd,(-1* abs(dep.lag)),dw.cutoff_date)))
,iif(dep.bin_dep_cd = 0,dw.cutoff_date,dateadd(mm,-21,dateadd(dd,(-1* abs(dep.lag)),dw.cutoff_date)))
from (ref_filter_dependency dep 
join ref_last_dw_transfer dw on 1=1) 
