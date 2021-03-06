
USE [CA_ODS]
GO
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

				if object_ID('tempDB..##all_episodes') is not null drop table ##all_episodes
					select		distinct
								 0 as qry_type -- unique
								 ,@date_type  as date_type --month
								 ,@startDate  as startdate
								 ,@endDate as stopdate
								 ,tce.[ID_PRSN_CHILD] as id_prsn_child
								 ,tce.First_Removal_date as first_removal_date
								 ,tce.Latest_Removal_date as latest_removal_date
								 ,tce.[State_Custody_Start_Date] as state_custody_start_date
								 ,ent.[month] as entry_month_date
								 ,ent.[Year] as entry_year_date
								 ,tce.state_discharge_date
								 ,isnull(tce.Federal_Discharge_Date_Force_18,'12/31/3999') as federal_discharge_date
								 ,ext.[month] as exit_month_date
								 ,ext.[YEAR] as exit_year_date
								 ,tce.[State_Discharge_Reason] as state_discharge_reason
								 ,tce.[State_Discharge_Reason_Code]  as  state_discharge_reason_code
								 ,tce.[Federal_Discharge_Reason_Code] as  federal_discharge_reason_code
								 , tce.[Federal_Discharge_Reason] as federal_discharge_reason
								 , tce.id_removal_episode_fact
								 , tce.bin_dep_cd
								 , tce.max_bin_los_cd
								 , isnull(plcm.bin_placement_cd,0) as bin_placement_cd
								 , isnull(rpt.collapsed_cd_reporter_type,-99) as cd_reporter_type
								  , isnull(si.[fl_cps_invs],0) as fl_cps_invs
								  , isnull(si.[fl_cfws],0) as fl_cfws
								  , isnull(si.[fl_risk_only],0) as [fl_risk_only]
								  , isnull(si.[fl_alternate_intervention],0) as [fl_alternate_intervention]
								  , isnull(si.[fl_frs],0) as [fl_frs]
								  , case when si.[cnt_intk_grp_phys_abuse] > 0 then 1 else 0 end as  fl_phys_abuse
								  , case when si.[cnt_intk_grp_sexual_abuse]  > 0 then 1 else 0 end  as fl_sexual_abuse
								  , case when si.[cnt_intk_grp_neglect]  > 0 then 1 else 0 end  as fl_neglect
								  , case when si.[cnt_intk_grp_phys_abuse]>0
										  or si.[cnt_intk_grp_sexual_abuse] > 0
										   or  si.[cnt_intk_grp_neglect]  > 0 then 1 else 0 end as fl_any_legal
								  , case when si.[cnt_intk_grp_founded_phys_abuse]  > 0 then 1 else 0 end  as fl_founded_phys_abuse
								  , case when si.[cnt_intk_grp_founded_sexual_abuse]  > 0 then 1 else 0 end  as fl_founded_sexual_abuse
								  , case when si.[cnt_intk_grp_founded_neglect]  > 0 then 1 else 0 end  as fl_founded_neglect
								  , case when si.[cnt_intk_grp_founded_any_legal]  > 0 then 1 else 0 end as fl_found_any_legal
								 , tce.bin_ihs_svc_cd
								, isnull(eps_svc.fl_family_focused_services,0) as fl_family_focused_services
								, isnull(eps_svc.fl_child_care,0) as fl_child_care
								, isnull(eps_svc.fl_therapeutic_services,0) as fl_therapeutic_services
								, isnull(eps_svc.fl_mh_services,0) as fl_mh_services
								, isnull(eps_svc.fl_receiving_care,0) as fl_receiving_care
								, isnull(eps_svc.fl_family_home_placements,0) as fl_family_home_placements
								, isnull(eps_svc.fl_behavioral_rehabiliation_services,0) as fl_behavioral_rehabiliation_services
								, isnull(eps_svc.fl_other_therapeutic_living_situations,0) as fl_other_therapeutic_living_situations
								, isnull(eps_svc.fl_specialty_adolescent_services,0) as fl_specialty_adolescent_services
								, isnull(eps_svc.fl_respite,0) as fl_respite
								, isnull(eps_svc.fl_transportation,0) as fl_transportation
								, isnull(eps_svc.fl_clothing_incidentals,0) as fl_clothing_incidentals
								, isnull(eps_svc.fl_sexually_aggressive_youth,0) as fl_sexually_aggressive_youth
								, isnull(eps_svc.fl_adoption_support,0) as fl_adoption_support
								, isnull(eps_svc.fl_various,0) as fl_various
								, isnull(eps_svc.fl_medical,0) as fl_medical
								, isnull(eps_svc.fl_budget_C12,0) as fl_budget_C12
								, isnull(eps_svc.fl_budget_C14,0) as fl_budget_C14
								, isnull(eps_svc.fl_budget_C15,0) as fl_budget_C15
								, isnull(eps_svc.fl_budget_C16,0) as fl_budget_C16
								, isnull(eps_svc.fl_budget_C18,0) as fl_budget_C18
								, isnull(eps_svc.fl_budget_C19,0) as fl_budget_C19
								, isnull(eps_svc.fl_uncat_svc,0) as fl_uncat_svc
								 , age.census_child_group_cd as age_grouping_cd
								 , tce.[CD_RACE_Census]  as cd_race
								 , tce.census_hispanic_latino_origin_cd
								 , ISNULL(G.PK_GNDR,3) as pk_gndr
								  ,frstplc.cd_plcm_setng as init_cd_plcm_setng
								  ,longplc.cd_plcm_setng  as long_cd_plcm_setng
								  ,tce.Removal_County_cd  as Removal_County_Cd
								 , prm.int_match_param_key
								 , tce.petition_dependency_date
								 , tce.fl_dep_exist

						into ##all_episodes
						from base.TBL_CHILD_EPISODES tce 
						join dbo.CALENDAR_DIM ent on ent.CALENDAR_DATE= tce.state_custody_start_date
						left join dbo.calendar_dim ext on ext.CALENDAR_DATE=tce.federal_discharge_date_force_18
						 --join dbo.ref_Age_Groupings_census Age on CHILD_AGE_REMOVAL_BEGIN >=Age.age_begin and CHILD_AGE_REMOVAL_BEGIN < age.Age_LessThan_End
							--	and age.age_grouping_cd between 1 and 4 
						join age_dim age on age.age_mo=tce.age_eps_begin_mos 
						left join dbo.ref_lookup_placement_event frstplc on frstplc.id_plcmnt_evnt=tce.init_id_plcmnt_evnt
						left join dbo.ref_lookup_placement_event longplc on longplc.id_plcmnt_evnt=tce.longest_id_plcmnt_evnt
							left join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
						left join dbo.ref_lookup_gender G on G.CD_GNDR=tce.CD_GNDR
						left join dbo.ref_lookup_county cnty on cnty.County_Cd=tce.Removal_County_Cd
						left join dbo.vw_intakes_screened_in si on si.id_intake_fact=tce.id_intake_fact
						left join base.tbl_ihs_episodes ihs on ihs.id_intake_fact=tce.id_intake_fact and ihs.id_case=tce.id_case
						left join dbo.ref_filter_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter
						left join dbo.ref_match_ooh_parameters prm on 
									prm.age_grouping_cd=age.census_child_group_cd	
								and prm.match_cd_race_census=tce.cd_race_census
								and prm.match_cd_hispanic_latino_origin=tce.census_hispanic_latino_origin_cd
								and prm.match_pk_gndr=g.pk_gndr
								and prm.match_init_cd_plcm_setng=frstplc.cd_plcm_setng
								and prm.match_long_cd_plcm_setng=longplc.cd_plcm_setng
								and prm.match_county_cd=tce.Removal_County_Cd
						left join dbo.[ref_filter_nbr_placement] plcm on tce.cnt_ooh_plcm between plcm.nbr_placement_from and plcm.nbr_placement_thru and plcm.bin_placement_cd <>0
						left join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=tce.id_removal_episode_fact
						--REMOVE EPISODES FOR KIDS 18 AND AOVER
					WHERE STATE_CUSTODY_START_DATE <= ISNULL(TCE.Federal_Discharge_Date_Force_18,'12/31/3999')
					and ((STATE_CUSTODY_START_DATE <=@startDate and ISNULL(TCE.Federal_Discharge_Date_Force_18,'12/31/3999') >=@startDate)
					or state_custody_start_date >=@startDate)
					and child_age_removal_begin between 0 and 17
					ORDER BY  tce.ID_PRSN_CHILD,TCE.STATE_CUSTODY_START_DATE
					
				
					
								
					create index idx_child_start_discharge on ##all_episodes(id_prsn_child,state_custody_start_date,federal_discharge_date)
					create index idx_id_removal_episode_fact on ##all_episodes(id_removal_episode_fact);
					create index idx_child_start on ##all_episodes(id_prsn_child,state_custody_start_date);
					create index idx_first_start on ##all_episodes(first_removal_date,state_custody_start_date);
					create index idx_federal_discharge_date on ##all_episodes(Federal_Discharge_Date);
					update statistics ##all_episodes;
					
				 --- build DCFS table  
					
					--Get overlapping nondcfs custody  
					if object_ID('tempDB..##nondcfs') is not null drop table ##nondcfs;
					select eps.id_removal_episode_fact,eps.id_prsn_child,eps.state_custody_start_date,eps.federal_discharge_date
							,dcfs.cust_begin
							,case when dcfs.cust_end='12/31/3999' and  eps.federal_discharge_date  < dcfs.cust_end
							 then eps.federal_discharge_date else dcfs.cust_end end as cust_end
	
							,row_number() over (partition by eps.id_removal_episode_fact
									order by eps.id_removal_episode_fact,dcfs.cust_begin asc
									,dcfs.cust_end asc) as sort_asc
							,row_number() over (partition by eps.id_removal_episode_fact
									order by eps.id_removal_episode_fact,dcfs.cust_begin desc,dcfs.cust_end desc) as sort_desc 
							,0 as fl_update
					into ##nondcfs
					from ##all_episodes eps
					join base.wrk_nonDCFS_All dcfs on dcfs.id_prsn=eps.id_prsn_child
					and dcfs.cust_begin < federal_discharge_date
					and dcfs.cust_end > state_custody_start_date
					and NOT(dcfs.cust_begin<=state_custody_start_date and dcfs.cust_end>=federal_discharge_date)
					
							
					-- if the cust_begin is prior to the episode begin date .. set state_custody_start_date to cust_end date
					update ##nondcfs
					set state_custody_start_date=cust_end 
					where cust_begin <=state_custody_start_date
					and cust_end < federal_discharge_date
					
					--split the episodes where there is ONLY 1 custody segment
					if object_ID('tempDB..##tmp') is not null drop table ##tmp

					create table ##tmp
					( id_removal_episode_fact int
						,state_custody_start_date datetime
						,federal_discharge_date datetime
						,fl_multiple int 
						,  entry_month_date datetime
						,  entry_year_date datetime
						, exit_month_date datetime
						, exit_year_date datetime )

					insert into ##tmp(id_removal_episode_fact,state_custody_start_date,federal_discharge_date,fl_multiple)
					select  id_removal_episode_fact,state_custody_start_date,cust_begin as federal_discharge_date,0 as fl_multiple
					from ##nondcfs where sort_asc=1 and sort_desc=1
					and state_custody_start_date < cust_begin
					union 
					select  id_removal_episode_fact,cust_end,federal_discharge_date,0 as fl_multiple
					from ##nondcfs where sort_asc=1 and sort_desc=1
					and state_custody_start_date < cust_begin and cust_end < federal_discharge_date
					union
					select  id_removal_episode_fact,cust_end,federal_discharge_date,0 as fl_multiple
					from ##nondcfs where sort_asc=1 and sort_desc=1
					and state_custody_start_date >= cust_begin and cust_end < federal_discharge_date
					union --- get the first segment for the multiple custody segments
					select  id_removal_episode_fact,state_custody_start_date,cust_begin as federal_discharge_date,1 as fl_multiple
					from ##nondcfs where sort_asc=1 and sort_desc<>1
						and state_custody_start_date < cust_begin
							
					select @maxNbrCustSeg=max(sort_desc) -1 from ##nondcfs;
					--loop through getting the next custody segment
					set @rowcount=1
					while @rowcount < @maxNbrCustSeg
					begin
					
						insert into ##tmp(id_removal_episode_fact,state_custody_start_date,federal_discharge_date,fl_multiple)
						select  n1.id_removal_episode_fact,n1.cust_end,dbo.lessorDate(n2.federal_discharge_date,n2.cust_begin),1 as fl_multiple
						from ##nondcfs n1
						join ##nondcfs n2 on n2.id_removal_episode_fact=n1.id_removal_episode_fact and n2.sort_asc=@rowcount + 1
						where n1.sort_asc=@rowcount 
						and n1.state_custody_start_date < n1.cust_begin
						and n1.cust_end < n2.cust_begin
						
						set @rowcount=@rowcount + 1;
					end
					--select * from ##tmp where id_removal_episode_fact=684
					--select * from base.tbl_child_episodes where id_removal_episode_fact=684
					--select * from base.WRK_nonDCFS_All where  id_prsn=753301
					
					--now get last multiple custody segment
					insert into ##tmp(id_removal_episode_fact,state_custody_start_date,federal_discharge_date,fl_multiple)
						select  n1.id_removal_episode_fact,n2.cust_end,dbo.lessorDate(n1.federal_discharge_date,n1.cust_begin),1 as fl_multiple
						from ##nondcfs n1
						join ##nondcfs n2 on n2.id_removal_episode_fact=n1.id_removal_episode_fact and n2.sort_desc=2
						where n1.sort_desc=1
						and n1.state_custody_start_date < n1.cust_begin
						and n2.cust_end < n1.cust_begin

					update ##tmp
					set entry_month_date=calendar_dim.[month]
						,  entry_year_date =calendar_dim.[year]
					from dbo.CALENDAR_DIM 
					where CALENDAR_DATE=state_custody_start_date


					update ##tmp
					set exit_month_date=calendar_dim.[month]
						,  exit_year_date =calendar_dim.[year]
					from dbo.CALENDAR_DIM 
					where CALENDAR_DATE=federal_discharge_date


					
					if object_ID('tempDB..##dcfs_alleps') is not null drop table ##dcfs_alleps;
					select distinct
						ae.qry_type
						, ae.date_type
						, ae.startdate
						, ae.stopdate
						, ae.id_prsn_child
						, ae.first_removal_date
						, ae.latest_removal_date
						, ae.state_custody_start_date
						, ae.entry_month_date
						, ae.entry_year_date
						, ae.state_discharge_date
						, ae.federal_discharge_date
						, ae.exit_month_date
						, ae.exit_year_date
						, ae.state_discharge_reason
						, ae.state_discharge_reason_code
						, ae.federal_discharge_reason_code
						, ae.federal_discharge_reason
						, ae.id_removal_episode_fact
						, ae.bin_dep_cd
						, ae.max_bin_los_cd
						, ae.bin_placement_cd
						, ae.cd_reporter_type
						, ae.fl_cps_invs
						, ae.fl_cfws
						, ae.fl_risk_only
						, ae.fl_alternate_intervention
						, ae.fl_frs
						, ae.fl_phys_abuse
						, ae.fl_sexual_abuse
						, ae.fl_neglect
						, ae.fl_any_legal
						, ae.fl_founded_phys_abuse
						, ae.fl_founded_sexual_abuse
						, ae.fl_founded_neglect
						, ae.fl_found_any_legal
						, ae.bin_ihs_svc_cd
						, ae.fl_family_focused_services
						, ae.fl_child_care
						, ae.fl_therapeutic_services
						, ae.fl_mh_services
						, ae.fl_receiving_care
						, ae.fl_family_home_placements
						, ae.fl_behavioral_rehabiliation_services
						, ae.fl_other_therapeutic_living_situations
						, ae.fl_specialty_adolescent_services
						, ae.fl_respite
						, ae.fl_transportation
						, ae.fl_clothing_incidentals
						, ae.fl_sexually_aggressive_youth
						, ae.fl_adoption_support
						, ae.fl_various
						, ae.fl_medical
						, ae.fl_budget_C12
						, ae.fl_budget_C14
						, ae.fl_budget_C15
						, ae.fl_budget_C16
						, ae.fl_budget_C18
						, ae.fl_budget_C19
						, ae.fl_uncat_svc
						, ae.age_grouping_cd
						, ae.cd_race
						, ae.census_hispanic_latino_origin_cd
						, ae.pk_gndr
						, ae.init_cd_plcm_setng
						, ae.long_cd_plcm_setng
						, ae.Removal_County_Cd
						, ae.int_match_param_key
						, ae.petition_dependency_date
						, ae.fl_dep_exist
					into ##dcfs_alleps
					from ##all_episodes ae
					left join --exclude nondcfs overlapping episodes 
						(	select eps.id_removal_episode_fact
							from ##all_episodes eps
							join base.wrk_nonDCFS_All dcfs on dcfs.id_prsn=eps.id_prsn_child
							and dcfs.cust_begin < federal_discharge_date
							and dcfs.cust_end > state_custody_start_date				
								) nd on nd.id_removal_episode_fact=ae.id_removal_episode_fact
					where nd.id_removal_episode_fact is null 
					
					--insert our SPLIT DCFS state_custody_start_date and federal_discharge_date	
					insert into ##dcfs_alleps
				
					SELECT  distinct
							ae.qry_type
						  , ae.date_type
						  , ae.startdate
						  , ae.stopdate
						  , ae.id_prsn_child
						  , ae.first_removal_date
						  , ae.latest_removal_date
						  , t.state_custody_start_date
						  , t.entry_month_date
						  , t.entry_year_date
						  , ae.state_discharge_date
						  , t.federal_discharge_date
						  , t.exit_month_date
						  , t.exit_year_date
						  , ae.state_discharge_reason
						  , ae.state_discharge_reason_code
						  , ae.federal_discharge_reason_code
						  , ae.federal_discharge_reason
						  , ae.id_removal_episode_fact
						  , ae.bin_dep_cd
						  , ae.max_bin_los_cd
						  , ae.bin_placement_cd
						  , ae.cd_reporter_type
						  , ae.fl_cps_invs
						  , ae.fl_cfws
						  , ae.fl_risk_only
						  , ae.fl_alternate_intervention
						  , ae.fl_frs
						  , ae.fl_phys_abuse
						  , ae.fl_sexual_abuse
						  , ae.fl_neglect
						  , ae.fl_any_legal
						  , ae.fl_founded_phys_abuse
						  , ae.fl_founded_sexual_abuse
						  , ae.fl_founded_neglect
						  , ae.fl_found_any_legal
						  , ae.bin_ihs_svc_cd
						  , ae.fl_family_focused_services
						  , ae.fl_child_care
						  , ae.fl_therapeutic_services
						  , ae.fl_mh_services
						  , ae.fl_receiving_care
						  , ae.fl_family_home_placements
						  , ae.fl_behavioral_rehabiliation_services
						  , ae.fl_other_therapeutic_living_situations
						  , ae.fl_specialty_adolescent_services
						  , ae.fl_respite
						  , ae.fl_transportation
						  , ae.fl_clothing_incidentals
						  , ae.fl_sexually_aggressive_youth
						  , ae.fl_adoption_support
						  , ae.fl_various
						  , ae.fl_medical
						  , ae.fl_budget_C12
						  , ae.fl_budget_C14
						  , ae.fl_budget_C15
						  , ae.fl_budget_C16
						  , ae.fl_budget_C18
						  , ae.fl_budget_C19
						  , ae.fl_uncat_svc
						  , ae.age_grouping_cd
						  , ae.cd_race
						  , ae.census_hispanic_latino_origin_cd
						  , ae.pk_gndr
						  , ae.init_cd_plcm_setng
						  , ae.long_cd_plcm_setng
						  , ae.Removal_County_Cd
						  , ae.int_match_param_key
						, ae.petition_dependency_date
						, ae.fl_dep_exist
					from ##all_episodes ae
					join ##tmp t on t.id_removal_episode_fact=ae.Id_removal_episode_Fact
					left join ##dcfs_alleps d on d.id_removal_episode_fact=ae.id_removal_episode_fact
					where d.id_removal_episode_fact is null;


					update ##dcfs_alleps
					 set bin_dep_cd=  ref.bin_dep_cd
					 from dbo.[ref_filter_dependency] ref
					 where ref.fl_dep_exist=##dcfs_alleps.fl_dep_exist
					 and petition_dependency_date between dateadd(dd,diff_days_from,state_custody_start_date)
					and dateadd(dd,diff_days_thru,state_custody_start_date)

					
/***********************************************************  POINT IN TIME       **************************/
						if OBJECT_ID('tempDB..##ooh') is not null drop table ##ooh

							CREATE TABLE ##ooh(
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
									[age_grouping_cd] int  NULL,
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
							

	insert into ##ooh (qry_type,date_type,	[start_date]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_first)

/*************************************  qry_type ALL    ALL   ***********************************************************/
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						 
						  from ##all_episodes
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from ##all_episodes
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						 
						  from ##all_episodes
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact) as cnt_eps
						  from ##all_episodes
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from ##all_episodes
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from ##all_episodes
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
					ORDER BY date_type,qry_type,[start_date],int_match_param_key

---- point in time DCFS 
/*************************************  DCFS qry_type ALL    ALL   ***********************************************************/
		insert into ##ooh (qry_type,date_type,	[start_date]
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
								  ,[age_grouping_cd]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						 
						  from ##dcfs_alleps
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from ##dcfs_alleps
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						 
						  from ##dcfs_alleps
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact) as cnt_eps
						  from ##dcfs_alleps
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from ##dcfs_alleps
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_prsn_child) as cnt_eps
						  from ##dcfs_alleps
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
					ORDER BY date_type,qry_type,[start_date],int_match_param_key


/************************************************************                        ENTRIES    ENTRIES  **************************/					
		-- create entries table
						if OBJECT_ID('tempDB..##entries') is not null drop table ##entries
							CREATE TABLE ##entries(
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
									[age_grouping_cd] int  NULL,
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
							
							insert into ##entries (qry_type,date_type,	[start_date]
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
								  ,[age_grouping_cd]
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
							SELECT 2 --all
								  ,0 -- month
								  ,entry_month_date as [start_date]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where entry_month_date between @startDate and @last_month_end
						  group by   entry_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
					UNION ALL

							SELECT 2
								  ,2
								  ,entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where entry_year_date between @startdate and  @last_year_end
						  group by   entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
						union all
----  first entries
							SELECT 1
								  ,0
								  ,entry_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where entry_month_date between @startDate and @last_month_end
						  and state_custody_start_date=first_removal_date
						  group by   entry_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
		UNION ALL

							SELECT 1
								  ,2
								  ,entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where entry_year_date between @startdate and  @last_year_end
						  and state_custody_start_date=first_removal_date
						  group by   entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
----  UNIQUE ENTRIES
				union all
							
							SELECT 0 as qry_type
								  ,0 as date_type
								  ,unq.entry_month_date as start_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,0 as custody_id
								  ,count(distinct unq.id_prsn_child) as cnt_entries
						  from ##all_episodes ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  ##all_episodes.*
										,row_number() over (partition by entry_month_date,id_prsn_child  order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##all_episodes 
								where entry_month_date between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1 
								and ae.entry_month_date=unq.entry_month_date
								
						  where ae.entry_month_date between @startDate and @last_month_end --='2005-01-01'
						  group by   unq.entry_month_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								 
UNION ALL

							SELECT 0
								  ,2
								  , unq.entry_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,0 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from ##all_episodes ae
						  join (select ##all_episodes.*
										,row_number() over (partition by entry_year_date,id_prsn_child order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##all_episodes 
								where entry_year_date between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.entry_year_date=unq.entry_year_date
						  where ae.entry_year_date between @startdate and  @last_year_end
						  group by   unq.entry_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key	
							UNION ALL
	--  ALL DCFS ENTRIES 
							SELECT 2
								  ,0
								  ,entry_month_date as [start_date]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where entry_month_date between @startDate and @last_month_end
						  group by   entry_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
							UNION ALL

							SELECT 2
								  ,2
								  ,entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where entry_year_date between @startdate and  @last_year_end
						  group by   entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
						union all
----  first DCFS entries
							SELECT 1
								  ,0
								  ,entry_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where entry_month_date between @startDate and @last_month_end
						  and state_custody_start_date=first_removal_date
						  group by   entry_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
					UNION ALL

							SELECT 1
								  ,2
								  ,entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where entry_year_date between @startdate and  @last_year_end
						  and state_custody_start_date=first_removal_date
						  group by   entry_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
----  UNIQUE DCFS ENTRIES
							union all
							
							SELECT 0 as qry_type
								  ,0 as date_type
								  ,unq.entry_month_date as start_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,  1 as custody_id
								  ,  count(distinct unq.id_prsn_child) as cnt_entries
						  from ##dcfs_alleps ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  ##dcfs_alleps.*
										,row_number() over (partition by entry_month_date,id_prsn_child  order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##dcfs_alleps 
								where entry_month_date between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1 
								and ae.entry_month_date=unq.entry_month_date
								
						  where ae.entry_month_date between @startDate and @last_month_end --='2005-01-01'
						  group by   unq.entry_month_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								 
							UNION ALL

							SELECT 0
								  ,2
								  , unq.entry_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from ##dcfs_alleps ae
						  join (select ##dcfs_alleps.*
										,row_number() over (partition by entry_year_date,id_prsn_child order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##dcfs_alleps 
								where entry_year_date between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.entry_year_date=unq.entry_year_date
						  where ae.entry_year_date between @startdate and  @last_year_end
						  group by   unq.entry_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key	

								  order by [custody_id],[start_date],[int_match_param_key]
		/*************************************************************************************  EXITS ******************* EXITS **/
					if OBJECT_ID('tempDB..##exits') is not null drop table ##exits
							CREATE TABLE ##exits(
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
									[age_grouping_cd] int  NULL,
									[cd_race] [int] NULL,
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
							
							insert into ##exits (qry_type,date_type,	[start_date]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id ,cnt_exits)

--  ALL exits 
							SELECT 2
								  ,0
								  ,exit_month_date as [start_date]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where exit_month_date between @startDate and @last_month_end
						  group by   exit_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
					UNION ALL

							SELECT 2
								  ,2
								  ,exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where exit_year_date between @startdate and  @last_year_end
						  group by   exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
						union all
----  first exits
							SELECT 1
								  ,0
								  ,exit_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where exit_month_date between @startDate and @last_month_end
						  and state_custody_start_date=first_removal_date
						  group by   exit_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
							UNION ALL

							SELECT 1
								  ,2
								  ,exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,0 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##all_episodes
						  where exit_year_date between @startdate and  @last_year_end
						  and state_custody_start_date=first_removal_date
						  group by   exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
					----  UNIQUE exits
							union all
							
							SELECT 0 as qry_type
								  ,0 as date_type
								  ,  unq.exit_month_date as start_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,0 as custody_id
								  ,count(distinct unq.id_prsn_child) as cnt_exits
						  from ##all_episodes ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  ##all_episodes.*
										,row_number() over (partition by exit_month_date,id_prsn_child  order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##all_episodes 
								where exit_month_date between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1 
								and ae.exit_month_date=unq.exit_month_date
								
						  where ae.exit_month_date between @startDate and @last_month_end --='2005-01-01'
						  group by   unq.exit_month_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								 
UNION ALL

							SELECT 0
								  ,2
								  , unq.exit_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,0 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from ##all_episodes ae
						  join (select ##all_episodes.*
										,row_number() over (partition by exit_year_date,id_prsn_child order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##all_episodes 
								where exit_year_date between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.exit_year_date=unq.exit_year_date
						  where ae.exit_year_date between @startdate and  @last_year_end
						  group by   unq.exit_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key	
UNION ALL
	--  ALL DCFS exits 
							SELECT 2
								  ,0
								  ,exit_month_date as [start_date]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where exit_month_date between @startDate and @last_month_end
						  group by   exit_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
					UNION ALL

							SELECT 2
								  ,2
								  ,exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where exit_year_date between @startdate and  @last_year_end
						  group by   exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
						union all
----  first DCFS exits
							SELECT 1
								  ,0
								  ,exit_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where exit_month_date between @startDate and @last_month_end
						  and state_custody_start_date=first_removal_date
						  group by   exit_month_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								 
					UNION ALL

							SELECT 1
								  ,2
								  ,exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
								  ,1 as custody_id
								  ,count(distinct id_removal_episode_fact)
						  from ##dcfs_alleps
						  where exit_year_date between @startdate and  @last_year_end
						  and state_custody_start_date=first_removal_date
						  group by   exit_year_date
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[removal_county_cd]
								  ,[int_match_param_key]
----  UNIQUE DCFS exits
				union all
							
							SELECT 0 as qry_type
								  ,0 as date_type
								  ,unq.exit_month_date as start_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child) as cnt_exits
						  from ##dcfs_alleps ae
						  -- for demographic and flags we'll select first entry episode for information
						  join (select  ##dcfs_alleps.*
										,row_number() over (partition by exit_month_date,id_prsn_child  order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##dcfs_alleps 
								where exit_month_date between @startDate and @last_month_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1 
								and ae.exit_month_date=unq.exit_month_date
								
						  where ae.exit_month_date between @startDate and @last_month_end --='2005-01-01'
						  group by   unq.exit_month_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								 
					UNION ALL

			
							SELECT 0
								  ,2
								  , unq.exit_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key
								  ,1 as custody_id
								  ,count(distinct ae.id_prsn_child)
						  from ##dcfs_alleps ae
						  join (select ##dcfs_alleps.*
										,row_number() over (partition by exit_year_date,id_prsn_child order by state_custody_start_date asc,federal_discharge_date asc) as row_num
								from ##dcfs_alleps 
								where exit_year_date between @startdate and  @last_year_end
								)unq on ae.id_removal_episode_Fact=unq.id_removal_episode_fact and unq.row_num=1
								and ae.exit_year_date=unq.exit_year_date
						  where ae.exit_year_date between @startdate and  @last_year_end
						  group by   unq.exit_year_date
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
								  ,  unq.age_grouping_cd
								  ,  unq.cd_race
								  ,  unq.census_hispanic_latino_origin_cd
								  ,  unq.pk_gndr
								  ,  unq.init_cd_plcm_setng
								  ,  unq.long_cd_plcm_setng
								  ,  unq.removal_county_cd
								  ,  unq.int_match_param_key	

								  order by custody_id,[start_date],[int_match_param_key]
		



/*************     UPDATE ENTRIES               ***************************************/

			update AE
			set cnt_entries= ent.cnt_entries
			from ##ooh ae
			join ##entries ent
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
				ae.[age_grouping_cd] = ent.[age_grouping_cd] and
				ae.[cd_race] = ent.[cd_race] and
				ae.[census_hispanic_latino_origin_cd] = ent.[census_hispanic_latino_origin_cd] and
				ae.[pk_gndr] = ent.[pk_gndr] and
				ae.[init_cd_plcm_setng] = ent.[init_cd_plcm_setng] and
				ae.[long_cd_plcm_setng] = ent.[long_cd_plcm_setng] and
				ae.county_cd= ent.county_cd  and
				ae.[int_match_param_key] = ent.[int_match_param_key] and
				ae.custody_id=ent.custody_id
			



			insert into ##ooh (qry_type,date_type,	[start_date]
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
								  ,[age_grouping_cd]
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_entries
								from ##entries
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
								  ,[age_grouping_cd]
								  ,[cd_race]
								  ,[census_hispanic_latino_origin_cd]
								  ,[pk_gndr]
								  ,[init_cd_plcm_setng]
								  ,[long_cd_plcm_setng]
								  ,[county_cd]
								  ,[int_match_param_key],custody_id,cnt_entries
								from ##ooh
						
	




/*********************************************              EXITS  ********************************************************/
			update AE
			set cnt_exits= ext.cnt_exits
			from ##ooh ae
			join ##exits ext
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
				ae.[age_grouping_cd] = ext.[age_grouping_cd] and
				ae.[cd_race] = ext.[cd_race] and
				ae.[census_hispanic_latino_origin_cd] = ext.[census_hispanic_latino_origin_cd] and
				ae.[pk_gndr] = ext.[pk_gndr] and
				ae.[init_cd_plcm_setng] = ext.[init_cd_plcm_setng] and
				ae.[long_cd_plcm_setng] = ext.[long_cd_plcm_setng] and
				ae.county_cd= ext.county_cd  and
				ae.[int_match_param_key] = ext.[int_match_param_key] and
				ae.custody_id=ext.custody_id
				
			

			/******************   insert exits with NO FIRST DAY **********************************************************************/
			insert into ##ooh (qry_type,date_type,	[start_date]
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
								  ,[age_grouping_cd]
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
						,[age_grouping_cd]
						,[cd_race]
						,[census_hispanic_latino_origin_cd]
						,[pk_gndr]
						,[init_cd_plcm_setng]
						,[long_cd_plcm_setng]
						,[county_cd]
						,[int_match_param_key],custody_id,cnt_exits
					from ##exits
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
						,[age_grouping_cd]
						,[cd_race]
						,[census_hispanic_latino_origin_cd]
						,[pk_gndr]
						,[init_cd_plcm_setng]
						,[long_cd_plcm_setng]
						,[county_cd]
						,[int_match_param_key],custody_id,cnt_exits
					from ##ooh

	


	CREATE NONCLUSTERED INDEX idx_insert_qry
	ON ##ooh ([date_type],[custody_id],[qry_type])
	INCLUDE ([start_date],[bin_dep_cd],[max_bin_los_cd],[bin_placement_cd],[bin_ihs_svc_cd],[cd_reporter_type],[fl_cps_invs],[fl_cfws],[fl_risk_only],[fl_alternate_intervention],[fl_frs],[fl_phys_abuse],[fl_sexual_abuse],[fl_neglect],[fl_any_legal],[fl_founded_phys_abuse],[fl_founded_sexual_abuse],[fl_founded_neglect],[fl_found_any_legal],[fl_family_focused_services],[fl_child_care],[fl_therapeutic_services],[fl_mh_services],[fl_receiving_care],[fl_family_home_placements],[fl_behavioral_rehabiliation_services],[fl_other_therapeutic_living_situations],[fl_specialty_adolescent_services],[fl_respite],[fl_transportation],[fl_clothing_incidentals],[fl_sexually_aggressive_youth],[fl_adoption_support],[fl_various],[fl_medical],[fl_budget_C12],[fl_budget_C14],[fl_budget_C15],[fl_budget_C16],[fl_budget_C18],[fl_budget_C19],[fl_uncat_svc],[age_grouping_cd],[cd_race],[census_hispanic_latino_origin_cd],[pk_gndr],[init_cd_plcm_setng],[long_cd_plcm_setng],[county_cd],[int_match_param_key],[cnt_first],[cnt_entries],[cnt_exits])

	
						
	

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
					,[age_grouping_cd]
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
				   ,[age_grouping_cd]
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
			From ##ooh where date_type=0 and custody_id=1 and qry_type=@qry_type
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
					,[age_grouping_cd]
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
				   ,[age_grouping_cd]
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
			From ##ooh where date_type=2 and custody_id=1 and qry_type=@qry_type
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
					,[age_grouping_cd]
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
					)
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
				   ,[age_grouping_cd]
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
		From ##ooh
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
				   ,[age_grouping_cd]
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
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
					,[age_grouping_cd]
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
					)
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
				   ,[age_grouping_cd]
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
			From ##ooh
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
				   ,[age_grouping_cd]
				   ,[cd_race]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[init_cd_plcm_setng]
				   ,[long_cd_plcm_setng]
				   ,[county_cd]
				   ,[int_match_param_key]
				   ,custody_id
			commit tran t4
			set @qry_type=@qry_type + 1
		end
	update statistics prtl.prtl_poc1ab;
	  		

		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end

		