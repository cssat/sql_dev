-- exec prtl.[prod_build_rate_placement_order_specific]

--alter procedure prtl.[prod_build_rate_placement_order_specific]
--as

		if OBJECT_ID('tempDB..#scrn_in') is not null drop table #scrn_in;
		select  
				  cohort_entry_date
				, intake_grouper
				, grp_id_intake_fact
				, grp_rfrd_date "rfrd_date"
				, id_case
				, intake_county_cd
				, id_intake_fact
				, DENSE_RANK() over 
					(partition by id_case
							order by 
								grp_rfrd_date
								,intake_grouper asc) nth_order
		into #scrn_in
		from [prtl].[vw_referrals_grp] tce
		where  tce.cd_access_type in (1,4) and fl_dlr=0
		and hh_with_children_under_18=1  and cd_final_decision=1

if OBJECT_ID('tempDB..#cases_intakes_placements') is not null drop table #cases_intakes_placements
select distinct 0 date_type,2 qry_type
				,intk.grp_id_intake_fact
				,intk.id_intake_fact
				,intk.intake_county_cd
				,intk.id_case
				,q.id_case id_case_removal
				,q.id_removal_episode_fact
				,intk.rfrd_date
				,q.removal_dt
				,q.federal_discharge_date
				,q.trh_begin_date
				,q.trh_end_date
				,DATEFROMPARTS(year(q.removal_dt),month(q.removal_dt),1) cohort_date
				,DENSE_RANK() over (partition by q.id_case order by q.removal_dt asc) nth_order
into #cases_intakes_placements
from #scrn_in intk
 join (
	select eps.id_case
		,id_intake_fact
		,eps.id_removal_episode_fact
		,(select top 1 rfrd_date from base.tbl_intakes intk where intk.id_intake_fact=eps.id_intake_fact) rfrd_date
		,eps.removal_dt
		,IIF(eps.discharge_dt>dateadd(yy,18,eps.birthdate) 
						and dateadd(yy,18,eps.birthdate)  < cutoff_date
				,dateadd(yy,18,eps.birthdate) 
				,eps.discharge_dt) federal_discharge_date
				,trh.trh_begin_date
				,trh.trh_end_date
	 from  base.rptPlacement   eps
	 join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
	 left join trial_return_home_placement_spans trh on trh.id_removal_episode_fact=eps.id_removal_episode_fact
	 where id_intake_fact is not null 
		and age_at_removal_mos< (18*12)
		and not exists(select * from  vw_nondcfs_combine_adjacent_segments nd 
					where  nd.id_prsn=eps.child
							and eps.removal_dt between nd.cust_begin and nd.cust_end
							and  eps.discharge_dt between nd.cust_begin and  nd.cust_end) 
		 ) q on q.id_intake_fact=intk.id_intake_fact

-- select * from #cases_intakes_placements order by id_case_removal,nth_order

select count(*) from base.rptPlacement eps where id_intake_fact is not null 
and  age_at_removal_mos< (18*12)
and not exists(select * from  vw_nondcfs_combine_adjacent_segments nd 
					where  nd.id_prsn=eps.child 
							and eps.removal_dt between nd.cust_begin and nd.cust_end
							and  eps.discharge_dt between nd.cust_begin and  nd.cust_end) 

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
from  (select distinct [Month] cohort_date from Calendar_dim ,ref_last_dw_transfer
			where [Month] between '2000-01-01' and dateadd(mm,-1,cutoff_date)) mnth
join ref_lookup_county cnty on cnty.county_cd between 0 and 39
join numbers nth_order on nth_order.number between 1 and 5

	where mnth.cohort_date >='2004-01-01'
order by cnty.county_cd,number,mnth.cohort_date


