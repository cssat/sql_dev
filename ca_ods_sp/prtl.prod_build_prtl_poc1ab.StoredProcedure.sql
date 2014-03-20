USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_poc1ab]    Script Date: 2/27/2014 11:12:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure  [prtl].[prod_build_prtl_poc1ab](@permission_key datetime) 
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

		--			select 		@endDate,		@last_month_end,@last_year_end
			

					
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
									filter_service_category decimal(18,0),
									filter_service_budget decimal(18,0),
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
								  , filter_service_category
								  , filter_service_budget
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
								  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,case when min(abs(evt.derived_county)) > 39 then -99 else  min(abs(evt.derived_county)) end
								  ,(cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(ad.census_child_group_cd,0)) + 
										(power(10.0,6) * coalesce(ooh_dcfs_eps.cd_race_census,7)) +
											(power(10.0,5) * coalesce(ooh_dcfs_eps.census_Hispanic_Latino_Origin_cd,5)) + 
												(power(10.0,4) * coalesce(ooh_dcfs_eps.pk_gndr,3)) + 
													(power(10.0,3) * ooh_dcfs_eps.init_cd_plcm_setng) +
														(power(10.0,2) * ooh_dcfs_eps.long_cd_plcm_setng) + 
															(power(10.0,0) *  ( case when   min(abs(evt.derived_county)) between 1 and 39 
																										then  min(abs(evt.derived_county)) else  99 end	)) as decimal(9,0))) as [int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 			   removal_dt < cd.[Month]
						  and federal_discharge_date >=cd.[Month]
						   join base.rptPlacement_Events  evt 
								on evt.id_removal_episode_fact=ooh_dcfs_eps.id_removal_episode_fact
								and  evt.begin_date  < cd.[Month] 
								 and coalesce(evt.end_date,'3999-12-31')  >=cd.[Month]
						join age_dim ad on ad.age_mo=datediff(mm,ooh_dcfs_eps .birth_dt,cd.[MONTH]) and ad.age_mo >=  0 and ad.age_mo < 18*12
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
								  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
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
								  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  , case when min(abs(evt.derived_county)) > 39 then -99 else  min(abs(evt.derived_county)) end
								  , (cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(ad.census_child_group_cd,0)) + 
										(power(10.0,6) * coalesce(ooh_dcfs_eps.cd_race_census,7)) +
											(power(10.0,5) * coalesce(ooh_dcfs_eps.census_Hispanic_Latino_Origin_cd,5)) + 
												(power(10.0,4) * coalesce(ooh_dcfs_eps.pk_gndr,3)) + 
													(power(10.0,3) * ooh_dcfs_eps.init_cd_plcm_setng) +
														(power(10.0,2) * ooh_dcfs_eps.long_cd_plcm_setng) + 
															(power(10.0,0) *  ( case when   min(abs(evt.derived_county)) between 1 and 39 
																										then  min(abs(evt.derived_county)) else  99 end	)) as decimal(9,0))) as [int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    removal_dt < cd.[Year]
						  and federal_discharge_date >=cd.[Year]
						join base.rptPlacement_Events  evt 
								on evt.id_removal_episode_fact=ooh_dcfs_eps.id_removal_episode_fact
								and  evt.begin_date  < cd.[Year] 
								 and coalesce(evt.end_date,'3999-12-31')  >=cd.[Year]				
						join age_dim ad on ad.age_mo=datediff(mm,ooh_dcfs_eps .birth_dt,cd.[Year])	and ad.age_mo >=  0 and ad.age_mo < 18*12							 		
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
									  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								
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
								  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,case when min(abs(evt.derived_county)) > 39 then -99 else min(abs(evt.derived_county)) end
								  , (cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(ad.census_child_group_cd,0)) + 
										(power(10.0,6) * coalesce(ooh_dcfs_eps.cd_race_census,7)) +
											(power(10.0,5) * coalesce(ooh_dcfs_eps.census_Hispanic_Latino_Origin_cd,5)) + 
												(power(10.0,4) * coalesce(ooh_dcfs_eps.pk_gndr,3)) + 
													(power(10.0,3) * ooh_dcfs_eps.init_cd_plcm_setng) +
														(power(10.0,2) * ooh_dcfs_eps.long_cd_plcm_setng) + 
															(power(10.0,0) *  ( case when   min(abs(evt.derived_county))  between 1 and 39 
																										then  min(abs(evt.derived_county))  else  99 end	)) as decimal(9,0))) as [int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   removal_dt < cd.[Month]
						  and federal_discharge_date >=cd.[Month]
						join base.rptPlacement_Events  evt 
								on evt.id_removal_episode_fact=ooh_dcfs_eps.id_removal_episode_fact
								and  evt.begin_date  < cd.[Month] 
								 and coalesce(evt.end_date,'3999-12-31')  >=cd.[Month]		
						join age_dim ad on ad.age_mo=datediff(mm,ooh_dcfs_eps .birth_dt,cd.[MONTH]) and ad.age_mo >=  0 and ad.age_mo < 18*12
						where ooh_dcfs_eps.removal_dt=first_removal_dt
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
								  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
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
								  ,filter_service_category
								  , filter_service_budget
								 ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  , case when min(abs(evt.derived_county)) > 39 then -99 else min(abs(evt.derived_county))  end
								  , (cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(ad.census_child_group_cd,0)) + 
										(power(10.0,6) * coalesce(ooh_dcfs_eps.cd_race_census,7)) +
											(power(10.0,5) * coalesce( ooh_dcfs_eps.census_Hispanic_Latino_Origin_cd,5)) + 
												(power(10.0,4) * coalesce( ooh_dcfs_eps.pk_gndr,3)) + 
													(power(10.0,3) * ooh_dcfs_eps.init_cd_plcm_setng) +
														(power(10.0,2) * ooh_dcfs_eps.long_cd_plcm_setng) + 
															(power(10.0,0) *  ( case when   min(abs(evt.derived_county))  between 1 and 39 
																										then  min(abs(evt.derived_county))  else  99 end	)) as decimal(9,0))) as [int_match_param_key_census_child_group]
								  ,1 as custody_id
								  ,count(distinct ooh_dcfs_eps.id_removal_episode_fact) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    removal_dt < cd.[Year]
						  and federal_discharge_date >=cd.[Year]
						join base.rptPlacement_Events  evt 
								on evt.id_removal_episode_fact=ooh_dcfs_eps.id_removal_episode_fact
								and  evt.begin_date  < cd.[Year] 
								 and coalesce(evt.end_date,'3999-12-31')  >=cd.[Year]		
						join age_dim ad on ad.age_mo=datediff(mm,ooh_dcfs_eps .birth_dt,cd.[Year]) and ad.age_mo >=  0 and ad.age_mo < 18*12
						 where ooh_dcfs_eps.removal_dt=ooh_dcfs_eps.first_removal_dt
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
									  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
		UNION ALL
			-- unique is same as all 

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
									  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  , case when min(abs(evt.derived_county)) > 39 then -99 else min(abs(evt.derived_county))  end
								   , (cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(ad.census_child_group_cd,0)) + 
										(power(10.0,6) * coalesce( ooh_dcfs_eps.cd_race_census,7)) +
											(power(10.0,5) * coalesce( ooh_dcfs_eps.census_Hispanic_Latino_Origin_cd,5)) + 
												(power(10.0,4) * coalesce( ooh_dcfs_eps.pk_gndr,3)) + 
													(power(10.0,3) * ooh_dcfs_eps.init_cd_plcm_setng) +
														(power(10.0,2) * ooh_dcfs_eps.long_cd_plcm_setng) + 
															(power(10.0,0) *  ( case when   min(abs(evt.derived_county))  between 1 and 39 
																										then min(abs(evt.derived_county))  else  99 end	)) as decimal(9,0)))
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   removal_dt < cd.[Month]
						  and federal_discharge_date >=cd.[Month]
					    join base.rptPlacement_Events  evt 
								on evt.id_removal_episode_fact=ooh_dcfs_eps.id_removal_episode_fact
								and  evt.begin_date  < cd.[Month] 
								 and coalesce(evt.end_date,'3999-12-31')  >=cd.[Month]		
						join age_dim ad on ad.age_mo=datediff(mm,ooh_dcfs_eps .birth_dt,cd.[Month]) and ad.age_mo >=  0 and ad.age_mo < 18*12
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
								  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
				UNION ALL
							SELECT 0 as qry_type
								  , 2 as date_type
								  , cd.[Year]  as [start_date]
								   ,[bin_dep_cd]
								  , [max_bin_los_cd]
								  , [bin_placement_cd]
								  , [bin_ihs_svc_cd]
								  , [cd_reporter_type]
								  , [fl_cps_invs]
								  , [fl_cfws]
								  , [fl_risk_only]
								  , [fl_alternate_intervention]
								  , [fl_frs]
								  , [fl_phys_abuse]
								  , [fl_sexual_abuse]
								  , [fl_neglect]
								  , [fl_any_legal]
								  , [fl_founded_phys_abuse]
								  , [fl_founded_sexual_abuse]
								  , [fl_founded_neglect]
								  , [fl_found_any_legal]
								  , filter_service_category
								  , filter_service_budget
								  , ad.census_child_group_cd
								  , ooh_dcfs_eps.cd_race_census
								  , [census_hispanic_latino_origin_cd]
								  , [pk_gndr]
								  , [init_cd_plcm_setng]
								  , [long_cd_plcm_setng]
								  , case when min(abs(evt.derived_county)) > 39 then -99 else min(abs(evt.derived_county)) end
								  , (cast(power(10.0,8) + 
										(power(10.0,7) * coalesce(ad.census_child_group_cd,0)) + 
										(power(10.0,6) * coalesce(ooh_dcfs_eps.cd_race_census,7)) +
											(power(10.0,5) * coalesce(ooh_dcfs_eps.census_Hispanic_Latino_Origin_cd,5)) + 
												(power(10.0,4) * coalesce(ooh_dcfs_eps.pk_gndr,3)) + 
													(power(10.0,3) * ooh_dcfs_eps.init_cd_plcm_setng) +
														(power(10.0,2) * ooh_dcfs_eps.long_cd_plcm_setng) + 
															(power(10.0,0) *  ( case when   min(abs(evt.derived_county)) between 1 and 39 
																										then  min(abs(evt.derived_county)) else  99 end	)) as decimal(9,0))) as [int_match_param_key_census_child_group]
								  , 1 as custody_id
								  , count(distinct id_prsn_child) as cnt_eps
						  from prtl.ooh_dcfs_eps
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    removal_dt < cd.[Year]
								and federal_discharge_date >=cd.[Year]
						 join base.rptPlacement_Events  evt 
								on evt.id_removal_episode_fact=ooh_dcfs_eps.id_removal_episode_fact
								and  evt.begin_date  < cd.[Year] 
								 and coalesce(evt.end_date,'3999-12-31')  >=cd.[Year]		
						join age_dim ad on ad.age_mo=datediff(mm,ooh_dcfs_eps .birth_dt,cd.[Year]) and ad.age_mo >=  0 and ad.age_mo < 18*12
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
								  ,filter_service_category
								  , filter_service_budget
								  ,ad.census_child_group_cd
								  ,ooh_dcfs_eps.cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
					ORDER BY date_type,qry_type,[start_date],int_match_param_key_census_child_group

--select sum(cnt_first) from #ooh where qry_type=2 and date_type=2 and start_date='2010-01-01'
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
								    filter_service_category decimal(18,0),
									filter_service_budget decimal(18,0),
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
								  , filter_service_category
								  , filter_service_budget
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								 
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_entry_month between @startDate and @last_month_end
						  and removal_dt=first_removal_dt
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								 
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_entry_year between @startdate and  @last_year_end
						  and removal_dt=ooh_dcfs_eps.first_removal_dt
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,ooh_dcfs_eps.entry_int_match_param_key_census_child_group
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
								  , unq.filter_service_category
								  , unq.filter_service_budget
								  ,  unq.entry_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.entry_int_match_param_key_census_child_group
								  ,  1 as custody_id
								  ,  count(distinct unq.id_prsn_child) as cnt_entries
						  from prtl.ooh_dcfs_eps ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_entry_month,id_prsn_child  order by removal_dt asc,federal_discharge_date asc) as row_num
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
								  , unq.filter_service_category
								  , unq.filter_service_budget
								  ,  unq.entry_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.entry_int_match_param_key_census_child_group
								 
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
								  , unq.filter_service_category
								  , unq.filter_service_budget
								  ,  unq.entry_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.entry_int_match_param_key_census_child_group
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from prtl.ooh_dcfs_eps ae
						  join (select prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_entry_year,id_prsn_child order by removal_dt asc,federal_discharge_date asc) as row_num
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
								  , unq.filter_service_category
								  , unq.filter_service_budget
								  ,  unq.entry_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.entry_int_match_param_key_census_child_group	

								  order by [custody_id],[start_date],entry_int_match_param_key_census_child_group

								 
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
									filter_service_category decimal(18,0) not null,
									filter_service_budget decimal(18,0) not null,
									age_grouping_cd int  NULL,
									cd_race [int] NULL,
									[census_hispanic_latino_origin_cd] [int] NULL,
									[pk_gndr] [int] NOT NULL,
									[init_cd_plcm_setng] [int] NULL,
									[long_cd_plcm_setng] [int] NULL,
									county_cd [int] NULL,
									[int_match_param_key] [bigint] NULL,
									--cnt_episodes int,
									cd_discharge_type int,
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
								  , filter_service_category
								  , filter_service_budget
								  ,age_grouping_cd
								  ,cd_race
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],cd_discharge_type,custody_id ,cnt_exits)


	----  ALL DCFS exits 

	--						SELECT 2
	--							  ,0
	--							  ,cohort_exit_month as [start_date]
	--							  ,[bin_dep_cd]
	--							  ,[max_bin_los_cd]
	--							  ,[bin_placement_cd]
	--							  ,[bin_ihs_svc_cd]
	--							  ,[cd_reporter_type]
	--							  ,[fl_cps_invs]
	--							  ,[fl_cfws]
	--							  ,[fl_risk_only]
	--							  ,[fl_alternate_intervention]
	--							  ,[fl_frs]
	--							  ,[fl_phys_abuse]
	--							  ,[fl_sexual_abuse]
	--							  ,[fl_neglect]
	--							  ,[fl_any_legal]
	--							  ,[fl_founded_phys_abuse]
	--							  ,[fl_founded_sexual_abuse]
	--							  ,[fl_founded_neglect]
	--							  ,[fl_found_any_legal]
	--								  , filter_service_category
	--							  , filter_service_budget
	--							  ,ooh_dcfs_eps.exit_census_child_group_cd
	--							  ,[cd_race_census]
	--							  ,[census_hispanic_latino_origin_cd]
	--							  ,[pk_gndr]
	--							  ,[init_cd_plcm_setng]
	--							  ,[long_cd_plcm_setng]
	--							  ,[removal_county_cd]
	--							  ,exit_int_match_param_key_census_child_group
	--							  , ooh_dcfs_eps.cd_discharge_type
	--							  ,1 as custody_id
	--							  ,count(distinct id_removal_episode_fact)
	--					  from prtl.ooh_dcfs_eps
	--					  where cohort_exit_month between @startDate and @last_month_end
	--					  group by   cohort_exit_month
	--							  ,[bin_dep_cd]
	--							  ,[max_bin_los_cd]
	--							  ,[bin_placement_cd]
	--							  ,[bin_ihs_svc_cd]
	--							  ,[cd_reporter_type]
	--							  ,[fl_cps_invs]
	--							  ,[fl_cfws]
	--							  ,[fl_risk_only]
	--							  ,[fl_alternate_intervention]
	--							  ,[fl_frs]
	--							  ,[fl_phys_abuse]
	--							  ,[fl_sexual_abuse]
	--							  ,[fl_neglect]
	--							  ,[fl_any_legal]
	--							  ,[fl_founded_phys_abuse]
	--							  ,[fl_founded_sexual_abuse]
	--							  ,[fl_founded_neglect]
	--							  ,[fl_found_any_legal]
	--							  , filter_service_category
	--							  , filter_service_budget
	--							  ,ooh_dcfs_eps.exit_census_child_group_cd
	--							  ,[cd_race_census]
	--							  ,[census_hispanic_latino_origin_cd]
	--							  ,[pk_gndr]
	--							  ,[init_cd_plcm_setng]
	--							  ,[long_cd_plcm_setng]
	--							  ,[removal_county_cd]
	--							  ,exit_int_match_param_key_census_child_group
	--							  , ooh_dcfs_eps.cd_discharge_type
								 
	--				UNION ALL

	--						SELECT 2
	--							  ,2
	--							  ,cohort_exit_year
	--							  ,[bin_dep_cd]
	--							  ,[max_bin_los_cd]
	--							  ,[bin_placement_cd]
	--							  ,[bin_ihs_svc_cd]
	--							  ,[cd_reporter_type]
	--							  ,[fl_cps_invs]
	--							  ,[fl_cfws]
	--							  ,[fl_risk_only]
	--							  ,[fl_alternate_intervention]
	--							  ,[fl_frs]
	--							  ,[fl_phys_abuse]
	--							  ,[fl_sexual_abuse]
	--							  ,[fl_neglect]
	--							  ,[fl_any_legal]
	--							  ,[fl_founded_phys_abuse]
	--							  ,[fl_founded_sexual_abuse]
	--							  ,[fl_founded_neglect]
	--							  ,[fl_found_any_legal]
	--							  , filter_service_category
	--							  , filter_service_budget
	--							  ,ooh_dcfs_eps.exit_census_child_group_cd
	--							  ,[cd_race_census]
	--							  ,[census_hispanic_latino_origin_cd]
	--							  ,[pk_gndr]
	--							  ,[init_cd_plcm_setng]
	--							  ,[long_cd_plcm_setng]
	--							  ,[removal_county_cd]
	--							  ,exit_int_match_param_key_census_child_group
	--							    , ooh_dcfs_eps.cd_discharge_type
	--							  ,1 as custody_id
	--							  ,count(distinct id_removal_episode_fact)
	--					  from prtl.ooh_dcfs_eps
	--					  where cohort_exit_year between @startdate and  @last_year_end
	--					  group by   cohort_exit_year
	--							  ,[bin_dep_cd]
	--							  ,[max_bin_los_cd]
	--							  ,[bin_placement_cd]
	--							  ,[bin_ihs_svc_cd]
	--							  ,[cd_reporter_type]
	--							  ,[fl_cps_invs]
	--							  ,[fl_cfws]
	--							  ,[fl_risk_only]
	--							  ,[fl_alternate_intervention]
	--							  ,[fl_frs]
	--							  ,[fl_phys_abuse]
	--							  ,[fl_sexual_abuse]
	--							  ,[fl_neglect]
	--							  ,[fl_any_legal]
	--							  ,[fl_founded_phys_abuse]
	--							  ,[fl_founded_sexual_abuse]
	--							  ,[fl_founded_neglect]
	--							  ,[fl_found_any_legal]
	--							  , filter_service_category
	--							  , filter_service_budget
	--							  ,ooh_dcfs_eps.exit_census_child_group_cd
	--							  ,[cd_race_census]
	--							  ,[census_hispanic_latino_origin_cd]
	--							  ,[pk_gndr]
	--							  ,[init_cd_plcm_setng]
	--							  ,[long_cd_plcm_setng]
	--							  ,[removal_county_cd]
	--							  ,exit_int_match_param_key_census_child_group
	--							    , ooh_dcfs_eps.cd_discharge_type
	--					union all
----  first DCFS exits
							SELECT 1
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.exit_census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,exit_int_match_param_key_census_child_group
								 , ooh_dcfs_eps.cd_discharge_type
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_exit_month between @startDate and @last_month_end
						  and removal_dt=ooh_dcfs_eps.first_removal_dt
						  and exit_census_child_group_cd  between 1 and 4
							
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.exit_census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[exit_int_match_param_key_census_child_group]
								 , ooh_dcfs_eps.cd_discharge_type

								 
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.exit_census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[exit_int_match_param_key_census_child_group]
								 , ooh_dcfs_eps.cd_discharge_type
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps
						  where cohort_exit_year between @startdate and  @last_year_end
						  and removal_dt=ooh_dcfs_eps.first_removal_dt
						  and exit_census_child_group_cd  between 1 and 4
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
								  , filter_service_category
								  , filter_service_budget
								  ,ooh_dcfs_eps.exit_census_child_group_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[exit_int_match_param_key_census_child_group]
								 , ooh_dcfs_eps.cd_discharge_type

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
								  ,  unq.filter_service_category
								  ,  unq.filter_service_budget
								  ,  unq.exit_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.exit_int_match_param_key_census_child_group
								 , unq.cd_discharge_type
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child) as cnt_exits
						  from prtl.ooh_dcfs_eps ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_exit_month,id_prsn_child  order by removal_dt asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								where cohort_exit_month between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1 
								and ae.cohort_exit_month=unq.cohort_exit_month
								
						  where ae.cohort_exit_month between @startDate and @last_month_end --='2005-01-01'
						  and unq.exit_census_child_group_cd  between 1 and 4
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
									  , unq.filter_service_category
								  , unq.filter_service_budget
								  ,  unq.exit_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.exit_int_match_param_key_census_child_group
								 , unq.cd_discharge_type
								 
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
								  ,  unq.filter_service_category
								  ,  unq.filter_service_budget
								  ,  unq.exit_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.exit_int_match_param_key_census_child_group
								 , unq.cd_discharge_type
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from prtl.ooh_dcfs_eps ae
						  join (select prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_exit_year,id_prsn_child order by removal_dt asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								where cohort_exit_year between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.cohort_exit_year=unq.cohort_exit_year
						  where ae.cohort_exit_year between @startdate and  @last_year_end
						  and unq.exit_census_child_group_cd  between 1 and 4
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
								  ,  unq.filter_service_category
								  ,  unq.filter_service_budget
								  ,  unq.exit_census_child_group_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.exit_int_match_param_key_census_child_group	
								 , unq.cd_discharge_type
								  order by custody_id,[start_date],exit_int_match_param_key_census_child_group
		

	

--/*************     UPDATE ENTRIES               ***************************************/

--			update AE
--			set cnt_entries= ent.cnt_entries
--			from #ooh ae
--			join #entries ent
--				  on ae.qry_type = ent.qry_type and
--				ae.date_type = ent.date_type and
--				ae.[start_date] = ent.[start_date] and
--				ae.[bin_dep_cd] = ent.[bin_dep_cd] and
--				ae.[max_bin_los_cd] = ent.[max_bin_los_cd] and
--				ae.[bin_placement_cd] = ent.[bin_placement_cd] and
--				ae.[bin_ihs_svc_cd] = ent.[bin_ihs_svc_cd] and
--				ae.[cd_reporter_type] = ent.[cd_reporter_type] and
--				ae.[fl_cps_invs] = ent.[fl_cps_invs] and
--				ae.[fl_cfws] = ent.[fl_cfws] and
--				ae.[fl_risk_only] = ent.[fl_risk_only] and
--				ae.[fl_alternate_intervention] = ent.[fl_alternate_intervention] and
--				ae.[fl_frs] = ent.[fl_frs] and
--				ae.[fl_phys_abuse] = ent.[fl_phys_abuse] and
--				ae.[fl_sexual_abuse] = ent.[fl_sexual_abuse] and
--				ae.[fl_neglect] = ent.[fl_neglect] and
--				ae.[fl_any_legal] = ent.[fl_any_legal] and
--				ae.[fl_founded_phys_abuse] = ent.[fl_founded_phys_abuse] and
--				ae.[fl_founded_sexual_abuse] = ent.[fl_founded_sexual_abuse] and
--				ae.[fl_founded_neglect] = ent.[fl_founded_neglect] and
--				ae.filter_service_category=ent.filter_service_category and
--				ae.filter_service_budget=ent.filter_service_budget and
--				ae.age_grouping_cd = ent.age_grouping_cd and
--				ae.[cd_race] = ent.[cd_race] and
--				ae.[census_hispanic_latino_origin_cd] = ent.[census_hispanic_latino_origin_cd] and
--				ae.[pk_gndr] = ent.[pk_gndr] and
--				ae.[init_cd_plcm_setng] = ent.[init_cd_plcm_setng] and
--				ae.[long_cd_plcm_setng] = ent.[long_cd_plcm_setng] and
--				ae.county_cd= ent.county_cd  and
--				ae.[int_match_param_key] = ent.[int_match_param_key] and
--				ae.custody_id=ent.custody_id
			



--			insert into #ooh (qry_type,date_type,	[start_date]
--								  ,[bin_dep_cd]
--								  ,[max_bin_los_cd]
--								  ,[bin_placement_cd]
--								  ,[bin_ihs_svc_cd]
--								  ,[cd_reporter_type]
--								  ,[fl_cps_invs]
--								  ,[fl_cfws]
--								  ,[fl_risk_only]
--								  ,[fl_alternate_intervention]
--								  ,[fl_frs]
--								  ,[fl_phys_abuse]
--								  ,[fl_sexual_abuse]
--								  ,[fl_neglect]
--								  ,[fl_any_legal]
--								  ,[fl_founded_phys_abuse]
--								  ,[fl_founded_sexual_abuse]
--								  ,[fl_founded_neglect]
--								  ,[fl_found_any_legal]
--								  ,filter_service_category
--								  ,filter_service_budget
--								  ,age_grouping_cd
--								  ,[cd_race]
--								  ,[census_hispanic_latino_origin_cd]
--								  ,[pk_gndr]
--								  ,[init_cd_plcm_setng]
--								  ,[long_cd_plcm_setng]
--								  ,[county_cd]
--								  ,[int_match_param_key],custody_id,cnt_entries)



--	/******************   insert entries with NO FIRST DAY **********************************************************************/

--								select 
--									qry_type
--								  ,date_type
--								  ,[start_date]
--								  ,[bin_dep_cd]
--								  ,[max_bin_los_cd]
--								  ,[bin_placement_cd]
--								  ,[bin_ihs_svc_cd]
--								  ,[cd_reporter_type]
--								  ,[fl_cps_invs]
--								  ,[fl_cfws]
--								  ,[fl_risk_only]
--								  ,[fl_alternate_intervention]
--								  ,[fl_frs]
--								  ,[fl_phys_abuse]
--								  ,[fl_sexual_abuse]
--								  ,[fl_neglect]
--								  ,[fl_any_legal]
--								  ,[fl_founded_phys_abuse]
--								  ,[fl_founded_sexual_abuse]
--								  ,[fl_founded_neglect]
--								  ,[fl_found_any_legal]
--									,filter_service_category
--									,filter_service_budget
--								  ,age_grouping_cd
--								  ,[cd_race]
--								  ,[census_hispanic_latino_origin_cd]
--								  ,[pk_gndr]
--								  ,[init_cd_plcm_setng]
--								  ,[long_cd_plcm_setng]
--								  ,[county_cd]
--								  ,[int_match_param_key],custody_id,cnt_entries
--								from #entries
--								except
--								select 
--									qry_type
--								  ,date_type
--								  ,[start_date]
--								  ,[bin_dep_cd]
--								  ,[max_bin_los_cd]
--								  ,[bin_placement_cd]
--								  ,[bin_ihs_svc_cd]
--								  ,[cd_reporter_type]
--								  ,[fl_cps_invs]
--								  ,[fl_cfws]
--								  ,[fl_risk_only]
--								  ,[fl_alternate_intervention]
--								  ,[fl_frs]
--								  ,[fl_phys_abuse]
--								  ,[fl_sexual_abuse]
--								  ,[fl_neglect]
--								  ,[fl_any_legal]
--								  ,[fl_founded_phys_abuse]
--								  ,[fl_founded_sexual_abuse]
--								  ,[fl_founded_neglect]
--								  ,[fl_found_any_legal]
--									,filter_service_category
--									,filter_service_budget
--								  ,age_grouping_cd
--								  ,[cd_race]
--								  ,[census_hispanic_latino_origin_cd]
--								  ,[pk_gndr]
--								  ,[init_cd_plcm_setng]
--								  ,[long_cd_plcm_setng]
--								  ,[county_cd]
--								  ,[int_match_param_key],custody_id,cnt_entries
--								from #ooh
						
	



--/*********************************************              EXITS  ********************************************************/
--			update AE
--			set cnt_exits= ext.cnt_exits
--			from #ooh ae
--			join #exits ext
--					on ae.qry_type = ext.qry_type and
--				ae.date_type = ext.date_type and
--				ae.[start_date] = ext.[start_date] and
--				ae.[bin_dep_cd] = ext.[bin_dep_cd] and
--				ae.[max_bin_los_cd] = ext.[max_bin_los_cd] and
--				ae.[bin_placement_cd] = ext.[bin_placement_cd] and
--				ae.[bin_ihs_svc_cd] = ext.[bin_ihs_svc_cd] and
--				ae.[cd_reporter_type] = ext.[cd_reporter_type] and
--				ae.[fl_cps_invs] = ext.[fl_cps_invs] and
--				ae.[fl_cfws] = ext.[fl_cfws] and
--				ae.[fl_risk_only] = ext.[fl_risk_only] and
--				ae.[fl_alternate_intervention] = ext.[fl_alternate_intervention] and
--				ae.[fl_frs] = ext.[fl_frs] and
--				ae.[fl_phys_abuse] = ext.[fl_phys_abuse] and
--				ae.[fl_sexual_abuse] = ext.[fl_sexual_abuse] and
--				ae.[fl_neglect] = ext.[fl_neglect] and
--				ae.[fl_any_legal] = ext.[fl_any_legal] and
--				ae.[fl_founded_phys_abuse] = ext.[fl_founded_phys_abuse] and
--				ae.[fl_founded_sexual_abuse] = ext.[fl_founded_sexual_abuse] and
--				ae.[fl_founded_neglect] = ext.[fl_founded_neglect] and
--				ae.[fl_found_any_legal] = ext.[fl_found_any_legal] and
--				ae.filter_service_category=ext.filter_service_category and
--				ae.filter_service_budget=ext.filter_service_budget and
--				ae.age_grouping_cd= ext.age_grouping_cd and
--				ae.[cd_race] = ext.[cd_race] and
--				ae.[census_hispanic_latino_origin_cd] = ext.[census_hispanic_latino_origin_cd] and
--				ae.[pk_gndr] = ext.[pk_gndr] and
--				ae.[init_cd_plcm_setng] = ext.[init_cd_plcm_setng] and
--				ae.[long_cd_plcm_setng] = ext.[long_cd_plcm_setng] and
--				ae.county_cd= ext.county_cd  and
--				ae.[int_match_param_key] = ext.[int_match_param_key] and
--				ae.custody_id=ext.custody_id
				
			

--			/******************   insert exits with NO FIRST DAY **********************************************************************/
--			insert into #ooh (qry_type,date_type,	[start_date]
--								  ,[bin_dep_cd]
--								  ,[max_bin_los_cd]
--								  ,[bin_placement_cd]
--								  ,[bin_ihs_svc_cd]
--								  ,[cd_reporter_type]
--								  ,[fl_cps_invs]
--								  ,[fl_cfws]
--								  ,[fl_risk_only]
--								  ,[fl_alternate_intervention]
--								  ,[fl_frs]
--								  ,[fl_phys_abuse]
--								  ,[fl_sexual_abuse]
--								  ,[fl_neglect]
--								  ,[fl_any_legal]
--								  ,[fl_founded_phys_abuse]
--								  ,[fl_founded_sexual_abuse]
--								  ,[fl_founded_neglect]
--								  ,[fl_found_any_legal]
--								  ,filter_service_category
--								  ,filter_service_budget
--								  ,age_grouping_cd
--								  ,[cd_race]
--								  ,[census_hispanic_latino_origin_cd]
--								  ,[pk_gndr]
--								  ,[init_cd_plcm_setng]
--								  ,[long_cd_plcm_setng]
--								  ,[county_cd]
--								  ,[int_match_param_key],custody_id,cnt_exits)
--					select 
--						qry_type
--						,date_type
--						,[start_date]
--						,[bin_dep_cd]
--						,[max_bin_los_cd]
--						,[bin_placement_cd]
--						,[bin_ihs_svc_cd]
--						,[cd_reporter_type]
--						,[fl_cps_invs]
--						,[fl_cfws]
--						,[fl_risk_only]
--						,[fl_alternate_intervention]
--						,[fl_frs]
--						,[fl_phys_abuse]
--						,[fl_sexual_abuse]
--						,[fl_neglect]
--						,[fl_any_legal]
--						,[fl_founded_phys_abuse]
--						,[fl_founded_sexual_abuse]
--						,[fl_founded_neglect]
--						,[fl_found_any_legal]
--						,filter_service_category
--						,filter_service_budget
--						,age_grouping_cd
--						,[cd_race]
--						,[census_hispanic_latino_origin_cd]
--						,[pk_gndr]
--						,[init_cd_plcm_setng]
--						,[long_cd_plcm_setng]
--						,[county_cd]
--						,[int_match_param_key],custody_id,cnt_exits
--					from #exits
--					except
--					select 
--						qry_type
--						,date_type
--						,[start_date]
--						,[bin_dep_cd]
--						,[max_bin_los_cd]
--						,[bin_placement_cd]
--						,[bin_ihs_svc_cd]
--						,[cd_reporter_type]
--						,[fl_cps_invs]
--						,[fl_cfws]
--						,[fl_risk_only]
--						,[fl_alternate_intervention]
--						,[fl_frs]
--						,[fl_phys_abuse]
--						,[fl_sexual_abuse]
--						,[fl_neglect]
--						,[fl_any_legal]
--						,[fl_founded_phys_abuse]
--						,[fl_founded_sexual_abuse]
--						,[fl_founded_neglect]
--						,[fl_found_any_legal]
--						,filter_service_category
--						,filter_service_budget
--						,age_grouping_cd
--						,[cd_race]
--						,[census_hispanic_latino_origin_cd]
--						,[pk_gndr]
--						,[init_cd_plcm_setng]
--						,[long_cd_plcm_setng]
--						,[county_cd]
--						,[int_match_param_key],custody_id,cnt_exits
--					from #ooh

	


	CREATE NONCLUSTERED INDEX idx_insert_qry
	ON #ooh ([date_type],[custody_id],[qry_type])
	INCLUDE ([start_date],[bin_dep_cd],[max_bin_los_cd],[bin_placement_cd],[bin_ihs_svc_cd],[cd_reporter_type],[fl_cps_invs],[fl_cfws]
	,[fl_risk_only],[fl_alternate_intervention],[fl_frs],[fl_phys_abuse],[fl_sexual_abuse],[fl_neglect],[fl_any_legal],[fl_founded_phys_abuse]
	,[fl_founded_sexual_abuse],[fl_founded_neglect],[fl_found_any_legal]
	,filter_service_category,filter_service_budget
	,age_grouping_cd,[cd_race],[census_hispanic_latino_origin_cd],[pk_gndr],[init_cd_plcm_setng],[long_cd_plcm_setng],[county_cd],[int_match_param_key],[cnt_first],[cnt_entries],[cnt_exits])

	--drop table ##ooh
	--select * into ##ooh from #ooh
						
	--select #ooh.start_date, sum(cnt_entries)
	--from #ooh
	--where date_type=2 and qry_type=1 
	--group by start_date
	--order by start_date


	if object_ID(N'prtl.prtl_poc1ab',N'U') is not null truncate table [prtl].[prtl_poc1ab]	
		if object_ID(N'prtl.prtl_poc1ab_entries',N'U') is not null truncate table [prtl].[prtl_poc1ab_entries]	
		if object_ID(N'prtl.prtl_poc1ab_exits',N'U') is not null truncate table [prtl].prtl_poc1ab_exits	


	declare @qry_type int
	set @qry_type=0
	while @qry_type <=2
	begin			
					
			insert into [prtl].[prtl_poc1ab] ([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					, filter_allegation
					, filter_finding
					, filter_service_category
					, filter_service_budget
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
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,filter_service_category
				   ,filter_service_budget
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
				   ,year(start_date)
			From #ooh where date_type=0 and custody_id=1 and qry_type=@qry_type
				set @qry_type=@qry_type + 1;
		end
	-- reinitialize

	set @qry_type=0
	while @qry_type <=2
	begin
			insert into [prtl].[prtl_poc1ab] ([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					, filter_allegation
					, filter_finding
					, filter_service_category
					, filter_service_budget
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
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,filter_service_category
				   ,filter_service_budget
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
				   ,year(start_date)
			From #ooh where date_type=2 and custody_id=1 and qry_type=@qry_type
			set @qry_type=@qry_type + 1
			end
	


-- reinitialize



	set @qry_type=0
	while @qry_type <=2
	begin			
					
			insert into [prtl].[prtl_poc1ab_entries] ([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					, filter_allegation
					, filter_finding
					, filter_service_category
					, filter_service_budget
					,age_grouping_cd
					,[cd_race]
					,[census_hispanic_latino_origin_cd]
					,[pk_gndr]
					,[init_cd_plcm_setng]
					,[long_cd_plcm_setng]
					,[county_cd]
					,[int_match_param_key]
					,custody_id
					,[cnt_entries]
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
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,filter_service_category
				   ,filter_service_budget
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
				   ,[cnt_entries]
				   ,year(start_date)
			From #entries where date_type=0 and custody_id=1 and qry_type=@qry_type
				set @qry_type=@qry_type + 1;
		end
	-- reinitialize

	set @qry_type=0
	while @qry_type <=2
	begin
			insert into [prtl].[prtl_poc1ab_entries] ([qry_type]
					,[date_type]
					,[start_date]
					,[bin_dep_cd]
					,[max_bin_los_cd]
					,[bin_placement_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					,filter_access_type
					, filter_allegation
					, filter_finding
					, filter_service_category
					, filter_service_budget
					,age_grouping_cd
					,[cd_race]
					,[census_hispanic_latino_origin_cd]
					,[pk_gndr]
					,[init_cd_plcm_setng]
					,[long_cd_plcm_setng]
					,[county_cd]
					,[int_match_param_key]
					,custody_id
					,[cnt_entries]
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
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,filter_service_category
				   ,filter_service_budget
				   ,age_grouping_cd
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
				   ,[cnt_entries]
				   ,year(start_date)
			From #entries where date_type=2 and custody_id=1 and qry_type=@qry_type
			set @qry_type=@qry_type + 1
			end
	-- reinitialize

	

	set @qry_type=0
	while @qry_type <=1
	begin			
					
			insert into prtl.prtl_poc1ab_exits (qry_type
					,date_type
					,start_date
					,bin_dep_cd
					,max_bin_los_cd
					,bin_placement_cd
					,bin_ihs_svc_cd
					,cd_reporter_type
					,filter_access_type
					, filter_allegation
					, filter_finding
					, filter_service_category
					, filter_service_budget
					,age_grouping_cd
					,cd_race
					,census_hispanic_latino_origin_cd
					,pk_gndr
					,init_cd_plcm_setng
					,long_cd_plcm_setng
					,county_cd
					,int_match_param_key
					,cd_discharge_type
					,custody_id
					,cnt_exits
					,start_year
					--,cnt_dcfs_start_date
					--,cnt_dcfs_exits
					--,cnt_dcfs_exits
					)

		select qry_type
				   ,date_type
				   ,start_date
				   ,bin_dep_cd
				   ,max_bin_los_cd
				   ,bin_placement_cd
				   ,bin_ihs_svc_cd
				   ,cd_reporter_type
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * fl_cfws)
					+ (power(10.0,2) * fl_risk_only)
					+ (power(10.0,1) * fl_alternate_intervention)
					+ (power(10.0,0) * fl_frs) as filter_access_type
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + ((fl_founded_phys_abuse * 1 ) + (fl_founded_sexual_abuse * 10) +  (fl_founded_neglect * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,filter_service_category
				   ,filter_service_budget
				   ,age_grouping_cd
				   ,cd_race
				   ,census_hispanic_latino_origin_cd
				   ,pk_gndr
				   ,init_cd_plcm_setng
				   ,long_cd_plcm_setng
				   ,county_cd
				   ,int_match_param_key
				   ,cd_discharge_type
				   ,custody_id
				   ,cnt_exits
				   ,year(start_date)
			From #exits where date_type=0 and custody_id=1 and qry_type=@qry_type
				set @qry_type=@qry_type + 1;
		end
	-- reinitialize

	set @qry_type=0
	while @qry_type <=1
	begin
			insert into prtl.prtl_poc1ab_exits (qry_type
					,date_type
					,start_date
					,bin_dep_cd
					,max_bin_los_cd
					,bin_placement_cd
					,bin_ihs_svc_cd
					,cd_reporter_type
					,filter_access_type
					, filter_allegation
					, filter_finding
					, filter_service_category
					, filter_service_budget
					,age_grouping_cd
					,cd_race
					,census_hispanic_latino_origin_cd
					,pk_gndr
					,init_cd_plcm_setng
					,long_cd_plcm_setng
					,county_cd
					,int_match_param_key
					,cd_discharge_type
					,custody_id
					,cnt_exits
					,start_year
					)

		select qry_type
				   ,date_type
				   ,start_date
				   ,bin_dep_cd
				   ,max_bin_los_cd
				   ,bin_placement_cd
				   ,bin_ihs_svc_cd
				   ,cd_reporter_type
				   ,power(10.0,5) + (power(10.0,4) * fl_cps_invs)
					+ (power(10.0,3) * fl_cfws)
					+ (power(10.0,2) * fl_risk_only)
					+ (power(10.0,1) * fl_alternate_intervention)
					+ (power(10.0,0) * fl_frs) as filter_access_type
				    ,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + ((fl_founded_phys_abuse * 1 ) + (fl_founded_sexual_abuse * 10) +  (fl_founded_neglect * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,filter_service_category
				   ,filter_service_budget
				   ,age_grouping_cd
				   ,cd_race
				   ,census_hispanic_latino_origin_cd
				   ,pk_gndr
				   ,init_cd_plcm_setng
				   ,long_cd_plcm_setng
				   ,county_cd
				   ,int_match_param_key,cd_discharge_type
				   ,custody_id
				   ,cnt_exits
				   ,year(start_date)
			From #exits where date_type=2 and custody_id=1 and qry_type=@qry_type
			set @qry_type=@qry_type + 1
			end
	

	update statistics prtl.prtl_poc1ab;
		update statistics prtl.prtl_poc1ab_entries;
	  	update statistics prtl.prtl_poc1ab_exits;
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_poc1ab)
	  where tbl_id=1;

	    update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_poc1ab_entries)
	  where tbl_id=37;
	
	    update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_poc1ab_exits)
	  where tbl_id=38;

		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end

		


