create procedure prtl.prod_build_order_specific_placement_rate
as

if OBJECT_ID('tempDB..#cases_from_intakes_placements') is not null drop table #cases_from_intakes_placements
select distinct 0 date_type,2 qry_type,intk.id_intake_fact,intk.county_cd,intk.id_case,q.id_case id_case_removal,intk.rfrd_date,q.removal_dt,DATEFROMPARTS(year(intk.rfrd_date),month(intk.rfrd_date),day(0)) cohort_date
into #cases_from_intakes_placements
from (
	select id_case,id_intake_fact	, intake_county_cd county_cd,rfrd_date   -- , (select top 1 removal_dt from base.rptPlacement plc where plc.id_intake_fact is not null and plc.id_intake_fact=intk.id_intake_fact order by removal_dt)  removal_dt
	from base.tbl_intakes intk where id_case > 0
	and exists(select id_case from base.tbl_household_children chld where chld.id_intake_fact=intk.id_intake_fact    and age_at_referral_dt<18 and id_case>0)
	) intk
left join (
	select id_case,id_intake_fact,(select top 1 rfrd_date from base.tbl_intakes intk where intk.id_intake_fact=plc.id_intake_fact) rfrd_date
	,removal_dt
	 from base.rptPlacement plc where id_intake_fact is not null and age_at_removal_mos< (18*12) ) q on q.id_intake_fact=intk.id_intake_fact


if OBJECT_ID('tempDB..#case_placement_rankings') is not null drop table #case_placement_rankings
select p1.cohort_date,p1.id_case,p1.county_cd,p1.id_intake_fact,p1.rfrd_date,(select count(distinct p2.id_intake_fact) from #cases_from_intakes_placements p2 where p2.removal_dt is not null
			and p2.id_case=p1.id_case and p2.rfrd_date< p1.rfrd_date ) prior_placement_rank
into #case_placement_rankings
from #cases_from_intakes_placements p1
order by p1.id_case,p1.rfrd_date asc
/** qa
select * from #case_placement_rankings order by id_case,rfrd_date
select * from #case_placement_rankings where id_case=65037  order by id_case,rfrd_date
select * from #cases_from_intakes_placements where id_case=65037 order by id_case,rfrd_date
**/


truncate table prtl.rate_placement_order_specific
insert into prtl.rate_placement_order_specific(date_type,qry_type,cohort_date,nth_order,county_cd,cnt_nth_order_placement_cases,cnt_prior_order_placement_cases,placement_rate)
select  0 date_type
		,2 qry_type
		,mnth.cohort_date
		,nth_order.number nth_order
		,cnty.county_cd
		,coalesce(cnt_case,0) cnt_nth_order_placement_cases
		,coalesce(cnt_prior_case,0) cnt_prior_order_placement_cases
		,IIF(cnt_prior_case!=0 and cnt_case!=0,cnt_case/(cnt_prior_case * 1.0000) * 1000,null) placement_rate
from  (select distinct [Month] cohort_date from Calendar_dim ,ref_last_dw_transfer where [Month] between '2000-01-01' and dateadd(mm,-1,cutoff_date)) mnth
join ref_lookup_county cnty on cnty.county_cd between 0 and 39
join numbers nth_order on nth_order.number between 1 and 3
left join (select 0 date_type,2 qry_type,   cohort_date,cnty.cd_cnty "county_cd",prior_placement_rank as nth_order_plcmnt
			,count(distinct id_case) cnt_case
			from #case_placement_rankings
			join prm_cnty cnty on cnty.match_code=county_cd
			group by cohort_date,cnty.cd_cnty,prior_placement_rank
			) cases_with_plcm on cases_with_plcm.county_cd=cnty.county_cd
			and cases_with_plcm.cohort_date=mnth.cohort_date
			and nth_order.number=cases_with_plcm.nth_order_plcmnt
left join (select 0 date_type,2 qry_type,   cohort_date,cnty.cd_cnty "county_cd",prior_placement_rank as nth_order_plcmnt
			,count(distinct id_case) cnt_prior_case
			from #case_placement_rankings
			join prm_cnty cnty on cnty.match_code=county_cd
			group by cohort_date,cnty.cd_cnty,prior_placement_rank
	--		order by prior_placement_rank,cnty.cd_cnty,cohort_date
			) cases_prior_plcm on cases_prior_plcm.county_cd=cnty.county_cd
			and cases_prior_plcm.cohort_date=mnth.cohort_date
			and nth_order.number=cases_prior_plcm.nth_order_plcmnt + 1
	where mnth.cohort_date >='2004-01-01'
order by cnty.county_cd,number,mnth.cohort_date


