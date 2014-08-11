select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 1 [qry_seq]
			, qt.qry_type [Filter ID]
			, qt.qry_type_desc  [Filter Category]
			, isnull(max(p2.cnt_opened),0) cnt_opened
			, isnull(max(p2.cnt_closed),0) cnt_closed
			, isnull(max(s2.among_first_cmpt_rereferred),0) among_first_cmpt_rereferred
from (select min_date_any,max_date_any from ref_lookup_max_date where id=6  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join ref_lookup_qry_type qt
left join prtl.cache_poc2ab_aggr p2 on p2.start_date=cd.CALENDAR_DATE and p2.cd_county=cnty.county_cd and p2.qry_type=qt.qry_type
		 and p2.date_type=1   
		 and p2.qry_type=qt.qry_type
		and p2.qry_id in  (1,6) 
left join prtl.cache_pbcs2_aggr s2 on  s2.start_date=cd.CALENDAR_DATE and s2.cd_county=cnty.county_cd 	and s2.qry_type=qt.qry_type
			and s2.date_type=2
			and s2.qry_type=qt.qry_type
			and s2.month=12
			and s2.qry_id  in (1,6) 
group by county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, qt.qry_type
			, qt.qry_type_desc
union all

select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 2 [qry_seq]
			,  age.cd_sib_age_grp [Filter ID]
			, age.tx_sib_age_grp  [Filter Category]
			, isnull(max(p2.cnt_opened),0) cnt_opened
			, isnull(max(p2.cnt_closed),0) cnt_closed
			, isnull(max(s2.among_first_cmpt_rereferred),0) among_first_cmpt_rereferred
from (select min_date_any,max_date_any from ref_lookup_max_date where id=6  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join (select cd_sib_age_grp,tx_sib_age_grp from ref_lookup_sib_age_grp  where cd_sib_age_grp < 4)age
left join prtl.cache_poc2ab_aggr p2 on p2.start_date=cd.CALENDAR_DATE and p2.cd_county=cnty.county_cd and p2.cd_sib_age_grp=age.cd_sib_age_grp
		 and p2.date_type=1   
		 and p2.qry_type=0 
		and p2.qry_id in  (21,26) 
left join prtl.cache_pbcs2_aggr s2 on  s2.start_date=cd.CALENDAR_DATE and s2.cd_county=cnty.county_cd 	and s2.cd_sib_age_grp=age.cd_sib_age_grp
			and s2.date_type=2
			and s2.qry_type=0
			and s2.month=12
			and s2.qry_id  in  (21,26)
group by county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, age.cd_sib_age_grp
			,age.tx_sib_age_grp
union all
select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 3 [qry_seq]
			,  eth.cd_race_census [Filter ID]
			, eth.tx_race_census [Filter Category]
			, isnull(max(p2.cnt_opened),0) cnt_opened
			, isnull(max(p2.cnt_closed),0) cnt_closed
			, isnull(max(s2.among_first_cmpt_rereferred),0) among_first_cmpt_rereferred
from (select min_date_any,max_date_any from ref_lookup_max_date where id=6  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  (select cd_race_census,tx_race_census from ref_lookup_ethnicity_census where cd_race_census <> 7  ) eth -- exclude unknown
left join prtl.cache_poc2ab_aggr p2 on p2.start_date=cd.CALENDAR_DATE and p2.cd_county=cnty.county_cd and p2.cd_race=eth.cd_race_census
		and p2.qry_id in (13,17)  and p2.qry_type=0 and p2.date_type=1   
left join prtl.cache_pbcs2_aggr s2 on  s2.start_date=cd.CALENDAR_DATE and s2.cd_county=cnty.county_cd 	and s2.cd_race=eth.cd_race_census
			and s2.date_type=2
			and s2.qry_type=0
			and s2.month=12
			and s2.qry_id  in (13,17)  
group by county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			,  eth.cd_race_census
			, eth.tx_race_census 
union all
select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 4 [qry_seq]
			,  alg.cd_allegation [Filter ID]
			, alg.tx_allegation [Filter Category]
			, isnull(max(p2.cnt_opened),0) cnt_opened
			, isnull(max(p2.cnt_closed),0) cnt_closed
			, isnull(max(s2.among_first_cmpt_rereferred),0) among_first_cmpt_rereferred
from (select min_date_any,max_date_any from ref_lookup_max_date where id=6  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  ref_filter_allegation alg
left join prtl.cache_poc2ab_aggr p2 on p2.start_date=cd.CALENDAR_DATE and p2.cd_county=cnty.county_cd and p2.cd_allegation=alg.cd_allegation
		and p2.qry_type=0 
		and p2.date_type=1   
		and p2.qry_id in (3,8)  
left join prtl.cache_pbcs2_aggr s2 on  s2.start_date=cd.CALENDAR_DATE and s2.cd_county=cnty.county_cd 	and s2.cd_allegation=alg.cd_allegation
			and s2.date_type=2
			and s2.qry_type=0
			and s2.month=12
			and s2.qry_id  in (3,8)
group by county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			,  alg.cd_allegation
			, alg.tx_allegation
			union all
select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 4 [qry_seq]
			,  fnd.cd_finding [Filter ID]
			, fnd.tx_finding [Filter Category]
			, isnull(max(p2.cnt_opened),0) cnt_opened
			, isnull(max(p2.cnt_closed),0) cnt_closed
			, isnull(max(s2.among_first_cmpt_rereferred),0) among_first_cmpt_rereferred
from (select min_date_any,max_date_any from ref_lookup_max_date where id=6  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  ref_filter_finding fnd
left join prtl.cache_poc2ab_aggr p2 on p2.start_date=cd.CALENDAR_DATE and p2.cd_county=cnty.county_cd and p2.cd_finding=fnd.cd_finding
		and p2.qry_type=0 
		and p2.date_type=1   
		and p2.qry_id in (2,7)  
left join prtl.cache_pbcs2_aggr s2 on  s2.start_date=cd.CALENDAR_DATE and s2.cd_county=cnty.county_cd 	and s2.cd_finding=fnd.cd_finding
			and s2.date_type=2
			and s2.qry_type=0
			and s2.month=12
			and s2.qry_id  in (2,7)
group by county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			,  fnd.cd_finding
			, fnd.tx_finding
order by qry_seq,[CountyCd],[Year],[Quarter],[Filter ID]

--  select * from prtl.cache_poc2ab_params where filter_finding <> '0' and cd_county = '0' order by qry_id  qryid in (2,7)







