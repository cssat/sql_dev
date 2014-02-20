USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_pbcp5]    Script Date: 2/18/2014 1:02:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [prtl].[prod_build_prtl_pbcp5](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin

	set nocount on
	


	declare @date_type int
	declare @cutoff_date datetime
	declare @start_date datetime
	declare @stop_date datetime

	set @start_date = '2000-01-01'
	set @stop_date= '2012-01-01'
	select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer


				
	
								
		---------------------------------------------------------------------------------------------------------------------------------------------------------GET SUBSET OF DATA
	if object_ID('tempDB..#eps') is not null drop table #eps
	select distinct  cohort_exit_year 
	, 2 as date_type, 0 as qry_type, id_prsn_child, id_removal_episode_fact
	, cd_discharge_type, first_removal_date, fl_first_removal
	, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, federal_discharge_reason_code
	, state_discharge_reason_code, removal_id_placement_result_dim_latest_end_reason_cd, removal_plcm_discharge_reason_cd
	, cdc_census_mix_age_cd as age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key_cdc_census_mix as int_match_param_key
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements
	, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite
	, fl_transportation, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical
	, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, unsafe_begin, unsafe_end
	, trh_begin, trh_duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc
	, case when nxt_reentry_within_min_month_mult3 = 3 
		then 1 else 0 end prsn_cnt
	, exit_within_min_month_mult3
	, nxt_reentry_within_min_month_mult3
	, 3 as mnth
	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc
	, cast(null as int) as row_num		
	, case when 3 =nxt_reentry_within_min_month_mult3  
		or nxt_reentry_within_min_month_mult3 is null then 1 else 0 end as cohort_count	
	into #eps	
	from prtl.ooh_dcfs_eps tce
	where tce.cd_discharge_type in (1,3,4)
	and cohort_exit_year between @start_date and @stop_date
	order by  tce.id_prsn_child,tce.state_custody_start_date

							
							
	update eps
	set row_num=q.row_num2
	from #eps eps 
	join (select tce.* ,row_number() over (-- only want one episode per cohort_period
					partition by tce.id_prsn_child,tce.cohort_exit_year
						order by id_prsn_child,cohort_exit_year asc ,state_custody_start_date asc,federal_discharge_date asc) as row_num2
						from #eps tce
						-- order by  tce.ID_PRSN_CHILD,tce.Cohort_Entry_Date
						) q on q.id_removal_episode_fact=eps.id_removal_episode_fact and q.state_custody_start_date=eps.state_custody_start_date						
							
	--only want child in cohort once
	delete from #eps where row_num > 1;


insert into #eps
select distinct  cohort_exit_year 
	, 2 as date_type, 0 as qry_type, id_prsn_child, id_removal_episode_fact
	, cd_discharge_type, first_removal_date, fl_first_removal
	, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, federal_discharge_reason_code
	, state_discharge_reason_code, removal_id_placement_result_dim_latest_end_reason_cd, removal_plcm_discharge_reason_cd
	, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements
	, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite
	, fl_transportation, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical
	, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, unsafe_begin, unsafe_end
	, trh_begin, trh_duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc
	, case when nxt_reentry_within_min_month_mult3 <= n.mnth then 1 else 0 end prsn_cnt
	, exit_within_min_month_mult3
	, nxt_reentry_within_min_month_mult3
	, n.mnth as mnth
	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc
	, row_num
	, case when n.mnth  =nxt_reentry_within_min_month_mult3 then 1 else 0 end as cohort_count
from #eps
, (select number * 3 as mnth from numbers where number between 2 and 16) n 




-- insert first removals
	insert into #eps
	select cohort_exit_year 
	, 2 as date_type, 1 as qry_type, id_prsn_child, id_removal_episode_fact
	, cd_discharge_type, first_removal_date, fl_first_removal
	, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, federal_discharge_reason_code
	, state_discharge_reason_code, removal_id_placement_result_dim_latest_end_reason_cd, removal_plcm_discharge_reason_cd
	, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
	, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key as int_match_param_key
	, bin_dep_cd, max_bin_los_cd,  bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
	, fl_risk_only, fl_alternate_intervention, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect
	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
	, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements
	, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite
	, fl_transportation, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical
	, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, unsafe_begin, unsafe_end
	, trh_begin, trh_duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc, prsn_cnt,exit_within_min_month_mult3
	, nxt_reentry_within_min_month_mult3
	, mnth
	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc
	, row_num
	, cohort_count
	from #eps
	where fl_first_removal = 1 



---- insert all los_cd records
--	insert into #eps
--	select cohort_exit_year 
--	, date_type, qry_type, id_prsn_child, id_removal_episode_fact
--	, cd_discharge_type, first_removal_date, fl_first_removal
--	, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, federal_discharge_reason_code
--	, state_discharge_reason_code, removal_id_placement_result_dim_latest_end_reason_cd, removal_plcm_discharge_reason_cd
--	, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng
--	, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key as int_match_param_key
--	, bin_dep_cd, max_bin_los_cd, los.bin_los_cd, bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
--	, fl_risk_only, fl_alternate_intervention, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect
--	, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, bin_ihs_svc_cd
--	, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements
--	, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite
--	, fl_transportation, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical
--	, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, unsafe_begin, unsafe_end
--	, trh_begin, trh_duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc, prsn_cnt,exit_within_min_month_mult3
--	, nxt_reentry_within_min_month_mult3
--	, mnth
--	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc
--	, cast(null as int) as row_num
--	, fl_include_in_cohort_count
--	from #eps
--	join ref_filter_los los on los.bin_los_cd < max_bin_los_cd


	

	if object_ID('tempDB..#prtl_pbcp5') is not null drop table #prtl_pbcp5;

	select cohort_exit_year
			,date_type
			,qry_type
			,cd_discharge_type
			,age_grouping_cd
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,bin_dep_cd
			,max_bin_los_cd
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
			,power(10.0,8) 
					+ (power(10.0,7) *fl_any_legal ) 
					+ (power(10.0,6) *fl_neglect )
					+ (power(10.0,5) *fl_sexual_abuse )
					+ (power(10.0,4) *fl_phys_abuse ) +
					+ (power(10.0,3) *fl_found_any_legal )
					+ (power(10.0,2) *fl_founded_neglect )
					+ (power(10.0,1) *fl_founded_sexual_abuse )
					+ (power(10.0,0) *fl_founded_phys_abuse ) as filter_alg_fnd
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
			,mnth
			,sum(prsn_cnt) as prsn_cnt
			,sum(cohort_count) cohort_count
	into #prtl_pbcp5
	from #eps eps
	group by 
		cohort_exit_year
			,date_type
			,qry_type
			,cd_discharge_type
			,age_grouping_cd
			,pk_gndr
			,cd_race_census
			,census_Hispanic_Latino_Origin_cd
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key
			,max_bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			,bin_dep_cd
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
			, mnth
			
			truncate table prtl.prtl_pbcp5


			---  query to extract data
			--select 	cd_discharge_type,sum(prsn_cnt) as prsn_cnt
			--,sum(ret_to_care_m3)/(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m3
			--,sum(ret_to_care_m6) /(sum(prsn_cnt) *1.0000) * 100 as ret_to_care_m6
			--,sum(ret_to_care_m9)/(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m9
			--,sum(ret_to_care_m12)/(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m12
			--,sum(ret_to_care_m15)/(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m15
			--,sum(ret_to_care_m18)/(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m18
			--,sum(ret_to_care_m21)/(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m21
			--,sum(ret_to_care_m24) /(sum(prsn_cnt) *1.0000) * 100 as ret_to_care_m24
			--,sum(ret_to_care_m27) /(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m27
			--,sum(ret_to_care_m30)/(sum(prsn_cnt) *1.0000) * 100   as ret_to_care_m30
			--,sum(ret_to_care_m33) /(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m33
			--,sum(ret_to_care_m36) /(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m36
			--,sum(ret_to_care_m39) /(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m39
			--,sum(ret_to_care_m42) /(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m42
			--,sum(ret_to_care_m45) /(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m45
			--,sum(ret_to_care_m48) /(sum(prsn_cnt) *1.0000) * 100  as ret_to_care_m48
			--from #prtl_pbcp5
			--where cohort_exit_year=	'2009-01-01' and bin_dep_cd=0 and bin_los_cd=1 and qry_type=0
			--group by cd_discharge_type order by cd_discharge_type

			insert into prtl.prtl_pbcp5 (cohort_exit_year, date_type, qry_type, cd_discharge_type, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng
, Removal_County_Cd, int_match_param_key, bin_dep_cd, max_bin_los_cd, bin_placement_cd, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, fl_cps_invs, fl_alternate_intervention, fl_frs
, fl_risk_only, fl_cfws, filter_allegation, fl_any_legal, fl_neglect, fl_sexual_abuse, fl_phys_abuse, filter_finding, fl_found_any_legal, fl_founded_neglect, fl_founded_sexual_abuse
, fl_founded_phys_abuse, filter_alg_fnd,filter_service_type, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements, fl_behavioral_rehabiliation_services
, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation ,fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various
, fl_medical, filter_budget_type, fl_budget_C12
, fl_budget_C14, fl_budget_C15, fl_budget_C16
, fl_budget_C18, fl_budget_C19, fl_uncat_svc
, mnth,prsn_cnt,cohort_count
)
			select cohort_exit_year, date_type, qry_type, cd_discharge_type, age_grouping_cd, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng
, Removal_County_Cd, int_match_param_key, bin_dep_cd, max_bin_los_cd, bin_placement_cd, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, fl_cps_invs, fl_alternate_intervention, fl_frs
, fl_risk_only, fl_cfws, filter_allegation, fl_any_legal, fl_neglect, fl_sexual_abuse, fl_phys_abuse, filter_finding, fl_found_any_legal, fl_founded_neglect, fl_founded_sexual_abuse
, fl_founded_phys_abuse,filter_alg_fnd,filter_service_type, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements, fl_behavioral_rehabiliation_services
, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation ,fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support, fl_various
, fl_medical, filter_budget_type, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, mnth,prsn_cnt,cohort_count
			from #prtl_pbcp5






			update statistics prtl.prtl_pbcp5;

			-- QA
			--select 
			--prtl_pbcp5.dschtype
			--, count(distinct id_prsn_child) as prsn_cnt
			--,sum(retc3)/(tot.total * 1.0000) * 100  as retc3
			--,sum(retc6)/(tot.total * 1.0000) * 100 as retc6
			--,sum(retc9)/(tot.total * 1.0000) * 100 as retc9
			--,sum(retc12)/(tot.total * 1.0000) * 100 as retc12
			--,sum(retc15)/(tot.total * 1.0000) * 100 as retc15
			--,sum(retc18)/(tot.total * 1.0000)* 100  as retc18
			--,sum(retc21)/(tot.total * 1.0000) * 100 as retc21
			--,sum(retc24)/(tot.total * 1.0000) * 100 as retc24
			--,sum(retc27) /(tot.total * 1.0000) * 100as retc27
			--,sum(retc30)/(tot.total * 1.0000) * 100 as retc30
			--,sum(retc33)/(tot.total * 1.0000)* 100  as retc33
			--,sum(retc36) /(tot.total * 1.0000) * 100 as retc36
			--,sum(retc39)/(tot.total * 1.0000) * 100 as retc39
			--,sum(retc42)/(tot.total * 1.0000)* 100  as retc42
			--,sum(retc45)/(tot.total * 1.0000) * 100 as retc45
			--,sum(retc48) /(tot.total * 1.0000)* 100  as retc48
			--,tot.total
			--from dbCoreAdministrativeTables.dbo.prtl_pbcp5
			--	, (select  dschtype,count(distinct id_prsn_child) as total from dbCoreAdministrativeTables.dbo.prtl_pbcp5 where cohort_entry_date='2009-01-01' and date_type=2 group by dschtype ) tot 
			--	 where cohort_entry_date='2009-01-01' and date_type=2 and tot.dschtype=prtl_pbcp5.dschtype
			--group by prtl_pbcp5.dschtype,tot.total order by prtl_pbcp5.dschtype

			

			

			--select id_prsn_child,state_custody_start_date,federal_discharge_date 
			--from  dbCoreAdministrativeTables.dbo.prtl_pbcp5 where cohort_entry_date='2009-01-01' and date_type=2  -- order by id_prsn_child
			--except
			--select id_prsn_child,state_custody_start_date,federal_discharge_date 
			--from #eps where cohort_exit_year='2009-01-01' and date_type=2 and bin_los_cd=0 and bin_dep_cd=0 and qry_type=0 order by id_prsn_child


			--select id_prsn_child,state_custody_start_date,federal_discharge_date 
			--from #eps where cohort_exit_year='2009-01-01' and date_type=2 and bin_los_cd=0 and bin_dep_cd=0 and qry_type=0  --order by id_prsn_child
			--except
			--select id_prsn_child,state_custody_start_date,federal_discharge_date 
			--from  dbCoreAdministrativeTables.dbo.prtl_pbcp5 where cohort_entry_date='2009-01-01' and date_type=2   order by id_prsn_child
		
			

			--select id_prsn_child,state_custody_start_date,federal_discharge_date 
			--from  dbCoreAdministrativeTables.dbo.prtl_pbcp5 where cohort_entry_date='2009-01-01' and date_type=2  -- order by id_prsn_child
			--except
			--select id_prsn_child,state_custody_start_date,federal_discharge_date 
			--from #eps where cohort_exit_year='2009-01-01' and date_type=2 and bin_los_cd=1 and bin_dep_cd=0 and qry_type=0 order by id_prsn_child

			update statistics prtl.prtl_pbcp5;

			update prtl.prtl_tables_last_update		
			set last_build_date=getdate()
				,row_count=(select count(*) from prtl.prtl_pbcp5)
			where tbl_id=5;

end




	

			

	


