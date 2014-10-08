----    exec prtl.prod_build_rate_referrals_order_specific

alter procedure prtl.prod_build_rate_referrals_order_specific
as

	if OBJECT_ID('tempDB..#referrals') is not null drop table #referrals;
	select tce.* 
			,DENSE_RANK() over (partition by id_case
							order by 
								grp_rfrd_date
								,intake_grouper asc) nth_order
			,cast(null as datetime)  nxt_rfrd_date
	into #referrals
	from [prtl].[vw_referrals_grp] tce
	where  tce.entry_point!=7
	and hh_with_children_under_18=1 

	-- get next cps referral
	update ref
	set nxt_rfrd_date=nxt.rfrd_date
	from #referrals ref
	join #referrals nxt on ref.id_case=nxt.id_case and nxt.nth_order=ref.nth_order+1

	--select count(*) from #referrals where cd_final_decision=1 541793

	CREATE NONCLUSTERED INDEX idx_start_date_nxt_rfrd_date_id_case_nth_order_scrn
	ON #referrals (cohort_entry_date,[nxt_rfrd_date])
	INCLUDE ([id_case],[nth_order])


--- get nth order At Risk households
	if OBJECT_ID('tempDB..#nthOrderAtRiskHH') is not null drop table #nthOrderAtRiskHH;
	select [month],n.nth_order,cnty.cd_cnty county_cd,count(distinct curr.id_case) cnt_households
	into #nthOrderAtRiskHH
from 	 #referrals   curr 
	join (select number nth_order from numbers) n on n.nth_order in (1,2,3)
				and curr.nth_order=n.nth_order-1
	join (select distinct [month] from calendar_dim 
			where calendar_date between '2000-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
			) mnth
			on mnth.[month]>=curr.cohort_entry_date 
				and (mnth.[month]<= cast(convert(varchar(10),nxt_rfrd_date,121) as datetime)
											or nxt_rfrd_date is null)
	join prm_cnty cnty on cnty.match_code=curr.intake_county_cd
    where exists(select intake_grouper from  base.tbl_household_children chld 
								where  chld.id_intake_fact=curr.id_intake_fact 
								and IIF(day([month]) < day(chld.dt_birth) and chld.[dt_birth]<[month]
												, datediff(mm,chld.dt_birth,[month]) - 1
												,datediff(mm,chld.dt_birth,[month])) < (18*12))
		--exclude households that have an nth order prior to month
		and not exists(select * from #referrals nRef
				where nRef.id_case=curr.id_case
				and nRef.cohort_entry_date<curr.cohort_entry_date
				and nRef.nth_order>curr.nth_order)
	 group by [month],n.nth_order,cnty.cd_cnty
	order by  cnty.cd_cnty,[month],n.nth_order

--	select * from #nthOrderAtRiskHH order by county_cd,month,nth_order
	

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
 join (select number nth_order from numbers ) n on n.nth_order between 1 and 3
 left join (
 					select cps.nth_order  "nth_order"
						,cohort_entry_date cohort_date
						,cnty.cd_cnty
						,date_type
						,qry_type
						,count(distinct cps.intake_grouper) cnt_referrals
					from  #referrals cps 
					join prm_cnty cnty on cps.intake_county_cd=cnty.match_code
					group by cps.nth_order
						,cohort_entry_date 
						,cnty.cd_cnty
						,date_type
						,qry_type
			) cps on cps.cohort_date=mnth.MONTH
			and cps.nth_order=n.nth_order
			and cps.cd_cnty=refC.county_cd
 left join #nthOrderAtRiskHH h on h.MONTH=mnth.month 
			and refC.county_cd=h.county_cd and  h.nth_order =n.nth_order
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
		

--select * from prtl.rate_referrals_order_specific order by county_cd,start_date,nth_order

