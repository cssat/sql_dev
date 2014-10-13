----  exec prtl.prod_build_rate_referrals_screened_in_order_specific

alter procedure prtl.prod_build_rate_referrals_screened_in_order_specific
as


-- this table is for all cps intakes

		if OBJECT_ID('tempDB..#ref') is not null drop table #ref;
		select distinct 
				  cohort_entry_date
				, intake_grouper
				, grp_id_intake_fact
				, grp_rfrd_date "rfrd_date"
				, id_intake_fact
				, id_case
				, intake_county_cd
				, cd_final_decision
				, IIF(cd_final_decision=1,DENSE_RANK() over 
					(partition by id_case,cd_final_decision
							order by 
								grp_rfrd_date
								,intake_grouper asc) ,null)  nth_order
				, DENSE_RANK() over 
					(partition by id_case
							order by 
								grp_rfrd_date
								,intake_grouper asc) referral_order
			,cast(null as datetime) as nxt_rfrd_date
			,cast(null as datetime) as prior_scrn_in_rfrd_date
		into #ref
		from [prtl].[vw_referrals_grp] tce
		where  tce.entry_point!=7
		and hh_with_children_under_18=1  

	

		--get next screened in referral
		update ref
		set nxt_rfrd_date=nxt.rfrd_date
		from #ref ref
		join #ref nxt on ref.id_case=nxt.id_case 
		and nxt.referral_order=ref.referral_order+1
	 
		
		-- first set prior screened in for all screened in intakes
		update ref
		set prior_scrn_in_rfrd_date=pri.rfrd_date
		from #ref ref
		join #ref pri on ref.id_case=pri.id_case 
		and pri.nth_order=ref.nth_order-1
		and pri.cd_final_decision=1
		and ref.cd_final_decision=1
		
		--set NEXT referrals for those where the prior referral is screened in and next referral is NOT screened in
		update nxt
		set nth_order=ref.nth_order
				,prior_scrn_in_rfrd_date=iif(nxt.prior_scrn_in_rfrd_date is null,ref.rfrd_date,nxt.prior_scrn_in_rfrd_date)
		from #ref ref
		join #ref nxt on ref.id_case=nxt.id_case 
		and nxt.referral_order=ref.referral_order+1
		where nxt.nth_order is null
		and ref.cd_final_decision=1 and nxt.cd_final_decision=0;

		-- now update those referrals where the prior referral is not screened in (but it has a prior screened in from preceding step)
		set nocount off;
		declare @rowcount int=1
		while @rowcount>0
		begin
			update nxt
			set nth_order=ref.nth_order,prior_scrn_in_rfrd_date=iif(nxt.prior_scrn_in_rfrd_date is null,ref.prior_scrn_in_rfrd_date,nxt.prior_scrn_in_rfrd_date)
		--	select ref.id_case,ref.rfrd_date,ref.nth_order,ref.prior_scrn_in_rfrd_date,nxt.rfrd_date
			from #ref ref
			join #ref nxt on ref.id_case=nxt.id_case 
			and nxt.referral_order=ref.referral_order+1
			where nxt.nth_order is null
			and ref.nth_order is not null
			and ref.cd_final_decision=0 and nxt.cd_final_decision=0;
			set @rowcount=@@ROWCOUNT;
		end

		--set remaining to 0
		update ref
		set nth_order=0
		from #ref ref
		where ref.nth_order is null
		and ref.cd_final_decision=0 ;

		--	select count(distinct intake_grouper) from #ref where cohort_entry_date='2010-03-01'
			--denominator
	-- this table is the "AT RISK of NTH ORDER"  aggregate Screened-in Referrals
-- the intakes included here are from households that  have N-1 SCREENED IN Referrals
--check to be sure the kids are still under 18 and at risk and they must have a referral in this month

		if OBJECT_ID('tempDB..#priorOrder') is not null drop table #priorOrder;
	--		insert 	into #priorOrder  			 --- has exactly "n" prior screened in intakes
			select [month]
					,cnty.cd_cnty county_cd
					,count(distinct curr.intake_grouper) cnt_referrals
					,n.nth_order
			INTO #priorOrder
			from 	 #ref   curr 
			join (select distinct [month] from calendar_dim 
					where calendar_date between '2000-01-01' 
								and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
					) mnth  on mnth.[month]=curr.cohort_entry_date 
				join (select 1 nth_order union select 2  union select 3 union select 4) n 
				on ((n.nth_order=curr.nth_order   and curr.cd_final_decision=1)
							or (n.nth_order = curr.nth_order+1 and curr.cd_final_decision=0 ))
			join prm_cnty cnty on cnty.match_code=curr.intake_county_cd
			group by 	[month],cnty.cd_cnty,n.nth_order

/**  QA
		select * from #ref ref join (
						select intake_grouper from #ref where prior_scrn_in_rfrd_date is null
			and  cohort_entry_date='2010-01-01' 

		except
			  select intake_grouper
		 from #ref  where cohort_entry_date='2010-01-01' 
		and  ( (nth_order=0 and cd_final_decision=0)
		or (nth_order=1 and cd_final_decision=1 ))
		) q on q.intake_grouper=ref.intake_grouper
		where cohort_entry_date='2010-01-01'  

		select * from #ref where id_case= and cohort_entry_date<='2010-01-01'  order by rfrd_date 

		select count(distinct intake_grouper)
		 from #ref  where cohort_entry_date='2010-01-01' 
		 and prior_scrn_in_rfrd_date is null
			
	 select count(distinct intake_grouper) from #ref where cohort_entry_date='2010-01-01' 
	 SELECT *   from #priorOrder where county_cd=0 and month='2010-01-01'  order by nth_order
	 **/
	

		--this is the count by  "Nth" order screened in referral...
			if OBJECT_ID('tempDB..#referrals') is not null drop table #referrals;
			select   0 date_type
						, 2 qry_type
						, scrn.cohort_entry_date "cohort_date"
						, scrn.nth_order
						, cnty.cd_cnty county_cd
						, count(distinct scrn.intake_grouper)  cnt_referrals
			into #referrals
			from #ref scrn
			join prm_cnty cnty on cnty.match_code=scrn.intake_county_cd
			where scrn.cd_final_decision=1
			group by scrn.cohort_entry_date,scrn.nth_order,cnty.cd_cnty

--			select * from #referrals order by county_cd,cohort_date,nth_order
--select * from #priorOrder order by county_cd,MONTH,nth_order


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
			,coalesce(pO.cnt_referrals,0)    "prior_order_cnt_referrals"
			,IIF(coalesce(pO.cnt_referrals,0) >0
									,nth_order.cnt_referrals /
									((coalesce(pO.cnt_referrals,0)) *1.0000)
						,null) * 1000 "referral_rate"
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
--where refC.county_cd=0 and year(mnth.[MONTH])=2010
order by refC.county_cd, mnth.[MONTH],"nth_order"
		
alter table prtl.rate_referrals_scrn_in_order_specific CHECK CONSTRAINT ALL
-- select *  from prtl.rate_referrals_scrn_in_order_specific

--select * from prtl.rate_referrals_scrn_in_order_specific --where start_date='2013-03-01'   
--order by county_cd,start_date,nth_order


--select * from #ref r
--where exists(select * from #ref r2 where r2.id_case=r.id_case and r2.referral_order=53)
--order by rfrd_date
	