-- exec prtl.[prod_build_rate_placement_order_specific]

CREATE procedure prtl.[prod_build_rate_placement_order_specific]
as

/**
R0 is defined as follows:
Numerator:  Households with at least 1 removal this month with no children already in episode this month
and there are 0 prior removals ever
Denomintaor: Referrals this month that are screened-in where the household has 0 prior removals ever

R1 is defined as follows:
Numerator:  Households with at least 1 removal this month with no children already in episode this month
and there are 1 prior removals ever
Denomintaor: Referrals this month that are screened-in where the household has 1 prior removals ever

R2 is defined as follows:
Numerator:  Households with at least 1 removal this month with no children already in episode this month
and there are 2 prior removals ever
Denomintaor: Referrals this month that are screened-in where the household has 2 prior removals ever
**/
		if OBJECT_ID('tempDB..#scrn_in') is not null drop table #scrn_in;
		select distinct 
				  cohort_entry_date
				, intake_grouper
				, grp_id_intake_fact
				, grp_rfrd_date "rfrd_date"
				, id_intake_fact
				, id_case
				, intake_county_cd
				, cd_final_decision
				, DENSE_RANK() over 
					(partition by id_case
							order by 
								grp_rfrd_date
								,intake_grouper asc) nth_order
			,cast(null as datetime) as nxt_rfrd_date
			,cast(null as datetime) as prior_scrn_in_rfrd_date
			,cast(null as int) as running_plcm_cnt
		into #scrn_in
		from [prtl].[vw_referrals_grp] tce
		where  entry_point<>7 --  exclude DLR
		and hh_with_children_under_18=1  --has children under 18
		and cd_final_decision=1  --  screened in
	

		--get next screened in referral
		update ref
		set nxt_rfrd_date=nxt.rfrd_date
		from #scrn_in ref
		join #scrn_in nxt on ref.id_case=nxt.id_case 
		and nxt.nth_order=ref.nth_order+1
	 
		
		-- first set prior screened in for all screened in intakes
		update ref
		set prior_scrn_in_rfrd_date=pri.rfrd_date
		from #scrn_in ref
		join #scrn_in pri on ref.id_case=pri.id_case 
		and pri.nth_order=ref.nth_order-1
		and pri.cd_final_decision=1
		and ref.cd_final_decision=1

	
if OBJECT_ID('tempDB..#cases_intakes_placements') is not null drop table #cases_intakes_placements
-- the id_case from removal & intake are not always an exact match so include them both in placements for matching later
select distinct 0 date_type,2 qry_type
				,intk.grp_id_intake_fact
				,intk.id_intake_fact
				,intk.intake_county_cd
				,intk.id_case
				,q.id_case id_case_removal
				,q.id_removal_episode_fact
				,intk.rfrd_date
				,q.removal_dt
				,q.discharge_dt
				--,q.trh_begin_date
				--,q.trh_end_date
				,DATEFROMPARTS(year(q.removal_dt),month(q.removal_dt),1) cohort_date
				,DENSE_RANK() over (partition by intk.id_case order by q.removal_dt asc) nth_order
into #cases_intakes_placements
from #scrn_in intk
join ref_last_dw_transfer d on d.cutoff_date=d.cutoff_date
join (
			select eps.id_case
				,eps.id_intake_fact
				,eps.id_removal_episode_fact
				,(select top 1 rfrd_date from base.tbl_intakes intk where intk.id_intake_fact=eps.id_intake_fact) rfrd_date
				,eps.removal_dt
				,IIF(eps.discharge_dt> eps.[18bday]
								and eps.[18bday] < cutoff_date
						,eps.[18bday]
						,eps.discharge_dt) discharge_dt
			 from  base.rptPlacement   eps
			 join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
			 --  limit to first removal for a specific  intake
			  join (select intk.id_case,intk.id_intake_fact,min(removal_dt) intk_grp_removal_dt 
								from base.rptPlacement rpt
								join #scrn_in intk on intk.id_intake_fact=rpt.id_intake_fact
								group by intk.id_case,intk.id_intake_fact
								) grp on grp.id_intake_fact=eps.id_intake_fact and grp.intk_grp_removal_dt=eps.removal_dt
			 where eps.id_intake_fact is not null 
				and age_at_removal_mos< (18*12)
				and not exists(select * from  vw_nondcfs_combine_adjacent_segments nd 
							where  nd.id_prsn=eps.child
									and eps.removal_dt between nd.cust_begin and nd.cust_end
									and  eps.discharge_dt between nd.cust_begin and  nd.cust_end) 
				 ) q on q.id_intake_fact=intk.id_intake_fact
	where not exists(--exclude families with a child already in care
								select id_case from base.rptPlacement sic where sic.id_case=q.id_case
									and sic.removal_dt < DATEFROMPARTS(year(q.removal_dt),month(q.removal_dt),1)
									and --discharge date greater than removal date
										 iif(sic.[18bday]<sic.discharge_dt 
													and sic.discharge_dt <=d.cutoff_date , sic.[18bday] ,sic.discharge_dt)> q.removal_dt)


--  select * from #cases_intakes_placements order by id_case,nth_order

-- now update the screened-in intakes that are associated with a placement
update #scrn_in
set running_plcm_cnt=plcm.nth_order
from #cases_intakes_placements plcm 
where plcm.id_intake_fact=#scrn_in.id_intake_fact


--we want to remove intakes where referral date between removal_dt & discharge_dt
delete si 
--select si.*
from #scrn_in  si 
where exists(select * from #cases_intakes_placements si2 where si2.id_case=si.id_case
					and convert(varchar(10),si.rfrd_date,121) between si2.removal_dt and si2.discharge_dt
					and si2.id_intake_fact!=si.id_intake_fact)
and running_plcm_cnt is null

--  select * from #scrn_in where running_plcm_cnt is null order by id_case,nth_order

--next 3 steps need to update because of delete above
		-- update nth order first
		update si
		set si.nth_order=scrn_rev.nth_order_rev
		from #scrn_in si 
		join (select *,	 DENSE_RANK() over 
							(partition by id_case
									order by 
										rfrd_date
										,intake_grouper asc) nth_order_rev
			from #scrn_in) scrn_rev on scrn_rev.id_intake_fact=si.id_intake_fact

		--Update  next screened in referral
		update ref
		set nxt_rfrd_date=nxt.rfrd_date
		from #scrn_in ref
		join #scrn_in nxt on ref.id_case=nxt.id_case 
		and nxt.nth_order=ref.nth_order+1
	 
		
		--update prior screened in for all screened in intakes
		update ref
		set prior_scrn_in_rfrd_date=pri.rfrd_date
		from #scrn_in ref
		join #scrn_in pri on ref.id_case=pri.id_case 
		and pri.nth_order=ref.nth_order-1
		and pri.cd_final_decision=1
		and ref.cd_final_decision=1

-- update running_plcm_cnt
/** example of data to this point for one case
cohort_entry_date	rfrd_date	nth_order	nxt_rfrd_date	prior_scrn_in_rfrd_date	running_plcm_cnt
2003-08-01 	2003-08-01 17:00:00.000	1	2003-08-13 11:01:00.000	NULL	NULL
2003-08-01 	2003-08-13 11:01:00.000	2	2003-09-11 11:30:00.000	2003-08-01 17:00:00.000	NULL
2003-09-01 	2003-09-11 11:30:00.000	3	2006-12-14 11:17:00.000	2003-08-13 11:01:00.000	1
2006-12-01 	2006-12-14 11:17:00.000	4	2007-06-25 09:49:00.000	2003-09-11 11:30:00.000	NULL
2007-06-01 	2007-06-25 09:49:00.000	5	2009-12-07 15:13:00.000	2006-12-14 11:17:00.000	2
2009-12-01 	2009-12-07 15:13:00.000	6	2014-03-21 17:12:00.000	2007-06-25 09:49:00.000	NULL
2014-03-01 	2014-03-21 17:12:00.000	7	2014-04-03 17:09:00.000	2009-12-07 15:13:00.000	NULL
2014-04-01 	2014-04-03 17:09:00.000	8	2014-05-28 15:20:00.000	2014-03-21 17:12:00.000	NULL
2014-05-01 	2014-05-28 15:20:00.000	9	2014-07-18 15:12:00.000	2014-04-03 17:09:00.000	NULL
2014-07-01 	2014-07-18 15:12:00.000	10	NULL	2014-05-28 15:20:00.000	NULL
**/
-- here we are filling in the "running" placement count of the NEXT referral date if it did  NOT result in a placement
set nocount off
declare @rowcount int=1
while @rowcount > 0
begin
		update nxt
		set running_plcm_cnt=curr.running_plcm_cnt
		from #scrn_in curr
		join #scrn_in nxt on nxt.id_case=curr.id_case
		and nxt.nth_order=curr.nth_order + 1
		where curr.running_plcm_cnt is not null
		and nxt.running_plcm_cnt is null;
		set @rowcount=@@ROWCOUNT
end

/**  example if data to this point  for particular case
Case A
rfrd_date	nth_order	running_plcm_cnt
2005-05-31 12:10:00.000	1	NULL
2006-02-28 16:32:00.000	2	1
2006-03-09 15:55:00.000	3	1
2006-04-13 11:00:00.000	4	1
2006-05-31 10:26:00.000	5	1

Case B
rfrd_date	nth_order	running_plcm_cnt
2009-03-18 22:23:00.000	1	NULL
2011-07-12 10:37:00.000	2	NULL
2011-09-04 17:53:00.000	3	NULL
2011-11-04 13:49:00.000	4	NULL
2012-04-24 20:09:00.000	5	NULL
2013-03-08 19:13:00.000	6	NULL
2013-05-19 19:40:00.000	7	NULL
2013-05-26 10:40:00.000	8	NULL
2013-08-29 10:02:00.000	9	NULL
2013-10-26 13:34:00.000	10	NULL
2014-01-12 23:15:00.000	11	NULL
2014-02-24 12:46:00.000	12	NULL
**/
--update remaining to 0's .. these are referrals that never resulted in a placement
--  OR  referrals occurring prior to the referral that triggered the  first placement 
update  #scrn_in 
set running_plcm_cnt=0
where running_plcm_cnt is null;

alter table prtl.rate_placement_order_specific NOCHECK constraint ALL;
truncate table prtl.rate_placement_order_specific;
insert into prtl.rate_placement_order_specific(date_type,qry_type,cohort_date,county_cd,nth_order,cnt_nth_order_placement_cases,cnt_prior_order_si_referrals,placement_rate)
select  0 date_type,2 qry_type,mnth.[MONTH] [start_date],refC.county_cd,n.nth_order
		,coalesce(plc.cnt_hh_w_plcm,0) cnt_hh_w_plcm
		,coalesce(cnt_referrals,0) cnt_referrals
		,iif(cnt_referrals>0,cnt_hh_w_plcm/(cnt_referrals*1.0000) * 1000,null) rate
from    (select distinct [month] from calendar_dim 
				where calendar_date between '2004-01-01' and (select dateadd(m,-1,(select cutoff_date from ref_last_dw_transfer)))
				) mnth
 join ref_lookup_county refC on refC.county_cd between 0 and 39
 join (select number nth_order from numbers ) n on n.nth_order between 1 and 3
left  join ( -- this is the numerator count of households with nth order placement
 		select cohort_date,cnty.cd_cnty county_cd
		,count(distinct id_case)   cnt_hh_w_plcm
		,nth_order
		from #cases_intakes_placements 
		join prm_cnty cnty on cnty.match_code=intake_county_cd
		group by cohort_date,cnty.cd_cnty,nth_order
		) plc on plc.cohort_date=mnth.[MONTH]
		and plc.county_cd=refC.county_cd
		and plc.nth_order=n.nth_order
left join  (-- this is the denominator 
		select  cohort_entry_date cohort_date,cnty.cd_cnty county_cd,count(distinct intake_grouper) cnt_referrals
		,n.nth_order
		from #scrn_in si
		join prm_cnty cnty on cnty.match_code=si.intake_county_cd
		 join (select number nth_order from numbers ) n on n.nth_order between 1 and 3
		 -- all screened in referrals this month  from households with an n-1 placement order
		 -- OR any screened in referrals from households resulting in a "nth order" placement and the intake has to be an nth order screened in intake
		where (si.running_plcm_cnt=n.nth_order-1 
			  or (si.running_plcm_cnt=n.nth_order and si.nth_order=n.nth_order))
			group by cohort_entry_date ,cnty.cd_cnty,n.nth_order
			) intk on intk.cohort_date=mnth.[MONTH]
		and intk.county_cd=refC.county_cd
		and intk.nth_order=n.nth_order
		order by refC.county_cd,start_date,nth_order

alter table prtl.rate_placement_order_specific CHECK constraint ALL;




	