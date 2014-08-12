select   cnty.county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 1 [qry_seq]
			, qt.qry_type [Filter ID]
			, qt.qry_type_desc  [Filter Category]
			, isnull(max(p1.cnt_entries),0) cnt_entries
			, isnull(max(p1x.cnt_exits),0) cnt_exits
			, isnull(max(p5.reentry_rate),0) reentry_rate
from (select min_date_any,max_date_any from ref_lookup_max_date where id=24  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join ref_lookup_qry_type qt
left join prtl.cache_poc1ab_entries_aggr p1 on  p1.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13)
		and  p1.start_date=cd.CALENDAR_DATE 
		and p1.county_cd=cnty.county_cd
		 and p1.qry_type=qt.qry_type
		 and p1.date_type=1   
left join prtl.cache_poc1ab_exits_aggr p1x on  p1x.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13)
		and  p1x.start_date=cd.CALENDAR_DATE 
		and p1x.county_cd=cnty.county_cd
		 and p1x.qry_type=qt.qry_type
		 and p1x.date_type=1   
left join (select int_all_param_key,cohort_exit_year,qry_type,sum(reentry_rate) reentry_rate from  prtl.cache_pbcp5_aggr p5
					cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
					where p5.date_type=2
					and p5.reentry_within_month=12
					and p5.int_all_param_key=power(10.0, 21) + cnty.county_cd * power(10.0,13)
					group by int_all_param_key,cohort_exit_year,qry_type ) p5
 on  p5.int_all_param_key = power(10.0, 21) + cnty.county_cd * power(10.0,13)
			and p5.cohort_exit_year=cd.CALENDAR_DATE
			 and p5.qry_type=qt.qry_type
group by cnty.county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, qt.qry_type
			, qt.qry_type_desc
union all
select   cnty.county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 2 [qry_seq]
			, age.age_grouping_cd [Filter ID]
			, age.age_grouping  [Filter Category]
			, isnull(max(p1.cnt_entries),0) cnt_entries
			, isnull(max(p1x.cnt_exits),0) cnt_exits
			, isnull(max(p5.reentry_rate),0) reentry_rate
from (select min_date_any,max_date_any from ref_lookup_max_date where id=24  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join (select age_grouping_cd,age_grouping from ref_age_groupings_census )age
left join prtl.cache_poc1ab_entries_aggr p1 on  p1.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  age.age_grouping_cd * power(10.0,20)
		and  p1.start_date=cd.CALENDAR_DATE 
		and p1.county_cd=cnty.county_cd
		and p1.age_grouping_cd=age.age_grouping_cd
		 and p1.date_type=1   
		 and p1.qry_type=0
left join prtl.cache_poc1ab_exits_aggr p1x on  p1x.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  age.age_grouping_cd * power(10.0,20)
		and  p1x.start_date=cd.CALENDAR_DATE 
		and p1x.county_cd=cnty.county_cd
		 and p1x.age_grouping_cd=age.age_grouping_cd
		 and p1x.date_type=1   
		 and p1X.qry_type=0
left join (select int_all_param_key,cohort_exit_year,qry_type,sum(reentry_rate) reentry_rate from  prtl.cache_pbcp5_aggr p5
					cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
					cross join (select age_grouping_cd,age_grouping from ref_age_groupings_census )age
					where p5.date_type=2
					and p5.reentry_within_month=12
					and p5.int_all_param_key=power(10.0, 21) + cnty.county_cd * power(10.0,13) +  age.age_grouping_cd * power(10.0,20)
					and p5.qry_type=0
					group by int_all_param_key,cohort_exit_year,qry_type ) p5
 on  p5.int_all_param_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  age.age_grouping_cd * power(10.0,20)
			and p5.cohort_exit_year=cd.CALENDAR_DATE
			 and p5.qry_type=p1.qry_type
group by cnty.county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, age.age_grouping_cd
			, age.age_grouping
union all
select   cnty.county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 3 [qry_seq]
			, eth.cd_race_census [Filter ID]
			, eth.tx_race_census [Filter Category]
			, isnull(max(p1.cnt_entries),0) cnt_entries
			, isnull(max(p1x.cnt_exits),0) cnt_exits
			, isnull(max(p5.reentry_rate),0) reentry_rate
from (select min_date_any,max_date_any from ref_lookup_max_date where id=24  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  (select cd_race_census,tx_race_census from ref_lookup_ethnicity_census where cd_race_census <> 7  ) eth
left join prtl.cache_poc1ab_entries_aggr p1 on  p1.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  eth.cd_race_census * power(10.0,18)
		and  p1.start_date=cd.CALENDAR_DATE 
		and p1.county_cd=cnty.county_cd
		and p1.cd_race=eth.cd_race_census
		 and p1.date_type=1   
		 and p1.qry_type=0
left join prtl.cache_poc1ab_exits_aggr p1x on  p1x.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  eth.cd_race_census * power(10.0,18)
		and  p1x.start_date=cd.CALENDAR_DATE 
		and p1x.county_cd=cnty.county_cd
		 and p1x.cd_race=eth.cd_race_census
		 and p1x.date_type=1   
		 and p1X.qry_type=0
left join (select int_all_param_key,cohort_exit_year,qry_type,sum(reentry_rate) reentry_rate from  prtl.cache_pbcp5_aggr p5
					cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
					cross join  (select cd_race_census,tx_race_census from ref_lookup_ethnicity_census where cd_race_census <> 7  ) eth
					where p5.date_type=2
					and p5.reentry_within_month=12
					and p5.int_all_param_key=power(10.0, 21) + cnty.county_cd * power(10.0,13) +  eth.cd_race_census * power(10.0,18)
					and p5.qry_type=0
					group by int_all_param_key,cohort_exit_year,qry_type ) p5
 on  p5.int_all_param_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  eth.cd_race_census  * power(10.0,18)
			and p5.cohort_exit_year=cd.CALENDAR_DATE
			 and p5.qry_type=p1.qry_type
group by cnty.county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, eth.cd_race_census
			, eth.tx_race_census
union all
select   cnty.county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 4 [qry_seq]
			, alg.cd_allegation [Filter ID]
			, alg.tx_allegation [Filter Category]
			, isnull(max(p1.cnt_entries),0) cnt_entries
			, isnull(max(p1x.cnt_exits),0) cnt_exits
			, isnull(max(p5.reentry_rate),0) reentry_rate
from (select min_date_any,max_date_any from ref_lookup_max_date where id=24  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  ref_filter_allegation alg
left join prtl.cache_poc1ab_entries_aggr p1 on  p1.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) + alg.cd_allegation * power(10.0,5)
		and  p1.start_date=cd.CALENDAR_DATE 
		and p1.county_cd=cnty.county_cd
		and p1.cd_allegation=alg.cd_allegation
		 and p1.date_type=1   
		 and p1.qry_type=0
left join prtl.cache_poc1ab_exits_aggr p1x on  p1x.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  alg.cd_allegation * power(10.0,5)
		and  p1x.start_date=cd.CALENDAR_DATE 
		and p1x.county_cd=cnty.county_cd
		 and p1x.cd_allegation=alg.cd_allegation
		 and p1x.date_type=1   
		 and p1X.qry_type=0
left join (select int_all_param_key,cohort_exit_year,qry_type,sum(reentry_rate) reentry_rate from  prtl.cache_pbcp5_aggr p5
					cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
					cross join  ref_filter_allegation alg
					where p5.date_type=2
					and p5.reentry_within_month=12
					and p5.int_all_param_key=power(10.0, 21) + cnty.county_cd * power(10.0,13) +  alg.cd_allegation * power(10.0,5)
					and p5.qry_type=0
					group by int_all_param_key,cohort_exit_year,qry_type ) p5
 on  p5.int_all_param_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) + alg.cd_allegation  *power(10.0,5)
			and p5.cohort_exit_year=cd.CALENDAR_DATE
			 and p5.qry_type=p1.qry_type
group by cnty.county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, alg.cd_allegation
			, alg.tx_allegation
union all
select   cnty.county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 5 [qry_seq]
			, fnd.cd_finding [Filter ID]
			, fnd.tx_finding [Filter Category]
			, isnull(max(p1.cnt_entries),0) cnt_entries
			, isnull(max(p1x.cnt_exits),0) cnt_exits
			, isnull(max(p5.reentry_rate),0) reentry_rate
from (select min_date_any,max_date_any from ref_lookup_max_date where id=24  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  ref_filter_finding fnd
left join prtl.cache_poc1ab_entries_aggr p1 on  p1.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) + fnd.cd_finding * power(10.0,4)
		and  p1.start_date=cd.CALENDAR_DATE 
		and p1.county_cd=cnty.county_cd
		and p1.cd_finding=fnd.cd_finding
		 and p1.date_type=1   
		 and p1.qry_type=0
left join prtl.cache_poc1ab_exits_aggr p1x on  p1x.int_hash_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) +  fnd.cd_finding * power(10.0,4)
		and  p1x.start_date=cd.CALENDAR_DATE 
		and p1x.county_cd=cnty.county_cd
		 and p1x.cd_finding=fnd.cd_finding
		 and p1x.date_type=1   
		 and p1X.qry_type=0
left join (select int_all_param_key,cohort_exit_year,qry_type,sum(reentry_rate) reentry_rate from  prtl.cache_pbcp5_aggr p5
					cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
					cross join  ref_filter_finding fnd
					where p5.date_type=2
					and p5.reentry_within_month=12
					and p5.int_all_param_key=power(10.0, 21) + cnty.county_cd * power(10.0,13) +  fnd.cd_finding * power(10.0,4)
					and p5.qry_type=0
					group by int_all_param_key,cohort_exit_year,qry_type ) p5
 on  p5.int_all_param_key = power(10.0, 21) + cnty.county_cd * power(10.0,13) + fnd.cd_finding  *power(10.0,4)
			and p5.cohort_exit_year=cd.CALENDAR_DATE
			 and p5.qry_type=p1.qry_type
group by cnty.county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, fnd.cd_finding
			, fnd.tx_finding
order by [CountyCd],qry_seq,[Year],[Quarter],[Filter ID]

-- select * from prtl.ooh_int_hash_key

--select * from prtl.cache_poc1ab_entries_params order by qry_id desc

