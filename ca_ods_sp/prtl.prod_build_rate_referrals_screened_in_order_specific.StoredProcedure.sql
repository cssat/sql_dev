----  exec prtl.prod_build_rate_referrals_screened_in_order_specific

alter procedure prtl.prod_build_rate_referrals_screened_in_order_specific
as


-- this table is for all screened in cps intakes
		if OBJECT_ID('tempDB..#scrn_in') is not null drop table #scrn_in;
		select distinct 
				  cohort_entry_date
				, intake_grouper
				, grp_id_intake_fact
				, grp_rfrd_date "rfrd_date"
				, id_intake_fact
				, id_case
				, intake_county_cd
				, DENSE_RANK() over 
					(partition by id_case
							order by 
								grp_rfrd_date
								,intake_grouper asc) nth_order
			,cast(null as datetime) as nxt_rfrd_date
		into #scrn_in
		from [prtl].[vw_referrals_grp] tce
		where  tce.cd_access_type in (1,4) and fl_dlr=0
		and hh_with_children_under_18=1  and cd_final_decision=1
		--and id_case in (542445,276882,1419411,625877,380510,478562,1160180)
		--and year(cohort_entry_date)=2010 

		--get next screened in referral.... LOH 
		update SC
		set nxt_rfrd_date=nxt.rfrd_date
		from #scrn_in SC
		join #scrn_in nxt on sc.id_case=nxt.id_case and nxt.nth_order=sc.nth_order+1

-- this table is the "AT RISK of NTH ORDER"  aggregate Screened-in Referrals
-- the intakes included here are from households that  have N-1 SCREENED IN Referrals
--check to be sure the kids are still under 18 and at risk

	if OBJECT_ID('tempDB..#priorOrder') is not null drop table #priorOrder;
	select [month]
			,n.nth_order
			,cnty.cd_cnty county_cd
			,count(distinct curr.intake_grouper) cnt_referrals
	into #priorOrder
	from 	 #scrn_in   curr 
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
		and not exists(select * from #scrn_in scr
				where scr.id_case=curr.id_case
				and scr.cohort_entry_date<curr.cohort_entry_date
				and scr.nth_order>curr.nth_order)
	 group by [month],n.nth_order,cnty.cd_cnty
	order by  cnty.cd_cnty,[month],n.nth_order
	

	-- these are referrals for cases that will be at risk for 1st order screened-in  referrals.
		-- they have no PRIOR screened in referral
		if OBJECT_ID('tempDB..#no_scrn_in_ever') is not null drop table #no_scrn_in_ever;
		select  
				 cohort_entry_date
				, ( intake_grouper) 
				,id_intake_fact
				, tce.id_case
				, cnty.cd_cnty county_cd
				, si.min_rfrd_date [frst_screened_in_referral]
		into #no_scrn_in_ever
		from [prtl].[vw_referrals_grp] tce
		left join (select si.id_case,min(rfrd_date) min_rfrd_date 
					from  #scrn_in si 
					group by si.id_case) si  on si.id_case=tce.id_case 
		join prm_cnty cnty on cnty.match_code=tce.intake_county_cd
		where  tce.cd_access_type in (1,4) and fl_dlr=0
		and hh_with_children_under_18=1  
		and cd_final_decision!=1
		and (si.id_case is null or tce.rfrd_date<si.min_rfrd_date)
-- aggregate table for all months,aggregate counts
--  for cases still at  risk  for FIRST screened-in referral
	if OBJECT_ID('tempDB..#noScrn') is not null drop table #noScrn;
	select [month]
			, county_cd
			,count(distinct curr.intake_grouper) cnt_referrals
	into #noScrn
	from 	 #no_scrn_in_ever   curr 
		join (select distinct [month] from calendar_dim 
				where calendar_date between '2000-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
				) mnth
				on mnth.[month]>=curr.cohort_entry_date 
					and (mnth.[month]<= cast(convert(varchar(10),frst_screened_in_referral,121) as datetime)
											 or frst_screened_in_referral is null)
    where exists(select intake_grouper from  base.tbl_household_children chld 
								where  chld.id_intake_fact=curr.id_intake_fact 
								and IIF(day([month]) < day(chld.dt_birth) and chld.[dt_birth]<[month]
												, datediff(mm,chld.dt_birth,[month]) - 1
												,datediff(mm,chld.dt_birth,[month])) < (18*12))
	 group by [month],county_cd
	order by  county_cd,[month]


		CREATE NONCLUSTERED INDEX idx_scrn_in2
		ON #scrn_in ([intake_county_cd])
		INCLUDE ([cohort_entry_date],[intake_grouper],[id_case],[nth_order])

		--this is the count by  "Nth" order screened in referral...
			if OBJECT_ID('tempDB..#referrals') is not null drop table #referrals;
			select   0 date_type
						, 2 qry_type
						, ns.cohort_entry_date "cohort_date"
						, ns.nth_order
						, cnty.cd_cnty county_cd
						, count(distinct ns.intake_grouper)  cnt_referrals
			into #referrals
			from #scrn_in ns
			join prm_cnty cnty on cnty.match_code=ns.intake_county_cd
			group by ns.cohort_entry_date,ns.nth_order,cnty.cd_cnty

--			select * from #referrals order by county_cd,cohort_date,nth_order



alter table prtl.rate_referrals_scrn_in_order_specific NOCHECK CONSTRAINT ALL
truncate table prtl.rate_referrals_scrn_in_order_specific
insert into prtl.rate_referrals_scrn_in_order_specific
(nth_order,start_date,date_type,qry_type,county_cd
	,cnt_referrals,prior_order_referrals,referral_rate)
select  n.nth_order "nth_order"
			, mnth.[MONTH] "Date"
			,0 date_type
			,2 qry_type 
			,refC.county_cd
			,coalesce(nth_order.cnt_referrals,0)  "cnt_referrals"
			,coalesce(
				IIF(n.nth_order>1
						,coalesce(pO.cnt_referrals,0) 
					,noscrn.cnt_referrals)
					,0)   "prior_order_cnt_referrals"
			,IIF(n.nth_order>1
						,IIF(coalesce(pO.cnt_referrals,0) >0
									,nth_order.cnt_referrals /
									((coalesce(pO.cnt_referrals,0)) *1.0000)
						,null)
						,IIF(noscrn.cnt_referrals>0,nth_order.cnt_referrals/(noscrn.cnt_referrals *1.0000),null)
						) * 1000 "referral_rate"
from    (select distinct [month] from calendar_dim 
				where calendar_date between '2004-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
				) mnth
 join ref_lookup_county refC on refC.county_cd between 0 and 39
 join (select number nth_order from numbers ) n on n.nth_order between 1 and 3
left join #priorOrder pO on pO.MONTH=mnth.MONTH
	and pO.county_cd=refc.county_cd
	and po.nth_order=n.nth_order
left join #referrals nth_order  on nth_order.nth_order=n.nth_order
			and refc.county_cd=nth_order.county_cd
			and nth_order.cohort_date=mnth.[MONTH]
left join #noScrn noScrn on noScrn.[MONTH]=mnth.[MONTH]
and noscrn.county_cd=refC.county_cd
--where refC.county_cd=0 and year(mnth.[MONTH])=2010
order by refC.county_cd, mnth.[MONTH],"nth_order"
		
alter table prtl.rate_referrals_scrn_in_order_specific CHECK CONSTRAINT ALL
-- select *  from prtl.rate_referrals_scrn_in_order_specific

select * from prtl.rate_referrals_scrn_in_order_specific order by county_cd,start_date,nth_order

