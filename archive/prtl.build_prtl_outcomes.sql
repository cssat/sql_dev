USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_outcomes]    Script Date: 11/21/2013 12:17:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [prtl].[prod_build_prtl_outcomes](@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin

	
		declare @start_date datetime
		declare @cutoff_date datetime
		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer	
		declare @date_type int
		set @date_type=2
			
		set @start_date = '2000-01-01'

-------------------------------------------------------------------------------------------------------------------------------------------------------GET SUBSET OF DATA
				if object_ID('tempDB..#eps') is not null drop table #eps
				select  distinct
					  cd.[Year]  as cohort_entry_date
--					, dateadd(dd,-1,dateadd(yy,1,cd.[Year]))  as Cohort_End_Date
					, @date_type as date_type
					, 0 as qry_type
					, tce.[ID_PRSN_CHILD]
					, tce.[ID_REMOVAL_EPISODE_FACT]
					,  max(case 
							--legally free (last placement end reason code)
							when tce.state_discharge_reason_code=27 and xw3.discharge_type is not null then  xw3.discharge_type  
							--force emancipation 18 
							when  xwE.discharge_type is not null 
							and ((tce.federal_discharge_date is not null 
									and tce.federal_discharge_date_force_18 < tce.federal_discharge_date)
								or (tce.federal_discharge_date is null and tce.federal_discharge_date_force_18 is not null))
							  then xwE.discharge_type
							 --state discharge code
							when xws.discharge_type is not null  then  xws.discharge_type
							--federal discharge code
							when xwF.discharge_type is not null then xwF.discharge_type
							----force emancipation 18 if no prior reason exists
							--when xwE.discharge_type is not null then xwE.discharge_type
							-- last placement discharge (last out of home placement(cd_epsd_type=1 from placement table)
							when xwLstPlcmnt.discharge_type is not null then  xwLstPlcmnt.discharge_type
							-- trh discharge
							when xTRH.discharge_type is not null then xTRH.discharge_type
							-- other discharge
							when xOth.discharge_type is not null then xOth.discharge_type
							-- still in care
							else xSC.discharge_type
							end ) as discharge_type
					, cast(null as int) as cd_discharge_type
					, max([First_Removal_Date]) as first_removal_date
					, max(case when tce.[First_Removal_Date]=tce.[State_Custody_Start_Date] then 1 else 0 end )as fl_first_removal
					, max(tce.state_custody_start_date) as state_custody_start_date
					, max(case when  Federal_Discharge_Date_Force_18  is null 
								and tcps.trh_begin_date is not null
								and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,@cutoff_date) >=183))
								then coalesce(tcps.trh_end_date,dateadd(dd,183,tcps.trh_begin_date)) else coalesce(Federal_Discharge_Date_Force_18,'12/31/3999') end) as Federal_Discharge_Date
					, max(coalesce(tce.[Federal_Discharge_Date],'12/31/3999')) as orig_federal_discharge_date
					, max(tce.[Federal_Discharge_Reason_Code]) as [Federal_Discharge_Reason_Code]
					, max(tce.[Federal_Discharge_Reason]) as [Federal_Discharge_Reason]
					, max(tce.state_discharge_reason_code ) as state_discharge_reason_code
					, max(tce.state_discharge_reason) as state_discharge_reason
					, max(tce.[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON]) as [Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON]
					, max(tce.[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD] ) as [Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD]
					, max(tce.[Removal_Plcm_Discharge_Reason]) as [Removal_Plcm_Discharge_Reason]
					, max(tce.[Removal_Plcm_Discharge_Reason_Cd]) as [Removal_Plcm_Discharge_Reason_Cd]
					, max(Age.cdc_census_mix_age_cd) as age_grouping_cd
					, max(Age.cdc_census_mix_age_tx) as age_grouping
					, max(coalesce(G.PK_GNDR,3)) as pk_gndr
					, max(coalesce(tce.cd_race_census,7)) as cd_race_census
					, max(coalesce(tce.census_Hispanic_Latino_Origin_cd,5)) as census_Hispanic_Latino_Origin_cd
					, max(frstdesc.tx_plcm_setng) as init_tx_plcm_setng
					, max(frstplc.cd_plcm_setng) as init_cd_plcm_setng
					, max(longdesc.tx_plcm_setng)  as long_tx_plcm_setng
					, max(longplc.cd_plcm_setng)  as long_cd_plcm_setng
					, max(coalesce(tce.[Removal_County_Cd],-99)) as [Removal_County_Cd] 
					, max(cast(power(10.0,8) + 
					(power(10.0,7) * coalesce(age.cdc_census_mix_age_cd,0)) + 
						(power(10.0,6) * coalesce(tce.cd_race_census,7)) +
							(power(10.0,5) * coalesce(tce.census_Hispanic_Latino_Origin_cd,5)) + 
								(power(10.0,4) * coalesce(g.pk_gndr,3)) + 
									(power(10.0,3) * frstplc.cd_plcm_setng) +
										(power(10.0,2) * longplc.cd_plcm_setng) + 
											(power(10.0,0) * (case when coalesce(tce.removal_county_cd,-99) not between 1 and 39 then 99 else tce.removal_county_cd end))
											as decimal(9,0))) as int_match_param_key
					, max(coalesce(tce.[Removal_County],'-')) as [Removal_County]
					, max(isnull(tce.bin_dep_cd,1)) as bin_dep_cd
					, max(isnull(tce.max_bin_los_cd,0)) as max_bin_los_cd
					, max(isnull(tce.max_bin_los_cd,0))  as bin_los_cd
					, max(coalesce(plcm.bin_placement_cd,0)) as bin_placement_cd
					, max(coalesce(rpt.collapsed_cd_reporter_type,-99))as cd_reporter_type
					, max(coalesce(si.[fl_cps_invs],0)) as fl_cps_invs
					, max(coalesce(si.[fl_cfws],0)) as fl_cfws
					, max(coalesce(si.[fl_risk_only],0)) as [fl_risk_only]
					, max(coalesce(si.[fl_alternate_intervention],0)) as [fl_alternate_intervention]
					, max(coalesce(si.[fl_frs],0)) as [fl_frs]
					, max(case when si.[cnt_intk_grp_phys_abuse] > 0 then 1 else 0 end) as  fl_phys_abuse
					, max(case when si.[cnt_intk_grp_sexual_abuse]  > 0 then 1 else 0 end)  as fl_sexual_abuse
					, max(case when si.[cnt_intk_grp_neglect]  > 0 then 1 else 0 end)  as fl_neglect
					, max(case when si.[cnt_intk_grp_phys_abuse]>0
							or si.[cnt_intk_grp_sexual_abuse] > 0
							or  si.[cnt_intk_grp_neglect]  > 0 then 1 else 0 end) as fl_any_legal
					, max(case when si.[cnt_intk_grp_founded_phys_abuse]  > 0 then 1 else 0 end)  as fl_founded_phys_abuse
					, max(case when si.[cnt_intk_grp_founded_sexual_abuse]  > 0 then 1 else 0 end)  as fl_founded_sexual_abuse
					, max(case when si.[cnt_intk_grp_founded_neglect]  > 0 then 1 else 0 end)  as fl_founded_neglect
					, max(case when si.[cnt_intk_grp_founded_any_legal]  > 0 then 1 else 0 end) as fl_found_any_legal
					, max(tce.bin_ihs_svc_cd) as bin_ihs_svc_cd
					, max(coalesce(eps_svc.fl_family_focused_services,0)) as fl_family_focused_services
					, max(coalesce(eps_svc.fl_child_care,0)) as fl_child_care
					, max(coalesce(eps_svc.fl_therapeutic_services,0)) as fl_therapeutic_services
					, max(coalesce(eps_svc.fl_mh_services,0)) as fl_mh_services
					, max(coalesce(eps_svc.fl_receiving_care,0)) as fl_receiving_care
					, max(coalesce(eps_svc.fl_family_home_placements,0)) as fl_family_home_placements
					, max(coalesce(eps_svc.fl_behavioral_rehabiliation_services,0)) as fl_behavioral_rehabiliation_services
					, max(coalesce(eps_svc.fl_other_therapeutic_living_situations,0)) as fl_other_therapeutic_living_situations
					, max(coalesce(eps_svc.fl_specialty_adolescent_services,0)) as fl_specialty_adolescent_services
					, max(coalesce(eps_svc.fl_respite,0)) as fl_respite
					, max(coalesce(eps_svc.fl_transportation,0)) as fl_transportation
					, max(coalesce(eps_svc.fl_clothing_incidentals,0)) as fl_clothing_incidentals
					, max(coalesce(eps_svc.fl_sexually_aggressive_youth,0)) as fl_sexually_aggressive_youth
					, max(coalesce(eps_svc.fl_adoption_support,0)) as fl_adoption_support
					, max(coalesce(eps_svc.fl_various,0)) as fl_various
					, max(coalesce(eps_svc.fl_medical,0)) as fl_medical
					, max(coalesce(eps_svc.fl_budget_C12,0)) as fl_budget_C12
					, max(coalesce(eps_svc.fl_budget_C14,0)) as fl_budget_C14
					, max(coalesce(eps_svc.fl_budget_C15,0)) as fl_budget_C15
					, max(coalesce(eps_svc.fl_budget_C16,0)) as fl_budget_C16
					, max(coalesce(eps_svc.fl_budget_C18,0)) as fl_budget_C18
					, max(coalesce(eps_svc.fl_budget_C19,0)) as fl_budget_C19
					, max(coalesce(eps_svc.fl_uncat_svc,0)) as fl_uncat_svc
					, max(case when unsf.id_removal_episode_fact is not null and unsf2.id_removal_episode_fact is null and tcps.placement_end_reason_code <> 10 
								then unsf.entry_date 
								when unsf.id_removal_episode_fact is not null  and tcps.placement_end_reason_code = 10 then unsf.exit_date
								else '3999-12-31' end) as unsafe_begin
					, max(case when unsf.id_removal_episode_fact is not null and unsf2.id_removal_episode_fact is null and tcps.placement_end_reason_code <> 10 
								then unsf.exit_date 
								else '3999-12-31' end)  as unsafe_end
					, max(coalesce(tcps.trh_begin_date,'12/31/3999')) as trh_begin
					, max(coalesce(datediff(dd,tcps.trh_begin_date,coalesce(tcps.trh_end_date,@cutoff_date)),0)) as TRH_Duration
					, min(coalesce(nondcfs.CUST_BEGIN,'12/31/3999')) as nonDCFS_Cust_Begin
					, cast(null as datetime) as nonDCFS_Cust_End
					, max(case when unsf.placement_end_reason_code = 47 then 1 else 0 end) as JRAdetn
					, max(case when unsf.id_removal_episode_fact is not null and unsf2.id_removal_episode_fact is null then 1 else 0 end) as unsafe_exit
					, cast('No' as varchar(20)) as unsafe_exit_Desc
					, 1 as prsn_cnt
					, cast(0 as int) as extm3
					, cast(0 as int) as extm6
					, cast(0 as int) as extm9
					, cast(0 as int) as extm12
					, cast(0 as int) as extm15
					, cast(0 as int) as extm18
					, cast(0 as int) as extm21
					, cast(0 as int) as extm24
					, cast(0 as int) as extm27
					, cast(0 as int) as extm30
					, cast(0 as int) as extm33
					, cast(0 as int) as extm36
					, cast(0 as int) as extm39
					, cast(0 as int) as extm42
					, cast(0 as int) as extm45
					, cast(0 as int) as extm48
					, cast(null as int) as Row_Num
				into #eps  
				from base.tbl_child_episodes tce
					join dbo.calendar_dim cd on cd.calendar_date=tce.state_custody_start_date 
				--	join ref_filter_los los on los.bin_los_cd <=max_bin_los_cd 
					left join age_dim Age on tce.age_eps_begin_mos =Age.age_mo  
							-- and age. between 1 and 8 
					--left join dbo.ref_Age_Groupings_Census AgeCens on CHILD_AGE_REMOVAL_BEGIN >=AgeCens.age_begin 
					--			and CHILD_AGE_REMOVAL_BEGIN < AgeCens.Age_LessThan_End
					--		and AgeCens.age_grouping_cd between 1 and 4
					left join dbo.ref_lookup_placement_event frstplc on frstplc.id_plcmnt_evnt=tce.init_id_plcmnt_evnt
					left join dbo.ref_lookup_placement_event longplc on longplc.id_plcmnt_evnt=tce.longest_id_plcmnt_evnt
					left join dbo.ref_lookup_plcmnt frstdesc on frstdesc.cd_plcm_setng=frstplc.cd_plcm_setng
					left join dbo.ref_lookup_plcmnt longdesc on longdesc.cd_plcm_setng=longplc.cd_plcm_setng
					left join dbo.vw_intakes_screened_in si on si.id_intake_fact=tce.id_intake_fact
					left join base.tbl_ihs_episodes ihs on ihs.id_intake_fact=tce.id_intake_fact and ihs.id_case=tce.id_case
					left join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter
					left join dbo.ref_lookup_gender G on G.CD_GNDR=tce.CD_GNDR
					left join dbo.ref_lookup_county cnty on cnty.County_Cd=tce.Removal_County_Cd
					left join dbo.ref_filter_nbr_placement plcm on tce.cnt_ooh_plcm between plcm.nbr_placement_from and plcm.nbr_placement_thru and plcm.bin_placement_cd <>0
					left join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=tce.id_removal_episode_fact
					-- non-DCFS custody start date within episode
					-- get first out of dcfs custody 
					left join vw_nondcfs_combine_adjacent_segments nondcfs on nondcfs.ID_PRSN=tce.id_prsn_child
						and nondcfs.CUST_BEGIN between tce.state_custody_start_date
							and coalesce(tce.federal_discharge_date_force_18,'12/31/3999')
						and nondcfs.CUST_END between tce.state_custody_start_date
							and coalesce(tce.federal_discharge_date_force_18,'12/31/3999')
					--non-DCFS custody concatenate adjacent segments and exclude episodes contained within
					left join vw_nondcfs_combine_adjacent_segments nondcfs_eps_within on nondcfs_eps_within.ID_PRSN=tce.id_prsn_child
								and nondcfs_eps_within.cust_begin <= tce.state_custody_start_date
								and nondcfs_eps_within.cust_end >= coalesce(tce.federal_discharge_date_force_18,'12/31/3999')
					--TRH
					left join base.tbl_child_placement_settings tcps on tcps.id_removal_episode_fact=tce.id_removal_episode_fact
						and fl_lst_ooh_plcm =1 and Trial_Return_Home_Cd=1 
						and (tcps.trh_end_date is not null or (tcps.trh_end_date is null and datediff(dd,tcps.trh_begin_date,@cutoff_date) >=183))
					-- mark unsafe exits
					left join base.tbl_child_placement_settings unsf on unsf.id_removal_episode_fact=tce.id_removal_episode_fact
						and unsf.placement_end_reason_code in (5,6,10,47) and unsf.fl_lst_ooh_plcm=1
					-- mark those where the child is located after a runaway
					left join base.tbl_child_placement_settings unsf2 on unsf.id_removal_episode_fact=unsf2.id_removal_episode_fact
						and unsf2.entry_date > unsf.entry_date and unsf.placement_end_reason_code =6 and  unsf2.placement_end_reason_code=29
					----dschtype comes from here
					left join dbo.ref_lookup_ethnicity_census rcens on rcens.cd_race_census=tce.cd_race_census
						-- match on state discharge reason code ... CD_DSCH_RSN
					left join  dbo.ref_state_discharge_xwalk xwS
							on xwS.state_discharge_reason_code=tce.state_discharge_reason_code
							and xwS.State_Discharge_Reason_Code > 0
							and tce.federal_discharge_date is not null
					-- for those marked as legally free but have been adopted etc use placement end reason instead		
					left join  dbo.ref_state_discharge_xwalk xw3 
							on xw3.CD_DSCH_RSN=tce.Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD
							and  tce.state_discharge_reason_code=27 
							and tce.federal_discharge_date is not null
					-- get the last placement
					left join base.tbl_child_placement_settings tcpsLst on tcpsLst.id_removal_episode_fact=tce.id_removal_episode_fact
							and tcpsLst.fl_lst_ooh_plcm =1
					left join dbo.ref_state_discharge_xwalk xwLstPlcmnt 
												on xwLstPlcmnt.CD_DSCH_RSN=tcpsLst.placement_end_reason_code
								and   xwLstPlcmnt.state_discharge_reason_code > 0
								and  tce.federal_discharge_date is not null 
					--  now update those who have been discharged but do not have a state discharge reason code with federal discharge					
					left outer join [ref_federal_discharge_reason_xwalk] xwFED 
							on xwFED.Federal_discharge_reason_code=tce.Federal_discharge_reason_code
							and isnull(tce.federal_discharge_date,tce.federal_discharge_date_force_18) is not null
					left join dbo.ref_state_discharge_xwalk xwF on xwF.state_discharge_reason_code=xwFED.state_discharge_reason_code
					--- force these to emancipation at 18th birthday federal_discharge_date is federal_discharge_date_force_18
					left join dbo.ref_state_discharge_xwalk xwE 
						on xwE.CD_DSCH_RSN=12 
							and tce.federal_discharge_date_force_18  is not  null 
												and tce.federal_discharge_date is null
					--trh
					left join dbo.ref_state_discharge_xwalk xTRH on xTRH.state_discharge_reason_code=15 and tcps.id_removal_episode_fact is not null
					--other
					left join dbo.ref_state_discharge_xwalk xOth on xOth.state_discharge_reason_code=42 and isnull(tcps.trh_end_date,federal_discharge_date) is not null -- just using 42 for other
					--still in care
					left join dbo.ref_state_discharge_xwalk xSC on xSC.state_discharge_reason_code=-99 -- still in care
				where --**  select entry cohort
						 tce.state_custody_start_date >=@start_date
						and tce.state_custody_start_date <= isnull(federal_discharge_date_force_18,@cutoff_date)
						and tce.age_eps_begin_mos is not null 
						and age.age_mo < (12*18) 
						and age.cdc_census_mix_age_cd is not null 
						and nondcfs_eps_within.ID_PRSN is null

				GROUP BY cd.[Year],tce.id_removal_episode_fact,tce.id_prsn_child

		update eps
		set row_num=q.row_num2
		from #eps eps 
		join (select tce.* ,row_number() over (-- only want one episode per cohort_period
						partition by tce.ID_PRSN_CHILD,tce.Cohort_Entry_Date
							order by Cohort_Entry_Date asc ,state_custody_start_date asc,federal_discharge_date asc) as row_num2
							from #eps tce
							-- order by  tce.ID_PRSN_CHILD,tce.Cohort_Entry_Date
							) q on q.id_removal_episode_fact=eps.id_removal_episode_fact


		delete from #eps where row_num > 1;


		
		update eps
		set cd_discharge_type=q.cd_discharge_type
		from #eps eps join (select distinct xw.cd_discharge_type,xw.discharge_type from dbo.ref_state_discharge_xwalk xw) q
		on q.discharge_type=eps.discharge_type

		update eps
		set unsafe_begin=null
		from #eps eps where unsafe_begin='12/31/3999'

		update eps
		set unsafe_end=null
		from #eps eps where unsafe_end='12/31/3999' and unsafe_begin is null
		
		update eps
		set trh_begin=null
		from #eps eps 
		where trh_begin='12/31/3999';

		update eps
		set nonDCFS_Cust_Begin=null
		from #eps eps
		where nonDCFS_Cust_Begin ='12/31/3999';
		
		
		update eps
		set nonDCFS_Cust_End=nonDCFS.cust_end
		from #eps eps
		join vw_nondcfs_combine_adjacent_segments nonDCFS on nonDCFS.ID_PRSN=eps.id_prsn_child
				and nonDCFS.cust_begin=eps.nonDCFS_Cust_Begin;


		-- reset state custody start dates
		update eps
		set state_custody_start_date=nonDCFS_Cust_End
			,cohort_entry_date =cd.[year]
		from #eps eps
		join dbo.CALENDAR_DIM cd on cd.CALENDAR_DATE=nonDCFS_Cust_End
		where state_custody_start_date=nonDCFS_Cust_Begin
			and nonDCFS_Cust_End < coalesce(federal_discharge_date,'12/31/3999');
		-- move federal discharge date up to custody begin date where child is in nonDCFS custody until exit
		update eps
		set Federal_Discharge_Date=nonDCFS_Cust_Begin
			,cd_discharge_type=case when orig_federal_discharge_date='12/31/3999' and cd_discharge_type=0
				then 6 else eps.cd_discharge_type end
			,discharge_type=case when orig_federal_discharge_date='12/31/3999' and cd_discharge_type=0
				then 'Other' else eps.discharge_type end

		--  select id_prsn_child,state_custody_start_date,Federal_Discharge_Date,nonDCFS_Cust_Begin,nonDCFS_Cust_End
		from #eps eps
		where Federal_Discharge_Date=nonDCFS_Cust_End
	
		update eps
		set JRAdetn=1,unsafe_end=cust_end,unsafe_begin=cust_begin
		from #eps eps join base.WRK_nonDCFS_All nonDCFS on nonDCFS.ID_PRSN=eps.id_prsn_child
			and nonDCFS.CUST_BEGIN=eps.nonDCFS_Cust_Begin
			and nonDCFS.CD_PLACEMENT_CARE_AUTH=10 

		update eps
		set JRAdetn=1,unsafe_end=cust_end,unsafe_begin=cust_begin
		from #eps eps join base.WRK_nonDCFS_All nonDCFS on nonDCFS.ID_PRSN=eps.id_prsn_child
			and nonDCFS.CUST_END=eps.nonDCFS_Cust_end
			and nonDCFS.CD_PLACEMENT_CARE_AUTH=10 
			where unsafe_begin is null;
			
			
		if object_ID('tempDB..#nondcfs') is not null drop table #nondcfs;
		select distinct eps.id_removal_episode_fact,eps.id_prsn_child,null as bin_los_cd,eps.state_custody_start_date,eps.federal_discharge_date
				,dcfs.cust_begin
				,case when dcfs.cust_end='12/31/3999' and  eps.federal_discharge_date  < dcfs.cust_end
					then eps.federal_discharge_date else dcfs.cust_end end as cust_end
				,row_number() over (partition by eps.id_removal_episode_fact
						order by eps.id_removal_episode_fact,dcfs.cust_begin asc
						,dcfs.cust_end asc) as sort_asc
				,row_number() over (partition by eps.id_removal_episode_fact
						order by eps.id_removal_episode_fact,dcfs.cust_begin desc,dcfs.cust_end desc) as sort_desc 
				,0 as fl_update
		into #nondcfs
		from #eps eps
		join vw_nondcfs_combine_adjacent_segments dcfs on dcfs.id_prsn=eps.id_prsn_child
		and dcfs.cust_begin < federal_discharge_date
		and dcfs.cust_end > state_custody_start_date
		and NOT(dcfs.cust_begin<=state_custody_start_date and dcfs.cust_end>=federal_discharge_date)

		
		--	select * from #nondcfs where id_removal_episode_fact=143960 
	
		if object_ID('tempDB..#tmp') is not null drop table #tmp

		create table #tmp
		( id_removal_episode_fact int
			,state_custody_start_date datetime
			,federal_discharge_date datetime
			,fl_multiple int 
			, bin_los_cd int
			,  entry_month_date datetime
			,  entry_year_date datetime
			, exit_month_date datetime
			, exit_year_date datetime )

		insert into #tmp(id_removal_episode_fact,state_custody_start_date,federal_discharge_date,fl_multiple)
		-- use custody begin date as federal discharge date  for the first part ot the split
		select  id_removal_episode_fact,state_custody_start_date,cust_begin as federal_discharge_date,0 as fl_multiple
		from #nondcfs where sort_asc=1 and sort_desc=1
		and state_custody_start_date < cust_begin
		union 
		-- use custody end date as the state custody start date for the next split segment where the custody end date is less than the federal discharge date where there is only 1 segment
		select  id_removal_episode_fact,cust_end,federal_discharge_date,0 as fl_multiple
		from #nondcfs where sort_asc=1 and sort_desc=1
		and cust_end < federal_discharge_date
		union --- get the first segment for the multiple custody segments
		select  id_removal_episode_fact,state_custody_start_date,cust_begin as federal_discharge_date,1 as fl_multiple
		from #nondcfs where sort_asc=1 and sort_desc<>1
			and state_custody_start_date < cust_begin


		declare @maxNbrCustSeg int
		declare @rowcount int
							
		select @maxNbrCustSeg=max(sort_desc) -1 from #nondcfs;
		--loop through getting the next custody segment
		set @rowcount=1
		while @rowcount < @maxNbrCustSeg
		begin
					
			insert into #tmp(id_removal_episode_fact,state_custody_start_date,federal_discharge_date,fl_multiple)
			select  n1.id_removal_episode_fact,n1.cust_end,dbo.lessorDate(n2.federal_discharge_date,n2.cust_begin),1 as fl_multiple
			from #nondcfs n1
			join #nondcfs n2 on n2.id_removal_episode_fact=n1.id_removal_episode_fact and n2.sort_asc=@rowcount + 1
				
			where n1.sort_asc=@rowcount 
			and n1.state_custody_start_date < n1.cust_begin
			and n1.cust_end < n2.cust_begin
						
			set @rowcount=@rowcount + 1;
		end

					
		--now get last multiple custody segment
		insert into #tmp(id_removal_episode_fact,state_custody_start_date,federal_discharge_date,fl_multiple)
			select  n1.id_removal_episode_fact,n2.cust_end,dbo.lessorDate(n1.federal_discharge_date,n1.cust_begin),1 as fl_multiple
			from #nondcfs n1
			join #nondcfs n2 on n2.id_removal_episode_fact=n1.id_removal_episode_fact and n2.sort_desc=2
			where n1.sort_desc=1
			and n1.state_custody_start_date < n1.cust_begin
			and n2.cust_end < n1.cust_begin

		update #tmp
		set entry_month_date=calendar_dim.[month]
			,  entry_year_date =calendar_dim.[year]
		from dbo.CALENDAR_DIM 
		where CALENDAR_DATE=state_custody_start_date


		update #tmp
		set exit_month_date=calendar_dim.[month]
			,  exit_year_date =calendar_dim.[year]
		from dbo.CALENDAR_DIM 
		where CALENDAR_DATE=federal_discharge_date
	


	
		if object_ID('tempDB..#bkp_eps') is not null drop table #bkp_eps;
		select entry_year_date, date_type, qry_type, ID_PRSN_CHILD, tmp.ID_REMOVAL_EPISODE_FACT
		, case when orig_federal_discharge_date='3999-12-31' and tmp.federal_discharge_date <> '3999-12-31'
			and cd_discharge_type=0 then 'Other' else discharge_type end	as  discharge_type
		, case when orig_federal_discharge_date='3999-12-31' and tmp.federal_discharge_date <> '3999-12-31'
			and cd_discharge_type=0 then 6 else cd_discharge_type end as cd_discharge_type
		, first_removal_date,fl_first_removal
		, tmp.state_custody_start_date, tmp.Federal_Discharge_Date, orig_federal_discharge_date, Federal_Discharge_Reason_Code, Federal_Discharge_Reason
		, state_discharge_reason_code, state_discharge_reason, Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON, Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD
		, Removal_Plcm_Discharge_Reason, Removal_Plcm_Discharge_Reason_Cd, age_grouping_cd, age_grouping, pk_gndr, cd_race_census, census_Hispanic_Latino_Origin_cd
		, init_tx_plcm_setng, init_cd_plcm_setng, long_tx_plcm_setng, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key, Removal_County
		, bin_dep_cd, tmp.bin_los_cd as max_bin_los_cd, tmp.bin_los_cd, bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws, fl_risk_only, fl_alternate_intervention
		, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect
		, fl_found_any_legal, bin_ihs_svc_cd, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care
		, fl_family_home_placements, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation
		, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical, fl_budget_C12, fl_budget_C14
		, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, unsafe_begin, unsafe_end, trh_begin
		, TRH_Duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc, prsn_cnt,extm3,extm6,extm9,extm12,extm15,extm18,extm21,extm24,extm27,extm30
		,extm33,extm36,extm39,extm42,extm45,extm48
		, Row_Num
		into #bkp_eps
		from #eps eps
		join #tmp tmp on eps.id_removal_episode_fact=tmp.id_removal_episode_fact 

	


		delete from #eps where id_removal_episode_fact in  (select id_Removal_episode_fact from #tmp)

		
		delete eps
		--select *
		from #bkp_eps eps 
		join -- select * from
				(select tce.* ,row_number() over (
						partition by tce.ID_PRSN_CHILD,tce.entry_year_date
							order by entry_year_date asc ,state_custody_start_date asc) as row_num2
							from #bkp_eps tce
							--  where id_prsn_child=1476032
							) q  --  where q.row_num2 > 1
							on q.id_removal_episode_fact=eps.id_removal_episode_fact
		where row_num2 > 1 ;

		CREATE NONCLUSTERED INDEX idx_tmp_33 on #eps ([ID_REMOVAL_EPISODE_FACT],[state_custody_start_date],[Federal_Discharge_Date])
		INCLUDE ([bin_los_cd])

		insert into #eps
		select distinct * from #bkp_eps;

		update eps
		set bin_los_cd=q.max_bin_los_cd,max_bin_los_cd=q.max_bin_los_cd
		from #eps eps join (
				select id_removal_episode_fact,state_custody_start_date,federal_discharge_date,max(los.bin_los_cd) as max_bin_los_cd
				from #eps
				join ref_filter_los los on datediff(dd,state_custody_start_date,case when federal_discharge_date = '12/31/3999' then @cutoff_date else federal_discharge_date end) + 1  between los.dur_days_from and los.dur_days_thru
				
				  --and id_removal_episode_fact=90216  --  select * from #eps where id_Removal_episode_fact=90216
				group by id_removal_episode_fact,state_custody_start_date,federal_discharge_date
				) q on q.id_removal_episode_fact=eps.id_removal_episode_fact
					and q.state_custody_start_date=eps.state_custody_start_date
					and q.Federal_Discharge_Date=eps.Federal_Discharge_Date
		where eps.bin_los_cd <> q.max_bin_los_cd or eps.bin_los_cd is null

		update eps
		set bin_placement_cd=plcm.bin_placement_cd
		from #eps eps join (
						select  eps.id_removal_episode_fact,eps.state_custody_start_date,eps.federal_discharge_date,count(distinct id_placement_fact) as ooh_cnt
						from #eps eps
						join base.tbl_child_placement_settings tcps on tcps.id_removal_episode_fact=eps.id_removal_episode_fact
						where cd_epsd_type=1
						and entry_date between state_custody_start_date and Federal_Discharge_Date
						group by eps.id_removal_episode_fact,eps.state_custody_start_date,eps.federal_discharge_date
						) q on q.id_removal_episode_fact=eps.id_removal_episode_fact
						and q.state_custody_start_date=eps.state_custody_start_date
						and q.Federal_Discharge_Date=eps.Federal_Discharge_Date
		join ref_filter_nbr_placement plcm on q.ooh_cnt between plcm.nbr_placement_from and plcm.nbr_placement_thru and plcm.bin_placement_cd <>0
		where eps.bin_placement_cd <> plcm.bin_placement_cd

		
		
			
		--update eps
		--set row_num=q.row_num2
		--from #eps eps 
		--join (select tce.* ,row_number() over (
		--				partition by tce.ID_PRSN_CHILD,tce.Cohort_Entry_Date
		--					order by Cohort_Entry_Date asc ,state_custody_start_date asc) as row_num2
		--					from #eps tce) q on q.id_removal_episode_fact=eps.id_removal_episode_fact


		update #eps
		set fl_first_removal = 0 where state_custody_start_date <> first_removal_date and fl_first_removal=1

		update #eps
		set extm3= case when dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=3 then 1 else 0 end
			,extm6=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=6 then 1 else 0 end
			,extm9=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=9 then 1 else 0 end
			,extm12=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=12 then 1 else 0 end
			,extm15=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=15 then 1 else 0 end
			,extm18=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=18 then 1 else 0 end
			,extm21=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=21 then 1 else 0 end
			,extm24=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=24 then 1 else 0 end
			,extm27=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=27 then 1 else 0 end
			,extm30=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=30 then 1 else 0 end
			,extm33=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=33 then 1 else 0 end
			,extm36=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=36 then 1 else 0 end
			,extm39=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=39 then 1 else 0 end
			,extm42=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=42 then 1 else 0 end
			,extm45=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=45 then 1 else 0 end
			,extm48=case when  dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date)<=48 then 1 else 0 end		

		
		update #eps
		set extm3=1
			,extm6=1
			,extm9=1
			,extm12=1
			,extm15=1
			,extm18=1
			,extm21=1
			,extm24=1
			,extm27=1
			,extm30=1
			,extm33=1
			,extm36=1
			,extm39=1
			,extm42=1
			,extm45=1
			,extm48=1
		where prsn_cnt=1 and cd_discharge_type=0

		--select max_bin_los_cd,id_prsn_child,id_removal_episode_fact,state_custody_start_date,Federal_Discharge_Date,dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date) as mo
		--	 from #eps where bin_los_cd=4 and (extm9 > 0 or extm6>0 or extm3>0 or extm12>0 or extm15>0 or extm18>0 or extm21>0) and cd_discharge_type <>0

			-- insert other LOS records	
			insert into #eps
			SELECT distinct 
				[cohort_entry_date]
				  ,[date_type]
				  ,[qry_type]
				  ,[ID_PRSN_CHILD]
				  ,[ID_REMOVAL_EPISODE_FACT]
				  ,[discharge_type]
				  ,[cd_discharge_type]
				  ,[first_removal_date]
				  ,[fl_first_removal]
				  ,[state_custody_start_date]
				  ,[Federal_Discharge_Date]
				  ,[orig_federal_discharge_date]
				  ,[Federal_Discharge_Reason_Code]
				  ,[Federal_Discharge_Reason]
				  ,[state_discharge_reason_code]
				  ,[state_discharge_reason]
				  ,[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON]
				  ,[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD]
				  ,[Removal_Plcm_Discharge_Reason]
				  ,[Removal_Plcm_Discharge_Reason_Cd]
				  ,[age_grouping_cd]
				  ,[age_grouping]
				  ,[pk_gndr]
				  ,[cd_race_census]
				  ,[census_Hispanic_Latino_Origin_cd]
				  ,[init_tx_plcm_setng]
				  ,[init_cd_plcm_setng]
				  ,[long_tx_plcm_setng]
				  ,[long_cd_plcm_setng]
				  ,[Removal_County_Cd]
				  ,[int_match_param_key]
				  ,[Removal_County]
				  ,[bin_dep_cd]
				  ,[max_bin_los_cd]
				  ,los.[bin_los_cd]
				  ,[bin_placement_cd]
				  ,[cd_reporter_type]
				  ,[fl_cps_invs]
				  ,[fl_cfws]
				  ,[fl_risk_only]
				  ,[fl_alternate_intervention]
				  ,[fl_frs]
				  ,[fl_phys_abuse]
				  ,[fl_sexual_abuse]
				  ,[fl_neglect]
				  ,[fl_any_legal]
				  ,[fl_founded_phys_abuse]
				  ,[fl_founded_sexual_abuse]
				  ,[fl_founded_neglect]
				  ,[fl_found_any_legal]
				  ,[bin_ihs_svc_cd]
				  ,[fl_family_focused_services]
				  ,[fl_child_care]
				  ,[fl_therapeutic_services]
				  ,[fl_mh_services]
				  ,[fl_receiving_care]
				  ,[fl_family_home_placements]
				  ,[fl_behavioral_rehabiliation_services]
				  ,[fl_other_therapeutic_living_situations]
				  ,[fl_specialty_adolescent_services]
				  ,[fl_respite]
				  ,[fl_transportation]
				  ,[fl_clothing_incidentals]
				  ,[fl_sexually_aggressive_youth]
				  ,[fl_adoption_support]
				  ,[fl_various]
				  ,[fl_medical]
				  ,[fl_budget_C12]
				  ,[fl_budget_C14]
				  ,[fl_budget_C15]
				  ,[fl_budget_C16]
				  ,[fl_budget_C18]
				  ,[fl_budget_C19]
				  ,[fl_uncat_svc]
				  ,[unsafe_begin]
				  ,[unsafe_end]
				  ,[trh_begin]
				  ,[TRH_Duration]
				  ,[nonDCFS_Cust_Begin]
				  ,[nonDCFS_Cust_End]
				  ,[JRAdetn]
				  ,[unsafe_exit]
				  ,[unsafe_exit_Desc]
				  ,[prsn_cnt]
				  ,[extm3]
				  ,[extm6]
				  ,[extm9]
				  ,[extm12]
				  ,[extm15]
				  ,[extm18]
				  ,[extm21]
				  ,[extm24]
				  ,[extm27]
				  ,[extm30]
				  ,[extm33]
				  ,[extm36]
				  ,[extm39]
				  ,[extm42]
				  ,[extm45]
				  ,[extm48]
				  ,[Row_Num]
			  FROM #eps
			  join ref_filter_los los on los.bin_los_cd < max_bin_los_cd 
			  


		insert into #eps
		select cohort_entry_date, date_type, 1 as qry_type, ID_PRSN_CHILD, ID_REMOVAL_EPISODE_FACT, discharge_type, cd_discharge_type,first_removal_date,fl_first_removal
		, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, Federal_Discharge_Reason_Code, Federal_Discharge_Reason
		, state_discharge_reason_code, state_discharge_reason, Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON, Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD
		, Removal_Plcm_Discharge_Reason, Removal_Plcm_Discharge_Reason_Cd, age_grouping_cd, age_grouping, pk_gndr, cd_race_census, census_Hispanic_Latino_Origin_cd
		, init_tx_plcm_setng, init_cd_plcm_setng, long_tx_plcm_setng, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key, Removal_County
		, bin_dep_cd, max_bin_los_cd, bin_los_cd, bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws, fl_risk_only, fl_alternate_intervention
		, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect
		, fl_found_any_legal, bin_ihs_svc_cd, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care
		, fl_family_home_placements, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation
		, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical, fl_budget_C12, fl_budget_C14
		, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc,  unsafe_begin, unsafe_end, trh_begin
		, TRH_Duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc, prsn_cnt,extm3,extm6,extm9,extm12,extm15,extm18,extm21,extm24,extm27,extm30
		,extm33,extm36,extm39,extm42,extm45,extm48,  Row_Num
		from #eps eps
		where fl_first_removal=1;

		
		insert into #eps
		select distinct cohort_entry_date, date_type, qry_type, ID_PRSN_CHILD, ID_REMOVAL_EPISODE_FACT, 'Still in care', 0,first_removal_date,fl_first_removal
		, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, Federal_Discharge_Reason_Code, Federal_Discharge_Reason
		, state_discharge_reason_code, state_discharge_reason, Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON, Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD
		, Removal_Plcm_Discharge_Reason, Removal_Plcm_Discharge_Reason_Cd, age_grouping_cd, age_grouping, pk_gndr, cd_race_census, census_Hispanic_Latino_Origin_cd
		, init_tx_plcm_setng, init_cd_plcm_setng, long_tx_plcm_setng, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key, Removal_County
		, bin_dep_cd, max_bin_los_cd, bin_los_cd, bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws, fl_risk_only, fl_alternate_intervention
		, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect
		, fl_found_any_legal, bin_ihs_svc_cd, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care
		, fl_family_home_placements, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation
		, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical, fl_budget_C12, fl_budget_C14
		, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc,  unsafe_begin, unsafe_end, trh_begin
		, TRH_Duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc
		, 0 as prsn_cnt,1-extm3,1-extm6,1-extm9,1-extm12,1- extm15,1- extm18,1- extm21,1- extm24,1- extm27,1- extm30
		,1- extm33,1- extm36,1- extm39,1- extm42,1- extm45,1 - extm48,  Row_Num
		from #eps eps
		where extm3=0 and cd_discharge_type <> 0 
	

	

		--  select bin_los_cd as v, * from #eps where id_prsn_child=28  order by qry_type,id_prsn_child,cohort_entry_date,cd_discharge_type,bin_los_cd
		
			
		truncate table prtl.prtl_outcomes;
		insert into prtl.prtl_outcomes(cohort_entry_date,date_type,qry_type,discharge_type,cd_discharge_type,age_grouping_cd,age_grouping,pk_gndr,cd_race_census
		,census_Hispanic_Latino_Origin_cd,init_cd_plcm_setng,long_cd_plcm_setng,Removal_County_Cd,int_match_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd
		,cd_reporter_type,bin_ihs_svc_cd,filter_access_type,fl_cps_invs,fl_alternate_intervention,fl_frs,fl_risk_only,fl_cfws,filter_allegation
		,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal,filter_finding,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_found_any_legal,filter_service_type,fl_family_focused_services
		,fl_child_care,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services
		,fl_respite,fl_transportation,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support,fl_various,fl_medical,filter_budget_type,fl_budget_C12,fl_budget_C14,fl_budget_C15
		,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,prsn_cnt,extm3,extm6,extm9,extm12,extm15,extm18,extm21,extm24,extm27,extm30,extm33,extm36,extm39,extm42,extm45,extm48)
		select 
			cohort_entry_date
			,date_type
			,qry_type
			,discharge_type
			,cd_discharge_type
			,age_grouping_cd
			,age_grouping
			,pk_gndr
			,cd_race_census
			,census_Hispanic_Latino_Origin_cd
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,bin_dep_cd
			,bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			-- select * from ref_filter_access_type
			,power(10.0,5) + (power(10.0,4) * fl_cps_invs)  + (power(10.0,3) * fl_alternate_intervention) + (power(10.0,2) * fl_frs) + (power(10.0,1) * fl_risk_only) + (power(10.0,0) * fl_cfws) as filter_access_type
			,fl_cps_invs
			,fl_alternate_intervention
			,fl_frs
			,fl_risk_only
			,fl_cfws
			-- select * from ref_filter_allegation
			,power(10.0,4) + (power(10.0,3) *fl_any_legal ) 
			+ (power(10.0,2) *fl_neglect )
				+ (power(10.0,1) *fl_sexual_abuse )
					+ (power(10.0,0) *fl_phys_abuse ) as filter_allegation
			,fl_any_legal
			,fl_neglect
			,fl_sexual_abuse
			,fl_phys_abuse
			-- select * from ref_filter_finding
			,power(10.0,4) 
			+ (power(10.0,3) *fl_found_any_legal )
					+ (power(10.0,2) *fl_founded_neglect )
					+ (power(10.0,1) *fl_founded_sexual_abuse )
						+ (power(10.0,0) *fl_founded_phys_abuse )as filter_finding
			,fl_found_any_legal
			,fl_founded_neglect
			,fl_founded_sexual_abuse
			,fl_founded_phys_abuse
			-- select * from [dbo].[ref_service_cd_subctgry_poc]
			, power(10.0,16) 
				+ (power(10.0,15) * fl_family_focused_services)  
					+ (power(10.0,14) * fl_child_care)  
						+ (power(10.0,13) * fl_therapeutic_services)  
							+ (power(10.0,12) * fl_mh_services)  
								+ (power(10.0,11) * fl_receiving_care)  
									+ (power(10.0,10) * fl_family_home_placements)  
										+ (power(10.0,9) * fl_behavioral_rehabiliation_services)  
											+ (power(10.0,8) * fl_other_therapeutic_living_situations)  
												+ (power(10.0,7) * fl_specialty_adolescent_services)  
													+ (power(10.0,6) * fl_respite)  
														+ (power(10.0,5) * fl_transportation)  
															+ (power(10.0,4) * fl_clothing_incidentals)  
																+ (power(10.0,3) * fl_sexually_aggressive_youth)  
																	+ (power(10.0,2) * fl_adoption_support)  
																		+ (power(10.0,1) * fl_various)  
																			+ (power(10.0,0) * fl_medical)  as filter_service_type
			,fl_family_focused_services
			,fl_child_care
			,fl_therapeutic_services
			,fl_mh_services
			,fl_receiving_care
			,fl_family_home_placements
			,fl_behavioral_rehabiliation_services
			,fl_other_therapeutic_living_situations
			,fl_specialty_adolescent_services
			,fl_respite
			,fl_transportation
			,fl_clothing_incidentals
			,fl_sexually_aggressive_youth
			,fl_adoption_support
			,fl_various
			,fl_medical
			-- select * from [dbo].[ref_service_cd_budget_poc_frc]
			,power(10.0,7) 
			+ (power(10.0,6) * fl_budget_C12 ) 
				+ (power(10.0,5) * fl_budget_C14 ) 
					+ (power(10.0,4) * fl_budget_C15 ) 
						+ (power(10,3) * fl_budget_C16 ) 
							+ (power(10,2) * fl_budget_C18 ) 
								+ (power(10,1) * fl_budget_C19 ) 
									+ (power(10,0) * fl_uncat_svc ) 	 as filter_budget_type
			,fl_budget_C12
			,fl_budget_C14
			,fl_budget_C15
			,fl_budget_C16
			,fl_budget_C18
			,fl_budget_C19
			,fl_uncat_svc
			,sum(prsn_cnt) as prsn_cnt
			,sum(extm3) as extm3
			,sum(extm6) as extm6
			,sum(extm9) as extm9
			,sum(extm12) as extm12
			,sum(extm15) as extm15
			,sum(extm18) as extm18
			,sum(extm21) as extm21
			,sum(extm24) as extm24
			,sum(extm27) as extm27
			,sum(extm30) as extm30
			,sum(extm33) as extm33
			,sum(extm36) as extm36
			,sum(extm39) as extm39
			,sum(extm42) as extm42
			,sum(extm45) as extm45
			,sum(extm48) as extm48
		from #eps
		group by cohort_entry_date
			,date_type
			,qry_type
			,discharge_type
			,cd_discharge_type
			,age_grouping_cd
			,age_grouping
			,pk_gndr
			,cd_race_census
			,census_Hispanic_Latino_Origin_cd
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,bin_dep_cd
			,bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			,fl_cps_invs
			,fl_alternate_intervention
			,fl_frs
			,fl_risk_only
			,fl_cfws
			,fl_any_legal
			,fl_neglect
			,fl_sexual_abuse
			,fl_phys_abuse
			,fl_found_any_legal
			,fl_founded_neglect
			,fl_founded_sexual_abuse
			,fl_founded_phys_abuse
			-- select * from [dbo].[ref_service_cd_subctgry_poc]
			,fl_family_focused_services
			,fl_child_care
			,fl_therapeutic_services
			,fl_mh_services
			,fl_receiving_care
			,fl_family_home_placements
			,fl_behavioral_rehabiliation_services
			,fl_other_therapeutic_living_situations
			,fl_specialty_adolescent_services
			,fl_respite
			,fl_transportation
			,fl_clothing_incidentals
			,fl_sexually_aggressive_youth
			,fl_adoption_support
			,fl_various
			,fl_medical
			,fl_budget_C12
			,fl_budget_C14
			,fl_budget_C15
			,fl_budget_C16
			,fl_budget_C18
			,fl_budget_C19
			,fl_uncat_svc



		
		-- insert all regardless of dependency
		insert into prtl.prtl_outcomes(cohort_entry_date,date_type,qry_type,discharge_type,cd_discharge_type,age_grouping_cd,age_grouping,pk_gndr,cd_race_census
		,census_Hispanic_Latino_Origin_cd,init_cd_plcm_setng,long_cd_plcm_setng,Removal_County_Cd,int_match_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd
		,cd_reporter_type,bin_ihs_svc_cd,filter_access_type,fl_cps_invs,fl_alternate_intervention,fl_frs,fl_risk_only,fl_cfws,filter_allegation
		,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal,filter_finding,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_found_any_legal,filter_service_type,fl_family_focused_services
		,fl_child_care,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services
		,fl_respite,fl_transportation,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support,fl_various,fl_medical,filter_budget_type,fl_budget_C12,fl_budget_C14,fl_budget_C15
		,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,prsn_cnt,extm3,extm6,extm9,extm12,extm15,extm18,extm21,extm24,extm27,extm30,extm33,extm36,extm39,extm42,extm45,extm48)
		select 
			cohort_entry_date
			,date_type
			,qry_type
			,discharge_type
			,cd_discharge_type
			,age_grouping_cd
			,age_grouping
			,pk_gndr
			,cd_race_census
			,census_Hispanic_Latino_Origin_cd
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,0 as bin_dep_cd
			,bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			-- select * from ref_filter_access_type
			,power(10.0,5) + (power(10.0,4) * fl_cps_invs)  + (power(10.0,3) * fl_alternate_intervention) + (power(10.0,2) * fl_frs) + (power(10.0,1) * fl_risk_only) + (power(10.0,0) * fl_cfws) as filter_access_type
			,fl_cps_invs
			,fl_alternate_intervention
			,fl_frs
			,fl_risk_only
			,fl_cfws
			-- select * from ref_filter_allegation
			,power(10.0,4) + (power(10.0,3) *fl_any_legal ) 
			+ (power(10.0,2) *fl_neglect )
				+ (power(10.0,1) *fl_sexual_abuse )
					+ (power(10.0,0) *fl_phys_abuse ) as filter_allegation
			,fl_any_legal
			,fl_neglect
			,fl_sexual_abuse
			,fl_phys_abuse
			-- select * from ref_filter_finding
			,power(10.0,4) 
			+ (power(10.0,3) *fl_found_any_legal )
					+ (power(10.0,2) *fl_founded_neglect )
					+ (power(10.0,1) *fl_founded_sexual_abuse )
						+ (power(10.0,0) *fl_founded_phys_abuse )as filter_finding
			,fl_found_any_legal
			,fl_founded_neglect
			,fl_founded_sexual_abuse
			,fl_founded_phys_abuse
			-- select * from [dbo].[ref_service_cd_subctgry_poc]
			, power(10.0,16) 
				+ (power(10.0,15) * fl_family_focused_services)  
					+ (power(10.0,14) * fl_child_care)  
						+ (power(10.0,13) * fl_therapeutic_services)  
							+ (power(10.0,12) * fl_mh_services)  
								+ (power(10.0,11) * fl_receiving_care)  
									+ (power(10.0,10) * fl_family_home_placements)  
										+ (power(10.0,9) * fl_behavioral_rehabiliation_services)  
											+ (power(10.0,8) * fl_other_therapeutic_living_situations)  
												+ (power(10.0,7) * fl_specialty_adolescent_services)  
													+ (power(10.0,6) * fl_respite)  
														+ (power(10.0,5) * fl_transportation)  
															+ (power(10.0,4) * fl_clothing_incidentals)  
																+ (power(10.0,3) * fl_sexually_aggressive_youth)  
																	+ (power(10.0,2) * fl_adoption_support)  
																		+ (power(10.0,1) * fl_various)  
																			+ (power(10.0,0) * fl_medical)  as filter_service_type
			,fl_family_focused_services
			,fl_child_care
			,fl_therapeutic_services
			,fl_mh_services
			,fl_receiving_care
			,fl_family_home_placements
			,fl_behavioral_rehabiliation_services
			,fl_other_therapeutic_living_situations
			,fl_specialty_adolescent_services
			,fl_respite
			,fl_transportation
			,fl_clothing_incidentals
			,fl_sexually_aggressive_youth
			,fl_adoption_support
			,fl_various
			,fl_medical
			-- select * from [dbo].[ref_service_cd_budget_poc_frc]
			,power(10.0,7) 
			+ (power(10.0,6) * fl_budget_C12 ) 
				+ (power(10.0,5) * fl_budget_C14 ) 
					+ (power(10.0,4) * fl_budget_C15 ) 
						+ (power(10,3) * fl_budget_C16 ) 
							+ (power(10,2) * fl_budget_C18 ) 
								+ (power(10,1) * fl_budget_C19 ) 
									+ (power(10,0) * fl_uncat_svc ) 	 as filter_budget_type
			,fl_budget_C12
			,fl_budget_C14
			,fl_budget_C15
			,fl_budget_C16
			,fl_budget_C18
			,fl_budget_C19
			,fl_uncat_svc
			,sum(prsn_cnt) as prsn_cnt
			,sum(extm3) as extm3
			,sum(extm6) as extm6
			,sum(extm9) as extm9
			,sum(extm12) as extm12
			,sum(extm15) as extm15
			,sum(extm18) as extm18
			,sum(extm21) as extm21
			,sum(extm24) as extm24
			,sum(extm27) as extm27
			,sum(extm30) as extm30
			,sum(extm33) as extm33
			,sum(extm36) as extm36
			,sum(extm39) as extm39
			,sum(extm42) as extm42
			,sum(extm45) as extm45
			,sum(extm48) as extm48
		from #eps
		group by cohort_entry_date
			,date_type
			,qry_type
			,discharge_type
			,cd_discharge_type
			,age_grouping_cd
			,age_grouping
			,pk_gndr
			,cd_race_census
			,census_Hispanic_Latino_Origin_cd
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			,fl_cps_invs
			,fl_alternate_intervention
			,fl_frs
			,fl_risk_only
			,fl_cfws
			,fl_any_legal
			,fl_neglect
			,fl_sexual_abuse
			,fl_phys_abuse
			,fl_found_any_legal
			,fl_founded_neglect
			,fl_founded_sexual_abuse
			,fl_founded_phys_abuse
			-- select * from [dbo].[ref_service_cd_subctgry_poc]
			,fl_family_focused_services
			,fl_child_care
			,fl_therapeutic_services
			,fl_mh_services
			,fl_receiving_care
			,fl_family_home_placements
			,fl_behavioral_rehabiliation_services
			,fl_other_therapeutic_living_situations
			,fl_specialty_adolescent_services
			,fl_respite
			,fl_transportation
			,fl_clothing_incidentals
			,fl_sexually_aggressive_youth
			,fl_adoption_support
			,fl_various
			,fl_medical
			,fl_budget_C12
			,fl_budget_C14
			,fl_budget_C15
			,fl_budget_C16
			,fl_budget_C18
			,fl_budget_C19
			,fl_uncat_svc	

			
			
			--select distinct dsch.*
			--from prtl.prtl_outcomes dsch
			--left join prtl.prtl_outcomes sic on sic.date_type=dsch.date_type
			--		and sic.cohort_entry_date=dsch.cohort_entry_date
			--		and sic.qry_type=dsch.qry_type
			--		and sic.cd_discharge_type=0
			--		and sic.int_match_param_key=dsch.int_match_param_key
			--		and dsch.bin_dep_cd=sic.bin_dep_cd
			--		and dsch.bin_los_cd =sic.bin_los_cd
			--		and dsch.bin_placement_cd = sic.bin_placement_cd
			--		and dsch.cd_reporter_type =sic.cd_reporter_type
			--		and dsch.bin_ihs_svc_cd =sic.bin_ihs_svc_cd
			--		and dsch.filter_access_type =sic.filter_access_type
			--		and dsch.filter_allegation =sic.filter_allegation
			--		and dsch.filter_finding  = sic.filter_finding
			--		and dsch.filter_service_type =sic.filter_service_type
			--		and dsch.filter_budget_type =sic.filter_budget_type
			--where dsch.cd_discharge_type > 0 and sic.cohort_entry_date is null
		
			
			update statistics prtl.prtl_outcomes;
			




end
else
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end

