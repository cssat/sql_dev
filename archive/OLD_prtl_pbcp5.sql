USE [dbCoreAdministrativeTables]
GO
/****** Object:  StoredProcedure [dbo].[prod_build_prtl_pbcp5]    Script Date: 11/21/2013 3:21:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[prod_build_prtl_pbcp5](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
	--comments with * (asterik) are from David Marshall spss code. He was kind enough to share it with us.
	--***  "PBC_P5_Placement_reentry_PPM.sps"  syntax for calculating 
	--***  placement re-entry from out-of-home reunification episodes
	--***  using tables from the Data Warehouse.
	--***  Re-entry is calculated within 12 months of exit using an exit cohort,
	--***  "look forward" method for disruption of reunification.
	--***  DCFS custody and initial (exiting) episodes and re-entry episodes 
	--***  with any LOS, per new Federal definition; children returned to care
	--***  before end of a documented six-month Trial Return Home are
	--***  excluded from the re-entry count, per new Federal/WA policy.
	--***
	--***  Like Federal measure, excludes initial episodes with LOS < 8 days.

	--**  select initial placement cohort records: exits to reunification,
	--**  guardianship, or adoption; plus returns to home from TRHs
	--**  by end of cohort period; exclude LOS < 8 days and TRHs of less than 30 days.
	--**  NOTE: plcm_dschtype = 8 is NOT reliable as a TRH indicator;
	--**  does not capture all TRHs, especially for pre-Release 2 records

	-- the logic has been altered from DM initial spss script.  After running the spss code i noted children in the cohort
	-- that did not fit the logic of forced discharge date for trh events more than 6 months in duration 
	-- where the end of the 6 month period (trh begin + 6 months) 
	--  fell within the cohort period  or  the federal discharge date fell within the cohort period.
	/** 2012-10-09  Change for placement settings and federal_discharge_force_18 ... and cd_race_census  **/
	set nocount on
	TRUNCATE TABLE PRTL_PBCP5;

	declare @cohort_entry_date datetime
	declare @cohort_end_date datetime
	declare @date_type int
	declare @cutoff_date datetime
	declare @stop_date datetime

	declare @age_grouping_stop int
	declare @age_grouping_start int

	set @age_grouping_start=(select age_grouping_cd from ref_age_groupings where age_begin=0 and age_lessthan_end < 18 and age_grouping_cd <> 0)
	set @age_grouping_stop=(select age_grouping_cd from ref_age_groupings where age_lessthan_end=18 and age_begin <> 0)

	select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer

	set @cohort_entry_date= '4/1/1999'
	set @cohort_end_date=dateadd(dd,-1,dateadd(mm,3,@cohort_entry_date));
	set @stop_date=dateadd(mm,-3,(select [Quarter] from CA.calendar_dim where calendar_date=@cutoff_date));


	set @date_type=1;

	while @date_type <=2
	begin
		while @cohort_entry_date <=@stop_date
		begin

				
						-- first we will identify the TRH exits to be sure to add them in to our cohort 
						-- if they have at least 6 month TRH duration with no intervening out of home placements
						
						-- identify the 6 month TRH events that would occur within the cohort period
						if object_ID('tempDB..#TRH') is not null drop table #TRH

						select  distinct @cohort_entry_date  as Cohort_Entry_Date
									,@cohort_end_date as Cohort_End_Date
									,tce.First_Removal_Date
									,tce.State_custody_start_date
									,tce.Federal_Discharge_Date_Force_18 as Federal_Discharge_Date
									,tce.State_Discharge_date
									,tce.state_discharge_reason_code
									,tce.state_discharge_reason
									,case when Placement_End_Reason_Code in (38,39,40) then 1 else 0 end as TRHmark
									,case when Placement_End_Reason_Code in (38,39,40) then exit_date else null end as TRH_begin
									,case when Placement_End_Reason_Code in (38,39,40) 
											then dateadd(dd,-1,dateadd(mm,6,exit_date)) else null end as TRH_6Mo_Marker
									,cast(0 as int) as FL_Has_Intervening_OH_Plmnt
									,cast(0 as int) as FL_Last_Placement
									, tcps.id_prsn_child
									, tcps.entry_date_int
									, tcps.exit_date_int
									, tcps.entry_date
									, tcps.exit_date
									, tcps.removal_county_cd
									, tcps.removal_county
									, tcps.placement_provider_caregiver_county_code
									, tcps.placement_provider_caregiver_county
									, tcps.placement_provider_caregiver_id
									, tcps.placement_setting_type_code
									, tcps.placement_setting_type
									, tcps.cd_epsd_type
									, tcps.tx_epsd_type
									, tcps.placement_end_reason_code
									, tcps.placement_end_reason
									, tcps.placement_discharge_reason_code
									, tcps.placement_discharge_reason
									, tcps.placement_care_auth_cd
									, tcps.placement_care_auth
									, tcps.placement_care_auth_tribe_cd
									, tcps.placement_care_auth_tribe
									, tcps.trial_return_home_cd
									, tcps.trial_return_home
									, tcps.trh_begin_date
									, tcps.trh_end_date
									, tcps.cd_srvc
									, tcps.tx_srvc
									, tcps.id_plcmnt_evnt
									, tcps.cd_plcmnt_evnt
									, tcps.id_removal_episode_fact
									, tcps.id_placement_fact
									, tcps.dur_days
									, tcps.fl_dur_7
									, tcps.fl_dur_90
									, tcps.plcm_rank
									, tcps.plcm_total
									, tcps.plcm_ooh_rank
									, tcps.plcm_ooh_total
									, tcps.fl_close
									, tcps.fl_lst_ooh_plcm
									, tcps.fl_lst_plcm
									, tcps.eps_plcm_sort_asc
									,row_number() over (partition by tcps.id_removal_episode_fact 
											order by tcps.id_removal_episode_fact
											,tcps.entry_date desc
											,tcps.exit_date desc) as row_num
						into #TRH
						from  dbo.tbl_child_placement_settings tcps 
							join dbo.tbl_child_episodes tce on  tce.id_removal_episode_fact=tcps.ID_removal_episode_Fact
							join dbo.ref_state_discharge_xwalk sdrx 
										on sdrx.state_discharge_reason_code=tce.state_discharge_reason_code 
										and sdrx.state_discharge_reason_code >0
											and  sdrx.CD_Discharge_Type in (1,3,4)
						 where  ( (CD_EPSD_Type in (1,5) 
								and Placement_End_Reason_Code in (38,39,40))
								and tcps.entry_date between tce.state_custody_start_date 
										and isnull(tce.Federal_Discharge_Date_Force_18,@cutoff_date))
								--and dateadd(dd,-1,dateadd(mm,6,exit_date)) between ref_lookup_cohort.cohort_entry_date  
								--and ref_lookup_cohort.cohort_end_date
								and dateadd(dd,-1,dateadd(mm,6,exit_date)) 
										< isnull(tce.Federal_Discharge_Date_Force_18,@cutoff_date)
								and datediff(dd,tce.state_custody_start_date,tcps.exit_date)>7
						ORDER BY [cohort_entry_date] ,TCPS.ID_PRSN_CHILD,TCE.STATE_CUSTODY_START_DATE,TCPS.ENTRY_DATE
						
						
						
						
						-- mark those who did not have 6 MONTH TRH
						update trh
						set  FL_Has_Intervening_OH_Plmnt=1
						from #TRH trh join tbl_child_placement_settings tcps on tcps.id_removal_episode_fact=trh.id_removal_episode_fact
						where  tcps.entry_date between TRH_begin and TRH_6Mo_Marker
									-- and tcps.CD_EPSD_Type=1
									and tcps.id_placement_fact <> trh.ID_Placement_fact;
									

						-- want the latest TRH  in quarter
					   delete from #TRH where row_num > 1;						
						--select * from #TRH
						
							---------------------------------------------------------------------------------------------------------------------------------------------------------GET SUBSET OF DATA
						if object_ID('tempDB..#FLDW_REMOVAL_EPISODE') is not null drop table #FLDW_REMOVAL_EPISODE
						select distinct  @cohort_entry_date  as Cohort_Entry_Date
									,@cohort_end_date as Cohort_End_Date
									,@date_type as date_type
									  ,tce.[ID_PRSN_CHILD]
									  ,tce.First_Removal_date
									  ,tce.Latest_Removal_date
									  ,tce.[Removal_Region]
									  ,tce.[Removal_County_Cd]
									  ,tce.[Removal_County]
									  ,tce.[State_Custody_Start_Date]
									  ,tce.[State_Discharge_Date]
									  ,tce.[State_Discharge_Reason]
									  ,tce.[State_Discharge_Reason_Code]
									  ,tce.Federal_Discharge_Date_Force_18 as [Federal_Discharge_Date]
									  ,tce.[Federal_Discharge_Reason_Code]
									  ,tce.[Federal_Discharge_Reason]
									  ,tce.[Initial_Plcm_Setting_For_Removal_Cd]
									  ,tce.[Initial_Plcm_Setting_For_Removal]
									  ,tce.[Last_Plcm_Setting_For_Removal_Cd]
									  ,tce.[Last_Plcm_Setting_For_Removal]
									  ,tce.[Removal_County_Initial_Placement_Caregiver_Cd]
									  ,tce.[Removal_County_Initial_Placement_Caregiver]
									  ,tce.[Removal_Initial_Placement_Worker_Office_Cd]
									  ,tce.[Removal_Initial_Placement_Worker_Office]
									  ,tce.[Removal_Initial_Placement_Worker_Office_County_cd]
									  ,tce.[Removal_Initial_Placement_Worker_Office_County]
									 -- ,tce.[Removal_initial_location_dim_placement_county_Cd]
									 --,tce.[Removal_initial_location_dim_placement_county]
									 ,tce.[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON]
									 ,tce.[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD]
									 ,tce.[Removal_Plcm_Discharge_Reason]
									 ,tce.[Removal_Plcm_Discharge_Reason_Cd]
									 ,tce.[CHILD_AGE_REMOVAL_BEGIN]
									 ,tce.[CHILD_AGE_REMOVAL_END]
									 ,tce.[ID_REMOVAL_EPISODE_FACT]
									 ,G.PK_GNDR
									 ,tce.[CD_GNDR]
									 ,tce.[TX_GNDR]
									 ,tce.[DT_BIRTH]
									 ,tce.[CD_RACE_CENSUS] as CD_RACE
									 ,tce.census_hispanic_latino_origin_cd
									  ,frstdesc.tx_plcm_setng as init_tx_plcm_setng
									  ,frstplc.cd_plcm_setng as init_cd_plcm_setng
									  ,lastdesc.tx_plcm_setng as last_tx_plcm_setng
									  ,lastplc.cd_plcm_setng as last_cd_plcm_setng
									,sdrx.CD_Discharge_Type  as dschtype
									,sdrx.Discharge_Type as dschtype_desc
									, pdrx.Placement_Discharge_Type_Cd as plcm_dschtype
									, pdrx.Placement_Discharge_Type  as plcm_dschtype_Desc		
									 ,tce.[Removal_ID_Location_Dim_Worker_County_Cd]
									  ,tce.[Removal_ID_Location_Dim_Worker_County]
									,case when (tce.Removal_neglect=1 or tce.Removal_Parent_Incapacity=1) then 1 else 0 end as FL_NEGLECT
									,case when 	(tce.Removal_Abuse =1 or tce.Removal_Physical_Abuse =1) then 1 else 0 end as FL_ABUSE
									,case when (tce.Removal_Sexual_Abuse =1) then 1 else 0 end as FL_SEXUAL_ABUSE 
									,case when (tce.Removal_Abandon=1 or tce.Removal_Child_Alcohol_Abuse=1   OR tce.Removal_Child_Behavior  =1 or tce.Removal_Child_Disability  =1   OR tce.Removal_Child_Drug_Abuse =1 or tce.Removal_Inadequate_Housing  =1   OR tce.Removal_Incarceration =1 or tce.Removal_Parent_Alcohol_Abuse =1   OR tce.Removal_Parent_Death  =1 or tce.Removal_Parent_Drug_Abuse   =1   OR tce.Removal_Relinquishment =1) then 1 else 0 end as FL_OTHER_ABUSE
									,case when (tce.Removal_neglect=0 AND tce.Removal_Parent_Incapacity=0  AND  tce.Removal_Abuse=0 
												AND tce.Removal_Physical_Abuse=0   AND tce.Removal_Sexual_Abuse=0   AND tce.Removal_Abandon=0 
												AND tce.Removal_Child_Alcohol_Abuse=0   AND tce.Removal_Child_Behavior =0 AND tce.Removal_Child_Disability =0   
												AND tce.Removal_Child_Drug_Abuse=0 AND tce.Removal_Inadequate_Housing =0   AND tce.Removal_Incarceration=0 
												AND tce.Removal_Parent_Alcohol_Abuse=0   AND tce.Removal_Parent_Death =0 AND tce.Removal_Parent_Drug_Abuse  =0   
												AND tce.Removal_Relinquishment=0 ) then 1 else 0 end as FL_MISSING
									, datediff(dd,tce.state_Custody_Start_Date,isnull(tce.Federal_Discharge_Date_Force_18,@cutoff_date)) as Time_In_Care
										, Age.Age_Grouping_Cd as Age_Grouping_Cd
									, Age.Age_Grouping as Age_Grouping
									,isnull(trh.TRHmark,0) as TRHmark
									,trh.TRH_Begin 
									,trh.TRH_6Mo_Marker  
									,cast(null as varchar(1)) as FL_RET_TO_CARE
									,case when  (  tce.Federal_Discharge_Date_Force_18 
									 between @cohort_entry_date and @cohort_end_date
											and datediff(dd,tce.state_custody_start_date, tce.Federal_Discharge_Date_Force_18)>7 )  
											then 1 else 0 end as dschmark
									,case when trh.trhmark is not null then 1 else 0 end as trhdsch
									,cast(0 as int) as rtctrh6mo  -- this is not begin used these are returns to care from TRH before 183 days
									,cast(0 as int) as rtctrhgt6mo -- this is those client with a return to care greater than 6 months 
									,cast(0 as int) as replc -- flag for replacement is true = 1 false = 0
									,cast(null as int) as rpplcid  --  replacement  id_removal_episode_fact
									,cast(null as int) as rpcaseid --replacement   id_case
									,cast(null as datetime) as rppdate -- replacement id_removal_episode_fact
									,cast(null as datetime) as rpepend -- replacement federal discharge date
									,cast(null as int) as rplos -- replacement los
									,cast(null as int) as dayspepd --days between cohort federal discharge date and re-placement episode start date
									,cast(0 as int) as rthomtyp --(Return to home type rolls up the greater than 6 month TRH to reunifications at end)
									,cast(null as int) as combrtc--**  compute combined reunificationss + TRHs dschtype for measure reporting
							into #FLDW_REMOVAL_EPISODE
							from dbo.tbl_child_episodes tce
							--left  join calendar_dim cd on cd.calendar_date=tce.Federal_Discharge_Date_Force_18
							left join dbo.ref_Age_Groupings Age on CHILD_AGE_REMOVAL_BEGIN >=Age.age_begin 
							and CHILD_AGE_REMOVAL_BEGIN < age.Age_LessThan_End
									and age.age_grouping_cd between @age_grouping_start and @age_grouping_stop
							left join dbo.ref_state_discharge_xwalk sdrx 
								on sdrx.state_discharge_reason_code=tce.state_discharge_reason_code 
								and sdrx.state_discharge_reason_code >0
							left join dbo.ref_plcm_discharge_reason_xwalk pdrx 
								on pdrx.Removal_Plcm_Discharge_Reason_Cd = tce.Removal_Plcm_Discharge_Reason_Cd
							left join dbo.ref_plcm_setting_xwalk FP on FP.cd_plcm_setng=tce.Initial_Plcm_Setting_For_Removal_Cd
							left join  dbo.ref_plcm_setting_xwalk LP on LP.cd_plcm_setng=tce.Last_Plcm_Setting_For_Removal_Cd
							-- left join dbo.REF_BRAAM_RACE RC on RC.cd_braam_race=tce.CD_RACE
							left join dbo.ref_lookup_ethnicity_census cen on cen.cd_race_census=tce.cd_race_census
							left join dbo.ref_lookup_gender G on G.CD_GNDR=tce.CD_GNDR
							left join dbo.ref_lookup_county cnty on cnty.County_Cd=tce.Removal_County_Cd
							-- 6 month trial return home with no intervening placements
							left join #TRH trh on trh.id_removal_episode_fact=tce.ID_REMOVAL_EPISODE_FACT 
									and trh.FL_Has_Intervening_OH_Plmnt=0
							left join dbo.ref_lookup_placement_event frstplc on frstplc.id_plcmnt_evnt=tce.init_id_plcmnt_evnt
							left join dbo.ref_lookup_placement_event lastplc on lastplc.id_plcmnt_evnt=tce.last_id_plcmnt_evnt
							left join dbo.ref_lookup_plcmnt frstdesc on frstplc.cd_plcm_setng=frstdesc.cd_plcm_setng
							left join dbo.ref_lookup_plcmnt lastdesc on lastplc.cd_plcm_setng=lastdesc.cd_plcm_setng
						where sdrx.CD_Discharge_Type in (1,3,4)
						 AND ((  tce.Federal_Discharge_Date_Force_18 
											between @cohort_entry_date and @cohort_end_date
									and datediff(dd,tce.state_custody_start_date, tce.Federal_Discharge_Date_Force_18)>7 ) 
							OR  trh.id_removal_episode_fact is not null)
							and tce.Federal_Discharge_Date_Force_18 > tce.STATE_CUSTODY_START_DATE
							ORDER BY  tce.ID_PRSN_CHILD,TCE.STATE_CUSTODY_START_DATE
							
							
							
							
							--only want child in cohort once
							delete eps  
							--select q.eps_order,eps.*
							from #FLDW_REMOVAL_EPISODE eps
							join (select id_prsn_child,id_removal_episode_fact,state_custody_start_date,federal_discharge_date
									 , row_number() over (partition by id_prsn_child order by state_custody_start_date asc) as eps_order
										from #FLDW_REMOVAL_EPISODE) q on q.id_removal_episode_fact=eps.id_removal_episode_fact 
							where  q.eps_order > 1
					 
						

						-- remove forced 18 kids where custody start > federal discharge force 18
						
						delete from #FLDW_REMOVAL_EPISODE where state_custody_start_date >= federal_discharge_date;
						-- this is an update if the reentry happened within same episode with trh at least 6 months in duration
						-- in essence we are splitting the episode into 2 (this should happen very rarely) 
						--reentry episode end is the episode end date if it exists
						--rppdate(reentry episode begin) would be the first placement date following the 6 month TRH event
						--dayspepd (days between episode would be the datediff between the placement exit with trh also
						--known as trh begin date and the first event_begin following the 6 month duration.
							update EPS
							set replc=1
								,rpplcid=trh.id_removal_episode_fact
								,rpcaseid=trh.id_case
								,rppdate=trh.entry_date
								,rpepend=eps.federal_discharge_date
								,rplos=datediff(dd,rppdate,rpepend)
								,dayspepd=datediff(dd,discharge_date,trh.entry_date)
								,rtctrhgt6mo=1
							from #FLDW_REMOVAL_EPISODE EPS
							join (
									select trh.trh_begin as discharge_date
									, tcps.id_prsn_child
									, tcps.entry_date_int
									, tcps.exit_date_int
									, tcps.entry_date
									, tcps.exit_date
									, tcps.removal_county_cd
									, tcps.removal_county
									, tcps.placement_provider_caregiver_county_code
									, tcps.placement_provider_caregiver_county
									, tcps.placement_provider_caregiver_id
									, tcps.placement_setting_type_code
									, tcps.placement_setting_type
									, tcps.cd_epsd_type
									, tcps.tx_epsd_type
									, tcps.placement_end_reason_code
									, tcps.placement_end_reason
									, tcps.placement_discharge_reason_code
									, tcps.placement_discharge_reason
									, tcps.placement_care_auth_cd
									, tcps.placement_care_auth
									, tcps.placement_care_auth_tribe_cd
									, tcps.placement_care_auth_tribe
									, tcps.trial_return_home_cd
									, tcps.trial_return_home
									, tcps.trh_begin_date
									, tcps.trh_end_date
									, tcps.cd_srvc
									, tcps.tx_srvc
									, tcps.id_plcmnt_evnt
									, tcps.cd_plcmnt_evnt
									, tcps.id_removal_episode_fact
									, tcps.id_placement_fact
									, tcps.dur_days
									, tcps.fl_dur_7
									, tcps.fl_dur_90
									, tcps.plcm_rank
									, tcps.plcm_total
									, tcps.plcm_ooh_rank
									, tcps.plcm_ooh_total
									, tcps.fl_close
									, tcps.fl_lst_ooh_plcm
									, tcps.fl_lst_plcm
									, tcps.eps_plcm_sort_asc
									,tce.id_case
									,row_number() over (partition by tcps.id_removal_episode_fact
											order by tcps.id_removal_episode_fact,tcps.entry_date asc,tcps.exit_date asc) as reentry_sort
									from #TRH trh join tbl_child_placement_settings tcps 
										on trh.id_removal_episode_fact=tcps.id_removal_episode_fact
										join tbl_child_episodes tce on tce.id_removal_episode_fact=tcps.id_removal_episode_fact
									where tcps.cd_epsd_type=1 and  tcps.entry_date > TRH_6Mo_Marker and FL_Has_Intervening_OH_Plmnt=0
									 ) trh on eps.id_removal_episode_fact=trh.id_removal_episode_fact and trh.reentry_sort=1
							
			
			
							--update federal discharge date to be TRH_6Mo_Marker for clients forced discharge from TRH
							  update #FLDW_REMOVAL_EPISODE
							  set federal_discharge_date = TRH_6Mo_Marker
							  where TRH_6Mo_Marker is not null and federal_discharge_date > TRH_6Mo_Marker
							  
						
							  delete from #FLDW_REMOVAL_EPISODE where federal_discharge_date not between cohort_entry_date and cohort_end_date;
							
							--remove nonDCFS custody kids
		--					delete
							--from PRTL_PBCP5  eps
							--join dbo.WRK_nonDCFS_All nonDcfs on nondcfs.id_prsn=eps.id_prsn_child
							--		and cust_begin>=state_custody_start_date and cust_begin < federal_discharge_date
							--		and cust_end <> state_custody_start_date
							

						--**  mark subsequent episodes					
						--** copy subsequent episodes variables onto first episodes record
						--** and compute days between episodes
						if object_ID('tempDB..#tmp_eps') is not null drop table #tmp_eps;					
						select eps.id_removal_episode_fact as orig_id_removal_episode_fact
								,eps.state_custody_start_date as orig_state_custody_start_date
								,eps.federal_discharge_date as orig_federal_discharge_date
								,TCE.* 
							,row_number() over (
									partition by eps.id_prsn_child
										order by eps.id_prsn_child,tce.state_custody_start_date asc) as replc
						into #tmp_eps
						from #FLDW_REMOVAL_EPISODE EPS
						join dbo.TBL_CHILD_EPISODES TCE on TCE.ID_PRSN_CHILD=EPS.ID_PRSN_CHILD
						where tce.state_custody_start_date > EPS.state_custody_start_date
							and (datediff(dd,tce.state_custody_start_date,tce.Federal_Discharge_Date_Force_18) >0 
									or tce.Federal_Discharge_Date_Force_18 is null)
							and datediff(dd,eps.federal_discharge_date,tce.state_custody_start_date)>1
							and replc=0;

						update EPS
						set rpplcid=ts.id_removal_episode_fact
								,rpcaseid=ts.id_case
								,rppdate=ts.state_custody_start_date
								,rpepend=ts.federal_discharge_date
								,rplos=datediff(dd,ts.state_custody_start_date,ts.federal_discharge_date)
								,dayspepd=datediff(dd,ts.orig_federal_discharge_date,ts.state_custody_start_date)
								,replc=1
						from #FLDW_REMOVAL_EPISODE EPS
						join #tmp_eps ts on ts.id_prsn_child=eps.id_prsn_child and ts.replc=1
						and ts.orig_id_removal_episode_fact=eps.id_removal_episode_fact;


						--**  merge placement episode start and end dates into events file; select non-temporary cohort events
						--**  create first event relative for episode
					
						if object_ID('tempDB..#evts_temp') is not null drop table #evts_temp

							select tce.*
									,tcps.ID_PLACEMENT_FACT
									,tcps.entry_date
									,tcps.exit_date
									,cast(null as datetime) as rmvl_date
									,tcps.Placement_Setting_Type_Code
									,tcps.Placement_End_Reason_Code
									,tcps.Placement_Discharge_Reason_Code
									,tcps.Placement_Care_Auth_Cd
									,case when tcps.Placement_Setting_Type_Code in (10,11,15) then 1 else 0 end as firstkin
									,case when tcps.Placement_End_Reason_Code in (38,39,40) then 1 else 0 end as TRHEvt
									,cast(0 as int) as postTRHevt
									,datediff(dd,tcps.entry_date,tcps.exit_date) as evtlos
									,case when datediff(dd,tcps.entry_date,tcps.exit_date) < 31 then 1 else 0 end as evtlt31
									,cast(null as int) as ID_PRVD_ORG_CAREGIVER
									,cast(0 as int) as nocbusid
									,cast(0 as int) as FCevtlos
									,cast(0 as int) as PAevtlos
									,cast(0 as int) as Relevtlos
									,cast(0 as int) as GCevtlos
									,cast(0 as int) as Totevtlos
									,cast(0 as int) as CntEvents
									--**  compute collapsed types of placement setting
									--this happens on line 647 in spss code; will update later for PR
								,case when tcps.Placement_Setting_Type_Code in ( -99,1,12,13,17,19) or tcps.Placement_Setting_Type_Code is null  then 5
										when tcps.Placement_Setting_Type_Code in (2,4,5,18) then 1
										when tcps.Placement_Setting_Type_Code in (3,6,7,8,9,14,16) then 4
										when tcps.Placement_Setting_Type_Code in (10,11,15) then 3
									 end as Plctype
									,case when tcps.Placement_Setting_Type_Code in ( -99,1,12,13,17,19) or tcps.Placement_Setting_Type_Code is null  then  cast('Other' as varchar(50))
										when tcps.Placement_Setting_Type_Code in (2,4,5,18) then cast('Family Settings - DCFS' as varchar(50))
										when tcps.Placement_Setting_Type_Code in (3,6,7,8,9,14,16) then 'Group & Institutional Care' 
										when tcps.Placement_Setting_Type_Code in (10,11,15) then 'Relative Care'
									 end as Plctype_Desc
								,row_number() over (
											partition by
												tcps.id_prsn_child
												,tce.state_custody_start_date
												,tce.id_removal_episode_fact
											order by 
												tcps.id_prsn_child
												,tce.state_custody_start_date
												,tce.id_removal_episode_fact
												,tcps.entry_date asc )
												as evt_order
									,row_number() over (
												partition by 	tcps.id_prsn_child
												order by 
													tcps.id_prsn_child
													,tcps.entry_date asc ) 
													as Kin_Order
							into #evts_temp
							from #FLDW_REMOVAL_EPISODE tce
							join dbo.tbl_child_placement_settings tcps on tce.id_removal_episode_Fact=tcps.id_removal_episode_fact
								and tce.id_prsn_child=tcps.id_prsn_child
							where tcps.entry_date >=tce.state_custody_start_date
								and tcps.entry_date <= tce.state_discharge_date
								and tcps.CD_EPSD_TYPE = 1
							ORDER BY tce.Cohort_Entry_Date,TCPS.ID_PRSN_CHILD,TCE.STATE_CUSTODY_START_DATE,TCPS.ENTRY_DATE

							update PLM
							set rmvl_date = dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_RMVL) 
										,PLM.ID_PRVD_ORG_CAREGIVER=pf.ID_PRVD_ORG_CAREGIVER
							from #evts_temp PLM join CA.placement_fact pf on PLM.ID_PLACEMENT_FACT=pf.ID_PLACEMENT_FACT


							update PLM
							set firstkin=0	
							from #evts_temp PLM 
							where Kin_Order > 1 and Placement_Setting_Type_Code in (10,11,15) and firstkin=1
						
						create nonclustered index idx_prsn_child_entry_date on #evts_temp(Cohort_Entry_Date,ID_PRSN_CHILD,STATE_CUSTODY_START_DATE,Entry_Date)
									
									
						--**  select only WA-qualifying events for computing proportions of total LOS in event types  **
						--** count all non-temporary events except those with LOS < 31 days when they
						--** occur as an intermediate event between two events with the same business ID 
						--** (these criteria not used in the Federal definition)
						--**  exclude any events after a TRH from counts			
						if object_id('tempDB..#tempTRH') is not null drop table #tempTRH
						select *,row_number() over (partition by id_prsn_child,rmvl_date
							order by id_prsn_child,rmvl_date,entry_date asc) as plcmnt_order
						into #tempTRH
						from #evts_temp

						update T2
						set postTRHevt = 1
						from #tempTRH TRH
						join #tempTRH  t2 on t2.rmvl_date=trh.rmvl_date
							and t2.ID_PRSN_CHILD=trh.ID_PRSN_CHILD
							and t2.plcmnt_order=trh.plcmnt_order + 1
						where TRH.TRHevt=1

						update T2
						set postTRHevt = 1
						from #tempTRH TRH
						join #tempTRH  t2 on t2.rmvl_date=trh.rmvl_date
							and t2.ID_PRSN_CHILD=trh.ID_PRSN_CHILD
							and t2.plcmnt_order=trh.plcmnt_order + 2
						where TRH.TRHevt=1

						update T2
						set postTRHevt = 1
						from #tempTRH TRH
						join #tempTRH  t2 on t2.rmvl_date=trh.rmvl_date
							and t2.ID_PRSN_CHILD=trh.ID_PRSN_CHILD
							and t2.plcmnt_order=trh.plcmnt_order + 3
						where TRH.TRHevt=1

						update T2
						set postTRHevt = 1
						from #tempTRH TRH
						join #tempTRH  t2 on t2.rmvl_date=trh.rmvl_date
							and t2.ID_PRSN_CHILD=trh.ID_PRSN_CHILD
							and t2.plcmnt_order=trh.plcmnt_order + 4
						where TRH.TRHevt=1

						update T2
						set postTRHevt = 1
						from #tempTRH TRH
						join #tempTRH  t2 on t2.rmvl_date=trh.rmvl_date
							and t2.ID_PRSN_CHILD=trh.ID_PRSN_CHILD
							and t2.plcmnt_order=trh.plcmnt_order + 5
						where TRH.TRHevt=1

				--select if postTRHevt=0 (deleting where 1)
						delete E
						from #tempTRH TRH
						join #evts_temp E on e.id_removal_episode_fact =TRH.id_removal_episode_fact
							and e.id_placement_Fact=trh.id_placement_fact
						where TRH.postTRHevt = 1


						--clean up
						if object_id('tempDB..#tempTRH') is not null drop table #tempTRH

					--** phase 1 of same business ID removal; remove subsequent occurrence
						--** of same business ID AFTER intervening excluded events removed		
							update TE2
							set nocbusid=1
							from #evts_temp TE1
							join #evts_temp TE2 on te1.id_removal_episode_fact=tE2.id_removal_episode_fact
								and te1.ID_PRVD_ORG_CAREGIVER=te2.ID_PRVD_ORG_CAREGIVER
								and te2.evt_order=te1.evt_order + 1
								
						--** phase 2 of same business ID removal; remove later occurrence of
						--** same business ID IF intervening event is < 31 days
						--  shouldn't this be an update to the MIDDLE less than 31 days????
							update TE2
							set nocbusid=1
							from #evts_temp TE1
							join #evts_temp TE2 on te1.id_removal_episode_fact=tE2.id_removal_episode_fact
								and te1.ID_PRVD_ORG_CAREGIVER=te2.ID_PRVD_ORG_CAREGIVER
								and te2.evt_order=te1.evt_order + 2
							join #evts_temp mid on mid.id_removal_episode_fact=tE1.id_removal_episode_fact
								and te1.ID_PRVD_ORG_CAREGIVER<>mid.ID_PRVD_ORG_CAREGIVER
								and mid.evt_order=te1.evt_order + 1
								and mid.evtlt31=1;
								
							update TE2
							set nocbusid=1
							from #evts_temp TE1
							join #evts_temp TE2 on te1.id_removal_episode_fact=tE2.id_removal_episode_fact
								and te1.ID_PRVD_ORG_CAREGIVER=te2.ID_PRVD_ORG_CAREGIVER
								and te2.evt_order=te1.evt_order + 1
								and TE2.evtlt31=1
							where TE1.nocbusid=1;
			
						delete from #evts_temp where nocbusid = 1;

					
								--**  select PA payments in event date ranges
								if object_ID('tempDB..#payments') is not null drop table #payments;
											SELECT distinct  
											e.id_placement_fact
											,e.id_removal_episode_fact
											,e.entry_date
											,e.exit_date
											,payment_fact.ID_PRSN_CHILD
											,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_AUTHORIZATION_BEGIN) as Auth_Begin, 
											dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_AUTHORIZATION_END) as Auth_End,  
											dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_PAYMENT_START) as Payment_Start
											,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_PAYMENT_END) as Payment_End
											, dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN) as Service_Begin
											, dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END) as Service_End
											,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_WARRANT) as Warrant
											  , ID_PLACEMENT_CARE_AUTH_DIM
											  , ID_PLACEMENT_TYPE_DIM
											  ,CD_SSPS_RPT_UNIT, AM_RATE, AM_TOTAL_PAID, AM_UNITS,  ID_PRVD_ORG_PAYEE 
											,std.ID_SERVICE_TYPE_DIM,std.CD_SRVC,std.TX_SRVC
											,row_number() over (
													partition by e.id_prsn_child ,e.entry_date
														order by  e.id_prsn_child ,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_PAYMENT_START)  asc ) as Row_Order
											,case when CD_SRVC in (298,299,300,301,302,303,304,468,473,475,477,
													878,879,880,881,882,883,1499,1500,1501,1502,1503,1504,119003) then 1 else 0 end as PAmark
											,case when CD_SRVC in (298,299,300,301,302,303,304,468,473,475,477,
													878,879,880,881,882,883,1499,1500,1501,1502,1503,1504,119003) then 'Private Agency FC'  else 'Not PA' end as PAmark_Desc
											into #payments
											 FROM CA.PAYMENT_FACT  
											join #evts_temp e 
												on e.id_prsn_child= PAYMENT_FACT.id_prsn_child 
														and dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_PAYMENT_START) >= e.entry_date 
														and dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_PAYMENT_END) <= isnull(e.exit_date,@cutoff_date)
											left join CA.SERVICE_TYPE_DIM std 
													on std.ID_SERVICE_TYPE_DIM=PAYMENT_FACT.ID_SERVICE_TYPE_DIM
										WHERE CD_SRVC  IN (298,299,300,301,302,303,304,468,473,475,477,
																			 878,879,880,881,882,883,1499,1500,1501,1502,
																			 1503,1504,119003)
										  
										delete  from #payments where row_order > 1

									create nonclustered index idx_pymnt_removal_episode_placement on #payments(id_removal_episode_fact,id_placement_fact)


						--**  add PA markers to working events file
						--**  divide 'Family Settings' into private agency and DCFS sub-buckets
									update E
										set Plctype = 2,Plctype_Desc='Family Settings - Private Agency' 
										from #evts_temp E
										join #payments P on E.id_removal_episode_fact=P.id_removal_episode_fact 
											and E.id_placement_fact=p.id_placement_Fact
											and Plctype=1;
											
						--**  compute event LOS in different major event types 					
										update #evts_temp
										set FCevtlos = evtlos where plctype=1

										update #evts_temp
										set PAevtlos = evtlos where plctype=2
										update #evts_temp
										set Relevtlos = evtlos where plctype=3
										update #evts_temp
										set GCevtlos = evtlos where plctype=4
						--  N_alladj is CntEvents
						--** merge aggregated LOS variables into working episode file
										--update #FLDW_REMOVAL_EPISODE
										--set FCevtlos=q.FCevtlos
										--	,PAevtlos=q.PAevtlos
										--	,Relevtlos=q.Relevtlos
										--	,GCevtlos=q.GCevtlos
										--	,Totevtlos=q.Totevtlos
										--	,CntEvents = q.CntEvents
										--from (
										--		select id_removal_episode_fact
										--			,sum(FCevtlos) as  FCevtlos
										--			,sum(PAevtlos) as PAevtlos
										--			,sum(Relevtlos) as Relevtlos
										--			,sum(GCevtlos) as GCevtlos
										--			, sum(evtLOS) as Totevtlos
										--			, count(distinct id_placement_fact) as CntEvents
										--		from #evts_temp
										--		group by id_removal_episode_Fact
										--	) q where q.id_removal_episode_fact=#FLDW_REMOVAL_EPISODE.id_removal_episode_fact
											
											
										--	update #FLDW_REMOVAL_EPISODE
										--	set Nbr_Event_Grouping = 1,Nbr_Event_Grouping_Desc='1-2'
										--	where CntEvents in (1,2)
										--	update #FLDW_REMOVAL_EPISODE
										--	set Nbr_Event_Grouping = 2,Nbr_Event_Grouping_Desc='3-4'
										--	where CntEvents in (3,4)
										--	update #FLDW_REMOVAL_EPISODE
										--	set Nbr_Event_Grouping = 2,Nbr_Event_Grouping_Desc='5-10'
										--	where CntEvents between 5 and 10
										--	update #FLDW_REMOVAL_EPISODE
										--	set Nbr_Event_Grouping = 2,Nbr_Event_Grouping_Desc=' Greater Than 10'
										--	where CntEvents   > 10
											

											
										--update #FLDW_REMOVAL_EPISODE
										--set propFC = FCevtlos/(Totevtlos * 1.00)
										--	,propRel=Relevtlos/(Totevtlos * 1.00)
										--	,propPA=PAevtlos/(Totevtlos * 1.00)
										--	,propGC=GCevtlos/(Totevtlos * 1.00)
										--where Totevtlos > 0

										--update #FLDW_REMOVAL_EPISODE
										--set plcsetngtype=1
										--		,plcsetngtype_Desc='75%+ in DCFS Non-relative FC'
										--where propFC >=.75
												
										--update #FLDW_REMOVAL_EPISODE
										--set plcsetngtype=2
										--		,plcsetngtype_Desc= '75%+ in Relative FC'
										--where propRel >=.75
										--update #FLDW_REMOVAL_EPISODE
										--set plcsetngtype=3
										--		,plcsetngtype_Desc= '75%+ in Private Agency'
										--where propPA >=.75		
										--update #FLDW_REMOVAL_EPISODE
										--set plcsetngtype=4
										--		,plcsetngtype_Desc= '75%+ in Group/Institutional Care'
										--where propGC>=.75		
										--update #FLDW_REMOVAL_EPISODE
										--set plcsetngtype=5
										--		,plcsetngtype_Desc= '75% in any particular type (mixed settings)'
										--where plcsetngtype=0

										--update #FLDW_REMOVAL_EPISODE
										--set anyGC=1 where propGC > 0;
				

						--**  compute reporting periods
						if object_ID('tempDB..#PBCP5_PRTL') is not null drop table #PBCP5_PRTL;
						select *
								, cast(0 as int) as retc3  
								,cast(0 as int) as retc6  
								,cast(0 as int) as retc9  
								,cast(0 as int) as retc12 
								,cast(0 as int) as retc15 
								,cast(0 as int) as retc18 
								,cast(0 as int) as retc21 
								,cast(0 as int) as retc24 
								,cast(0 as int) as retc27 
								,cast(0 as int) as retc30 																		
								,cast(0 as int) as retc33 
								,cast(0 as int) as retc36  
								,cast(0 as int) as retc39  
								,cast(0 as int) as retc42  
								,cast(0 as int) as retc45  
								,cast(0 as int) as retc48  
								,cast(0 as int) as retcgt48
						into #PBCP5_PRTL
						from #FLDW_REMOVAL_EPISODE

						update #PBCP5_PRTL
						set retc3=1
						where dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=3
						and rppdate is not null -- and combrtc=1 

						update #PBCP5_PRTL
						set retc6=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=6
						and rppdate is not null

						update #PBCP5_PRTL
						set retc9=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=9
						and rppdate is not null


						update #PBCP5_PRTL
						set retc12=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=12
						and rppdate is not null

						update #PBCP5_PRTL
						set retc15=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=15
						and rppdate is not null

						update #PBCP5_PRTL
						set retc18=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=18
						and rppdate is not null

						update #PBCP5_PRTL
						set retc21=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=21
						and rppdate is not null

						update #PBCP5_PRTL
						set retc24=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=24
						and rppdate is not null

						update #PBCP5_PRTL
						set retc27=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=27
						and rppdate is not null

						update #PBCP5_PRTL
						set retc30=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=30
						and rppdate is not null

						update #PBCP5_PRTL
						set retc33=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=33
						and rppdate is not null

						update #PBCP5_PRTL
						set retc36=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=36
						and rppdate is not null

						update #PBCP5_PRTL
						set retc39=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=39
						and rppdate is not null

						update #PBCP5_PRTL
						set retc42=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=42
						and rppdate is not null

						update #PBCP5_PRTL
						set retc45=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=45
						and rppdate is not null

						update #PBCP5_PRTL
						set retc48=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) <=48
						and rppdate is not null

						update #PBCP5_PRTL
						set retcgt48=1
						where  dbo.fnc_datediff_mos(federal_discharge_date,rppdate) >48
						and rppdate is not null

			
						insert into dbo.PRTL_PBCP5
						select *  from #PBCP5_PRTL
						where age_grouping_cd is not null
			if @date_type = 1
				begin
					set @cohort_entry_date=dateadd(mm,3,@cohort_entry_date);
					set @cohort_end_date=dateadd(dd,-1,dateadd(mm,3,@cohort_entry_date))
				end
			else
				begin
					set @cohort_entry_date=dateadd(yy,1,@cohort_entry_date);
					set @cohort_end_date=dateadd(dd,-1,dateadd(yy,1,@cohort_entry_date))
				end;
		end
		set @date_type=@date_type+1;
		set @cohort_entry_date='1/1/2000';
		set @cohort_end_date=dateadd(dd,-1,dateadd(yy,1,@cohort_entry_date))
		set @stop_date=dateadd(yy,-1,(select [Year] from CA.calendar_dim where calendar_date=@cutoff_date));
		
	end

end -- if permission
else
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end
