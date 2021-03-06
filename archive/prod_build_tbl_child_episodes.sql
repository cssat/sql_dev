USE [dbCoreAdministrativeTables]
GO
/****** Object:  StoredProcedure [dbo].[prod_build_tbl_child_episodes]    Script Date: 8/21/2013 3:54:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[prod_build_tbl_child_episodes](@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin


		---- SET VARIABLES
		declare @removal_start_int int
		set  @removal_start_int= 19980101


		declare @start_date datetime
		set @start_date= convert(datetime ,cast(@removal_start_int as varchar(8)),112)
		declare @cutoff_date datetime
		select @cutoff_date=cutoff_date from ref_Last_DW_Transfer
		-- used in data clean up
		declare @loop int		
		declare @maxloop int	

		----------------------------------------------------------------------------------------------------------------------- Build  temp Episode table 

		--  Build  temp Episode table 
		if object_ID('tempDB..#REMOVALS') is not null drop table #REMOVALS
				select 
							ID_PRSN_CHILD
							,ID_PEOPLE_DIM_CHILD
							,ID_CALENDAR_DIM_BEGIN
							,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN) as eps_begin
							,ID_CALENDAR_DIM_END
							,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END) as eps_end
							,ID_REMOVAL_EPISODE_FACT as ID_REMOVAL_EPISODE_FACT
							,ID_CASE
							,CAST(NULL AS int) AS COUNTY
							,CAST(NULL AS int) AS OFFICE
							,CAST(NULL AS INT) AS REGION
							,CAST(NULL AS int) AS INVS_COUNTY
							,CAST(NULL AS int) AS INVS_OFFICE
							,CAST(NULL AS INT) AS INVS_REGION
				into #REMOVALS
				from CA.removal_episode_fact
				 join CA.PEOPLE_DIM pd on pd.id_people_dim=removal_episode_fact.id_people_dim_child 
		where  FL_IN_ERROR=0 
					and ((ID_CALENDAR_DIM_BEGIN >=@removal_start_int)
					or (ID_CALENDAR_DIM_BEGIN < @removal_start_int 
					and (ID_CALENDAR_DIM_END = 0 or ID_CALENDAR_DIM_END > @removal_start_int)))
					

		CREATE CLUSTERED INDEX PK_LAST_UPDATE_CHILD_EPISODE ON #REMOVALS(ID_PRSN_CHILD,ID_CALENDAR_DIM_BEGIN)
		create nonclustered index pk_luc_id_case on #REMOVALS(id_case)
		update statistics #REMOVALS
		
		CREATE NONCLUSTERED INDEX idx_tmp_removals_region_inc_date_ref
		ON #REMOVALS (REGION)
		INCLUDE (ID_PRSN_CHILD,ID_CALENDAR_DIM_BEGIN,ID_REMOVAL_EPISODE_FACT)
		

		--get primary investigation assignment location partition  by case, removal date
		IF OBJECT_ID('TEMPDB..#ASSMT_CASE_REMOVAL_MATCH') IS NOT NULL DROP TABLE #ASSMT_CASE_REMOVAL_MATCH
			SELECT  
						  rem.ID_CASE
						, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN) AS asgn_date
						, abs(datediff(dd, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN),dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin))) as diff
						, loc.CD_REGION AS region
						, loc.CD_OFFICE AS office
						, loc.CD_CNTY AS county  
						, row_number ()over (
								partition by rem.id_case
											,dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin) 
								order by rem.id_case
											,dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin)
										, abs(datediff(dd, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN)
										,dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin)))asc
										, CD_ASGN_TYPE desc)   as assgnmt_order
		INTO #ASSMT_CASE_REMOVAL_MATCH
		FROM #REMOVALS rem
				LEFT JOIN CA.ASSIGNMENT_FACT asf 
					ON rem.id_case = asf.ID_CASE  
				LEFT JOIN CA.LOCATION_DIM loc
					ON asf.ID_LOCATION_DIM = loc.ID_LOCATION_DIM AND LOC.ID_LOCATION_DIM >=1
				LEFT JOIN CA.ASSIGNMENT_ATTRIBUTE_DIM aad
					ON asf.ID_ASSIGNMENT_ATTRIBUTE_DIM = aad.ID_ASSIGNMENT_ATTRIBUTE_DIM
			WHERE
				 CD_ASGN_CTGRY = 1 AND CD_ASGN_ROLE = 1 -- select primary assignment worker
				AND CD_ASGN_TYPE IN (4,5,8,9)  -- DCFS workers
				
	CREATE NONCLUSTERED INDEX idx_tmp_assmt_case
			ON #ASSMT_CASE_REMOVAL_MATCH (assgnmt_order)
			INCLUDE (ID_CASE,region,office,county)	;			
			
		--update the  location with closest assignment for the case
			UPDATE REM
			SET  REGION=ACMR.REGION
					,OFFICE=ACMR.OFFICE
					,COUNTY=ACMR.COUNTY
			FROM #REMOVALS REM 
					JOIN #ASSMT_CASE_REMOVAL_MATCH ACMR 
						ON ACMR.ID_CASE=REM.ID_CASE AND assgnmt_order=1
					
		--get removal_location_worker if assignment is blank		
			UPDATE REM
			SET  REGION=LD.CD_REGION
					,OFFICE=LD.CD_OFFICE
					,COUNTY=LD.CD_CNTY
			FROM #REMOVALS REM 
					JOIN CA.REMOVAL_EPISODE_FACT REFT ON REFT.ID_REMOVAL_EPISODE_FACT=REM.ID_REMOVAL_EPISODE_FACT
					JOIN CA.LOCATION_DIM LD ON LD.ID_LOCATION_DIM=REFT.ID_LOCATION_DIM_WORKER AND ID_LOCATION_DIM >=1
		 WHERE REM.REGION IS NULL


		--clean up
		IF OBJECT_ID('TEMPDB..#ASSMT_CASE_REMOVAL_MATCH') IS NOT NULL DROP TABLE #ASSMT_CASE_REMOVAL_MATCH

		--get location of investigation worker
		IF OBJECT_ID('TEMPDB..#INVS_CASE_REMOVAL_MATCH') IS NOT NULL DROP TABLE #INVS_CASE_REMOVAL_MATCH
		select rem.ID_CASE
				,dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin) as Eps_Start_Date
				,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_LEVEL1_APPROVED) as Apprvl_Date_lvl1
				,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_LEVEL2_APPROVED) as Apprvl_Date_lvl2
				, loc.CD_REGION AS region
				, loc.CD_OFFICE AS office
				, loc.CD_CNTY AS county  
				,abs(datediff(dd, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_LEVEL1_APPROVED),dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin))) as diff_lvl1
				,abs(datediff(dd, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_LEVEL2_APPROVED),dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin))) as diff_lvl2
				, row_number ()over (
								partition by rem.id_case
											,dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin) 
								order by rem.id_case
											,dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin)
											, abs(datediff(dd, dbo.IntDate_to_CalDate(
													case when asf.ID_CALENDAR_DIM_LEVEL1_APPROVED=0  then ID_CALENDAR_DIM_LEVEL2_APPROVED 
															when asf.ID_CALENDAR_DIM_LEVEL1_APPROVED > ID_CALENDAR_DIM_LEVEL2_APPROVED 
																and ID_CALENDAR_DIM_LEVEL2_APPROVED <> 0  then ID_CALENDAR_DIM_LEVEL2_APPROVED 
															else ID_CALENDAR_DIM_LEVEL1_APPROVED 
													end),dbo.IntDate_to_CalDate(rem.id_calendar_dim_begin)))asc) as sort_cnt
		into #INVS_CASE_REMOVAL_MATCH
		FROM #REMOVALS rem
				 JOIN CA.investigation_assessment_fact asf 
					ON rem.id_case = asf.ID_CASE  
				LEFT JOIN CA.WORKER_DIM wd
					ON asf.ID_WORKER_DIM = wd.ID_WORKER_DIM 
				left join CA.location_dim loc on loc.id_location_dim=wd.id_location_dim_worker


			UPDATE REM
			SET  INVS_REGION=ACMR.REGION
					,INVS_OFFICE=ACMR.OFFICE
					,INVS_COUNTY=ACMR.COUNTY
			FROM #REMOVALS REM 
					JOIN #INVS_CASE_REMOVAL_MATCH ACMR ON ACMR.ID_CASE=REM.ID_CASE AND sort_cnt=1



		--------------------------------------------------------------------------------------------------------------------------------------------------------------FIRST PLACEMENTS

		if object_ID('tempDB..#Q_Placement') is not null drop table  #Q_Placement
		--get initial & last  placements matching on id_removal_episode_fact, id_prsn_child
		select 
				 pf.ID_PRSN_CHILD
				, pf.ID_CALENDAR_DIM_BEGIN
				, dbo.IntDate_to_CalDate(pf.ID_CALENDAR_DIM_BEGIN) as evt_begin
				,pf.ID_CALENDAR_DIM_END
				,dbo.IntDate_to_CalDate(pf.ID_CALENDAR_DIM_END) as evt_end
				, pf.ID_PLACEMENT_FACT
				, pf.ID_REMOVAL_EPISODE_FACT 
				, pf.id_service_type_dim
				, ptd.cd_epsd_type
				, row_number() over (partition by pf.id_removal_episode_fact 
						order by pf.id_removal_episode_fact
						,dbo.IntDate_to_CalDate(pf.ID_Calendar_dim_Begin) asc
						,isnull(dbo.IntDate_to_CalDate(pf.ID_Calendar_dim_End),'12-31-3999') desc) as First_plcmnt
				, row_number() over (partition by pf.id_removal_episode_fact 
						order by pf.id_removal_episode_fact
						,dbo.IntDate_to_CalDate(pf.ID_Calendar_dim_Begin) desc
						,isnull(dbo.IntDate_to_CalDate(pf.ID_Calendar_dim_End),'12-31-3999') desc) as Last_plcmnt
				, cast(null as int) ooh_plcm_sort_desc

		into #Q_Placement
		from CA.PLACEMENT_FACT PF
		join CA.placement_type_dim ptd on ptd.id_placement_type_dim=pf.id_placement_type_dim
		join #REMOVALS REM  
		on REM.ID_REMOVAL_EPISODE_FACT=pf.ID_REMOVAL_EPISODE_FACT
		-- where ptd.[CD_EPSD_TYPE]=1

		update Q
		set ooh_plcm_sort_desc=q2.ooh_plcm_sort_desc
		from #Q_Placement Q
		join (select id_placement_fact
						,row_number() over (partition by id_removal_episode_fact 
						order by id_removal_episode_fact
						,evt_begin desc
						,isnull(evt_end,'12-31-3999') desc) as ooh_plcm_sort_desc 
						from #Q_Placement where cd_epsd_type=1) Q2 on Q.id_placement_fact=Q2.id_placement_fact



		if object_ID('tempDB..#First_Placements') is not null drop table #First_Placements

						select 
								 pf.ID_PRSN_CHILD
								, pf.ID_CALENDAR_DIM_BEGIN
								, lsd.CD_LGL_STAT
								, lsd.TX_LGL_STAT
								, PD.CD_PHYS_COUNTY AS Removal_County_Initial_Placement_Caretaker
								, ld.cd_office  as Removal_Initial_Placement_Worker_Office_CD
								, ld.cd_cnty as Removal_Initial_Placement_Worker_Office_County_CD
								, ld.cd_region  as Removal_Initial_Placement_Worker_Region_Cd
								, ld2.cd_cnty AS Removal_initial_location_dim_placement_county
								, ptd.CD_EPSD_TYPE
								, ptd.TX_EPSD_TYPE
								, ptd.CD_PLCM_SETNG
								, ptd.TX_PLCM_SETNG
								, std.cd_srvc
								, pf.ID_PROVIDER_DIM_CAREGIVER as frst_plc_id_provider
								, case when CD_PLCM_SETNG=1 then 1
										when CD_PLCM_SETNG in (6,8) then 2
										when CD_PLCM_SETNG=2 then 3
										when CD_PLCM_SETNG in (4,7,14,16) then 4
										when CD_PLCM_SETNG in (3,9) then 5
										when CD_PLCM_SETNG=5 then 6
										when CD_PLCM_SETNG =17 then 8
										when CD_PLCM_SETNG in (10,11) then 9
										when CD_PLCM_SETNG in (12,13) then 10
										when CD_PLCM_SETNG =15 then 11
										when CD_PLCM_SETNG =18 then 13
									end as id_plcmnt_evnt
								, cast(null as char(3)) as cd_plcmnt_evnt
								, Q_Initial_Placement.ID_PLACEMENT_FACT
								, Q_Initial_Placement.ID_REMOVAL_EPISODE_FACT
						into #First_Placements		
						from CA.PLACEMENT_FACT pf
						 join #Q_Placement Q_Initial_Placement
										on Q_Initial_Placement.ID_REMOVAL_EPISODE_FACT=pf.ID_REMOVAL_EPISODE_FACT
										and Q_Initial_Placement.ID_PRSN_CHILD=pf.ID_PRSN_CHILD 
										and Q_Initial_Placement.ID_CALENDAR_DIM_BEGIN=pf.ID_CALENDAR_DIM_BEGIN
										and Q_Initial_Placement.ID_PLACEMENT_FACT=pf.ID_PLACEMENT_FACT
										and Q_Initial_Placement.First_plcmnt=1
						left join CA.placement_type_dim ptd on ptd.ID_PLACEMENT_TYPE_DIM=pf.ID_PLACEMENT_TYPE_DIM
						left join CA.service_type_dim std on std.ID_service_type_dim=pf.ID_service_type_dim
						left join CA.LEGAL_STATUS_DIM lsd on lsd.ID_LEGAL_STATUS_DIM=pf.ID_LEGAL_STATUS_DIM
						--ID_PROVIDER_DIM_CAREGIVER
						left join CA.provider_dim pd on pd.ID_PROVIDER_DIM=pf.ID_PROVIDER_DIM_CAREGIVER AND PD.TX_PHYS_COUNTY <>'-'
						--ID_LOCATION_DIM_WORKER 
						left join CA.location_dim ld on ld.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_WORKER and ld.id_location_dim > 0
						--ID_LOCATION_DIM_PLACEMENT
						left join CA.location_dim ld2 on ld2.id_location_dim=pf.id_location_dim_placement and ld2.id_location_dim > 0

			
				
					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt
					from #First_Placements r
					,dbo.ref_lookup_placement_event plc 
					where plc.id_plcmnt_evnt=10
					and R.id_plcmnt_evnt is null



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #First_Placements R
					join dbo.ref_lookup_placement_event plc on plc.id_plcmnt_evnt=11
					where  cd_srvc=342 and R.id_plcmnt_evnt=10;




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #First_Placements R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=3
					where  cd_srvc=1758 and R.id_plcmnt_evnt=10;



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #First_Placements R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=10
					where  cd_srvc=245000 and R.id_plcmnt_evnt=10;




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #First_Placements R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=5
					where  cd_srvc=2



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #First_Placements R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=12
					where  cd_srvc in (405,1768)




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #First_Placements R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=7
					where  cd_srvc in (1776,1777)


					update R
					set cd_plcmnt_evnt=plc.cd_plcmnt_evnt
					from #First_Placements r
					,dbo.ref_lookup_placement_event plc 
					where R.id_plcmnt_evnt=plc.id_plcmnt_evnt

		CREATE CLUSTERED INDEX PK_ID_FIRST_PLCMNT ON  #First_Placements(ID_PRSN_CHILD,ID_CALENDAR_DIM_BEGIN)

		---------------------------------------------------------------------------------------------------------------------------------------end first placement for removal
		---------------------------------------------------------------------------------------------------------------------------------------begin LATEST PLACEMENT FOR REMOVAL
		if object_ID('tempDB..#Last_Removal_Placement') is not null drop table #Last_Removal_Placement

						select 
								 pf.ID_PRSN_CHILD
								, pf.ID_CALENDAR_DIM_BEGIN
								, lsd.CD_LGL_STAT
								, lsd.TX_LGL_STAT
								, PD.CD_PHYS_COUNTY AS Removal_County_Last_Placement_Caretaker
								, ld.cd_office  as Removal_Last_Placement_Worker_Office_CD
								, ld.cd_cnty as Removal_Last_Placement_Worker_Office_County_CD
								, ld.cd_region  as Removal_Last_Placement_Worker_Region_Cd
								, ld2.CD_CNTY AS Removal_Last_location_dim_placement_county
								, ptd.CD_EPSD_TYPE
								, ptd.TX_EPSD_TYPE
								, ptd.CD_PLCM_SETNG
								, ptd.TX_PLCM_SETNG
								, std.cd_srvc
								, pf.ID_PROVIDER_DIM_CAREGIVER as lst_plc_id_provider
								, case when CD_PLCM_SETNG=1 then 1
										when CD_PLCM_SETNG in (6,8) then 2
										when CD_PLCM_SETNG=2 then 3
										when CD_PLCM_SETNG in (4,7,14,16) then 4
										when CD_PLCM_SETNG in (3,9) then 5
										when CD_PLCM_SETNG=5 then 6
										when CD_PLCM_SETNG =17 then 8
										when CD_PLCM_SETNG in (10,11) then 9
										when CD_PLCM_SETNG in (12,13) then 10
										when CD_PLCM_SETNG =15 then 11
										when CD_PLCM_SETNG =18 then 13
									end as id_plcmnt_evnt
								, cast(null as char(3)) as cd_plcmnt_evnt
								, Q_Last_Placement.ID_PLACEMENT_FACT
								, Q_Last_Placement.ID_REMOVAL_EPISODE_FACT
						into #Last_Removal_Placement		
						from CA.PLACEMENT_FACT pf  
						 join #Q_Placement Q_Last_Placement
										on  Q_Last_Placement.id_removal_episode_fact=pf.id_removal_episode_fact
										and  Q_Last_Placement.ID_PRSN_CHILD=pf.ID_PRSN_CHILD 
										and Q_Last_Placement.ID_CALENDAR_DIM_BEGIN=pf.ID_CALENDAR_DIM_BEGIN
										and Q_Last_Placement.ID_PLACEMENT_FACT=pf.ID_PLACEMENT_FACT
										and Q_Last_Placement.Last_plcmnt=1
						left join CA.placement_type_dim ptd on ptd.ID_PLACEMENT_TYPE_DIM=pf.ID_PLACEMENT_TYPE_DIM
						left join CA.service_type_dim std on std.ID_service_type_dim=pf.ID_service_type_dim
						left join CA.LEGAL_STATUS_DIM lsd on lsd.ID_LEGAL_STATUS_DIM=pf.ID_LEGAL_STATUS_DIM
						--ID_PROVIDER_DIM_CAREGIVER
						left join CA.provider_dim pd on pd.ID_PROVIDER_DIM=pf.ID_PROVIDER_DIM_CAREGIVER AND PD.TX_PHYS_COUNTY <>'-'
						--ID_LOCATION_DIM_WORKER 
						left join CA.location_dim ld on ld.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_WORKER and ld.id_location_dim > 0
						--ID_LOCATION_DIM_PLACEMENT
						left join CA.location_dim ld2 on ld2.id_location_dim=pf.id_location_dim_placement and ld2.id_location_dim > 0

					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt
					from #Last_Removal_Placement r
					,dbo.ref_lookup_placement_event plc 
					where plc.id_plcmnt_evnt=10
					and R.id_plcmnt_evnt is null



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #Last_Removal_Placement R
					join dbo.ref_lookup_placement_event plc on plc.id_plcmnt_evnt=11
					where  cd_srvc=342 and R.id_plcmnt_evnt=10;




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #Last_Removal_Placement R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=3
					where  cd_srvc=1758 and R.id_plcmnt_evnt=10;



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #Last_Removal_Placement R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=10
					where  cd_srvc=245000 and R.id_plcmnt_evnt=10;




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #Last_Removal_Placement R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=5
					where  cd_srvc=2



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #Last_Removal_Placement R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=12
					where  cd_srvc in (405,1768)




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from #Last_Removal_Placement R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=7
					where  cd_srvc in (1776,1777)
					
					update R
					set cd_plcmnt_evnt=plc.cd_plcmnt_evnt
					from #Last_Removal_Placement r
					,dbo.ref_lookup_placement_event plc 
					where R.id_plcmnt_evnt=plc.id_plcmnt_evnt


					
	--	if object_ID('tempDB..#Q_Placement') is not null drop table  #Q_Placement				
		CREATE CLUSTERED INDEX PK_ID_LAST_PLCMNT ON  #Last_Removal_Placement(ID_PRSN_CHILD,ID_CALENDAR_DIM_BEGIN)

		--------------------------------------------------------------------------------------------------------------------------------------------END LATEST PLACEMENT FOR REMOVAL
		-- LOAD Temporary table with all episodes
		
		if object_id('tempDB..#child_episodes') is not null drop table #child_episodes;
		
		CREATE TABLE #child_episodes(
			[ID_PRSN_CHILD] [int] NULL,
			[ID_CASE] [int] NULL,
			[First_Removal_Date] [datetime] NULL,
			[Latest_Removal_Date] [datetime] NULL,
			[Removal_Region] [int] NULL,
			[Removal_County_Cd] [int] NULL,
			[Removal_County] [varchar](255) NULL,
			[State_Custody_Start_Date] [datetime] NULL,
			[REMOVAL_EPISODE_BEGIN_INT] [int] NOT NULL,
			[REMOVAL_EPISODE_END_INT] [int] NULL,
			[State_Discharge_Date] [datetime] NULL,
			[State_Discharge_Reason] [varchar](200) NULL,
			[State_Discharge_Reason_Code] [int] NULL,
			[Federal_Discharge_Date] [datetime] NULL,
			[Federal_Discharge_Date_Force_18] [datetime] NULL,
			[Federal_Discharge_Reason_Code] [int] NULL,
			[Federal_Discharge_Reason] [varchar](255) NULL,
			[Initial_Plcm_Setting_For_Removal_Cd] [int] NULL,
			[Initial_Plcm_Setting_For_Removal] [varchar](200) NULL,
			[init_id_plcmnt_evnt] [int] NULL,
			[init_cd_plcmnt_evnt] [char](3) NULL,
			[Last_Plcm_Setting_For_Removal_Cd] [int] NULL,
			[Last_Plcm_Setting_For_Removal] [varchar](200) NULL,
			[last_id_plcmnt_evnt] [int] NULL,
			[last_cd_plcmnt_evnt] [char](3) NULL,
			[Removal_County_Initial_Placement_Caregiver_Cd] [int] NULL,
			[Removal_County_Initial_Placement_Caregiver] [varchar](200) NULL,
			[Removal_Initial_Placement_Worker_Office_Cd] [int] NULL,
			[Removal_Initial_Placement_Worker_Office] [varchar](200) NULL,
			[Removal_Initial_Placement_Worker_Office_County_cd] [varchar](4) NULL,
			[Removal_Initial_Placement_Worker_Office_County] [varchar](255) NULL,
			--[Removal_initial_location_dim_placement_county_Cd] [varchar](4) NULL,
			--[Removal_initial_location_dim_placement_county] [varchar](200) NULL,
			[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON] [varchar](200) NULL,
			[Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD] [int] NULL,
			[Removal_Plcm_Discharge_Reason] [varchar](200) NULL,
			[Removal_Plcm_Discharge_Reason_Cd] [int] NULL,
			[Disability_Diagnosis] [tinyint] NULL,
			[Disability_Physical] [char](1) NULL,
			[Disability_Sensory] [char](1) NULL,
			[Disability_MR] [char](1) NULL,
			[Disability_Emotional] [char](1) NULL,
			[Disability_Other] [char](1) NULL,
			[Removal_Abuse] [tinyint] NULL,
			[Removal_Abandon] [tinyint] NULL,
			[Removal_Relinquishment] [tinyint] NULL,
			[Removal_Child_Alcohol_Abuse] [tinyint] NULL,
			[Removal_Child_Behavior] [tinyint] NULL,
			[Removal_Child_Drug_Abuse] [tinyint] NULL,
			[Removal_Child_Disability] [int] NOT NULL,
			[Removal_Inadequate_Housing] [tinyint] NULL,
			[Removal_Neglect] [tinyint] NULL,
			[Removal_Parent_Alcohol_Abuse] [tinyint] NULL,
			[Removal_Parent_Drug_Abuse] [tinyint] NULL,
			[Removal_Parent_Incapacity] [tinyint] NULL,
			[Removal_Physical_Abuse] [tinyint] NULL,
			[Removal_Sexual_Abuse] [tinyint] NULL,
			[Removal_Parent_Death] [tinyint] NULL,
			[Removal_Incarceration] [int] NULL,
			[CHILD_AGE_REMOVAL_BEGIN] [int] NULL,
			[CHILD_AGE_REMOVAL_END] [int] NULL,
			[ID_REMOVAL_EPISODE_FACT] [int] NOT NULL,
			[CD_GNDR] [char](1) NULL,
			[TX_GNDR] [varchar](200) NULL,
			[DT_BIRTH] [datetime] NULL,
			[CD_BRAAM_RACE] [int] NULL,
			[TX_BRAAM_RACE] [varchar](200) NULL,
			[INVS_COUNTY_CD] [int] NOT NULL,
			[INVS_COUNTY] [varchar](200) NOT NULL,
			[Removal_ID_Location_Dim_Worker_County_Cd] [int] NULL,
			[Removal_ID_Location_Dim_Worker_County] [varchar](200) NULL,
			[id_people_dim_child] [int] NOT NULL,
			[cd_race_census] [int] NULL,
			[census_Hispanic_Latino_Origin_cd] [int] NULL,
			[petition_dependency_date] [datetime] NULL,
			dur_days int,
			fl_dur_7 smallint,
			fl_dur_90 smallint,
			dur_trh_days int,
			[cnt_trh] int,
			eps_total int,
			eps_rank int,
			eps_total_gt7 int,
			eps_rank_gt7 int,
			fl_close smallint,
			frst_plc_id_provider int,
			lst_plc_id_provider int,
			longest_cd_plcmnt_evnt varchar(3),
			longest_id_plcmnt_evnt int,
			dur_days_longest_plcm int,
			cnt_ooh_plcm int,
			cnt_plcm int,
			nxt_eps_date datetime,
			nxt_eps_date_gt7 datetime,
			primary_parent_id_prsn int,
			fam_structure_cd int,
		    fam_structure_tx varchar(200),
		 PRIMARY KEY CLUSTERED 
		(
			[ID_REMOVAL_EPISODE_FACT] ASC
		)
		) ON [PRIMARY]
		
		insert into #child_episodes
				select distinct  
				  refct.ID_PRSN_CHILD 
				, refct.ID_CASE
				, convert(datetime,cast(Q_AGGR.First_Removal_Date as varchar(8)),112) as First_Removal_Date
				, convert(datetime,cast(Q_AGGR.Latest_Removal_Date as varchar(8)),112) as Latest_Removal_Date
				, cast(coalesce(xwlk_DCFS.CD_REGION
								,ref_plcmnt_cnty.CD_REGION
								,ref_prov_ct.CD_REGION
								,xwlk_wrk.CD_REGION) as int) as Removal_Region
				, coalesce(xwlk_DCFS.CD_OFFICE_COLL_CMN_CNTY
							,frst_plct.Removal_initial_location_dim_placement_county
							,frst_plct.Removal_County_Initial_Placement_Caretaker
							,xwlk_wrk.CD_OFFICE_COLL_CMN_CNTY) as Removal_County_Cd
				, coalesce(xwlk_DCFS.TX_OFFICE_COLL_CMN_CNTY
							,ref_plcmnt_cnty.county_desc
							,ref_prov_ct.county_desc
							,xwlk_wrk.TX_OFFICE_COLL_CMN_CNTY) as Removal_County
				, convert(datetime,cast(refct.ID_CALENDAR_DIM_BEGIN as varchar(8)),12) as State_Custody_Start_Date
				, refct.ID_CALENDAR_DIM_BEGIN as REMOVAL_EPISODE_BEGIN_INT 
				, case 
					when refct.ID_CALENDAR_DIM_END=0 
					then null 
					else refct.ID_CALENDAR_DIM_END  
				  end as REMOVAL_EPISODE_END_INT 		
 						, case when refct.ID_CALENDAR_DIM_End = 0 
						then null 
						else  convert(datetime,cast(refct.ID_CALENDAR_DIM_End as varchar(8)),112) 
				  end as State_Discharge_Date
				, case when dcr.CD_DSCH_RSN <2 then null else dcr.TX_DSCH_RSN end as State_Discharge_Reason
				, case when dcr.CD_DSCH_RSN <2 then null else dcr.CD_DSCH_RSN end  as State_Discharge_Reason_Code
				, case when refct.ID_CALENDAR_DIM_AFCARS_END = 0 
					then null 
					else convert(datetime,cast(refct.ID_CALENDAR_DIM_AFCARS_END as varchar(8)),112) 
				  end as Federal_Discharge_Date
				, case when refct.ID_CALENDAR_DIM_AFCARS_END = 0 
					then null 
					else convert(datetime,cast(refct.ID_CALENDAR_DIM_AFCARS_END as varchar(8)),112) 
				  end as Federal_Discharge_Date_Force_18
				, coalesce(rc.Federal_Discharge_Reason_Code,r2c.Federal_Discharge_Reason_Code) as Federal_Discharge_Reason_Code
				, coalesce(rc.Federal_Category_Label,r2c.Federal_Category_Label) as Federal_Discharge_Reason
				, frst_plct.CD_PLCM_SETNG as Initial_Plcm_Setting_For_Removal_Cd
				, frst_plct.TX_PLCM_SETNG as Initial_Plcm_Setting_For_Removal
				, frst_plct.id_plcmnt_evnt as init_id_plcmnt_evnt
				, frst_plct.cd_plcmnt_evnt as init_cd_plcmnt_evnt
				, last_plct.CD_PLCM_SETNG as Last_Plcm_Setting_For_Removal_Cd
				, last_plct.TX_PLCM_SETNG as Last_Plcm_Setting_For_Removal
				, last_plct.id_plcmnt_evnt as last_id_plcmnt_evnt
				, last_plct.cd_plcmnt_evnt as last_cd_plcmnt_evnt
				, frst_plct.Removal_County_Initial_Placement_Caretaker as Removal_County_Initial_Placement_Caregiver_Cd
				, ref_prov_ct.county_desc  as Removal_County_Initial_Placement_Caregiver
--				, frst_plct.Removal_Initial_Placement_Worker_Office_Cd as Removal_Initial_Placement_Worker_Office_Cd
				, xwlk_wrk.CD_OFFICE_COLLAPSE as Removal_Initial_Placement_Worker_Office_Cd
				, xwlk_wrk.TX_OFFICE_COLLAPSE as Removal_Initial_Placement_Worker_Office
				, frst_plct.Removal_Initial_Placement_Worker_Office_County_cd as Removal_Initial_Placement_Worker_Office_County_cd
				, xwlk_wrk.TX_OFFICE_COLL_CMN_CNTY as Removal_Initial_Placement_Worker_Office_County
			--	, frst_plct.Removal_initial_location_dim_placement_county as Removal_initial_location_dim_placement_county_Cd
			--	, ref_plcmnt_cnty.county_desc as Removal_initial_location_dim_placement_county
				, prd.TX_END_RSN  as [Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON]
				, prd.CD_END_RSN as [Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD]
				, dcr.TX_PLCM_DSCH_RSN as [Removal_Plcm_Discharge_Reason]
				, dcr.CD_PLCM_DSCH_RSN as [Removal_Plcm_Discharge_Reason_Cd]
				, refct.FL_CHILD_CLINICALLY_DIAGNOSED as Disability_Diagnosis
				, pd.FL_PHYS_DISABLED as Disability_Physical
				, pd.FL_VIS_HEARING_IMPR as Disability_Sensory
				, pd.FL_MNTAL_RETARDATN as Disability_MR
				, pd.FL_EMOTION_DSTRBD as Disability_Emotional
				, pd.FL_OTHR_SPC_CARE as Disability_Other
				, refct.FL_ABUSE as Removal_Abuse
				, refct.FL_ABANDONMENT as Removal_Abandon
				, refct.FL_RELINQUISHMENT as Removal_Relinquishment
				, refct.FL_CHILD_ABUSE_ALCOHOL as Removal_Child_Alcohol_Abuse
				, refct.FL_CHILD_BEHAVIOR_PROBLEMS as Removal_Child_Behavior
				, refct.FL_CHILD_ABUSES_DRUG as Removal_Child_Drug_Abuse
						, case when pd.FL_MNTAL_RETARDATN = 'Y' 
						or pd.FL_EMOTION_DSTRBD='Y'
						or pd.FL_VIS_HEARING_IMPR='Y'
						or pd.FL_OTHR_SPC_CARE='Y'  
						or pd.FL_PHYS_DISABLED='Y'
						or refct.FL_CHILD_CLINICALLY_DIAGNOSED =1 
						then 1 else 0 end as  Removal_Child_Disability
				, refct.FL_INADEQUATE_HOUSNG as Removal_Inadequate_Housing
				, refct.FL_NEGLECT as Removal_Neglect
				, refct.FL_PARENT_ABUSE_ALCOHOL as Removal_Parent_Alcohol_Abuse
				, refct.FL_PARENT_DRUG_ABUSE as Removal_Parent_Drug_Abuse
				, refct.FL_CARETAKER_INABILITY_COPE as Removal_Parent_Incapacity
				, refct.FL_PHYSICAL_ABUSE as Removal_Physical_Abuse
				, refct.FL_SEX_ABUSE as Removal_Sexual_Abuse
				, refct.FL_PARENT_DEATH as Removal_Parent_Death
				, refct.FL_PARENT_INCARCERATION as Removal_Incarceration
				, refct.CHILD_AGE_REMOVAL_BEGIN
				, refct.CHILD_AGE_REMOVAL_END
		--		, LEGAL_JUR.TX_JURISDICTION as Court_Venue_Assigned
				, refct.ID_REMOVAL_EPISODE_FACT as ID_REMOVAL_EPISODE_FACT
				, isnull(pd.CD_GNDR,'U')
				, isnull(pd.TX_GNDR,'Unknown')
				, pd.DT_BIRTH
				--, pd.CD_RACE
				--, pd.TX_RACE
				, BR.CD_BRAAM_RACE as CD_BRAAM_RACE 
				, pd.TX_BRAAM_RACE as TX_BRAAM_RACE
				, isnull(REM.INVS_COUNTY,-99) as INVS_COUNTY_CD
				, isnull(ref_invs_cnty.county_desc,'-')  as INVS_COUNTY
				, case when (loc_rem.CD_CNTY = '-') then -99 else loc_rem.CD_CNTY end as  Removal_ID_Location_Dim_Worker_County_Cd
				, loc_rem.TX_CNTY as  Removal_ID_Location_Dim_Worker_County
				, refct.id_people_dim_child
				--12/10/2012 added cd_race_census
				, pd.cd_race_census
				, pd.census_Hispanic_Latino_Origin_cd
				, cast(null as datetime) as petition_dependency_date
				,0 
				,0 
				,0
				,0
				,0
				,0
				,0
				,0
				,0
				,0
				,frst_plct.frst_plc_id_provider
				,last_plct.lst_plc_id_provider
				, null
				, 0
				, null
				, 0
				, 0
				, null
				, null
				, refct.id_prsn_parent_primary as primary_parent_id_prsn
				, fsd.cd_crtkr as fam_structure_cd
				, fsd.tx_crtkr as fam_sturcture_tx
		from CA.removal_episode_fact refct
		join CA.PEOPLE_DIM pd on pd.id_prsn=refct.id_prsn_child
			and pd.IS_CURRENT=1 --and pd.FL_DELETED=0
		join #REMOVALS REM    
					on REM.ID_REMOVAL_EPISODE_FACT=refct.ID_REMOVAL_EPISODE_FACT
		join (--Q_AGGR
				select 
							ID_PRSN_CHILD
							,MIN(ID_CALENDAR_DIM_BEGIN) as First_Removal_Date
							,MAX(ID_CALENDAR_DIM_BEGIN) as Latest_Removal_Date
							,count(Distinct ID_CALENDAR_DIM_BEGIN) as Cnt_Distinct_Removals
				from CA.removal_episode_fact
				join CA.PEOPLE_DIM pd on pd.id_people_dim=removal_episode_fact.id_people_dim_child
				WHERE FL_IN_ERROR=0 
				and ((ID_CALENDAR_DIM_BEGIN >=@removal_start_int)
					or (ID_CALENDAR_DIM_BEGIN < @removal_start_int 
					and (ID_CALENDAR_DIM_END = 0 or ID_CALENDAR_DIM_END > @removal_start_int)))
		--			and ID_CALENDAR_DIM_BEGIN >=@removal_start_int
		--			and dbo.fnc_datediff_yrs(pd.dt_birth,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_BEGIN)) < @age
				group by ID_PRSN_CHILD
				) Q_AGGR 	on Q_AGGR.ID_PRSN_CHILD=refct.ID_PRSN_CHILD
		--removal county office match
		left join  (
						select xwlk.*
						from dbo.ref_xwalk_CD_OFFICE_DCFS xwlk
						left join  (	select CD_OFFICE,count(distinct  TX_OFFICE_COLL_CNTY_SRV) as cnt
									from dbo.ref_xwalk_CD_OFFICE_DCFS
									group by CD_OFFICE --exclude those counties serving multiple counties
									having count(distinct  TX_OFFICE_COLL_CNTY_SRV)  > 1 ) srvs_multiple 
									on srvs_multiple.CD_OFFICE=xwlk.cd_office
						where srvs_multiple.CD_OFFICE is null and xwlk.cd_office > 0
						) xwlk_DCFS on xwlk_DCFS.cd_office=REM.office
		left join CA.removal_dim redim 
			on redim.ID_REMOVAL_DIM=refct.ID_REMOVAL_DIM
		left join CA.discharge_reason_dim dcr 
			on dcr.ID_DISCHARGE_REASON_DIM=refct.ID_DISCHARGE_REASON_DIM
		--left join CA.LEGAL_STATUS_DIM lsd 
		--	on lsd.ID_LEGAL_STATUS_DIM=refct.ID_LEGAL_STATUS_DIM
		--left join CA.PEOPLE_DIM pd 
		--	on refct.ID_PEOPLE_DIM_CHILD=pd.ID_PEOPLE_DIM and PD.IS_CURRENT=1
		left join CA.PLACEMENT_RESULT_DIM prd   
			on prd.ID_PLACEMENT_RESULT_DIM=refct.ID_PLACEMENT_RESULT_DIM_LATEST
		left join dbo.ref_federal_discharge_reason_xwalk rc on rc.State_Discharge_Reason_Code=dcr.CD_DSCH_RSN
		left join dbo.ref_federal_discharge_reason_xwalk r2c on r2c.State_Discharge_Reason_Code=prd.CD_END_RSN
		  --FIRST PLACEMENT FOR REMOVAL GIVES LOCATION by INITIAL PROVIDER CAREGIVER & INITIAL WORKER
		left join  #First_Placements frst_plct 
				on frst_plct.ID_REMOVAL_EPISODE_FACT=REM.ID_REMOVAL_EPISODE_FACT
		--first placement worker office
		left join  (
						select xwlk.*
						from dbo.ref_xwalk_CD_OFFICE_DCFS xwlk
						left join  (	select CD_OFFICE,count(distinct  TX_OFFICE_COLL_CNTY_SRV) as cnt
									from dbo.ref_xwalk_CD_OFFICE_DCFS
									group by CD_OFFICE
									having count(distinct  TX_OFFICE_COLL_CNTY_SRV)  > 1 ) srvs_multiple 
									on srvs_multiple.CD_OFFICE=xwlk.cd_office
						where srvs_multiple.CD_OFFICE is null and xwlk.cd_office > 0
						) xwlk_wrk on xwlk_wrk.cd_office=frst_plct.Removal_Initial_Placement_Worker_Office_Cd
		--first placement ID_location_dim_placement
		left join dbo.ref_lookup_county ref_plcmnt_cnty on ref_plcmnt_cnty.county_cd=frst_plct.Removal_initial_location_dim_placement_county
		--first placement initial caretaker provider
		left join dbo.ref_lookup_county ref_prov_ct on ref_prov_ct.county_cd=frst_plct.Removal_County_Initial_Placement_Caretaker
		-- LAST PLACEMENT FOR REMOVAL
		LEFT JOIN #Last_Removal_Placement last_plct
				on last_plct.ID_REMOVAL_EPISODE_FACT=REM.ID_REMOVAL_EPISODE_FACT
				and last_plct.ID_PRSN_CHILD=REM.ID_PRSN_CHILD
		left join CA.location_dim loc_rem on id_location_dim=refct.id_location_dim_worker
		--invs_county
		left join dbo.ref_lookup_county ref_invs_cnty on ref_invs_cnty.county_cd=REM.INVS_COUNTY
		--lookup braam race code
		left join REF_BRAAM_RACE BR on BR.TX_BRAAM_RACE=PD.TX_BRAAM_RACE
		left join ca.family_structure_dim fsd on fsd.id_family_structure_dim=refct.id_family_structure_dim
		where   REFCT.FL_IN_ERROR=0 
				--	and refct.ID_CALENDAR_DIM_BEGIN >=@removal_start_int
				and ((REFCT.ID_CALENDAR_DIM_BEGIN >=@removal_start_int)
					or (REFCT.ID_CALENDAR_DIM_BEGIN < @removal_start_int 
					and (REFCT.ID_CALENDAR_DIM_END = 0 or REFCT.ID_CALENDAR_DIM_END > @removal_start_int)))
		order by  
			  refct.ID_PRSN_CHILD 
			, refct.ID_CALENDAR_DIM_BEGIN 
			
		-----------------------------------------------------------------------------------------------------------UPDATE added fields remove null values

		 
		update #child_episodes
		set Initial_Plcm_Setting_For_Removal='-',Initial_Plcm_Setting_For_Removal_Cd=-99
		where Initial_Plcm_Setting_For_Removal_Cd  is null

		update  #child_episodes
		set Last_Plcm_Setting_For_Removal='-',Last_Plcm_Setting_For_Removal_Cd=-99
		 where Last_Plcm_Setting_For_Removal_Cd is null
		 
		--tx_race is tx_braam_race 
		update  #child_episodes
		set CD_BRAAM_RACE=7,TX_BRAAM_RACE='Unknown'
		where CD_BRAAM_RACE is null  


		update tce
		set cd_race_census = 7
		 from #child_episodes tce where cd_Race_census is null;

		update #child_episodes 
		set removal_county='Unknown',removal_county_cd=-99
		where removal_county_Cd is null


		update #child_episodes
		set state_discharge_reason_code=-99,state_discharge_reason='-'
		where state_discharge_reason_code is null and state_discharge_reason is null


		---------------------------------------------------------------------------------------------------------------------- update county from legal fact
		if OBJECT_ID('tempDB..#legal') is not null drop table #legal
		select q.tx_jurisdiction, eps.id_removal_episode_fact,eps.id_prsn_child,eps.removal_county_cd,eps.removal_county
		into #legal
		from #child_episodes eps
		left join (
			select lrd.cd_result,lrd.tx_result,ljd.tx_jurisdiction,dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) as eff_dt ,id_prsn_child,id_removal_episode_fact,state_custody_start_date,federal_discharge_date
			, ROW_NUMBER() over ( partition by id_removal_episode_fact order by id_removal_episode_fact,dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) asc) as row_num
			from #child_episodes tce
			left join ca.legal_fact lf on tce.id_case=lf.id_case and tce.id_prsn_child=lf.id_prsn 
				and dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) between dateadd(dd,-30,state_custody_start_date) and isnull(federal_discharge_date,'12/31/3999')
			left join ca.legal_result_dim lrd on lf.id_legal_result_dim=lrd.id_legal_result_dim
			left join ca.legal_jurisdiction_dim ljd on ljd.id_legal_jurisdiction_dim=lf.id_legal_jurisdiction_dim
			where ljd.tx_jurisdiction <> '-'
				) q on q.id_removal_episode_fact=eps.id_removal_episode_fact
						and q.row_num=1

		
		update eps
		set Removal_County_Cd=q.new_county_cd,Removal_County=q.new_county_desc
		from #child_episodes eps 
		join (select cnty.county_cd as new_county_cd,cnty.county_desc as new_county_desc, * from #legal 
				join ref_lookup_county cnty on cnty.county_desc=replace(tx_jurisdiction,' County','') 
				where   tx_jurisdiction not like (removal_county + '%' ) and tx_jurisdiction not in ( 'Tribal','Other State')
			) q on q.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT

		update eps
		set Removal_Region=ref.old_region_cd
		from #child_episodes eps 
		join [ref_lookup_county] ref on ref.county_cd=eps.Removal_County_Cd

		update #child_episodes
		set removal_county_cd=-99,Removal_Region=-99
		where removal_county_cd in (40,999)

		update #child_episodes
		set removal_county='Unknown'
		where removal_county_cd=-99 
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
	


		--declare @cutoff_date datetime;
		--select @cutoff_date=cutoff_date from ref_Last_DW_Transfer
		
		
		update #child_episodes
		set init_id_plcmnt_evnt=10
		,init_cd_plcmnt_evnt='POT'
		where init_id_plcmnt_evnt is null

		update #child_episodes
		set last_id_plcmnt_evnt=10
		,last_cd_plcmnt_evnt='POT'
		where last_id_plcmnt_evnt is null

		---------  DATA CLEANUP ------------------------------------------------------------------------
			
		if object_Id(N'tbl_child_episode_orig_data_prior_cleanup',N'U') is not null truncate  table tbl_child_episode_orig_data_prior_cleanup
		if object_id(N'tbl_child_episode_merge_id',N'U') is not null truncate table tbl_child_episode_merge_id;
		
--- FL_CLEANUP_TYPE = D--- FL_CLEANUP_TYPE = D       --- FL_CLEANUP_TYPE = D       --- FL_CLEANUP_TYPE = D       --- FL_CLEANUP_TYPE = D       --- FL_CLEANUP_TYPE = D					

		insert into tbl_child_episode_orig_data_prior_cleanup
		select *,'D',null from #child_episodes where child_age_removal_begin > 21
        or child_age_removal_begin < 0
		
		delete   
		from #child_episodes
		where child_age_removal_begin > 21
        or child_age_removal_begin < 0
					
		insert into tbl_child_episode_orig_data_prior_cleanup
		select *,'D',null from #child_episodes where federal_discharge_date < state_custody_start_date

		delete  from #child_episodes where federal_discharge_date < state_custody_start_date


		if object_id('tempDB..#wrk_eps') is not null drop table #wrk_eps;


		-- back up and then delete those where person,state custody start date and federal discharge date 
		-- are same but one has no placements
		insert into tbl_child_episode_orig_data_prior_cleanup
		select tce.*,'D',0
		from  #child_episodes tce 
		left join (select id_removal_episode_fact,count(*) as cnt_plcm 
							from #Q_Placement 
							group by id_removal_episode_fact
							) q on q.id_removal_episode_fact=tce.id_removal_episode_fact
		where q.id_removal_episode_fact is null

		delete tce
		from  #child_episodes tce 
		left join (select id_removal_episode_fact,count(*) as cnt_plcm 
							from #Q_Placement 
							group by id_removal_episode_fact
							) q on q.id_removal_episode_fact=tce.id_removal_episode_fact
		where q.id_removal_episode_fact is null


		create table #wrk_eps (
			id_removal_episode_fact int not null,
			id_prsn_child int not null,
			state_custody_start_date datetime not null,
			federal_discharge_date datetime,
			cnt_plcm int not null,
			fl_ooh_plcm int not null,
			eps_order_asc bigint not null,
			eps_order_desc bigint not null,
			lst_evt_end datetime,
			frst_evt_strt datetime,
			frst_evt_end datetime,
			last_ooh_end datetime
			)


		CREATE NONCLUSTERED INDEX idx_wrk_eps
		ON #wrk_eps ([cnt_plcm])
		INCLUDE ([id_prsn_child],[state_custody_start_date],[federal_discharge_date],[eps_order_asc]);

		insert into #wrk_eps
		select tce.id_removal_episode_fact
				,tce.id_prsn_child
				,tce.state_custody_start_date 
				,tce.federal_discharge_date 
				,coalesce(q.cnt_plcm,0) 
				,case when ooh.id_removal_episode_fact is not null then 1 else 0 end 
				,row_number() over 
					(partition by tce.id_prsn_child
						order by tce.id_prsn_child,tce.state_custody_start_date asc,tce.federal_discharge_date asc) as eps_order_asc
				,row_number() over 
					(partition by tce.id_prsn_child
						order by tce.id_prsn_child,tce.state_custody_start_date desc,tce.federal_discharge_date desc) as eps_order_desc	
				,lst.evt_end as lst_evt_end
				,frstplc.evt_begin as frst_evt_strt
				,frstplc.evt_end as frst_evt_end
				,ooh.evt_end as last_ooh_end
		from #child_episodes tce
		left join #Q_Placement lst on lst.id_removal_episode_fact=tce.id_removal_episode_fact
			and lst.last_plcmnt=1
			left join (select id_removal_episode_fact,count(*) as cnt_plcm 
							from #Q_Placement 
							group by id_removal_episode_fact
							) q on q.id_removal_episode_fact=tce.id_removal_episode_fact
		left join #Q_Placement frstplc on frstplc.id_removal_episode_Fact=tce.id_removal_episode_fact and frstplc.first_plcmnt=1
		left join (select id_removal_episode_fact, evt_end from #Q_Placement
					where ooh_plcm_sort_desc=1 ) ooh on ooh.id_removal_episode_fact=tce.id_removal_episode_fact 
		order by tce.id_prsn_child
				,tce.state_custody_start_date  asc
				,tce.federal_discharge_date  asc
				,[eps_order_asc]




-- FL_CLEANUP_TYPE = U--- FL_CLEANUP_TYPE = U       --- FL_CLEANUP_TYPE = U       --- FL_CLEANUP_TYPE = U       --- FL_CLEANUP_TYPE = U       --- FL_CLEANUP_TYPE = U

		--first insert the records we will be updating into cleanup table
		--thse are episodes that do not have a federal dischage date but have a last event end date.
		insert into tbl_child_episode_orig_data_prior_cleanup
		select tce.*,'U',null
				from #child_episodes tce
		join #wrk_eps curr on curr.id_removal_episode_fact=tce.ID_REMOVAL_EPISODE_FACT
		left join #wrk_eps nxt 
			on curr.eps_order_asc+1=nxt.eps_order_asc 
				and curr.id_prsn_child=nxt.id_prsn_child
		where curr.federal_discharge_date is null 
		and curr.fl_ooh_plcm=1
		and	curr.last_ooh_end is not null 
		and curr.last_ooh_end < '12/31/3999'
		and curr.last_ooh_end >= curr.frst_evt_end
		and curr.last_ooh_end >=curr.state_custody_start_date
		and (nxt.state_custody_start_date is not null or (nxt.id_removal_episode_fact is null
		and curr.last_ooh_end <= dateadd(yy,-1,@cutoff_date)))
			
	
		insert into tbl_child_episode_orig_data_prior_cleanup
		select tce.*,'U',null
				from #child_episodes tce
		join #wrk_eps curr on curr.id_removal_episode_fact=tce.ID_REMOVAL_EPISODE_FACT
		left join #wrk_eps nxt 
			on curr.eps_order_asc+1=nxt.eps_order_asc 
				and curr.id_prsn_child=nxt.id_prsn_child
		where curr.federal_discharge_date is null 
		and	curr.fl_ooh_plcm=0
		and curr.last_ooh_end is  null and curr.lst_evt_end is not null
		and curr.lst_evt_end <> '12/31/3999'
		and curr.lst_evt_end >= curr.frst_evt_end
		and curr.lst_evt_end >=curr.state_custody_start_date
		and curr.fl_ooh_plcm=0
		and (nxt.state_custody_start_date is not null or (nxt.id_removal_episode_fact is null
			and curr.lst_evt_end <= dateadd(yy,-1,@cutoff_date)))

		-- Now update  those episodes that should be end dated
		update tce
		set Federal_Discharge_Date=curr.last_ooh_end
		--select curr.*,nxt.state_custody_start_date as nxt
		from #child_episodes tce
		join #wrk_eps curr on curr.id_removal_episode_fact=tce.ID_REMOVAL_EPISODE_FACT
		left join #wrk_eps nxt on curr.eps_order_asc+1=nxt.eps_order_asc 
		and curr.id_prsn_child=nxt.id_prsn_child
		where curr.federal_discharge_date is null 
		and	curr.last_ooh_end is not null 
		and curr.last_ooh_end < '12/31/3999'
		and curr.last_ooh_end >= curr.frst_evt_end
		and curr.last_ooh_end >=curr.state_custody_start_date
		and (nxt.state_custody_start_date is not null or (nxt.id_removal_episode_fact is null
		and curr.last_ooh_end <= dateadd(yy,-1,@cutoff_date)))

		update tce
		set Federal_Discharge_Date=curr.last_ooh_end
		--select curr.*,nxt.state_custody_start_date as nxt
		from #child_episodes tce
		join #wrk_eps curr on curr.id_removal_episode_fact=tce.ID_REMOVAL_EPISODE_FACT
		left join #wrk_eps nxt on curr.eps_order_asc+1=nxt.eps_order_asc 
		and curr.id_prsn_child=nxt.id_prsn_child
		where curr.federal_discharge_date is null 
		and	curr.fl_ooh_plcm=0
		and curr.last_ooh_end is  null and curr.lst_evt_end is not null
		and curr.lst_evt_end <> '12/31/3999'
		and curr.lst_evt_end >= curr.frst_evt_end
		and curr.lst_evt_end >=curr.state_custody_start_date
		and curr.fl_ooh_plcm=0
		and (nxt.state_custody_start_date is not null or (nxt.id_removal_episode_fact is null
			and curr.lst_evt_end <= dateadd(yy,-1,@cutoff_date)))
					


		--now remove those episodes where the last event date is prior to our start date of 19980101
		delete tce
		from  #child_episodes tce
		join #wrk_eps eps on tce.ID_REMOVAL_EPISODE_FACT=eps.id_removal_episode_fact
		where tce.Federal_Discharge_Date <= @start_date


		
			
	
		
		--  renumber work episodes
		truncate table #wrk_eps
		
		insert into #wrk_eps
		select tce.id_removal_episode_fact
				,tce.id_prsn_child
				,tce.state_custody_start_date 
				,tce.federal_discharge_date 
				,coalesce(q.cnt_plcm,0) 
				,case when ooh.id_removal_episode_fact is not null then 1 else 0 end 
				,row_number() over 
					(partition by tce.id_prsn_child
						order by tce.id_prsn_child,tce.state_custody_start_date asc,tce.federal_discharge_date asc) as eps_order_asc
				,row_number() over 
					(partition by tce.id_prsn_child
						order by tce.id_prsn_child,tce.state_custody_start_date desc,tce.federal_discharge_date desc) as eps_order_desc	
				,lst.evt_end as lst_evt_end
				,frstplc.evt_begin as frst_evt_strt
				,frstplc.evt_end as frst_evt_end
				,ooh.evt_end as last_ooh_end
		from #child_episodes tce
		left join #Q_Placement lst on lst.id_removal_episode_fact=tce.id_removal_episode_fact
			and lst.last_plcmnt=1
			left join (select id_removal_episode_fact,count(*) as cnt_plcm 
							from #Q_Placement 
							group by id_removal_episode_fact
							) q on q.id_removal_episode_fact=tce.id_removal_episode_fact
		left join #Q_Placement frstplc on frstplc.id_removal_episode_Fact=tce.id_removal_episode_fact and frstplc.first_plcmnt=1
		left join (select id_removal_episode_fact, evt_end from #Q_Placement
					where ooh_plcm_sort_desc=1 ) ooh on ooh.id_removal_episode_fact=tce.id_removal_episode_fact 
		order by tce.id_prsn_child
				,tce.state_custody_start_date  asc
				,tce.federal_discharge_date  asc
				,[eps_order_asc]
		

-- FL_CLEANUP_TYPE = M--- FL_CLEANUP_TYPE = M       --- FL_CLEANUP_TYPE = M       --- FL_CLEANUP_TYPE = M       --- FL_CLEANUP_TYPE = M       --- FL_CLEANUP_TYPE = M
		
		
		
		-- clean up overlapping episodes
		declare @seg_count int
		declare @counter int
		select @seg_count=max(curr.eps_order_asc) from #wrk_eps curr
				join #wrk_eps nxt on curr.id_prsn_child=nxt.id_Prsn_child 
				and nxt.eps_order_asc=curr.eps_order_asc+1
				where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
				and coalesce(curr.federal_discharge_date,'12/31/3999') <=coalesce(nxt.federal_discharge_date,'12/31/3999')

		set @counter=1
		while @counter <= @seg_count
		begin

			insert into tbl_child_episode_merge_id 
			select nxt.id_removal_episode_fact,tce.id_removal_episode_fact
			from  #child_episodes tce
				join #wrk_eps  curr on tce.id_removal_episode_fact=curr.id_removal_episode_fact
				join #wrk_eps nxt on curr.id_prsn_child=nxt.id_Prsn_child 
				and nxt.eps_order_asc=curr.eps_order_asc+1
				where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
				and coalesce(curr.federal_discharge_date,'12/31/3999') <=coalesce(nxt.federal_discharge_date,'12/31/3999')
			--	and curr.lst_evt_end< nxt.state_custody_start_date
				and curr.eps_order_asc=@counter
				 
			insert into tbl_child_episode_orig_data_prior_cleanup
			select tce.*,'M',nxt.id_removal_episode_fact as merge_episode_id
			--select  curr.id_prsn_child,curr.state_custody_start_date,curr.federal_discharge_date,curr.frst_evt_end,curr.lst_evt_end,curr.last_ooh_end,curr.cnt_plcm
			--,nxt.state_custody_start_date,nxt.federal_discharge_date,nxt.cnt_plcm
			from  #child_episodes tce
				join #wrk_eps  curr on tce.id_removal_episode_fact=curr.id_removal_episode_fact
				join #wrk_eps nxt on curr.id_prsn_child=nxt.id_Prsn_child and nxt.eps_order_asc=curr.eps_order_asc+1
				where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
				and coalesce(curr.federal_discharge_date,'12/31/3999') <=coalesce(nxt.federal_discharge_date,'12/31/3999')
				and curr.eps_order_asc=@counter

				
				
			
			update ce
			set state_custody_start_date=curr.state_custody_start_date
				,CHILD_AGE_REMOVAL_BEGIN=epsC.CHILD_AGE_REMOVAL_BEGIN
				,init_id_plcmnt_evnt=epsC.init_id_plcmnt_evnt
				,init_cd_plcmnt_evnt=epsc.init_cd_plcmnt_evnt
				,Initial_Plcm_Setting_For_Removal_Cd=epsc.Initial_Plcm_Setting_For_Removal_Cd
				,Initial_Plcm_Setting_For_Removal=epsc.Initial_Plcm_Setting_For_Removal
				,REMOVAL_EPISODE_BEGIN_INT=epsC.REMOVAL_EPISODE_BEGIN_INT
				,Removal_County_cd=epsC.Removal_County_Cd
				,Removal_County=epsC.Removal_County
				,removal_region=epsC.Removal_Region
			    ,Latest_Removal_Date=case when ce.State_Custody_Start_Date=ce.Latest_Removal_Date
					then epsC.Latest_Removal_Date else ce.Latest_Removal_Date end				
			--select  curr.id_prsn_child,curr.state_custody_start_date,curr.federal_discharge_date,curr.frst_evt_end,curr.lst_evt_end,curr.last_ooh_end,curr.cnt_plcm
			--,nxt.state_custody_start_date,nxt.federal_discharge_date,nxt.cnt_plcm
			from #child_episodes ce
			join #wrk_eps nxt on ce.ID_REMOVAL_EPISODE_FACT=nxt.id_removal_episode_fact
			join #wrk_eps  curr on curr.id_prsn_child=nxt.id_Prsn_child and nxt.eps_order_asc=curr.eps_order_asc+1
			join #child_episodes epsC on epsC.ID_REMOVAL_EPISODE_FACT= curr.id_removal_episode_fact
			where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
			and coalesce(curr.federal_discharge_date,'12/31/3999') <=coalesce(nxt.federal_discharge_date,'12/31/3999')
			and curr.eps_order_asc=@counter
			

		
				
			
		
			delete from #child_episodes where ID_REMOVAL_EPISODE_FACT in (select id_removal_episode_fact from tbl_child_episode_merge_id)
			delete from #wrk_eps where eps_order_asc=@counter
			--  renumber work episodes
			
		
			update wrk_eps
			set  state_custody_start_date=tce.state_custody_start_date
			from #child_episodes tce
			 join #wrk_eps wrk_eps on wrk_eps.id_removal_episode_fact=tce.ID_REMOVAL_EPISODE_FACT
			where wrk_eps.eps_order_asc=@counter + 1;

			
			set @counter=@counter + 1

		end
			
			
			

		--  renumber work episodes
		truncate table #wrk_eps
		
		insert into #wrk_eps
		select tce.id_removal_episode_fact
				,tce.id_prsn_child
				,tce.state_custody_start_date 
				,tce.federal_discharge_date 
				,coalesce(q.cnt_plcm,0) 
				,case when ooh.id_removal_episode_fact is not null then 1 else 0 end 
				,row_number() over 
					(partition by tce.id_prsn_child
						order by tce.id_prsn_child,tce.state_custody_start_date asc,tce.federal_discharge_date asc) as eps_order_asc
				,row_number() over 
					(partition by tce.id_prsn_child
						order by tce.id_prsn_child,tce.state_custody_start_date desc,tce.federal_discharge_date desc) as eps_order_desc	
				,lst.evt_end as lst_evt_end
				,frstplc.evt_begin as frst_evt_strt
				,frstplc.evt_end as frst_evt_end
				,ooh.evt_end as last_ooh_end
		from #child_episodes tce
		left join #Q_Placement lst on lst.id_removal_episode_fact=tce.id_removal_episode_fact
			and lst.last_plcmnt=1
		left join (select id_removal_episode_fact,count(*) as cnt_plcm 
					from #Q_Placement 
					group by id_removal_episode_fact
					) q on q.id_removal_episode_fact=tce.id_removal_episode_fact
		left join #Q_Placement frstplc on frstplc.id_removal_episode_Fact=tce.id_removal_episode_fact and frstplc.first_plcmnt=1
		left join (select id_removal_episode_fact, evt_end from #Q_Placement
					where ooh_plcm_sort_desc=1 ) ooh on ooh.id_removal_episode_fact=tce.id_removal_episode_fact 
		order by tce.id_prsn_child
				,tce.state_custody_start_date  asc
				,tce.federal_discharge_date  asc
				,[eps_order_asc]


		

		--declare @seg_count int
		--declare @counter int
		select @seg_count=max(nxt.eps_order_asc) from #wrk_eps curr
		join #wrk_eps nxt on curr.id_prsn_child=nxt.id_Prsn_child 
				and nxt.eps_order_asc=curr.eps_order_asc+1
				where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
				and coalesce(curr.federal_discharge_date,'12/31/3999') >= coalesce(nxt.federal_discharge_date,'12/31/3999')


-- FL_CLEANUP_TYPE =N--- FL_CLEANUP_TYPE =N       --- FL_CLEANUP_TYPE =N       --- FL_CLEANUP_TYPE =N       --- FL_CLEANUP_TYPE =N       --- FL_CLEANUP_TYPE =N
		
		
		
		-- next is contained within current
		declare @rows_returned int
		set @rows_returned=0
		set nocount off
		set @counter=1
		while @counter <= @seg_count 
		begin


			


			-- next is contained within current
			insert into tbl_child_episode_merge_id 
			select curr.id_removal_episode_fact,nxt.id_removal_episode_fact
			from  #child_episodes tce
				join #wrk_eps  curr on tce.id_removal_episode_fact=curr.id_removal_episode_fact
				join #wrk_eps nxt on curr.id_prsn_child=nxt.id_Prsn_child 
				and nxt.eps_order_asc=curr.eps_order_asc+1
				where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
				and coalesce(curr.federal_discharge_date,'12/31/3999') >= coalesce(nxt.federal_discharge_date,'12/31/3999')
			--	and curr.lst_evt_end< nxt.state_custody_start_date
				and curr.eps_order_asc=@counter
			
			
			--  next is contained within current	 
			insert into tbl_child_episode_orig_data_prior_cleanup
			select nxtEps.*,'N',tce.ID_REMOVAL_EPISODE_FACT
			--select  curr.id_prsn_child,curr.state_custody_start_date,curr.federal_discharge_date,curr.frst_evt_end,curr.lst_evt_end,curr.last_ooh_end,curr.cnt_plcm
			--,nxt.state_custody_start_date,nxt.federal_discharge_date,nxt.cnt_plcm
			from  #child_episodes tce
				join #wrk_eps  curr on tce.id_removal_episode_fact=curr.id_removal_episode_fact
				join #wrk_eps nxt on curr.id_prsn_child=nxt.id_Prsn_child and nxt.eps_order_asc=curr.eps_order_asc+1
				join #child_episodes nxtEps on nxtEps.ID_REMOVAL_EPISODE_FACT=nxt.id_removal_episode_fact
				where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
				and coalesce(curr.federal_discharge_date,'12/31/3999') >= coalesce(nxt.federal_discharge_date,'12/31/3999')
				and curr.eps_order_asc=@counter
			set @rows_returned=@@ROWCOUNT
			
			delete ce
			from #child_episodes ce
			where id_removal_episode_fact in 
			(select id_removal_episode_fact from tbl_child_episode_orig_data_prior_cleanup where fl_cleanup_type='N')


		-- next is rolled into current so we want to update our row sort for current to next then delete next
			delete from #wrk_eps where id_removal_episode_fact 
			in (select id_removal_episode_fact from tbl_child_episode_orig_data_prior_cleanup where fl_cleanup_type='N')

			--renumber
			truncate table #wrk_eps
		
			insert into #wrk_eps
			select tce.id_removal_episode_fact
					,tce.id_prsn_child
					,tce.state_custody_start_date 
					,tce.federal_discharge_date 
					,coalesce(q.cnt_plcm,0) 
					,case when ooh.id_removal_episode_fact is not null then 1 else 0 end 
					,row_number() over 
						(partition by tce.id_prsn_child
							order by tce.id_prsn_child,tce.state_custody_start_date asc,tce.federal_discharge_date asc) as eps_order_asc
					,row_number() over 
						(partition by tce.id_prsn_child
							order by tce.id_prsn_child,tce.state_custody_start_date desc,tce.federal_discharge_date desc) as eps_order_desc	
					,lst.evt_end as lst_evt_end
					,frstplc.evt_begin as frst_evt_strt
					,frstplc.evt_end as frst_evt_end
					,ooh.evt_end as last_ooh_end
			from #child_episodes tce
			left join #Q_Placement lst on lst.id_removal_episode_fact=tce.id_removal_episode_fact
				and lst.last_plcmnt=1
				left join (select id_removal_episode_fact,count(*) as cnt_plcm 
								from #Q_Placement 
								group by id_removal_episode_fact
								) q on q.id_removal_episode_fact=tce.id_removal_episode_fact
			left join #Q_Placement frstplc on frstplc.id_removal_episode_Fact=tce.id_removal_episode_fact and frstplc.first_plcmnt=1
			left join (select id_removal_episode_fact, evt_end from #Q_Placement
						where ooh_plcm_sort_desc=1 ) ooh on ooh.id_removal_episode_fact=tce.id_removal_episode_fact 
			order by tce.id_prsn_child
					,tce.state_custody_start_date  asc
					,tce.federal_discharge_date  asc
					,[eps_order_asc]

			
			
			
			-- because next was rolled up into current we want to repeat that loop so increase everything in #wrk_eps by 1
			--update #wrk_eps
			--set eps_order_asc=eps_order_asc + 1;
			
			
			if @rows_returned=0 
				set @counter=@counter + 1
			else
				begin
					set @counter=1
					select @seg_count=max(nxt.eps_order_asc) from #wrk_eps curr
						join #wrk_eps nxt on curr.id_prsn_child=nxt.id_Prsn_child 
					and nxt.eps_order_asc=curr.eps_order_asc+1
					where coalesce(curr.federal_discharge_date,'12/31/3999') >  nxt.state_custody_start_date
					and coalesce(curr.federal_discharge_date,'12/31/3999') >= coalesce(nxt.federal_discharge_date,'12/31/3999')
			end


		end


	
	


			update tce
			set tce.First_Removal_Date  = q.state_custody_start_date
			from #child_episodes tce
			cross apply (select top 1 id_prsn_child,state_custody_start_date
						from #child_episodes eps
						where eps.id_prsn_child=tce.id_prsn_child
						order by eps.id_prsn_child,state_custody_start_date asc)q
			where q.state_custody_start_date <> tce.First_Removal_Date
						
			
			
			update tce
			set tce.Latest_Removal_Date  = q.state_custody_start_date
			from #child_episodes tce
			cross apply (select top 1 id_prsn_child,state_custody_start_date
						from #child_episodes eps
						where eps.id_prsn_child=tce.id_prsn_child
						order by eps.id_prsn_child,state_custody_start_date desc)q
			where q.state_custody_start_date <> tce.Latest_Removal_Date



	--first update those who were discharged after 18th birthday 
		--this may result in some episodes where the state custody start date 
		-- is greater than or equal to federal discharge date force 18 (These need to be handled with code)

		update TCE
		set Federal_Discharge_Date_Force_18=federal_discharge_date
		from #child_episodes TCE
		where federal_discharge_date is not null

		update TCE
		set Federal_Discharge_Date_Force_18=dateadd(yy,18,DT_BIRTH)
		from #child_episodes TCE
		where  (Federal_Discharge_Date_Force_18 is not null and dateadd(yy,18,DT_BIRTH) < @cutoff_date)
		and dateadd(yy,18,DT_BIRTH) < Federal_discharge_date



		
		update TCE
		set Federal_Discharge_Date_Force_18=dateadd(yy,18,DT_BIRTH)
		from #child_episodes TCE
		where federal_discharge_date is null and dateadd(yy,18,DT_BIRTH) < @cutoff_date;
		
		update TCE
		set petition_dependency_date= q.petition_date
		--select id_prsn_child,tce.state_custody_start_date,tce.federal_discharge_date,q.days_frm_state_custody,q.petition_date as petition_dependency_date
		from #child_episodes TCE
		join (			select distinct id_removal_episode_fact
							,FAMLINKID
							,state_custody_start_date
							,federal_discharge_date
							,petition_date
							,petition_dependency_date
							,datediff(dd,tce.state_custody_start_date,Petition_date) as days_frm_state_custody
							,row_number() over (partition by id_prsn_child ,state_custody_start_date
									order by datediff(dd,tce.state_custody_start_date,Petition_date)  asc) as row_num
						from aoc.aoc_petition aoc
						join #child_episodes tce on 
						 tce.id_prsn_child=aoc.FAMLINKID
						--and (datediff(dd,aoc.Petition_date,tce.state_custody_start_date) <=365
							and Petition_date >= tce.state_custody_start_date 
									and Petition_date < isnull(tce.federal_discharge_date,@cutoff_date)
						and petition ='DEPENDENCY PETITION' 
				) q on q.id_removal_episode_fact=tce.id_removal_episode_fact  
					and q.row_num=1

		update TCE
		set petition_dependency_date=q.petition_date
		--select id_prsn_child,tce.state_custody_start_date,tce.federal_discharge_date,q.days_frm_state_custody,q.petition_date as petition_dependency_date
		from #child_episodes TCE
		join   (
					select FAMLINKID
						,Petition_date
						,min(abs(datediff(dd,aoc.Petition_date,tce.state_custody_start_date)) )as days_frm_state_custody
						from AOC.aoc_petition aoc
						join #child_episodes tce on tce.id_prsn_child=aoc.FAMLINKID
						left join (select id_prsn_child,petition_dependency_date 
								from #child_episodes where petition_dependency_date is not null) usd
							on usd.id_prsn_child=aoc.FAMLINKID
								and usd.petition_dependency_date=aoc.petition_date
						where
						 usd.petition_dependency_date is null
						and abs(datediff(dd,aoc.Petition_date,tce.state_custody_start_date)) <=365
						and aoc.Petition_date < tce.state_custody_start_date
						and petition ='DEPENDENCY PETITION' 
						group by FAMLINKID,Petition_date
						) q on q.FAMLINKID=tce.id_prsn_child 
						and abs(datediff(dd,q.Petition_date,tce.state_custody_start_date)) =q.days_frm_state_custody
						and q.Petition_date < tce.state_custody_start_date
		left join (select id_prsn_child,petition_dependency_date 
					from #child_episodes 
					where petition_dependency_date is not null) usd
							on usd.id_prsn_child=tce.id_prsn_child
								and usd.petition_dependency_date=tce.petition_dependency_date
		where usd.id_prsn_child is null and 
		  tce.petition_dependency_date is null
		




		update TCE
		set fl_dur_7=1
		from #child_episodes TCE
		where datediff(dd,state_custody_start_date,federal_discharge_date) + 1 <=7
		
		update TCE
		set fl_dur_90=1
		from #child_episodes TCE
		where datediff(dd,state_custody_start_date,federal_discharge_date) + 1 <=90
		
		update TCE
		set fl_close=1
		from #child_episodes TCE
		where federal_discharge_date is not null;
		

		update TCE
		set eps_total= q.eps_total
			,eps_total_gt7=q.eps_total_gt7
		from #child_episodes TCE
		join (select id_prsn_child,count(*) as eps_total
				,sum(case when datediff(dd,state_custody_start_date,federal_discharge_date) + 1 > 7 
						then 1 
						else 0 
					end) as eps_total_gt7
				from #child_episodes
				group by id_prsn_child 
				) q on q.id_prsn_child=TCE.id_prsn_child
				
	
		update TCE
		set eps_rank=q.sort_key
		from #child_episodes TCE
		join (select id_prsn_child,state_custody_start_date,coalesce(federal_discharge_date,'12/31/3999') as federal_discharge_date,id_removal_episode_fact
				,row_number() over(partition by id_prsn_child
									order by id_prsn_child,state_custody_start_date asc,
											coalesce(federal_discharge_date,'12/31/3999') asc) as sort_key
				from #child_episodes
				) q on q.id_prsn_child=tce.id_prsn_child
					and q.id_removal_episode_fact=tce.id_removal_episode_fact
					
		update TCE
		set eps_rank_gt7=q.sort_key
		from #child_episodes TCE
		join (select id_prsn_child,state_custody_start_date
				,coalesce(federal_discharge_date,'12/31/3999') as federal_discharge_date,id_removal_episode_fact
				,row_number() over(partition by id_prsn_child
									order by id_prsn_child,state_custody_start_date asc,
											coalesce(federal_discharge_date,'12/31/3999') asc) as sort_key
				from #child_episodes
				where  datediff(dd,state_custody_start_date,federal_discharge_date) + 1 > 7
				) q on q.id_prsn_child=tce.id_prsn_child
					and q.id_removal_episode_fact=tce.id_removal_episode_fact	
									
				
    
			
		update TCE
		set dur_days=datediff(dd,state_custody_start_date,isnull(federal_discharge_date,(select cutoff_date from ref_last_dw_transfer)) + 1)
		from #child_episodes TCE


-- select id_Removal_episode_fact as vid,id_prsn_child,state_custody_start_date,federal_discharge_date from #child_episodes where id_prsn_child=117161 order by state_custody_start_date asc

	--select id_prsn_child,state_custody_start_date,count(*) as cnt
	--from #child_episodes 
	--group by id_prsn_child,state_custody_start_date
	--having count(*) > 1
		---------------------------------------------------------------------------------------------------------------------------------------------------------drop child_episodes
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TBL_CHILD_EPISODES]') AND type in (N'U'))
		TRUNCATE TABLE [dbo].TBL_CHILD_EPISODES ;

		-----------------------------------------------------------------------------------------------------------------------------------------------------------create child_episodes

		insert into  dbo.TBL_CHILD_EPISODES
		  (ID_PRSN_CHILD
           ,ID_CASE
           ,First_Removal_Date
           ,Latest_Removal_Date
           ,Removal_Region
           ,Removal_County_Cd
           ,Removal_County
           ,State_Custody_Start_Date
           ,REMOVAL_EPISODE_BEGIN_INT
           ,REMOVAL_EPISODE_END_INT
           ,State_Discharge_Date
           ,State_Discharge_Reason
           ,State_Discharge_Reason_Code
           ,Federal_Discharge_Date
           ,Federal_Discharge_Date_Force_18
           ,Federal_Discharge_Reason_Code
           ,Federal_Discharge_Reason
           ,Initial_Plcm_Setting_For_Removal_Cd
           ,Initial_Plcm_Setting_For_Removal
           ,init_id_plcmnt_evnt
           ,init_cd_plcmnt_evnt
           ,Last_Plcm_Setting_For_Removal_Cd
           ,Last_Plcm_Setting_For_Removal
           ,last_id_plcmnt_evnt
           ,last_cd_plcmnt_evnt
           ,Removal_County_Initial_Placement_Caregiver_Cd
           ,Removal_County_Initial_Placement_Caregiver
           ,Removal_Initial_Placement_Worker_Office_Cd
           ,Removal_Initial_Placement_Worker_Office
           ,Removal_Initial_Placement_Worker_Office_County_cd
           ,Removal_Initial_Placement_Worker_Office_County
           ,Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON
           ,Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD
           ,Removal_Plcm_Discharge_Reason
           ,Removal_Plcm_Discharge_Reason_Cd
           ,Disability_Diagnosis
           ,Disability_Physical
           ,Disability_Sensory
           ,Disability_MR
           ,Disability_Emotional
           ,Disability_Other
           ,Removal_Abuse
           ,Removal_Abandon
           ,Removal_Relinquishment
           ,Removal_Child_Alcohol_Abuse
           ,Removal_Child_Behavior
           ,Removal_Child_Drug_Abuse
           ,Removal_Child_Disability
           ,Removal_Inadequate_Housing
           ,Removal_Neglect
           ,Removal_Parent_Alcohol_Abuse
           ,Removal_Parent_Drug_Abuse
           ,Removal_Parent_Incapacity
           ,Removal_Physical_Abuse
           ,Removal_Sexual_Abuse
           ,Removal_Parent_Death
           ,Removal_Incarceration
           ,CHILD_AGE_REMOVAL_BEGIN
           ,CHILD_AGE_REMOVAL_END
           ,ID_REMOVAL_EPISODE_FACT
           ,CD_GNDR
           ,TX_GNDR
           ,DT_BIRTH
           ,CD_BRAAM_RACE
           ,TX_BRAAM_RACE
           ,INVS_COUNTY_CD
           ,INVS_COUNTY
           ,Removal_ID_Location_Dim_Worker_County_Cd
           ,Removal_ID_Location_Dim_Worker_County
           ,id_people_dim_child
           ,cd_race_census
           ,census_Hispanic_Latino_Origin_cd
           ,petition_dependency_date
           ,dur_days
           ,fl_dur_7
           ,fl_dur_90
           ,dur_trh_days
		   ,cnt_trh
           ,eps_total
           ,eps_rank
           ,eps_total_gt7
           ,eps_rank_gt7
           ,fl_close
           ,frst_plc_id_provider
           ,lst_plc_id_provider
           ,longest_cd_plcmnt_evnt
		   ,longest_id_plcmnt_evnt
		   ,dur_days_longest_plcm
           ,cnt_ooh_plcm
           ,cnt_plcm
		   ,primary_parent_id_prsn
		   ,fam_structure_cd
		   ,fam_structure_tx)

		select 
		ID_PRSN_CHILD
           ,ID_CASE
           ,First_Removal_Date
           ,Latest_Removal_Date
           ,Removal_Region
           ,Removal_County_Cd
           ,Removal_County
           ,State_Custody_Start_Date
           ,REMOVAL_EPISODE_BEGIN_INT
           ,REMOVAL_EPISODE_END_INT
           ,State_Discharge_Date
           ,State_Discharge_Reason
           ,State_Discharge_Reason_Code
           ,Federal_Discharge_Date
           ,Federal_Discharge_Date_Force_18
           ,Federal_Discharge_Reason_Code
           ,Federal_Discharge_Reason
           ,Initial_Plcm_Setting_For_Removal_Cd
           ,Initial_Plcm_Setting_For_Removal
           ,init_id_plcmnt_evnt
           ,init_cd_plcmnt_evnt
           ,Last_Plcm_Setting_For_Removal_Cd
           ,Last_Plcm_Setting_For_Removal
           ,last_id_plcmnt_evnt
           ,last_cd_plcmnt_evnt
           ,Removal_County_Initial_Placement_Caregiver_Cd
           ,Removal_County_Initial_Placement_Caregiver
           ,Removal_Initial_Placement_Worker_Office_Cd
           ,Removal_Initial_Placement_Worker_Office
           ,Removal_Initial_Placement_Worker_Office_County_cd
           ,Removal_Initial_Placement_Worker_Office_County
           ,Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON
           ,Removal_ID_PLACEMENT_RESULT_DIM_LATEST_END_REASON_CD
           ,Removal_Plcm_Discharge_Reason
           ,Removal_Plcm_Discharge_Reason_Cd
           ,Disability_Diagnosis
           ,Disability_Physical
           ,Disability_Sensory
           ,Disability_MR
           ,Disability_Emotional
           ,Disability_Other
           ,Removal_Abuse
           ,Removal_Abandon
           ,Removal_Relinquishment
           ,Removal_Child_Alcohol_Abuse
           ,Removal_Child_Behavior
           ,Removal_Child_Drug_Abuse
           ,Removal_Child_Disability
           ,Removal_Inadequate_Housing
           ,Removal_Neglect
           ,Removal_Parent_Alcohol_Abuse
           ,Removal_Parent_Drug_Abuse
           ,Removal_Parent_Incapacity
           ,Removal_Physical_Abuse
           ,Removal_Sexual_Abuse
           ,Removal_Parent_Death
           ,Removal_Incarceration
           ,CHILD_AGE_REMOVAL_BEGIN
           ,CHILD_AGE_REMOVAL_END
           ,ID_REMOVAL_EPISODE_FACT
           ,CD_GNDR
           ,TX_GNDR
           ,DT_BIRTH
           ,CD_BRAAM_RACE
           ,TX_BRAAM_RACE
           ,INVS_COUNTY_CD
           ,INVS_COUNTY
           ,Removal_ID_Location_Dim_Worker_County_Cd
           ,Removal_ID_Location_Dim_Worker_County
           ,id_people_dim_child
           ,cd_race_census
           ,census_Hispanic_Latino_Origin_cd
           ,petition_dependency_date
           ,dur_days
           ,fl_dur_7
           ,fl_dur_90
           ,dur_trh_days
		   ,cnt_trh
           ,eps_total
           ,eps_rank
           ,eps_total_gt7
           ,eps_rank_gt7
           ,fl_close
           ,frst_plc_id_provider
           ,lst_plc_id_provider
           ,longest_cd_plcmnt_evnt
		   ,longest_id_plcmnt_evnt
		   ,dur_days_longest_plcm
           ,cnt_ooh_plcm
           ,cnt_plcm
		   ,primary_parent_id_prsn
		   ,fam_structure_cd
		   ,fam_structure_tx
		from #child_episodes
		 ;
		
		update dbo.TBL_CHILD_EPISODES
		set dt_birth=null
		where dt_birth > state_custody_start_date;


		
		update TCE
		set nxt_eps_date=q.nxt_eps_date
		from dbo.TBL_CHILD_EPISODES tce
		cross apply
			(select top 1
					nxt.id_prsn_child
					,tce.state_custody_start_date
					,nxt.state_custody_start_date as nxt_eps_date
			 from dbo.TBL_CHILD_EPISODES nxt
			 where nxt.id_prsn_child=tce.id_prsn_child
			 and nxt.state_custody_start_date> tce.state_custody_start_date
			 order by nxt.id_prsn_child,nxt.state_custody_start_date asc )q
		where q.state_custody_start_date=tce.state_custody_start_date
			and q.id_prsn_child=tce.id_prsn_child;
			
		update TCE
		set nxt_eps_date_gt7=q.nxt_eps_date
		from dbo.TBL_CHILD_EPISODES tce
		cross apply
			(select top 1
					nxt.id_prsn_child
					,tce.state_custody_start_date
					,nxt.state_custody_start_date as nxt_eps_date
			 from dbo.TBL_CHILD_EPISODES nxt
			 where nxt.id_prsn_child=tce.id_prsn_child
			 and nxt.state_custody_start_date> tce.state_custody_start_date
			 and nxt.fl_dur_7=0
			 order by nxt.id_prsn_child,nxt.state_custody_start_date asc )q
		where q.state_custody_start_date=tce.state_custody_start_date
			and q.id_prsn_child=tce.id_prsn_child;



		
		update tbl_child_episodes 
		set CHILD_AGE_REMOVAL_BEGIN=dbo.fnc_datediff_yrs(dt_birth,state_custody_start_date)
		where dbo.fnc_datediff_yrs(dt_birth,state_custody_start_date) <> CHILD_AGE_REMOVAL_BEGIN

		update tbl_child_episodes 
		set CHILD_AGE_REMOVAL_END=dbo.fnc_datediff_yrs(dt_birth,Federal_Discharge_Date)
		where federal_discharge_date is not null
			and dbo.fnc_datediff_yrs(dt_birth,Federal_Discharge_Date) <> CHILD_AGE_REMOVAL_END

		update tbl_child_episodes
		set age_eps_begin_mos = dbo.fnc_datediff_mos(tbl_child_episodes.dt_birth,state_custody_start_date)

		update tbl_child_episodes
		set age_eps_begin_mos = 0
		where tbl_child_episodes.dt_birth is null and child_age_removal_begin=0 and age_eps_begin_mos is null
		


		  update tbl_child_episodes
		  set fl_dep_exist=1
		  where petition_dependency_date is not null


		  update tbl_child_episodes
		  set bin_dep_cd=  ref.bin_dep_cd
		  from [ref_filter_dependency] ref
		  where ref.fl_dep_exist=tbl_child_episodes.fl_dep_exist
		  and petition_dependency_date between dateadd(dd,diff_days_from,state_custody_start_date)
					and dateadd(dd,diff_days_thru,state_custody_start_date)

		update tce
		set max_bin_los_cd=q.max_bin_los_cd
		from tbl_child_episodes tce
		join (select id_removal_episode_Fact,max(bin_los_cd) as max_bin_los_cd
				from tbl_child_episodes ce
				join [ref_filter_los] on  ce.dur_days between dur_days_from and dur_days_thru
					group by id_removal_episode_Fact) q
					on q.id_removal_episode_fact=tce.id_removal_episode_fact
			
		update statistics tbl_child_episodes;
		--select ID_PRSN_CHILD,State_Custody_Start_Date,count(*) as cnt
		--from #child_episodes
		--group by ID_PRSN_CHILD,State_Custody_Start_Date
		--having count(*) > 1

	--select id_removal_episode_Fact as v,* from #child_episodes where ID_PRSN_CHILD=2553545
	--	select * from dbo.TBL_CHILD_EPISODES_RPLCD_20130520 where ID_PRSN_CHILD=2553545
		-- select * from ca.REMOVAL_EPISODE_FACT where ID_PRSN_CHILD=2553545  

	
	end
else
begin
	select 'Need permission key to execute this --BUILDS TBL_CHILD_EPISODES!' as [Warning]
end

----select * from tbl_child_placement_settings p where p.id_removal_episode_fact=167963 order by p.eps_plcm_sort_asc desc
----select * from #child_episodes where id_removal_episode_fact=167963
----select id_prsn_child,id_removal_episode_fact,state_custody_start_date,isnull(federal_discharge_date,'12/31/3999') from #child_episodes
----except
----select id_prsn_child,id_removal_episode_fact,state_custody_start_date,isnull(federal_discharge_date,'12/31/3999') from tbl_child_episodes
----except
----select id_prsn_child,id_removal_episode_fact,state_custody_start_date,isnull(federal_discharge_date,'12/31/3999') from #child_episodes
----select * from dbo.tbl_child_episode_merge_id where id_removal_episode_fact in (144114,144115)
----select id_removal_episode_fact as vid, * from #child_episodes  where id_removal_episode_fact in (144114,144115)
----select * from #wrk_eps where id_removal_episode_fact in (144114,144115)
----select * from ca.placement_fact  where id_removal_episode_fact in (684) order by id_removal_episode_fact,id_calendar_dim_begin
----select * from tbl_child_placement_settings where id_removal_episode_fact=684

----select * from ca.removal_episode_fact where id_prsn_child=753301
----select * From #child_episodes where ID_PRSN_CHILD=753301

----select * from ca.removal_episode_fact where id_prsn_child=2943302
----select * From #child_episodes where ID_PRSN_CHILD=2943302 order by State_Custody_Start_Date
----select * from tbl_child_episode_orig_data_prior_cleanup  where ID_PRSN_CHILD=753301 order by State_Custody_Start_Date

----select count(*) from tbl_child_episodes tce left join #child_episodes ce 
----	on ce.ID_REMOVAL_EPISODE_FACT=tce.id_removal_episode_fact 
----	and ce.State_Custody_Start_Date=tce.state_custody_start_date
----and isnull(ce.Federal_Discharge_Date,'12/31/3999')= isnull(tce.Federal_Discharge_Date,'12/31/3999') --123796
----where ce.ID_REMOVAL_EPISODE_FACT is  null	



----select count(*) from tbl_child_episodes
----select count(*) from #child_episodes

----select fl_cleanup_type,count(*) from tbl_child_episode_orig_data_prior_cleanup group by fl_cleanup_type
----drop table dbo.clncy 
----select * into dbo.clncy from #child_episodes

----select * from #REMOVALS where id_prsn_child=317152
----select * from #wrk_eps where id_removal_episode_fact in  (42803,60087,67138,68394) 