--  exec prtl.prod_build_rate_placement 

alter procedure prtl.prod_build_rate_placement 
as

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
		where  fl_dlr=0
		and hh_with_children_under_18=1  
		and cd_final_decision=1
	

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

		--select * From #ref order by id_case,rfrd_date
		
		
alter table prtl.rate_placement  NOCHECK CONSTRAINT ALL;

truncate table prtl.rate_placement
insert into prtl.rate_placement(date_type,qry_type,cohort_date,county_cd,cnt_households_w_plcm,cnt_referrals_u18,rate_placement)
select  0 "date_type"
			, 2 "qry_type"
			, mnth.start_date
			, lu_cnty.county_cd
			,  coalesce(cnt_hh_plcm ,0)cnt_hh_plcm
			, coalesce(intk.cnt_referrals,0) cnt_ref
			, IIF(intk.cnt_referrals>0, cnt_hh_plcm/(intk.cnt_referrals*1.0000) * 1000 ,null) "placement_rate"
from (select distinct [Month] start_date from Calendar_dim ,ref_last_dw_transfer where [Month] between '2000-01-01' and dateadd(mm,-1,cutoff_date)) mnth
join ref_lookup_county lu_cnty on lu_cnty.county_cd between 0 and 39
left join (
				select distinct 0 "date_type",2 "qry_type",[month] start_date
						,count(distinct id_case) cnt_hh_plcm
						,cnty.cd_cnty   "county_cd"
				From  base.rptPlacement plc
						join prm_cnty cnty on cnty.match_code=plc.removal_county_cd
						join calendar_dim cd on cd.CALENDAR_DATE=plc.removal_dt
						join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
				where cd.MONTH>='2000-01-01'  and IIF(day([month]) < day(plc.birthdate) and plc.birthdate<[month]
												, datediff(mm,plc.birthdate,[month]) - 1
												,datediff(mm,plc.birthdate,[month])) < (18*12)
				-- exclude nondcfs episodes
				and not exists(select * from [dbo].[vw_nondcfs_combine_adjacent_segments]  nd where nd.id_prsn=plc.child
								and removal_dt between nd.cust_begin and nd.cust_end
								and iif([18bday]<discharge_dt and discharge_dt <=cutoff_date , [18bday] ,discharge_dt) between nd.cust_begin and nd.cust_end)
				and not exists(--exclude families with a child already in care
								select id_case from base.rptPlacement sic where sic.id_case=plc.id_case
									and sic.removal_dt < cd.[MONTH] 
									and --discharge date greater than removal date
										 iif(sic.[18bday]<sic.discharge_dt 
													and sic.discharge_dt <=dw.cutoff_date , sic.[18bday] ,sic.discharge_dt)> plc.removal_dt)
					group by cd.MONTH,cnty.cd_cnty
				) plc on plc.start_date=mnth.start_date and plc.county_cd=lu_cnty.county_cd
left join (select   0 date_type
						, 2 qry_type
						, scrn.cohort_entry_date start_date
						, cnty.cd_cnty county_cd
						, count(distinct scrn.intake_grouper)  cnt_referrals
			from #ref scrn
			join prm_cnty cnty on cnty.match_code=scrn.intake_county_cd
			group by scrn.cohort_entry_date,cnty.cd_cnty
			)  intk on intk.start_date=mnth.start_date
												and intk.county_cd=lu_cnty.county_cd
order by lu_cnty.county_cd,mnth.start_date

alter table prtl.rate_placement  CHECK CONSTRAINT ALL;			

--select * from prtl.rate_placement


