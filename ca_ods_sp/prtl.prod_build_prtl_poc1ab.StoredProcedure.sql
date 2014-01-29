USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_poc1ab]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure  [prtl].[prod_build_prtl_poc1ab](@permission_key datetime) 
as 
  set nocount on
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin

	
		declare @date_type int
		declare @startDate datetime
		declare @periodStart datetime
		declare @periodEnd datetime
		declare @endDate datetime


		declare @loopEndDate datetime
		declare @cutoff_date datetime
		declare @rowcount int
		declare @maxNbrCustSeg int
		--if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
		--begin

		declare @last_month_end datetime
		declare @last_year_end datetime

		set @date_type=0
		set @startDate='2000-01-01'

		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer

		--set @loopEndDate=@endDate

		--set @startDate='2006-02-01'
		--set @endDate='2006-03-01'

					
		set @periodStart=@startDate

		--set @endDate=(select dateadd(dd,-1,[year]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)
		set @endDate=(select dateadd(dd,-1,[month]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		set @last_month_end=(select dateadd(mm,-1,[month]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		set @last_year_end=(select dateadd(yy,-1,[year]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		--first pull all episodes into a temp table to clean up dirty data

									
				
					

					
/***********************************************************  POINT IN TIME       **************************/
						if OBJECT_ID('tempDB..#ooh') is not null drop table #ooh

							CREATE TABLE #ooh(
								[qry_type] [int] NOT NULL,
									[date_type] [int] NULL,
									[start_date] [datetime] NULL,
									[bin_dep_cd] [int] NOT NULL,
									[max_bin_los_cd] [int] NULL,
									[bin_placement_cd] [int] NULL,
									[bin_ihs_svc_cd] [int] NULL,
									[cd_reporter_type] [int] NOT NULL,
									[fl_cps_invs] [int] NOT NULL,
									[fl_cfws] [int] NOT NULL,
									[fl_risk_only] [int] NOT NULL,
									[fl_alternate_intervention] [int] NOT NULL,
									[fl_frs] [int] NOT NULL,
									[fl_phys_abuse] [int] NOT NULL,
									[fl_sexual_abuse] [int] NOT NULL,
									[fl_neglect] [int] NOT NULL,
									[fl_any_legal] [int] NOT NULL,
									[fl_founded_phys_abuse] [int] NOT NULL,
									[fl_founded_sexual_abuse] [int] NOT NULL,
									[fl_founded_neglect] [int] NOT NULL,
									[fl_found_any_legal] [int] NOT NULL,
									[fl_family_focused_services] [int] NOT NULL,
									[fl_child_care] [int] NOT NULL,
									[fl_therapeutic_services] [int] NOT NULL,
									[fl_mh_services] [int] NOT NULL,
									[fl_receiving_care] [int] NOT NULL,
									[fl_family_home_placements] [int] NOT NULL,
									[fl_behavioral_rehabiliation_services] [int] NOT NULL,
									[fl_other_therapeutic_living_situations] [int] NOT NULL,
									[fl_specialty_adolescent_services] [int] NOT NULL,
									[fl_respite] [int] NOT NULL,
									[fl_transportation] [int] NOT NULL,
									[fl_clothing_incidentals] [int] NOT NULL,
									[fl_sexually_aggressive_youth] [int] NOT NULL,
									[fl_adoption_support] [int] NOT NULL,
									[fl_various] [int] NOT NULL,
									[fl_medical] [int] NOT NULL,
									[fl_budget_C12] [int] NOT NULL,
									[fl_budget_C14] [int] NOT NULL,
									[fl_budget_C15] [int] NOT NULL,
									[fl_budget_C16] [int] NOT NULL,
									[fl_budget_C18] [int] NOT NULL,
									[fl_budget_C19] [int] NOT NULL,
									[fl_uncat_svc] [int] NOT NULL,
									age_grouping_cd int  NULL,
									[cd_race] [int] NULL,
									[census_hispanic_latino_origin_cd] [int] NULL,
									[pk_gndr] [int] NOT NULL,
									[init_cd_plcm_setng] [int] NULL,
									[long_cd_plcm_setng] [int] NULL,
									county_cd [int] NULL,
									[int_match_param_key] [bigint] NULL,
									custody_id int,
									cnt_first int not null default 0,
									cnt_entries int not null default 0,
									cnt_exits int  not null default 0,
									)
							

--- POINT IN TIME FIRST DAY OF COHORT
/*************************************  qry_type ALL    ALL   ***********************************************************/

---- point in time DCFS 
/*************************************  DCFS qry_type ALL    ALL   ***********************************************************/
		insert into #ooh (qry_type,date_type,	[start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,age_grouping_cd
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_first)
	

						SELECT 2 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						 
						  from prtl.ooh_dcfs_eps
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   state_custody_start_date < cd.[Month]
						  and federal_discharge_date >=cd.[Month]
						
						  group by   cd.[month] 
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
				UNION ALL
							SELECT 2 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    state_custody_start_date < cd.[Year]
						  and federal_discharge_date >=cd.[Year]
						
						  group by   cd.[Year] 
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
				UNION ALL
				----FIRST 

							SELECT 1 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						 
						  from prtl.ooh_dcfs_eps
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   state_custody_start_date < cd.[Month]
						  and federal_discharge_date >=cd.[Month]
						  where state_custody_start_date=first_removal_date
						
						  group by   cd.[month] 
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
				UNION ALL
							SELECT 1 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								 ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    state_custody_start_date < cd.[Year]
						  and federal_discharge_date >=cd.[Year]
						 where state_custody_start_date=first_removal_date
						  group by   cd.[Year] 
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
		UNION ALL
			-- unique is same as all however there is 1 overlapping episode that may throw things off

							SELECT 0 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
									  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   state_custody_start_date < cd.[Month]
						  and federal_discharge_date >=cd.[Month]
						
						  group by   cd.[month] 
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
				UNION ALL
							SELECT 0 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    state_custody_start_date < cd.[Year]
						  and federal_discharge_date >=cd.[Year]
						
						  group by   cd.[Year] 
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
					ORDER BY date_type,qry_type,[start_date],int_match_param_key_census_child_group


/************************************************************                        ENTRIES    ENTRIES  **************************/					
		-- create entries table
						if OBJECT_ID('tempDB..#entries') is not null drop table #entries
							CREATE TABLE #entries(
								[qry_type] [int] NOT NULL,
									[date_type] [int] NULL,
									[start_date] [datetime] NULL,
									[bin_dep_cd] [int] NOT NULL,
									[max_bin_los_cd] [int] NULL,
									[bin_placement_cd] [int] NULL,
									[bin_ihs_svc_cd] [int] NULL,
									[cd_reporter_type] [int] NOT NULL,
									[fl_cps_invs] [int] NOT NULL,
									[fl_cfws] [int] NOT NULL,
									[fl_risk_only] [int] NOT NULL,
									[fl_alternate_intervention] [int] NOT NULL,
									[fl_frs] [int] NOT NULL,
									[fl_phys_abuse] [int] NOT NULL,
									[fl_sexual_abuse] [int] NOT NULL,
									[fl_neglect] [int] NOT NULL,
									[fl_any_legal] [int] NOT NULL,
									[fl_founded_phys_abuse] [int] NOT NULL,
									[fl_founded_sexual_abuse] [int] NOT NULL,
									[fl_founded_neglect] [int] NOT NULL,
									[fl_found_any_legal] [int] NOT NULL,
									[fl_family_focused_services] [int] NOT NULL,
									[fl_child_care] [int] NOT NULL,
									[fl_therapeutic_services] [int] NOT NULL,
									[fl_mh_services] [int] NOT NULL,
									[fl_receiving_care] [int] NOT NULL,
									[fl_family_home_placements] [int] NOT NULL,
									[fl_behavioral_rehabiliation_services] [int] NOT NULL,
									[fl_other_therapeutic_living_situations] [int] NOT NULL,
									[fl_specialty_adolescent_services] [int] NOT NULL,
									[fl_respite] [int] NOT NULL,
									[fl_transportation] [int] NOT NULL,
									[fl_clothing_incidentals] [int] NOT NULL,
									[fl_sexually_aggressive_youth] [int] NOT NULL,
									[fl_adoption_support] [int] NOT NULL,
									[fl_various] [int] NOT NULL,
									[fl_medical] [int] NOT NULL,
									[fl_budget_C12] [int] NOT NULL,
									[fl_budget_C14] [int] NOT NULL,
									[fl_budget_C15] [int] NOT NULL,
									[fl_budget_C16] [int] NOT NULL,
									[fl_budget_C18] [int] NOT NULL,
									[fl_budget_C19] [int] NOT NULL,
									[fl_uncat_svc] [int] NOT NULL,
									age_grouping_cd int  NULL,
									[cd_race] [int] NULL,
									[census_hispanic_latino_origin_cd] [int] NULL,
									[pk_gndr] [int] NOT NULL,
									[init_cd_plcm_setng] [int] NULL,
									[long_cd_plcm_setng] [int] NULL,
									county_cd [int] NULL,
									[int_match_param_key] [bigint] NULL,
									--cnt_episodes int,
									custody_id int,
									cnt_entries int,

									--cnt_exits int,
									--cnt_dcfs_episodes int,
									--cnt_dcfs_entries int,
									--cnt_dcfs_exits int
									)
							
							insert into #entries (qry_type,date_type,	[start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  , age_grouping_cd
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key]
								  ,custody_id
								  ,cnt_entries)

--  ALL ENTRIES 

	--  ALL DCFS ENTRIES 
							SELECT 2
								  ,0
								  ,cohort_entry_month as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_entry_month between @startDate and @last_month_end
						  group by   cohort_entry_month
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								 
							UNION ALL

							SELECT 2
								  ,2
								  ,cohort_entry_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_entry_year between @startdate and  @last_year_end
						  group by   cohort_entry_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
						union all
----  first DCFS entries
							SELECT 1
								  ,0
								  ,cohort_entry_month
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_entry_month between @startDate and @last_month_end
						  and state_custody_start_date=first_removal_date
						  group by   cohort_entry_month
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								 
					UNION ALL

							SELECT 1
								  ,2
								  ,cohort_entry_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_entry_year between @startdate and  @last_year_end
						  and state_custody_start_date=first_removal_date
						  group by   cohort_entry_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,int_match_param_key_census_child_group
----  UNIQUE DCFS ENTRIES
							union all
							
							SELECT 0 as qry_type
								  ,0 as date_type
								  ,unq.cohort_entry_month as start_date
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group
								  ,  1 as custody_id
								  ,  count(distinct unq.id_prsn_child) as cnt_entries
						  from prtl.ooh_dcfs_eps ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_entry_month,id_prsn_child  order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								where cohort_entry_month between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1 
								and ae.cohort_entry_month=unq.cohort_entry_month
								
						  where ae.cohort_entry_month between @startDate and @last_month_end --='2005-01-01'
						  group by   unq.cohort_entry_month
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group
								 
							UNION ALL

							SELECT 0
								  ,2
								  , unq.cohort_entry_year
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from prtl.ooh_dcfs_eps ae
						  join (select prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_entry_year,id_prsn_child order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								where cohort_entry_year between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.cohort_entry_year=unq.cohort_entry_year
						  where ae.cohort_entry_year between @startdate and  @last_year_end
						  group by   unq.cohort_entry_year
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group	

								  order by [custody_id],[start_date],int_match_param_key_census_child_group

								 
		/*************************************************************************************  EXITS ******************* EXITS **/
					if OBJECT_ID('tempDB..#exits') is not null drop table #exits
							CREATE TABLE #exits(
								[qry_type] [int] NOT NULL,
									[date_type] [int] NULL,
									[start_date] [datetime] NULL,
									[bin_dep_cd] [int] NOT NULL,
									[max_bin_los_cd] [int] NULL,
									[bin_placement_cd] [int] NULL,
									[bin_ihs_svc_cd] [int] NULL,
									[cd_reporter_type] [int] NOT NULL,
									[fl_cps_invs] [int] NOT NULL,
									[fl_cfws] [int] NOT NULL,
									[fl_risk_only] [int] NOT NULL,
									[fl_alternate_intervention] [int] NOT NULL,
									[fl_frs] [int] NOT NULL,
									[fl_phys_abuse] [int] NOT NULL,
									[fl_sexual_abuse] [int] NOT NULL,
									[fl_neglect] [int] NOT NULL,
									[fl_any_legal] [int] NOT NULL,
									[fl_founded_phys_abuse] [int] NOT NULL,
									[fl_founded_sexual_abuse] [int] NOT NULL,
									[fl_founded_neglect] [int] NOT NULL,
									[fl_found_any_legal] [int] NOT NULL,
									[fl_family_focused_services] [int] NOT NULL,
									[fl_child_care] [int] NOT NULL,
									[fl_therapeutic_services] [int] NOT NULL,
									[fl_mh_services] [int] NOT NULL,
									[fl_receiving_care] [int] NOT NULL,
									[fl_family_home_placements] [int] NOT NULL,
									[fl_behavioral_rehabiliation_services] [int] NOT NULL,
									[fl_other_therapeutic_living_situations] [int] NOT NULL,
									[fl_specialty_adolescent_services] [int] NOT NULL,
									[fl_respite] [int] NOT NULL,
									[fl_transportation] [int] NOT NULL,
									[fl_clothing_incidentals] [int] NOT NULL,
									[fl_sexually_aggressive_youth] [int] NOT NULL,
									[fl_adoption_support] [int] NOT NULL,
									[fl_various] [int] NOT NULL,
									[fl_medical] [int] NOT NULL,
									[fl_budget_C12] [int] NOT NULL,
									[fl_budget_C14] [int] NOT NULL,
									[fl_budget_C15] [int] NOT NULL,
									[fl_budget_C16] [int] NOT NULL,
									[fl_budget_C18] [int] NOT NULL,
									[fl_budget_C19] [int] NOT NULL,
									[fl_uncat_svc] [int] NOT NULL,
									age_grouping_cd int  NULL,
									cd_race [int] NULL,
									[census_hispanic_latino_origin_cd] [int] NULL,
									[pk_gndr] [int] NOT NULL,
									[init_cd_plcm_setng] [int] NULL,
									[long_cd_plcm_setng] [int] NULL,
									county_cd [int] NULL,
									[int_match_param_key] [bigint] NULL,
									--cnt_episodes int,
									custody_id int,
									cnt_exits int
									--cnt_exits int,
									--cnt_dcfs_episodes int,
									--cnt_dcfs_exits int,
									--cnt_dcfs_exits int
									)
							
							insert into #exits (qry_type,date_type,	[start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,age_grouping_cd
								  ,cd_race
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id ,cnt_exits)


	--  ALL DCFS exits 

							SELECT 2
								  ,0
								  ,cohort_exit_month as [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_exit_month between @startDate and @last_month_end
						  group by   cohort_exit_month
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								 
					UNION ALL

							SELECT 2
								  ,2
								  ,cohort_exit_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_exit_year between @startdate and  @last_year_end
						  group by   cohort_exit_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
						union all
----  first DCFS exits
							SELECT 1
								  ,0
								  ,cohort_exit_month
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_exit_month between @startDate and @last_month_end
						  and state_custody_start_date=first_removal_date
						  group by   cohort_exit_month
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								 
					UNION ALL

							SELECT 1
								  ,2
								  ,cohort_exit_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_exit_year between @startdate and  @last_year_end
						  and state_custody_start_date=first_removal_date
						  group by   cohort_exit_year
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,ooh_dcfs_eps.census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key_census_child_group]
----  UNIQUE DCFS exits
				union all
							
							SELECT 0 as qry_type
								  ,0 as date_type
								  ,unq.cohort_exit_month as start_date
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child) as cnt_exits
						  from prtl.ooh_dcfs_eps ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_exit_month,id_prsn_child  order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								where cohort_exit_month between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1 
								and ae.cohort_exit_month=unq.cohort_exit_month
								
						  where ae.cohort_exit_month between @startDate and @last_month_end --='2005-01-01'
						  group by   unq.cohort_exit_month
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group
								 
					UNION ALL

			
							SELECT 0
								  ,2
								  , unq.cohort_exit_year
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from prtl.ooh_dcfs_eps ae
						  join (select prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_exit_year,id_prsn_child order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								where cohort_exit_year between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.cohort_exit_year=unq.cohort_exit_year
						  where ae.cohort_exit_year between @startdate and  @last_year_end
						  group by   unq.cohort_exit_year
								  ,  unq.bin_dep_cd
								  ,  unq.max_bin_los_cd
								  ,  unq.bin_placement_cd
								  ,  unq.bin_ihs_svc_cd
								  ,  unq.cd_reporter_type
								  ,  unq.fl_cps_invs
								  ,  unq.fl_cfws
								  ,  unq.fl_risk_only
								  ,  unq.fl_alternate_intervention
								  ,  unq.fl_frs
								  ,  unq.fl_phys_abuse
								  ,  unq.fl_sexual_abuse
								  ,  unq.fl_neglect
								  ,  unq.fl_any_legal
								  ,  unq.fl_founded_phys_abuse
								  ,  unq.fl_founded_sexual_abuse
								  ,  unq.fl_founded_neglect
								  ,  unq.fl_found_any_legal
								  ,  unq.fl_family_focused_services
								  ,  unq.fl_child_care
								  ,  unq.fl_therapeutic_services
								  ,  unq.fl_mh_services
								  ,  unq.fl_receiving_care
								  ,  unq.fl_family_home_placements
								  ,  unq.fl_behavioral_rehabiliation_services
								  ,  unq.fl_other_therapeutic_living_situations
								  ,  unq.fl_specialty_adolescent_services
								  ,  unq.fl_respite
								  ,  unq.fl_transportation
								  ,  unq.fl_clothing_incidentals
								  ,  unq.fl_sexually_aggressive_youth
								  ,  unq.fl_adoption_support
								  ,  unq.fl_various
								  ,  unq.fl_medical
								  ,  unq.fl_budget_C12
								  ,  unq.fl_budget_C14
								  ,  unq.fl_budget_C15
								  ,  unq.fl_budget_C16
								  ,  unq.fl_budget_C18
								  ,  unq.fl_budget_C19
								  ,  unq.fl_uncat_svc
								  ,  unq.census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key_census_child_group	

								  order by custody_id,[start_date],int_match_param_key_census_child_group
		

	

/*************     UPDATE ENTRIES               ***************************************/

			update AE
			set cnt_entries= ent.cnt_entries
			from #ooh ae
			join #entries ent
				  on ae.qry_type = ent.qry_type and
				ae.date_type = ent.date_type and
				ae.[start_date] = ent.[start_date] and
				ae.[bin_dep_cd] = ent.[bin_dep_cd] and
				ae.[max_bin_los_cd] = ent.[max_bin_los_cd] and
				ae.[bin_placement_cd] = ent.[bin_placement_cd] and
				ae.[bin_ihs_svc_cd] = ent.[bin_ihs_svc_cd] and
				ae.[cd_reporter_type] = ent.[cd_reporter_type] and
				ae.[fl_cps_invs] = ent.[fl_cps_invs] and
				ae.[fl_cfws] = ent.[fl_cfws] and
				ae.[fl_risk_only] = ent.[fl_risk_only] and
				ae.[fl_alternate_intervention] = ent.[fl_alternate_intervention] and
				ae.[fl_frs] = ent.[fl_frs] and
				ae.[fl_phys_abuse] = ent.[fl_phys_abuse] and
				ae.[fl_sexual_abuse] = ent.[fl_sexual_abuse] and
				ae.[fl_neglect] = ent.[fl_neglect] and
				ae.[fl_any_legal] = ent.[fl_any_legal] and
				ae.[fl_founded_phys_abuse] = ent.[fl_founded_phys_abuse] and
				ae.[fl_founded_sexual_abuse] = ent.[fl_founded_sexual_abuse] and
				ae.[fl_founded_neglect] = ent.[fl_founded_neglect] and
				ae.[fl_found_any_legal] = ent.[fl_found_any_legal] and
				ae.[fl_family_focused_services] = ent.[fl_family_focused_services] and
				ae.[fl_child_care] = ent.[fl_child_care] and
				ae.[fl_therapeutic_services] = ent.[fl_therapeutic_services] and
				ae.[fl_mh_services] = ent.[fl_mh_services] and
				ae.[fl_receiving_care] = ent.[fl_receiving_care] and
				ae.[fl_family_home_placements] = ent.[fl_family_home_placements] and
				ae.[fl_behavioral_rehabiliation_services] = ent.[fl_behavioral_rehabiliation_services] and
				ae.[fl_other_therapeutic_living_situations] = ent.[fl_other_therapeutic_living_situations] and
				ae.[fl_specialty_adolescent_services] = ent.[fl_specialty_adolescent_services] and
				ae.[fl_respite] = ent.[fl_respite] and
				ae.[fl_transportation] = ent.[fl_transportation] and
				ae.[fl_clothing_incidentals] = ent.[fl_clothing_incidentals] and
				ae.[fl_sexually_aggressive_youth] = ent.[fl_sexually_aggressive_youth] and
				ae.[fl_adoption_support] = ent.[fl_adoption_support] and
				ae.[fl_various] = ent.[fl_various] and
				ae.[fl_medical] = ent.[fl_medical] and
				ae.[fl_budget_C12] = ent.[fl_budget_C12] and
				ae.[fl_budget_C14] = ent.[fl_budget_C14] and
				ae.[fl_budget_C15] = ent.[fl_budget_C15] and
				ae.[fl_budget_C16] = ent.[fl_budget_C16] and
				ae.[fl_budget_C18] = ent.[fl_budget_C18] and
				ae.[fl_budget_C19] = ent.[fl_budget_C19] and
				ae.[fl_uncat_svc] = ent.[fl_uncat_svc] and
				ae.age_grouping_cd = ent.age_grouping_cd and
				ae.[cd_race] = ent.[cd_race] and
				ae.[census_hispanic_latino_origin_cd] = ent.[census_hispanic_latino_origin_cd] and
				ae.[pk_gndr] = ent.[pk_gndr] and
				ae.[init_cd_plcm_setng] = ent.[init_cd_plcm_setng] and
				ae.[long_cd_plcm_setng] = ent.[long_cd_plcm_setng] and
				ae.county_cd= ent.county_cd  and
				ae.[int_match_param_key] = ent.[int_match_param_key] and
				ae.custody_id=ent.custody_id
			



			insert into #ooh (qry_type,date_type,	[start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,age_grouping_cd
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_entries)



	/******************   insert entries with NO FIRST DAY **********************************************************************/

								select 
									qry_type
								  ,date_type
								  ,[start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,age_grouping_cd
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_entries
								from #entries
								except
								select 
									qry_type
								  ,date_type
								  ,[start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,age_grouping_cd
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_entries
								from #ooh
						
	




/*********************************************              EXITS  ********************************************************/
			update AE
			set cnt_exits= ext.cnt_exits
			from #ooh ae
			join #exits ext
					on ae.qry_type = ext.qry_type and
				ae.date_type = ext.date_type and
				ae.[start_date] = ext.[start_date] and
				ae.[bin_dep_cd] = ext.[bin_dep_cd] and
				ae.[max_bin_los_cd] = ext.[max_bin_los_cd] and
				ae.[bin_placement_cd] = ext.[bin_placement_cd] and
				ae.[bin_ihs_svc_cd] = ext.[bin_ihs_svc_cd] and
				ae.[cd_reporter_type] = ext.[cd_reporter_type] and
				ae.[fl_cps_invs] = ext.[fl_cps_invs] and
				ae.[fl_cfws] = ext.[fl_cfws] and
				ae.[fl_risk_only] = ext.[fl_risk_only] and
				ae.[fl_alternate_intervention] = ext.[fl_alternate_intervention] and
				ae.[fl_frs] = ext.[fl_frs] and
				ae.[fl_phys_abuse] = ext.[fl_phys_abuse] and
				ae.[fl_sexual_abuse] = ext.[fl_sexual_abuse] and
				ae.[fl_neglect] = ext.[fl_neglect] and
				ae.[fl_any_legal] = ext.[fl_any_legal] and
				ae.[fl_founded_phys_abuse] = ext.[fl_founded_phys_abuse] and
				ae.[fl_founded_sexual_abuse] = ext.[fl_founded_sexual_abuse] and
				ae.[fl_founded_neglect] = ext.[fl_founded_neglect] and
				ae.[fl_found_any_legal] = ext.[fl_found_any_legal] and
				ae.[fl_family_focused_services] = ext.[fl_family_focused_services] and
				ae.[fl_child_care] = ext.[fl_child_care] and
				ae.[fl_therapeutic_services] = ext.[fl_therapeutic_services] and
				ae.[fl_mh_services] = ext.[fl_mh_services] and
				ae.[fl_receiving_care] = ext.[fl_receiving_care] and
				ae.[fl_family_home_placements] = ext.[fl_family_home_placements] and
				ae.[fl_behavioral_rehabiliation_services] = ext.[fl_behavioral_rehabiliation_services] and
				ae.[fl_other_therapeutic_living_situations] = ext.[fl_other_therapeutic_living_situations] and
				ae.[fl_specialty_adolescent_services] = ext.[fl_specialty_adolescent_services] and
				ae.[fl_respite] = ext.[fl_respite] and
				ae.[fl_transportation] = ext.[fl_transportation] and
				ae.[fl_clothing_incidentals] = ext.[fl_clothing_incidentals] and
				ae.[fl_sexually_aggressive_youth] = ext.[fl_sexually_aggressive_youth] and
				ae.[fl_adoption_support] = ext.[fl_adoption_support] and
				ae.[fl_various] = ext.[fl_various] and
				ae.[fl_medical] = ext.[fl_medical] and
				ae.[fl_budget_C12] = ext.[fl_budget_C12] and
				ae.[fl_budget_C14] = ext.[fl_budget_C14] and
				ae.[fl_budget_C15] = ext.[fl_budget_C15] and
				ae.[fl_budget_C16] = ext.[fl_budget_C16] and
				ae.[fl_budget_C18] = ext.[fl_budget_C18] and
				ae.[fl_budget_C19] = ext.[fl_budget_C19] and
				ae.[fl_uncat_svc] = ext.[fl_uncat_svc] and
				ae.age_grouping_cd= ext.age_grouping_cd and
				ae.[cd_race] = ext.[cd_race] and
				ae.[census_hispanic_latino_origin_cd] = ext.[census_hispanic_latino_origin_cd] and
				ae.[pk_gndr] = ext.[pk_gndr] and
				ae.[init_cd_plcm_setng] = ext.[init_cd_plcm_setng] and
				ae.[long_cd_plcm_setng] = ext.[long_cd_plcm_setng] and
				ae.county_cd= ext.county_cd  and
				ae.[int_match_param_key] = ext.[int_match_param_key] and
				ae.custody_id=ext.custody_id
				
			

			/******************   insert exits with NO FIRST DAY **********************************************************************/
			insert into #ooh (qry_type,date_type,	[start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
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
								  ,age_grouping_cd
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_exits)
					select 
						qry_type
						,date_type
						,[start_date]
						,[bin_dep_cd]
						,[max_bin_los_cd]
						,[bin_placement_cd]
						,[bin_ihs_svc_cd]
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
						,age_grouping_cd
						,[cd_race]
						,[census_hispanic_latino_origin_cd]
						,[pk_gndr]
						,[init_cd_plcm_setng]
						,[long_cd_plcm_setng]
						,[county_cd]
						,[int_match_param_key],custody_id,cnt_exits
					from #exits
					except
					select 
						qry_type
						,date_type
						,[start_date]
						,[bin_dep_cd]
						,[max_bin_los_cd]
						,[bin_placement_cd]
						,[bin_ihs_svc_cd]
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
						,age_grouping_cd
						,[cd_race]
						,[census_hispanic_latino_origin_cd]
						,[pk_gndr]
						,[init_cd_plcm_setng]
						,[long_cd_plcm_setng]
						,[county_cd]
						,[int_match_param_key],custody_id,cnt_exits
					from #ooh

	


	CREATE NONCLUSTERED INDEX idx_insert_qry
	ON #ooh ([date_type],[custody_id],[qry_type])
	INCLUDE ([start_date],[bin_dep_cd],[max_bin_los_cd],[bin_placement_cd],[bin_ihs_svc_cd],[cd_reporter_type],[fl_cps_invs],[fl_cfws],[fl_risk_only],[fl_alternate_intervention],[fl_frs],[fl_phys_abuse],[fl_sexual_abuse],[fl_neglect],[fl_any_legal],[fl_founded_phys_abuse],[fl_founded_sexual_abuse],[fl_founded_neglect],[fl_found_any_legal],[fl_family_focused_services],[fl_child_care],[fl_therapeutic_services],[fl_mh_services],[fl_receiving_care],[fl_family_home_placements],[fl_behavioral_rehabiliation_services],[fl_other_therapeutic_living_situations],[fl_specialty_adolescent_services],[fl_respite],[fl_transportation],[fl_clothing_incidentals],[fl_sexually_aggressive_youth],[fl_adoption_support],[fl_various],[fl_medical],[fl_budget_C12],[fl_budget_C14],[fl_budget_C15],[fl_budget_C16],[fl_budget_C18],[fl_budget_C19],[fl_uncat_svc],age_grouping_cd,[cd_race],[census_hispanic_latino_origin_cd],[pk_gndr],[init_cd_plcm_setng],[long_cd_plcm_setng],[county_cd],[int_match_param_key],[cnt_first],[cnt_entries],[cnt_exits])

	--drop table ##ooh
	--select * into ##ooh from #ooh
						
	--select #ooh.start_date, sum(cnt_entries)
	--from #ooh
	--where date_type=2 and qry_type=1 
	--group by start_date
	--order by start_date




	if object_ID(N'prtl.prtl_poc1ab',N'U') is not null truncate table [prtl].[prtl_poc1ab]	
	declare @qry_type int
	set @qry_type=0
	while @qry_type <=2
	begin			
			begin tran t1				
			insert into [prtl].[prtl_poc1ab] ([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					,[fl_cps_invs]
					,[fl_cfws]
					,[fl_risk_only]
					,[fl_alternate_intervention]
					,[fl_frs]
					, filter_allegation
					,[fl_phys_abuse]
					,[fl_sexual_abuse]
					,[fl_neglect]
					,[fl_any_legal]
					, filter_finding
					,[fl_founded_phys_abuse]
					,[fl_founded_sexual_abuse]
					,[fl_founded_neglect]
					,[fl_found_any_legal]
					, filter_service_category
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
					, filter_service_budget
					,[fl_budget_C12]
					,[fl_budget_C14]
					,[fl_budget_C15]
					,[fl_budget_C16]
					,[fl_budget_C18]
					,[fl_budget_C19]
					,[fl_uncat_svc]
					,age_grouping_cd
					,[cd_race]
					,[census_hispanic_latino_origin_cd]
					,[pk_gndr]
					,[init_cd_plcm_setng]
					,[long_cd_plcm_setng]
					,[county_cd]
					,[int_match_param_key]
					,custody_id
					,[cnt_start_date]
					,[cnt_entries]
					,[cnt_exits]
					,start_year
					--,[cnt_dcfs_start_date]
					--,[cnt_dcfs_entries]
					--,[cnt_dcfs_exits]
					)

		select [qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,[bin_dep_cd]
				   ,[max_bin_los_cd]
				   ,[bin_placement_cd]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * [fl_cfws])
					+ (power(10.0,2) * [fl_risk_only])
					+ (power(10.0,1) * [fl_alternate_intervention])
					+ (power(10.0,0) * [fl_frs]) as filter_access_type
				   ,[fl_cps_invs]
				   ,[fl_cfws]
				   ,[fl_risk_only]
				   ,[fl_alternate_intervention]
				   ,[fl_frs]
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,power(10.0,16) + 
				   (fl_family_focused_services * 1000000000000000) + 
								(fl_child_care * 100000000000000) + 
								(fl_therapeutic_services * 10000000000000) + 
								(fl_mh_services * 1000000000000) + 
								(fl_receiving_care * 100000000000) + 
								(fl_family_home_placements * 10000000000) + 
								(fl_behavioral_rehabiliation_services * 1000000000) + 
								(fl_other_therapeutic_living_situations * 100000000) + 
								(fl_specialty_adolescent_services * 10000000) + 
								(fl_respite * 1000000) + 
								(fl_transportation * 100000) + 
								(fl_clothing_incidentals * 10000) + 
								(fl_sexually_aggressive_youth * 1000) + 
								(fl_adoption_support * 100) + 
								(fl_various * 10) + 
								(fl_medical * 1) as filter_service_category
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
				   ,power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					(fl_budget_C15 * 10000) + 
					(fl_budget_C16 * 1000) + 
					(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) as filter_service_budget
				   ,[fl_budget_C12]
				   ,[fl_budget_C14]
				   ,[fl_budget_C15]
				   ,[fl_budget_C16]
				   ,[fl_budget_C18]
				   ,[fl_budget_C19]
				   ,[fl_uncat_svc]
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
				   ,[cnt_first]
				   ,[cnt_entries]
				   ,[cnt_exits]
				   ,year(start_date)
			From #ooh where date_type=0 and custody_id=1 and qry_type=@qry_type
			commit tran t1
			set @qry_type=@qry_type + 1;
		end
	-- reinitialize
	set @qry_type=0
	while @qry_type <=2
	begin
			begin tran t2
			insert into [prtl].[prtl_poc1ab] ([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					,[fl_cps_invs]
					,[fl_cfws]
					,[fl_risk_only]
					,[fl_alternate_intervention]
					,[fl_frs]
					, filter_allegation
					,[fl_phys_abuse]
					,[fl_sexual_abuse]
					,[fl_neglect]
					,[fl_any_legal]
					, filter_finding
					,[fl_founded_phys_abuse]
					,[fl_founded_sexual_abuse]
					,[fl_founded_neglect]
					,[fl_found_any_legal]
					, filter_service_category
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
					, filter_service_budget
					,[fl_budget_C12]
					,[fl_budget_C14]
					,[fl_budget_C15]
					,[fl_budget_C16]
					,[fl_budget_C18]
					,[fl_budget_C19]
					,[fl_uncat_svc]
					,age_grouping_cd
					,[cd_race]
					,[census_hispanic_latino_origin_cd]
					,[pk_gndr]
					,[init_cd_plcm_setng]
					,[long_cd_plcm_setng]
					,[county_cd]
					,[int_match_param_key]
					,custody_id
					,[cnt_start_date]
					,[cnt_entries]
					,[cnt_exits]
					--,[cnt_dcfs_start_date]
					--,[cnt_dcfs_entries]
					--,[cnt_dcfs_exits]
					,start_year)

		select [qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,[bin_dep_cd]
				   ,[max_bin_los_cd]
				   ,[bin_placement_cd]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * [fl_cfws])
					+ (power(10.0,2) * [fl_risk_only])
					+ (power(10.0,1) * [fl_alternate_intervention])
					+ (power(10.0,0) * [fl_frs]) as filter_access_type
				   ,[fl_cps_invs]
				   ,[fl_cfws]
				   ,[fl_risk_only]
				   ,[fl_alternate_intervention]
				   ,[fl_frs]
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,power(10.0,16) + 
				   (fl_family_focused_services * 1000000000000000) + 
								(fl_child_care * 100000000000000) + 
								(fl_therapeutic_services * 10000000000000) + 
								(fl_mh_services * 1000000000000) + 
								(fl_receiving_care * 100000000000) + 
								(fl_family_home_placements * 10000000000) + 
								(fl_behavioral_rehabiliation_services * 1000000000) + 
								(fl_other_therapeutic_living_situations * 100000000) + 
								(fl_specialty_adolescent_services * 10000000) + 
								(fl_respite * 1000000) + 
								(fl_transportation * 100000) + 
								(fl_clothing_incidentals * 10000) + 
								(fl_sexually_aggressive_youth * 1000) + 
								(fl_adoption_support * 100) + 
								(fl_various * 10) + 
								(fl_medical * 1) as filter_service_category
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
				   ,power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					(fl_budget_C15 * 10000) + 
					(fl_budget_C16 * 1000) + 
					(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) as filter_service_budget
				   ,[fl_budget_C12]
				   ,[fl_budget_C14]
				   ,[fl_budget_C15]
				   ,[fl_budget_C16]
				   ,[fl_budget_C18]
				   ,[fl_budget_C19]
				   ,[fl_uncat_svc]
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
				   ,[cnt_first]
				   ,[cnt_entries]
				   ,[cnt_exits]
				   ,year(start_date)
			From #ooh where date_type=2 and custody_id=1 and qry_type=@qry_type
			commit tran t2
			set @qry_type=@qry_type + 1
			end
	-- reinitialize
	set @qry_type=0
	while @qry_type <=2
	begin		
		begin tran t3
			INSERT into prtl.prtl_poc1ab([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					,[fl_cps_invs]
					,[fl_cfws]
					,[fl_risk_only]
					,[fl_alternate_intervention]
					,[fl_frs]
					, filter_allegation
					,[fl_phys_abuse]
					,[fl_sexual_abuse]
					,[fl_neglect]
					,[fl_any_legal]
					, filter_finding
					,[fl_founded_phys_abuse]
					,[fl_founded_sexual_abuse]
					,[fl_founded_neglect]
					,[fl_found_any_legal]
					, filter_service_category
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
					, filter_service_budget
					,[fl_budget_C12]
					,[fl_budget_C14]
					,[fl_budget_C15]
					,[fl_budget_C16]
					,[fl_budget_C18]
					,[fl_budget_C19]
					,[fl_uncat_svc]
					,age_grouping_cd
					,[cd_race]
					,[census_hispanic_latino_origin_cd]
					,[pk_gndr]
					,[init_cd_plcm_setng]
					,[long_cd_plcm_setng]
					,[county_cd]
					,[int_match_param_key]
					,custody_id
					,[cnt_start_date]
					,[cnt_entries]
					,[cnt_exits]
					--,[cnt_dcfs_start_date]
					--,[cnt_dcfs_entries]
					--,[cnt_dcfs_exits]
					,start_year)
		select [qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,0 as [bin_dep_cd]
				   ,[max_bin_los_cd]
				   ,[bin_placement_cd]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * [fl_cfws])
					+ (power(10.0,2) * [fl_risk_only])
					+ (power(10.0,1) * [fl_alternate_intervention])
					+ (power(10.0,0) * [fl_frs]) as filter_access_type
				   ,[fl_cps_invs]
				   ,[fl_cfws]
				   ,[fl_risk_only]
				   ,[fl_alternate_intervention]
				   ,[fl_frs]
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,power(10.0,16) + 
				   (fl_family_focused_services * 1000000000000000) + 
								(fl_child_care * 100000000000000) + 
								(fl_therapeutic_services * 10000000000000) + 
								(fl_mh_services * 1000000000000) + 
								(fl_receiving_care * 100000000000) + 
								(fl_family_home_placements * 10000000000) + 
								(fl_behavioral_rehabiliation_services * 1000000000) + 
								(fl_other_therapeutic_living_situations * 100000000) + 
								(fl_specialty_adolescent_services * 10000000) + 
								(fl_respite * 1000000) + 
								(fl_transportation * 100000) + 
								(fl_clothing_incidentals * 10000) + 
								(fl_sexually_aggressive_youth * 1000) + 
								(fl_adoption_support * 100) + 
								(fl_various * 10) + 
								(fl_medical * 1) as filter_service_category
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
				   ,power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					(fl_budget_C15 * 10000) + 
					(fl_budget_C16 * 1000) + 
					(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) as filter_service_budget
				   ,[fl_budget_C12]
				   ,[fl_budget_C14]
				   ,[fl_budget_C15]
				   ,[fl_budget_C16]
				   ,[fl_budget_C18]
				   ,[fl_budget_C19]
				   ,[fl_uncat_svc]
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
				   ,sum([cnt_first])
				   ,sum([cnt_entries])
				   ,sum([cnt_exits])
				   
				   --,[cnt_dcfs_first]
				   --,[cnt_dcfs_entries]
				   --,[cnt_dcfs_exits]
				   ,year(start_date)
		From #ooh
		where date_type=0 and custody_id=1 and qry_type=@qry_type
		group by 
				[qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,[max_bin_los_cd]
				   ,[bin_placement_cd]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * [fl_cfws])
					+ (power(10.0,2) * [fl_risk_only])
					+ (power(10.0,1) * [fl_alternate_intervention])
					+ (power(10.0,0) * [fl_frs]) 
				   ,[fl_cps_invs]
				   ,[fl_cfws]
				   ,[fl_risk_only]
				   ,[fl_alternate_intervention]
				   ,[fl_frs]
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) 
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) 
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,power(10.0,16) + 
				   (fl_family_focused_services * 1000000000000000) + 
								(fl_child_care * 100000000000000) + 
								(fl_therapeutic_services * 10000000000000) + 
								(fl_mh_services * 1000000000000) + 
								(fl_receiving_care * 100000000000) + 
								(fl_family_home_placements * 10000000000) + 
								(fl_behavioral_rehabiliation_services * 1000000000) + 
								(fl_other_therapeutic_living_situations * 100000000) + 
								(fl_specialty_adolescent_services * 10000000) + 
								(fl_respite * 1000000) + 
								(fl_transportation * 100000) + 
								(fl_clothing_incidentals * 10000) + 
								(fl_sexually_aggressive_youth * 1000) + 
								(fl_adoption_support * 100) + 
								(fl_various * 10) + 
								(fl_medical * 1)
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
				   ,power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					(fl_budget_C15 * 10000) + 
					(fl_budget_C16 * 1000) + 
					(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) 
				   ,[fl_budget_C12]
				   ,[fl_budget_C14]
				   ,[fl_budget_C15]
				   ,[fl_budget_C16]
				   ,[fl_budget_C18]
				   ,[fl_budget_C19]
				   ,[fl_uncat_svc]
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
				   ,year(start_date)
		commit tran t3
		set @qry_type=@qry_type + 1
		end



-- reinitialize
	set @qry_type=0
	while @qry_type <=2
		begin	
		begin tran t4
		INSERT into prtl.prtl_poc1ab([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					,[fl_cps_invs]
					,[fl_cfws]
					,[fl_risk_only]
					,[fl_alternate_intervention]
					,[fl_frs]
					, filter_allegation
					,[fl_phys_abuse]
					,[fl_sexual_abuse]
					,[fl_neglect]
					,[fl_any_legal]
					, filter_finding
					,[fl_founded_phys_abuse]
					,[fl_founded_sexual_abuse]
					,[fl_founded_neglect]
					,[fl_found_any_legal]
					, filter_service_category
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
					, filter_service_budget
					,[fl_budget_C12]
					,[fl_budget_C14]
					,[fl_budget_C15]
					,[fl_budget_C16]
					,[fl_budget_C18]
					,[fl_budget_C19]
					,[fl_uncat_svc]
					,age_grouping_cd
					,[cd_race]
					,[census_hispanic_latino_origin_cd]
					,[pk_gndr]
					,[init_cd_plcm_setng]
					,[long_cd_plcm_setng]
					,[county_cd]
					,[int_match_param_key]
					,custody_id
					,[cnt_start_date]
					,[cnt_entries]
					,[cnt_exits]
					--,[cnt_dcfs_start_date]
					--,[cnt_dcfs_entries]
					--,[cnt_dcfs_exits]
					,start_year)
		select [qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,0 as [bin_dep_cd]
				   ,[max_bin_los_cd]
				   ,[bin_placement_cd]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * [fl_cfws])
					+ (power(10.0,2) * [fl_risk_only])
					+ (power(10.0,1) * [fl_alternate_intervention])
					+ (power(10.0,0) * [fl_frs]) as filter_access_type
				   ,[fl_cps_invs]
				   ,[fl_cfws]
				   ,[fl_risk_only]
				   ,[fl_alternate_intervention]
				   ,[fl_frs]
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,power(10.0,16) + 
				   (fl_family_focused_services * 1000000000000000) + 
								(fl_child_care * 100000000000000) + 
								(fl_therapeutic_services * 10000000000000) + 
								(fl_mh_services * 1000000000000) + 
								(fl_receiving_care * 100000000000) + 
								(fl_family_home_placements * 10000000000) + 
								(fl_behavioral_rehabiliation_services * 1000000000) + 
								(fl_other_therapeutic_living_situations * 100000000) + 
								(fl_specialty_adolescent_services * 10000000) + 
								(fl_respite * 1000000) + 
								(fl_transportation * 100000) + 
								(fl_clothing_incidentals * 10000) + 
								(fl_sexually_aggressive_youth * 1000) + 
								(fl_adoption_support * 100) + 
								(fl_various * 10) + 
								(fl_medical * 1) as filter_service_category
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
				   ,power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					(fl_budget_C15 * 10000) + 
					(fl_budget_C16 * 1000) + 
					(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) as filter_service_budget
				   ,[fl_budget_C12]
				   ,[fl_budget_C14]
				   ,[fl_budget_C15]
				   ,[fl_budget_C16]
				   ,[fl_budget_C18]
				   ,[fl_budget_C19]
				   ,[fl_uncat_svc]
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
					,custody_id
				   ,sum([cnt_first])
				   ,sum([cnt_entries])
				   ,sum([cnt_exits])
				   --,[cnt_dcfs_first]
				   --,[cnt_dcfs_entries]
				   --,[cnt_dcfs_exits]
				   ,year(start_date)
			From #ooh
			where date_type=2 and custody_id=1 and qry_type=@qry_type
			group by 
				[qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,[max_bin_los_cd]
				   ,[bin_placement_cd]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * [fl_cfws])
					+ (power(10.0,2) * [fl_risk_only])
					+ (power(10.0,1) * [fl_alternate_intervention])
					+ (power(10.0,0) * [fl_frs]) 
				   ,[fl_cps_invs]
				   ,[fl_cfws]
				   ,[fl_risk_only]
				   ,[fl_alternate_intervention]
				   ,[fl_frs]
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) 
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) 
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,power(10.0,16) + 
				   (fl_family_focused_services * 1000000000000000) + 
								(fl_child_care * 100000000000000) + 
								(fl_therapeutic_services * 10000000000000) + 
								(fl_mh_services * 1000000000000) + 
								(fl_receiving_care * 100000000000) + 
								(fl_family_home_placements * 10000000000) + 
								(fl_behavioral_rehabiliation_services * 1000000000) + 
								(fl_other_therapeutic_living_situations * 100000000) + 
								(fl_specialty_adolescent_services * 10000000) + 
								(fl_respite * 1000000) + 
								(fl_transportation * 100000) + 
								(fl_clothing_incidentals * 10000) + 
								(fl_sexually_aggressive_youth * 1000) + 
								(fl_adoption_support * 100) + 
								(fl_various * 10) + 
								(fl_medical * 1)
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
				   ,power(10.0,7) +
				   ( (fl_budget_C12 * 1000000) + 
					(fl_budget_C14 * 100000) + 
					(fl_budget_C15 * 10000) + 
					(fl_budget_C16 * 1000) + 
					(fl_budget_C18 * 100) + 
					(fl_budget_C19 * 10) + 
					(fl_uncat_svc * 1) ) 
				   ,[fl_budget_C12]
				   ,[fl_budget_C14]
				   ,[fl_budget_C15]
				   ,[fl_budget_C16]
				   ,[fl_budget_C18]
				   ,[fl_budget_C19]
				   ,[fl_uncat_svc]
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
				   ,year(start_date)
			commit tran t4
			set @qry_type=@qry_type + 1
		end
	update statistics prtl.prtl_poc1ab;
	  
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_poc1ab)
	  where tbl_id=1;


		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end

		
GO
