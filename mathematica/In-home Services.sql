select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 1 [qry_seq]
			, qt.qry_type [Filter ID]
			, qt.qry_type_desc  [Filter Category]
			, isnull(max(p3.cnt_opened),0) cnt_opened
			, isnull(max(p3.cnt_closed),0) cnt_closed
			, isnull(max(s3.placed),0) placed
from (select min_date_any,max_date_any from ref_lookup_max_date where id=22  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join ref_lookup_qry_type qt
left join prtl.cache_poc3ab_aggr p3 on  p3.int_hash_key = power(10.0, 16) + county_cd * power(10.0,10) 
		and  p3.start_date=cd.CALENDAR_DATE 
		and p3.cd_county=cnty.county_cd
		 and p3.qry_type=qt.qry_type
		 and p3.date_type=1   
left join prtl.cache_pbcs3_aggr s3 on  s3.int_hash_key = power(10.0, 16) + county_cd * power(10.0,10)  
			and s3.start_date=cd.CALENDAR_DATE
			 and s3.cd_county=cnty.county_cd 	
			 and s3.qry_type=qt.qry_type
			and s3.date_type=2
			and s3.month=12
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
			,age.cd_sib_age_grp [Filter ID]
			, age.tx_sib_age_grp  [Filter Category]
			, isnull(max(p3.cnt_opened),0) cnt_opened
			, isnull(max(p3.cnt_closed),0) cnt_closed
			, isnull(max(s3.placed),0) placed
from (select min_date_any,max_date_any from ref_lookup_max_date where id=22  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join (select cd_sib_age_grp,tx_sib_age_grp from ref_lookup_sib_age_grp  where cd_sib_age_grp < 4)age
left join prtl.cache_poc3ab_aggr p3 on  p3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  + age.cd_sib_age_grp * power(10.0,15 ))
		and  p3.start_date=cd.CALENDAR_DATE 
		and p3.cd_county=cnty.county_cd
		and p3.cd_sib_age_grp=age.cd_sib_age_grp
		 and p3.qry_type=0
		 and p3.date_type=1   
left join prtl.cache_pbcs3_aggr s3 on  s3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  + age.cd_sib_age_grp * power(10.0,15 ))
			and s3.start_date=cd.CALENDAR_DATE
			 and s3.cd_county=cnty.county_cd 	
			 and s3.cd_sib_age_grp=age.cd_sib_age_grp
			 and s3.qry_type=0
			and s3.date_type=2
			and s3.month=12
group by  power(10.0, 16) + cnty.county_cd * power(10.0,10)  + age.cd_sib_age_grp * power(10.0,15 )
			,county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, age.cd_sib_age_grp
			, age.tx_sib_age_grp
union all
select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 3 [qry_seq]
			,  eth.cd_race_census [Filter ID]
			, eth.tx_race_census [Filter Category]
			, isnull(max(p3.cnt_opened),0) cnt_opened
			, isnull(max(p3.cnt_closed),0) cnt_closed
			, isnull(max(s3.placed),0) placed
from (select min_date_any,max_date_any from ref_lookup_max_date where id=22  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  (select cd_race_census,tx_race_census from ref_lookup_ethnicity_census where cd_race_census <> 7  ) eth
left join prtl.cache_poc3ab_aggr p3 on  p3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  +  eth.cd_race_census * power(10.0,13 ))
		and  p3.start_date=cd.CALENDAR_DATE 
		and p3.cd_county=cnty.county_cd
		and p3.cd_race_census=eth.cd_race_census
		 and p3.qry_type=0
		 and p3.date_type=1   
left join prtl.cache_pbcs3_aggr s3 on  s3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  +  eth.cd_race_census * power(10.0,13 ))
			and s3.start_date=cd.CALENDAR_DATE
			 and s3.cd_county=cnty.county_cd 	
			 and s3.cd_race_census=eth.cd_race_census
			 and s3.qry_type=0
			and s3.date_type=2
			and s3.month=12
group by  power(10.0, 16) + cnty.county_cd * power(10.0,10)  +  eth.cd_race_census * power(10.0,13 )
			,county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			,  eth.cd_race_census
			,  eth.tx_race_census
union all
select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 4 [qry_seq]
			, alg.cd_allegation [Filter ID]
			, alg.tx_allegation [Filter Category]
			, isnull(max(p3.cnt_opened),0) cnt_opened
			, isnull(max(p3.cnt_closed),0) cnt_closed
			, isnull(max(s3.placed),0) placed
from (select min_date_any,max_date_any from ref_lookup_max_date where id=22  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  ref_filter_allegation alg
left join prtl.cache_poc3ab_aggr p3 on  p3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  +  alg.cd_allegation * power(10.0, 5 ))
		and  p3.start_date=cd.CALENDAR_DATE 
		and p3.cd_county=cnty.county_cd
		and p3.cd_allegation=alg.cd_allegation
		 and p3.qry_type=0
		 and p3.date_type=1   
left join prtl.cache_pbcs3_aggr s3 on  s3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  +  alg.cd_allegation *power(10.0, 5 ))
			and s3.start_date=cd.CALENDAR_DATE
			 and s3.cd_county=cnty.county_cd 	
			 and s3.cd_allegation=alg.cd_allegation
			 and s3.qry_type=0
			and s3.date_type=2
			and s3.month=12
group by  power(10.0, 16) + cnty.county_cd * power(10.0,10)  + alg.cd_allegation *power(10.0, 5 )
			,county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, alg.cd_allegation
			, alg.tx_allegation
union all
select   county_cd [CountyCd] 
			,county_desc [CountyID]
			, cd.YEAR_YYYY [Year]
			, cd.[QUARTER_OF_YEAR]  [Quarter]
			, 5 [qry_seq]
			, fnd.cd_finding [Filter ID]
			, fnd.tx_finding [Filter Category]
			, isnull(max(p3.cnt_opened),0) cnt_opened
			, isnull(max(p3.cnt_closed),0) cnt_closed
			, isnull(max(s3.placed),0) placed
from (select min_date_any,max_date_any from ref_lookup_max_date where id=22  ) dt
join  calendar_dim  cd on cd.CALENDAR_DATE between min_date_any and max_date_any  
cross join (select county_cd,county_desc from ref_lookup_county where county_cd between 0 and 39) cnty
cross join  ref_filter_finding fnd
left join prtl.cache_poc3ab_aggr p3 on  p3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  +   fnd.cd_finding * power(10.0, 4 ))
		and  p3.start_date=cd.CALENDAR_DATE 
		and p3.cd_county=cnty.county_cd
		and p3.cd_finding= fnd.cd_finding
		 and p3.qry_type=0
		 and p3.date_type=1   
left join prtl.cache_pbcs3_aggr s3 on  s3.int_hash_key = convert(decimal(22,0),power(10.0, 16) + cnty.county_cd * power(10.0,10)  +   fnd.cd_finding *power(10.0, 4 ))
			and s3.start_date=cd.CALENDAR_DATE
			 and s3.cd_county=cnty.county_cd 	
			 and s3.cd_finding= fnd.cd_finding
			 and s3.qry_type=0
			and s3.date_type=2
			and s3.month=12
group by  power(10.0, 16) + cnty.county_cd * power(10.0,10)  +  fnd.cd_finding *power(10.0, 4 )
			,county_cd
			,county_desc 
			, cd.YEAR_YYYY 
			, cd.[QUARTER_OF_YEAR] 
			, fnd.cd_finding
			, fnd.tx_finding
order by [CountyCd],qry_seq,[Year],[Quarter],[Filter ID]
