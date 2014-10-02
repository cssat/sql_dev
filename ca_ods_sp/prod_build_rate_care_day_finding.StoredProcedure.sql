
alter procedure prtl.prod_build_rate_care_day_finding
as
if OBJECT_ID('tempDB..#cases_from_intakes_placements') is not null drop table #cases_from_intakes_placements

select distinct 0 date_type
		,2 qry_type
		,q.id_intake_fact
		,q.county_cd
		,q.id_case
		,q.rfrd_date
		,q.removal_dt
		,q.discharge_dt
		,ref.rfrd_date as rfrd_date_during_placement
		,ref.id_intake_fact as rfrd_intake_during_placemnt
		,cd.STATE_FISCAL_YYYY fiscal_yr
into #cases_from_intakes_placements
from   (
	select id_case,id_intake_fact,(select top 1 rfrd_date from base.tbl_intakes intk where intk.id_intake_fact=plc.id_intake_fact) rfrd_date
	,removal_dt,discharge_dt,cnty.cd_cnty county_cd
	 from base.rptPlacement plc 
	 join prm_cnty cnty on cnty.match_code=removal_county_cd
	 where id_intake_fact is not null and age_at_removal_mos< (18*12)  and max_bin_los_cd>=1
	 ) q 
	 join prtl.vw_referrals_grp ref 
	on ref.id_case=q.id_case 
				and ref.rfrd_date between 
							dateadd(d,8,removal_dt) and 
								(iif(discharge_dt > (select cutoff_date from ref_last_dw_transfer),(select cutoff_date from ref_last_dw_transfer),discharge_dt))
				and ref.fl_founded_any_legal=1
	join CALENDAR_DIM cd on cd.CALENDAR_DATE=cast(convert(varchar(10),ref.rfrd_date,121) as datetime)



truncate table prtl.rate_care_day_finding
insert into  prtl.rate_care_day_finding(date_type,qry_type,fiscal_yr,county_cd,care_days,cnt_referrals,care_day_finding_rate)
select  0,2, cd.fiscal_yr,cd.county_cd
,sum(care_days) care_days
,isnull(sum(cnt_referrals),0) cnt_referrals
,isnull(round((sum(cnt_referrals) /(sum(care_days) * 1.00000000)) * 100000,9),0)  [care_day_finding_rate]
 from base.placement_care_days_mobility  cd
 left join (select intk.fiscal_yr,intk.county_cd,count(* ) cnt_referrals
					  from  #cases_from_intakes_placements intk
					  group by  intk.fiscal_yr,intk.county_cd
					  ) intk on cd.fiscal_yr=intk.fiscal_yr and cd.county_cd=intk.county_cd
 where age_yrs_exit=-99 and age_yrs_removal=-99 
 and cd_race=0 and exclude_7day=1 and exclude_trh=0 
 group by cd.fiscal_yr,cd.county_cd
 order by cd.county_cd,fiscal_yr

--    select * from prtl.rate_care_day_finding
--select  0,2, cd.fiscal_yr,cd.county_cd
--,sum(care_days) care_days
--from base.placement_care_days_mobility cd
--where age_yrs_exit=-99 and age_yrs_removal=-99 
-- and cd_race=0 and exclude_7day=1 and exclude_trh=0 
-- group by cd.fiscal_yr,cd.county_cd
-- order by cd.county_cd,fiscal_yr
