----  exec prtl.prod_build_rate_referrals_screened_in_order_specific

alter procedure prtl.prod_build_rate_referrals_screened_in_order_specific
as



		if OBJECT_ID('tempDB..#scrn_in') is not null drop table #scrn_in;
		select distinct 
				  cohort_entry_date
				, intake_grouper
				, grp_id_intake_fact
				, grp_rfrd_date "rfrd_date"
				, id_case
				, intake_county_cd
				, DENSE_RANK() over 
					(partition by id_case
							order by 
								grp_rfrd_date
								,intake_grouper asc) nth_order
		into #scrn_in
		from [prtl].[vw_referrals_grp] tce
		where  tce.cd_access_type in (1,4) and fl_dlr=0
		and hh_with_children_under_18=1  and cd_final_decision=1


		if OBJECT_ID('tempDB..#no_scrn_in_ever') is not null drop table #no_scrn_in_ever;
		select distinct 
				  cohort_entry_date
				, intake_grouper
				, grp_id_intake_fact
				, id_intake_fact
				, grp_rfrd_date "rfrd_date"
				, tce.id_case
				, intake_county_cd
		into #no_scrn_in_ever
		from [prtl].[vw_referrals_grp] tce
		join (select si.id_case,min(rfrd_date) min_rfrd_date from  #scrn_in si group by si.id_case) si  on si.id_case=tce.id_case and tce.rfrd_date<si.min_rfrd_date
		where  tce.cd_access_type in (1,4) and fl_dlr=0
		and hh_with_children_under_18=1  
		and cd_final_decision<>1
		

			
		-- select * from #scrn_in order by id_case,rfrd_date
		CREATE NONCLUSTERED INDEX idx_scrn_in2
		ON #scrn_in ([intake_county_cd])
		INCLUDE ([cohort_entry_date],[intake_grouper],[id_case],[nth_order])


			if OBJECT_ID('tempDB..#referrals') is not null drop table #referrals;
			select   0 date_type
						, 2 qry_type
						, ns.cohort_entry_date "cohort_date"
						, ns.nth_order
						, cnty.cd_cnty county_cd
						, count(distinct ns.intake_grouper)  cnt_referrals
						, (select count(distinct priorS.intake_grouper) 
							from #scrn_in priorS 
									left join prm_cnty cntyP on cntyP.match_code=priorS.intake_county_cd and cnty.cd_cnty=cntyP.cd_cnty
									where priorS.nth_order=ns.nth_order-1
									and priorS.cohort_entry_date<=ns.cohort_entry_date							
			)  [prior_order_cnt_referrals]
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
						,coalesce(prior_order_cnt_referrals,0) 
					,noPrior.cnt_referrals)
					,0)   "prior_order_cnt_referrals"
			,IIF(n.nth_order>1
						,IIF(coalesce(nth_order.prior_order_cnt_referrals,0) >0
									,nth_order.cnt_referrals /
									((coalesce(nth_order.prior_order_cnt_referrals,0)) *1.0000)
						,null)
						,IIF(noPrior.cnt_referrals>0,nth_order.cnt_referrals/(noPrior.cnt_referrals *1.0000),null)
						) * 1000 "referral_rate"
from    (select distinct [month] from calendar_dim 
				where calendar_date between '2004-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
				) mnth
 join ref_lookup_county refC on refC.county_cd between 0 and 39
 join (select number nth_order from numbers ) n on n.nth_order between 1 and 3
left join #referrals nth_order  on nth_order.nth_order=n.nth_order
			and refc.county_cd=nth_order.county_cd
			and nth_order.cohort_date=mnth.[MONTH]
--left join prtl.rate_referrals_order_specific ref 
--			on ref.start_date=mnth.[MONTH] and  ref.county_cd=refC.county_cd 
--			and ref.nth_order=1 
left join (	
		select mnth.[MONTH],cnty.cd_cnty county_cd
		,count(distinct intake_grouper)  cnt_referrals
		from  (select distinct [month] from calendar_dim 
				--where calendar_date between '2004-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
				) mnth
		join #no_scrn_in_ever noscrn on noscrn.cohort_entry_date<=mnth.[MONTH]
		join prm_cnty cnty on cnty.match_code=noscrn.intake_county_cd
		group by mnth.[MONTH],cnty.cd_cnty  
		order by cnty.cd_cnty  ,mnth.[MONTH]
		) noPrior on noPrior.[MONTH]=mnth.[MONTH]
				and noPrior.county_cd=refC.county_cd
		order by refC.county_cd, mnth.[MONTH],"nth_order"
		
alter table prtl.rate_referrals_scrn_in_order_specific CHECK CONSTRAINT ALL
-- select *  from prtl.rate_referrals_scrn_in_order_specific

select * from prtl.rate_referrals_scrn_in_order_specific order by county_cd,start_date,nth_order

