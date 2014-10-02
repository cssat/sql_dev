--  exec prtl.prod_build_rate_placement 

alter procedure prtl.prod_build_rate_placement 
as

alter table prtl.rate_placement  NOCHECK CONSTRAINT ALL;
truncate table prtl.rate_placement



insert into prtl.rate_placement(date_type,qry_type,cohort_date,county_cd,cnt_households_w_plcm,cnt_referrals_u18,rate_placement)
select  0 "date_type"
			, 2 "qry_type"
			, mnth.start_date
			, lu_cnty.county_cd
			, cnt_hh_plcm 
			, coalesce(intk.cnt_referrals,0) cnt_ref
			, IIF(intk.cnt_referrals>0, cnt_hh_plcm/(intk.cnt_referrals*1.0000) * 1000 ,null) "placement_rate"
from (select distinct [Month] start_date from Calendar_dim ,ref_last_dw_transfer where [Month] between '2000-01-01' and dateadd(mm,-1,cutoff_date)) mnth
join ref_lookup_county lu_cnty on lu_cnty.county_cd between 0 and 39
left join (
				select distinct 0 "date_type",2 "qry_type",[month] start_date
						,count(distinct id_case) cnt_hh_plcm
						,cnty.cd_cnty   "county_cd"
				From  prtl.ooh_dcfs_eps plc
						join prm_cnty cnty on cnty.match_code=plc.removal_county_cd
						join calendar_dim cd on cd.CALENDAR_DATE=plc.removal_dt
				where cd.MONTH>='2000-01-01'  and plc.entry_cdc_census_mix_age_cd is not null
				group by cd.MONTH,cnty.cd_cnty
				) plc on plc.start_date=mnth.start_date and plc.county_cd=lu_cnty.county_cd
left join prtl.rate_referrals_screened_in  intk on intk.start_date=mnth.start_date
												and intk.county_cd=lu_cnty.county_cd
order by lu_cnty.county_cd,mnth.start_date

alter table prtl.rate_placement  CHECK CONSTRAINT ALL;			


