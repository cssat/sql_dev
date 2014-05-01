USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_poc1ab]    Script Date: 4/1/2014 5:23:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure  [prtl].[prod_build_prtl_poc1ab](@permission_key datetime) 
as 
  set nocount on
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin

		declare @startDate datetime
		declare @endDate datetime

		declare @cutoff_date datetime



		declare @last_month_end datetime
		declare @last_year_end datetime

		-- initialize variables
		set @startDate='2000-01-01'
		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer
		set @endDate=(select dateadd(dd,-1,[month]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		set @last_month_end=(select dateadd(mm,-1,[month]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		set @last_year_end=(select dateadd(yy,-1,[year]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	

		if object_id('tempDB..#qtr') is not null drop table #qtr
		select q.*,dateadd(dd,-1,lead(q.qtr_begin) over (order by q.qtr_begin asc)) [qtr_end]
		into #qtr
		from
		(select distinct [quarter] qtr_begin,1 [date_type]  from dbo.CALENDAR_DIM where CALENDAR_DATE between @startDate and @endDate) q
		delete from #qtr  where qtr_end is null -- we have incomplete information for this quarter
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
									filter_access_type int not null,
									filter_allegation int not null,
									filter_finding int not null,
									filter_service_category decimal(18,0),
									filter_service_budget decimal(9,0),
									age_grouping_cd int  NULL,
									[cd_race] [int] NULL,
									[census_hispanic_latino_origin_cd] [int] NULL,
									[pk_gndr] [int] NOT NULL,
									[init_cd_plcm_setng] [int] NULL,
									[long_cd_plcm_setng] [int] NULL,
									county_cd [int] NULL,
									[int_match_param_key] [bigint] NULL,
									cnt_first int not null default 0,
									)

---- point in time DCFS 
/*************************************  DCFS qry_type ALL    ALL   ***********************************************************/
		insert into #ooh
						SELECT qry_type
								  , [date_type]
								  ,  point_in_time_date [start_date]
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
								  ,[cd_reporter_type]
									,filter_access_type 
									,filter_allegation 
									,filter_finding 
									,filter_service_category
									,filter_service_budget
								  ,age_grouping_cd_census [age_grouping_cd]
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,pit_county_cd
								  ,int_match_param_key_census [int_match_param_key]
								  ,count(distinct id_prsn_child) as cnt_eps
						  from  prtl.ooh_point_in_time_child ooh
						  group by   qry_type
								  ,date_type
								  , point_in_time_date
								  ,[bin_dep_cd]
								  ,[max_bin_los_cd]
								  ,[bin_placement_cd]
								  ,[bin_ihs_svc_cd]
								  ,[cd_reporter_type]
									,filter_access_type ,
									filter_allegation ,
									filter_finding ,
									filter_service_category,
									filter_service_budget
								  ,age_grouping_cd_census
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,pit_county_cd
								  ,int_match_param_key_census;

								  
/***********************************************************                        ENTRIES    ENTRIES  **************************/					
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
									cnt_entries int,
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
								  ,cnt_entries)

--  ALL ENTRIES 

	--  ALL DCFS ENTRIES 
							SELECT 2 [qry_type]
								  ,qtr.date_type [date_type]
								  ,qtr.qtr_begin as [start_date]
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
						  join #qtr qtr on eps.cohort_entry_month between qtr.qtr_begin and qtr.qtr_end
						  where cohort_entry_month between @startDate and @last_month_end
						  group by   qtr.date_type
								 ,qtr.qtr_begin
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								 
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
								  ,cnt_entries)

							SELECT 2 [qry_type]
								  ,2 [date_type]
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group

----  first DCFS entries
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
								  ,cnt_entries)
							SELECT 1 [qry_type]
								  ,qtr.date_type [date_type]
								  ,qtr.qtr_begin
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
						  join #qtr qtr on eps.cohort_entry_month between qtr.qtr_begin and qtr.qtr_end
						  where cohort_entry_month between @startDate and @last_month_end
						  and removal_dt=first_removal_dt
						  group by   qtr.date_type
								,qtr.qtr_begin
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								 
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
								  ,cnt_entries)

							SELECT 1 [qry_type]
								  ,2 [date_type]
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,entry_int_match_param_key_census_child_group
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
						  where cohort_entry_year between @startdate and  @last_year_end
						  and removal_dt=eps.first_removal_dt
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
								  ,eps.entry_census_child_group_cd
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,eps.entry_int_match_param_key_census_child_group
----  UNIQUE DCFS ENTRIES
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
								  ,cnt_entries)
							
							SELECT 0 [qry_type]
								  , unq.date_type [date_type]
								  ,unq.qtr_begin [start_date]
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
								  ,  count(distinct unq.id_prsn_child) as cnt_entries
						  from prtl.ooh_dcfs_eps ae
						   join #qtr qtr on ae.cohort_entry_month between qtr.qtr_begin and qtr.qtr_end
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  prtl.ooh_dcfs_eps.*,qtr.date_type,qtr.qtr_begin
										,row_number() over (partition by qtr.qtr_begin,id_prsn_child  order by removal_dt asc,federal_discharge_date asc) as row_num
									from prtl.ooh_dcfs_eps 
									 join #qtr qtr on ooh_dcfs_eps.cohort_entry_month between qtr.qtr_begin and qtr.qtr_end
									where cohort_entry_month between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact 
										and unq.row_num=1 
										and qtr.qtr_begin=unq.qtr_begin
										and qtr.date_type=unq.date_type
						  where ae.cohort_entry_month between @startDate and @last_month_end --='2005-01-01'
						  group by   unq.qtr_begin
								  , unq.date_type
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
								  ,cnt_entries)

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
								  ,  unq.entry_int_match_param_key_census_child_group	;

								

								 
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
									cd_discharge_type int,
									cnt_exits int
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
								  ,[int_match_param_key],cd_discharge_type,cnt_exits)
--  all EXITS
						SELECT 2 as [qry_type]
								  ,qtr.date_type [date_type]
								  ,qtr.qtr_begin as [start_date]
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
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,exit_county_cd
								  ,eps.exit_int_match_param_key_developmental
								 , eps.cd_discharge_type
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
						  join #qtr qtr on eps.cohort_exit_month between qtr.qtr_begin and qtr.qtr_end
						  where cohort_exit_month between @startDate and @last_month_end
						  and exit_developmental_age_cd is not null
							  group by   qtr.date_type
								,qtr.qtr_begin
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
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,exit_county_cd
								  ,exit_int_match_param_key_developmental
								 , eps.cd_discharge_type
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
								  , filter_service_category
								  , filter_service_budget
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[exit_county_cd]
								  ,exit_int_match_param_key_developmental
								 , eps.cd_discharge_type
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
						  where cohort_exit_year between @startdate and  @last_year_end
						  and exit_developmental_age_cd  is not null
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
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[exit_county_cd]
								  ,exit_int_match_param_key_developmental
								 , eps.cd_discharge_type
----  first entries -   EXITS
				UNION ALL
							SELECT 1 [qry_type]
								  ,qtr.date_type [date_type]
								  ,qtr.qtr_begin as [start_date]
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
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,exit_county_cd
								  ,exit_int_match_param_key_developmental
								 , eps.cd_discharge_type
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
						  join #qtr qtr on eps.cohort_exit_month between qtr.qtr_begin and qtr.qtr_end
						  where cohort_exit_month between @startDate and @last_month_end
						  and removal_dt=eps.first_removal_dt
						  and exit_developmental_age_cd  is not null
						  group by   qtr.qtr_begin
								  ,qtr.date_type
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
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,exit_county_cd
								  ,exit_int_match_param_key_developmental
								 , eps.cd_discharge_type
					UNION ALL
							SELECT 1 [qry_type]
								  ,2 [date_type]
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
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[exit_county_cd]
								  ,exit_int_match_param_key_developmental
								 , eps.cd_discharge_type
								  ,count(distinct id_removal_episode_fact)
						  from prtl.ooh_dcfs_eps eps
						  where cohort_exit_year between @startdate and  @last_year_end
						  and removal_dt=eps.first_removal_dt
						  and exit_developmental_age_cd  is not null
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
								  ,eps.exit_developmental_age_cd
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[exit_county_cd]
								  ,exit_int_match_param_key_developmental
								 , eps.cd_discharge_type

----  UNIQUE DCFS exits
				union all
							SELECT 0 as qry_type
								  , unq.date_type as date_type
								  ,  unq.qtr_begin as start_date
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
								  ,  unq.exit_developmental_age_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.exit_county_cd
								  ,  unq.exit_int_match_param_key_developmental
								 , unq.cd_discharge_type
								  ,count(distinct ae.id_prsn_child) as cnt_exits
						  from prtl.ooh_dcfs_eps ae
						  join #qtr qtr on ae.cohort_exit_month between qtr.qtr_begin and qtr.qtr_end
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  prtl.ooh_dcfs_eps.*,qtr.date_type,qtr.qtr_begin
										,row_number() over (partition by qtr.qtr_begin,id_prsn_child  order by removal_dt asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								join #qtr qtr on ooh_dcfs_eps.cohort_exit_month between qtr.qtr_begin and qtr.qtr_end
								where cohort_exit_month between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact 
										and unq.row_num=1 
										and qtr.qtr_begin=unq.qtr_begin
										and qtr.date_type=unq.date_type
						  where ae.cohort_exit_month between @startDate and @last_month_end --='2005-01-01'
						  and unq.exit_developmental_age_cd   is not null
						  group by   unq.date_type
									, unq.qtr_begin
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
								  ,  unq.exit_developmental_age_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.exit_county_cd
								  ,  unq.exit_int_match_param_key_developmental
								 , unq.cd_discharge_type
					UNION ALL
						SELECT 0 [qry_type]
								  ,2 [date_type]
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
								  ,  unq.exit_developmental_age_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.exit_county_cd
								  ,  unq.exit_int_match_param_key_developmental
								 , unq.cd_discharge_type
								  ,count(distinct ae.id_prsn_child)
						  from prtl.ooh_dcfs_eps ae
						  join (select prtl.ooh_dcfs_eps.*
										,row_number() over (partition by cohort_exit_year,id_prsn_child order by removal_dt asc,federal_discharge_date asc) as row_num
								from prtl.ooh_dcfs_eps 
								where cohort_exit_year between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.cohort_exit_year=unq.cohort_exit_year
						  where ae.cohort_exit_year between @startdate and  @last_year_end
						  and unq.exit_developmental_age_cd   is not null
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
								  ,  unq.exit_developmental_age_cd
								  ,  unq.cd_race_census
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.exit_county_cd
								  ,  unq.exit_int_match_param_key_developmental	
								 , unq.cd_discharge_type
								  order by [start_date],exit_int_match_param_key_developmental
		


	


	CREATE NONCLUSTERED INDEX idx_insert_qry
	ON #ooh ([date_type],[qry_type])
	INCLUDE ([start_date],[bin_dep_cd],[max_bin_los_cd],[bin_placement_cd],[bin_ihs_svc_cd]
	,[cd_reporter_type],filter_access_type,filter_allegation,filter_finding
	,filter_service_category,filter_service_budget
	,age_grouping_cd,[cd_race],[census_hispanic_latino_origin_cd],[pk_gndr],[init_cd_plcm_setng],[long_cd_plcm_setng],[county_cd],[int_match_param_key],[cnt_first])

	
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
					,[cnt_start_date]
					,start_year
					)

		select [qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,[bin_dep_cd]
				   ,[max_bin_los_cd]
				   ,[bin_placement_cd]
				   ,[bin_ihs_svc_cd]
				   ,[cd_reporter_type]
				   ,filter_access_type
				    ,filter_allegation
				   , filter_finding
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
				   ,[cnt_first]
				   ,year(start_date)
			From #ooh where  qry_type=@qry_type
				set @qry_type=@qry_type + 1;
		end
	-- reinitialize
	-- 	declare @qry_type int


		
	
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
				   ,[cnt_entries]
				   ,year(start_date)
			From #entries
		

					
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
				   ,int_match_param_key
				   ,cd_discharge_type
				   ,cnt_exits
				   ,year(start_date)
			From #exits 

	

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

		


