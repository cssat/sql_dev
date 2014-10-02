----  exec prtl.prod_build_rate_referrals_order_specific

alter procedure prtl.prod_build_rate_referrals_order_specific
as

	if OBJECT_ID('tempDB..#referrals') is not null drop table #referrals;
	select tce.* 
			,DENSE_RANK() over (partition by coalesce(grp_id_case,tce.id_intake_fact) 
										order by coalesce(grp_rfrd_date,tce.rfrd_date)
														,coalesce(intake_grouper,tce.id_intake_fact )asc) cps_hh_nth_order
			,lead(coalesce(grp_rfrd_date,tce.rfrd_date)) over (partition by coalesce(grp_id_case,tce.id_intake_fact) 
							order by coalesce(grp_rfrd_date,tce.rfrd_date)) nxt_rfrd_date
	into #referrals
	from [prtl].[vw_referrals_grp] tce
	where  tce.cd_access_type in (1,4) and fl_dlr=0
	and hh_with_children_under_18=1 


CREATE NONCLUSTERED INDEX idx_start_date_nxt_rfrd_date_id_case_nth_order_scrn
ON #referrals (cohort_entry_date,[nxt_rfrd_date])
INCLUDE ([id_case],[cps_hh_nth_order])


--- get nth order households
	if OBJECT_ID('tempDB..#households') is not null drop table #households;
	select [month],curr.cps_hh_nth_order,cnty.cd_cnty county_cd,count(distinct curr.id_case) cnt_households
	into #households
	from 	 #referrals   curr 
		join (select distinct [month] from calendar_dim 
				where calendar_date between '1998-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
				) mnth
				on mnth.[month]>=curr.cohort_entry_date and (mnth.[month]< nxt_rfrd_date or nxt_rfrd_date is null)
		join prm_cnty cnty on cnty.match_code=curr.intake_county_cd
    where exists(select * from  base.tbl_household_children chld 
								where  chld.id_intake_fact=curr.id_intake_fact 
								and IIF(day([month]) < day(chld.dt_birth) and chld.[dt_birth]<[month]
												, datediff(mm,chld.dt_birth,[month]) - 1
												,datediff(mm,chld.dt_birth,[month])) < (18*12))
	 group by [month],curr.cps_hh_nth_order,cnty.cd_cnty
	order by  cnty.cd_cnty,[month],curr.cps_hh_nth_order


	

alter table prtl.rate_referrals_order_specific NOCHECK CONSTRAINT ALL
truncate table prtl.rate_referrals_order_specific
insert into prtl.rate_referrals_order_specific(nth_order,[start_date],date_type,qry_type,county_cd,cnt_referrals,prior_order_cnt_households,referral_rate)
select distinct
			 n.nth_order "nth_order"
			,mnth.[MONTH] [start_date]
			,0 date_type
			,2 qry_type 
			,refC.county_cd  county_cd
			,isnull(cnt_referrals,0)  "nth_order_cnt_referrals"
			,isnull(IIF(n.nth_order>1,h.cnt_households,pop.tot_pop),0)   "prior_order_cnt_households"
			,IIF(n.nth_order>1
						,iif(h.cnt_households is null,null,cnt_referrals /(h.cnt_households*1.0000))
						,cnt_referrals/(pop.tot_pop*1.0000)
						) * 1000 "referral_rate"
from  (select distinct [month] from calendar_dim 
				where calendar_date between '2004-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
				) mnth
 join ref_lookup_county refC on refC.county_cd between 0 and 39
 join (select number nth_order from numbers ) n on n.nth_order between 1 and 2
 left join (
 					select cps.cps_hh_nth_order  "nth_order"
						,cohort_entry_date cohort_date
						,cnty.cd_cnty
						,date_type
						,qry_type
						,count(distinct cps.intake_grouper) cnt_referrals
					from  #referrals cps 
					join prm_cnty cnty on cps.intake_county_cd=cnty.match_code
					group by cps.cps_hh_nth_order
						,cohort_entry_date 
						,cnty.cd_cnty
						,date_type
						,qry_type
			) cps on cps.cohort_date=mnth.MONTH
			and cps.nth_order=n.nth_order
			and cps.cd_cnty=refC.county_cd
 left join #households h on h.MONTH=mnth.month 
			and refC.county_cd=h.county_cd and  h.cps_hh_nth_order =n.nth_order-1
left join (select measurement_year,county_cd,sum(pop_cnt) tot_pop
							from public_data.census_population_household where cd_race<9
							group by measurement_year,county_cd
							union all
							select measurement_year,0,sum(pop_cnt) tot_pop
							from public_data.census_population_household where cd_race<9
							group by measurement_year
						) pop on measurement_year=year(cps.cohort_date) and pop.county_cd=cps.cd_cnty
--where year(mnth.MONTH)=2010 and refc.county_cd=0
order by refC.county_cd,mnth.[MONTH],n.nth_order
		






--  