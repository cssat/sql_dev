--   exec prtl.prod_build_rate_referrals

CREATE procedure [prtl].[prod_build_rate_referrals] as 
		declare @startdate datetime=getdate()
		alter table prtl.rate_referrals NOCHECK CONSTRAINT ALL
		truncate table prtl.rate_referrals
		insert into prtl.rate_referrals(qry_type, date_type, start_date, county_cd, entry_point, cnt_referrals, tot_pop, referral_rate)
		SELECT tce.qry_type
				,tce.date_type
				,tce.cohort_entry_date as [start_date]
				,cnty.cd_cnty as [county_cd]
				,ep.entry_point
				,count(distinct tce.intake_grouper) as [cnt_ref]
				,pop.tot_pop
				,count(distinct tce.intake_grouper) / (pop.tot_pop * 1.0000) * 1000 as [referral_rate]
		from [prtl].[vw_referrals_grp] as tce
		--   this table is used for aggregating ALL as well as individual counties
		join prm_cnty as cnty 
			on cnty.match_code = intake_county_cd
		--  this table is used for aggregating the entry points as well as individual entry point
		join prm_entry_point as ep 
			on ep.match_code = tce.entry_point
		join (select measurement_year
				,county_cd
				,sum(pop_cnt) as tot_pop
			from public_data.census_population_household where cd_race<9
			group by measurement_year
				,county_cd

			union all

			select measurement_year
				,0
				,sum(pop_cnt) as [tot_pop]
			from public_data.census_population_household 
			where cd_race < 9
			group by measurement_year
		) as pop 
			on measurement_year = year(cohort_entry_date) 
			and pop.county_cd = cnty.cd_cnty 
		where  ep.entry_point <> 7 -- exclude DLR
			and hh_with_children_under_18 = 1  -- must have child under 18 associated with  intake group
		group by tce.qry_type
				 ,tce.date_type
				 ,tce.cohort_entry_date 
				 ,cnty.cd_cnty 
				 ,ep.entry_point
				 ,pop.tot_pop
		order by ep.entry_point
				 ,cnty.cd_cnty
				 ,cohort_entry_date


alter table prtl.rate_referrals CHECK CONSTRAINT ALL

declare @enddate datetime = getdate();
update tbl
set tbl.last_build_date = getdate()
		,tbl.row_count = (select count(*) from prtl.rate_referrals)
		,tbl.load_time_mins = dbo.fnc_datediff_mis(@startdate,@enddate)
from prtl.prtl_tables_last_update tbl
where tbl_id=55

----  select * from prtl.rate_referrals where  county_cd=0 and start_date='2010-01-01'  order by entry_point,start_date
--select start_date,sum(cnt_referrals)  from prtl.rate_referrals  
--where  county_cd=0 and start_date='2010-01-01'  and entry_point>0  group by start_date order by start_date

