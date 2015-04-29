drop table prtl.prtl_poc1ab_entries_bkp
select *
into prtl.prtl_poc1ab_entries_bkp
from prtl.prtl_poc1ab_entries
where date_type=2;

drop table #myDate
select distinct  [cohort_date],1 [date_type],LEAD([cohort_date],1)  over (order by [cohort_date] asc) [nxt_qtr]
into #myDate
 from (select distinct [quarter] [cohort_date] from CALENDAR_DIM 
 where ID_CALENDAR_DIM between 20000101 and 20131221) q
   order by [cohort_date]

drop table  #tmp
  select #myDate.*,n.qry_type
  into #tmp
  from #myDate
  cross join (select number qry_type from numbers where number between 0 and 2) n
  order by cohort_date,date_type,qry_type asc


 
 insert into prtl.prtl_poc1ab_entries_bkp
SELECT poc1ab.[qry_type]
      ,md.[date_type]
      ,md.cohort_date [start_date]
      ,[bin_dep_cd]
      ,[max_bin_los_cd]
      ,[bin_placement_cd]
      ,[bin_ihs_svc_cd]
      ,[cd_reporter_type]
      ,[age_grouping_cd]
      ,[cd_race]
      ,[census_hispanic_latino_origin_cd]
      ,[pk_gndr]
      ,[init_cd_plcm_setng]
      ,[long_cd_plcm_setng]
      ,[county_cd]
      ,[int_match_param_key]
      ,sum([cnt_entries])
      ,[filter_allegation]
      ,[filter_finding]
      ,[filter_service_category]
      ,[filter_service_budget]
      ,[filter_access_type]
      ,[start_year]
 from prtl.prtl_poc1ab_entries poc1ab
 join #tmp md on poc1ab.start_date >= md.cohort_date 
	and poc1ab.start_date <  md.nxt_qtr
	and poc1ab.qry_type=md.qry_type
where poc1ab.date_type=0 
group by poc1ab.qry_type
      ,md.[date_type]
      ,md.cohort_date 
      ,[bin_dep_cd]
      ,[max_bin_los_cd]
      ,[bin_placement_cd]
      ,[bin_ihs_svc_cd]
      ,[cd_reporter_type]
      ,[age_grouping_cd]
      ,[cd_race]
      ,[census_hispanic_latino_origin_cd]
      ,[pk_gndr]
      ,[init_cd_plcm_setng]
      ,[long_cd_plcm_setng]
      ,[county_cd]
      ,[int_match_param_key]
      ,[filter_allegation]
      ,[filter_finding]
      ,[filter_service_category]
      ,[filter_service_budget]
      ,[filter_access_type]
      ,[start_year]


truncate table prtl.prtl_poc1ab_entries
insert into prtl.prtl_poc1ab_entries
select * from prtl.prtl_poc1ab_entries_bkp

drop table #mydata
select *  into #mydata from prtl.cache_poc1ab_entries_aggr where date_type=0


declare @i int
set @i=21;
while @i < 42
begin
delete from prtl.cache_poc1ab_entries_aggr where qry_id=@i and date_type=0;
set @i+=1;
print @i
end


select max(qry_id) from prtl.cache_poc1ab_entries_aggr 
	
insert into prtl.cache_poc1ab_entries_aggr 
SELECT md.[qry_type]
      ,md.[date_type]
      ,[start_date]
      ,[int_param_key]
      ,[bin_dep_cd]
      ,[bin_los_cd]
      ,[bin_placement_cd]
      ,[bin_ihs_svc_cd]
      ,[cd_reporter_type]
      ,[cd_access_type]
      ,[cd_allegation]
      ,[cd_finding]
      ,[cd_subctgry_poc_frc]
      ,[cd_budget_poc_frc]
      ,[custody_id]
      ,[age_grouping_cd]
      ,[cd_race]
      ,[pk_gndr]
      ,[init_cd_plcm_setng]
      ,[long_cd_plcm_setng]
      ,[county_cd]
      ,sum([cnt_entries])
      ,[min_start_date]
      ,[max_start_date]
      ,[x1]
      ,[x2]
      ,[insert_date]
      ,[int_hash_key]
      ,[qry_id]
      ,[start_year]
      ,[fl_include_perCapita]
from #mydata poc1ab
join #tmp md on
poc1ab.start_date >= md.cohort_date 
	and poc1ab.start_date <  md.nxt_qtr
	and poc1ab.qry_type=md.qry_type
group by    md.[qry_type]
      ,md.[date_type]
      ,[start_date]
      ,[int_param_key]
      ,[bin_dep_cd]
      ,[bin_los_cd]
      ,[bin_placement_cd]
      ,[bin_ihs_svc_cd]
      ,[cd_reporter_type]
      ,[cd_access_type]
      ,[cd_allegation]
      ,[cd_finding]
      ,[cd_subctgry_poc_frc]
      ,[cd_budget_poc_frc]
      ,[custody_id]
      ,[age_grouping_cd]
      ,[cd_race]
      ,[pk_gndr]
      ,[init_cd_plcm_setng]
      ,[long_cd_plcm_setng]
      ,[county_cd]   ,[min_start_date]
      ,[max_start_date]
      ,[x1]
      ,[x2]
      ,[insert_date]
      ,[int_hash_key]
      ,[qry_id]
      ,[start_year]
      ,[fl_include_perCapita]