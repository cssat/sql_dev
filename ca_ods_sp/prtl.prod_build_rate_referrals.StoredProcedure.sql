USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_rate_referrals]    Script Date: 9/30/2014 10:31:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--   exec prtl.prod_build_rate_referrals

ALTER procedure [prtl].[prod_build_rate_referrals] as 
declare @startdate datetime=getdate()
alter table prtl.rate_referrals NOCHECK CONSTRAINT ALL
truncate table prtl.rate_referrals
insert into prtl.rate_referrals(qry_type,date_type,start_date,county_cd,cnt_referrals,tot_pop,referral_rate)
							SELECT qry_type
								  ,[date_type]
								  ,cohort_entry_date as [start_date]
								  ,cnty.cd_cnty county_cd
								  ,count( distinct intake_grouper) as cnt_ref
								  ,pop.tot_pop
								  , count( distinct intake_grouper) /(pop.tot_pop * 1.0000) *1000 "referral_rate"
						  from [prtl].[vw_referrals_grp] tce
						  join prm_cnty cnty on cnty.match_code=intake_county_cd
						  join (select measurement_year,county_cd,sum(pop_cnt) tot_pop
									 from public_data.census_population_household where cd_race<9
									 group by measurement_year,county_cd
									 union all
									 select measurement_year,0,sum(pop_cnt) tot_pop
									 from public_data.census_population_household where cd_race<9
									 group by measurement_year
									) pop on measurement_year=year(cohort_entry_date) and pop.county_cd=cnty.cd_cnty 
						  where  tce.cd_access_type in (1,4) and fl_dlr=0
						  and hh_with_children_under_18=1 
						  group by   qry_type
								  ,[date_type]
									,cohort_entry_date 
								  ,cnty.cd_cnty 
								  ,pop.tot_pop
							order by cnty.cd_cnty,cohort_entry_date


alter table prtl.rate_referrals CHECK CONSTRAINT ALL

declare @enddate datetime=getdate();
update tbl
set tbl.last_build_date=getdate()
		,tbl.row_count=(select count(*) from prtl.rate_referrals)
		,tbl.load_time_mins=dbo.fnc_datediff_mis(@startdate,@enddate)
from prtl.prtl_tables_last_update tbl
where tbl_id=55