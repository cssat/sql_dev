USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[obsolete_prod_build_prtl_pbcw3]    Script Date: 11/26/2013 12:01:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [prtl].[prod_build_prtl_pbcw3](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
set nocount on


	
	declare @cohort_begin_date datetime;
	declare @cutoff_date datetime;
	declare @date_type int;



	set @cohort_begin_date='1/1/2000'
	set @cutoff_date = (select cutoff_date from ref_Last_DW_Transfer)
	set @date_type=2;


	if object_ID('tempDB..#eps') is not null drop table #eps
	select distinct cd.[year] as cohort_begin_date,@date_type as date_type
		,0 as qry_type,eps.*
		,0 as Fl_Family_Setting
		,0  as FL_DCFS_Family_Setting
		,0 as FL_PA_Family_Setting
		,0 as FL_Relative_Care
		,0 as FL_Grp_Inst_Care
	into #eps
	from prtl.ooh_dcfs_eps eps
	join (select distinct [Year] from dbo.CALENDAR_DIM cd where cd.year >= @cohort_begin_date and cd.year < @cutoff_date) cd
	on eps.state_custody_start_date < cd.year and isnull(eps.Federal_Discharge_Date,'12/31/3999') >=cd.YEAR
			
		/******************************  EVENTS **************************************************/			
		--  select event of episode where event dates contain point in time (cohort_begin_date)
					if object_ID('tempDB..#events') is not null drop table #events
					select tcps.*,ep_begin,ep_end
							,case when placement_setting_type_code between 1 and 18 then 0 else 1 end as tempevt
							,row_number() over (
								partition by tcps.id_prsn_child,tcps.id_removal_episode_fact
										order by tcps.id_prsn_child,tcps.id_removal_episode_fact,case when placement_setting_type_code between 1 and 18 then 0 else 1 end asc,entry_date desc )
											as sort_order -- there should only be ones
							,0 as PAmark
							, case 
								when placement_setting_type_code in (1,2,4,5,18) then 1
								when placement_setting_type_code in  (10,11,15) then 3
								when placement_setting_type_code in (3,6,7,8,9,14,16,-99,12,13,17,19)   then 4
							end
							as plctypc
							,case 
								when placement_setting_type_code in (1,2,4,5,18) then cast('Family Setting (State Licensed Home)' as varchar(100))
								when placement_setting_type_code in  (10,11,15) then cast('Family Setting (Relative Placement)'as varchar(100))
								when placement_setting_type_code in (3,6,7,8,9,14,16,-99,12,13,17,19)   then cast('Non-Family Setting (Group Home or Other Institution)' as varchar(100))
							end
							as plctypc_desc
					into #events
					from base.tbl_child_placement_settings tcps 
					join 	(
								select distinct id_prsn_child
										,id_removal_episode_fact
										,state_custody_start_date as ep_begin
										,federal_discharge_date as ep_end 
										,cohort_begin_date
								from #eps
								) PBCW3_list on tcps.id_prsn_child=PBCW3_list.id_prsn_child
									and tcps.id_removal_episode_fact=PBCW3_list.id_removal_episode_fact
									and tcps.entry_date < cohort_begin_date 
									and coalesce(tcps.exit_date,@cutoff_date) >=cohort_begin_date;
	
				--because of dirty data select first placement example of dirty data for point in time 1/1/2010: id_removal_episode_fact=75091
				delete from #events where sort_order > 1		 



			
			--remove episodes where max(exit_date)< federal_discharge_date					
				delete eps
				--select max_exit_date,eps.*
				from #eps eps
				join (select id_removal_episode_fact,max(coalesce(exit_date,'12/31/3999')) as max_exit_date
						from base.tbl_child_placement_settings tcps
						-- where tcps.fl_lst_ooh_plcm=1
						group by id_removal_episode_fact
						 ) q on q.id_removal_episode_fact = eps.id_removal_episode_fact
				and max_exit_date < cohort_begin_date

				
			 --remove trial return home if it occurs during the point in time
			 delete eps
			--  select qry.*,eps.*
			 from #eps eps
			 join base.tbl_child_placement_settings tcps
					on  eps.id_removal_episode_fact=tcps.id_removal_episode_fact
					and tcps.placement_end_reason_code in (38,39,40) -- TRH
					and trh_begin_date < eps.cohort_begin_date   and trh_end_date >= eps.cohort_begin_date
											
		

									

		--  add private agency marker from payment table service codes	
		--  add PA markers to working events file
				update evt
				set PAmark=pymnt.PAmark,plctypc=case when pymnt.PAmark=1 then 2 else plctypc end
				,plctypc_desc=case when pymnt.PAmark=1 then 'Family Setting (Child Placing Agency Home)' else evt.plctypc_desc end 
				from #events evt
				join (
								SELECT distinct  
									  e.id_placement_fact
									, e.id_removal_episode_fact
									, e.entry_date
									, e.exit_date
									, svc.ID_PRSN_CHILD
									, svc.cd_budget_poc_frc
									, svc.tx_subctgry_poc_frc
									, svc.pymt_cd_srvc,svc.pymt_tx_srvc
									, svc.svc_begin_date
									, svc.svc_end_date
									, row_number() over ( --**  unduplicate by child and event
											partition by e.id_prsn_child ,e.id_removal_episode_fact
												order by  e.id_prsn_child ,e.id_removal_episode_fact,e.entry_date  asc ) 
												as entry_order
									, case when svc.pymt_cd_srvc in (298,299,300,301,302,303,304,468,473,475,477,
											878,879,880,881,882,883,1499,1500,1501,1502,1503,1504,119003) 
											then 1 else 0 end as PAmark
									, case when svc.pymt_cd_srvc in (298,299,300,301,302,303,304,468,473,475,477,
											878,879,880,881,882,883,1499,1500,1501,1502,1503,1504,119003) 
											then 'Private Agency FC'  else 'Not PA' end as PAmark_Desc
					--				into #payments
								FROM base.placement_payment_services svc
								join #eps eps on eps.id_removal_episode_fact=svc.id_removal_episode_fact
									and  svc_begin_date <= cohort_begin_date
									and  svc_end_date >= cohort_begin_date
								join #events e  --**  select PA payments in event date ranges
									on e.id_placement_fact=svc.id_placement_fact
								WHERE svc.pymt_cd_srvc  IN (298,299,300,301,302,303,304,468,473,475,477,
																	 878,879,880,881,882,883,1499,1500,1501,1502,
																	 1503,1504,119003) 
																	-- and svc.id_prsn_child=3933
																	
							--  order by id_prsn_child,id_removal_episode_fact,entry_date,[entry_order]
					 ) pymnt on pymnt.id_removal_episode_fact=evt.id_removal_episode_fact
						and pymnt.id_placement_fact= evt.id_placement_fact and pymnt.entry_order=1;
						
									
					
				update eps
				set FL_DCFS_Family_Setting=1
				from #eps eps 
					join #events evt on eps.id_removal_episode_fact=evt.id_removal_episode_fact
				where evt.plctypc=1;
				
				update eps
				set FL_PA_Family_Setting=1
				from #eps eps 
					join #events evt on eps.id_removal_episode_fact=evt.id_removal_episode_fact
				where evt.plctypc=2;
					
				update eps
				set FL_Relative_Care=1
				from #eps eps 
					join #events evt on eps.id_removal_episode_fact=evt.id_removal_episode_fact
				where evt.plctypc=3;
				
				update eps
				set FL_Grp_Inst_Care=1
				from #eps eps 
					join #events evt on eps.id_removal_episode_fact=evt.id_removal_episode_fact
				where evt.plctypc=4;
				
				update eps
				set FL_Family_Setting=1
				from #eps eps 
				where FL_DCFS_Family_Setting = 1 or FL_PA_Family_Setting=1 or FL_Relative_Care=1;
				
				update eps
				set FL_Grp_Inst_Care=1
				from #eps eps 
				where FL_Family_Setting = 0  and FL_Grp_Inst_Care=0;

				--- insert other LOS into eps
				insert into #eps (cohort_begin_date, date_type, qry_type, cohort_entry_year, cohort_entry_month, cohort_exit_year
, cohort_exit_month, id_prsn_child, id_removal_episode_fact, discharge_type, cd_discharge_type, first_removal_date, fl_first_removal
, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, federal_discharge_reason_code, state_discharge_reason_code, removal_id_placement_result_dim_latest_end_reason_cd
, removal_plcm_discharge_reason_cd, cdc_census_mix_age_cd, census_child_group_cd, developmental_age_cd, school_age_cd, pk_gndr, cd_race_census
, census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key_cdc_census_mix, int_match_param_key_census_child_group
, int_match_param_key_developmental_age, int_match_param_key_school_age, bin_dep_cd, max_bin_los_cd, bin_los_cd, bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
, fl_risk_only, fl_alternate_intervention, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect
, fl_found_any_legal, bin_ihs_svc_cd, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements, fl_behavioral_rehabiliation_services
, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support
, fl_various, fl_medical, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, unsafe_begin, unsafe_end, trh_begin, trh_duration
, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc, prsn_cnt, extm3, extm6, extm9, extm12, extm15, extm18, extm21, extm24, extm27, extm30, extm33
, extm36, extm39, extm42, extm45, extm48, ret_to_care_m3, ret_to_care_m6, ret_to_care_m9, ret_to_care_m12, ret_to_care_m15, ret_to_care_m18, ret_to_care_m21, ret_to_care_m24
, ret_to_care_m27, ret_to_care_m30, ret_to_care_m33, ret_to_care_m36, ret_to_care_m39, ret_to_care_m42, ret_to_care_m45, ret_to_care_m48, fl_nondcfs_eps, petition_dependency_date
, fl_dep_exist, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc, Fl_Family_Setting, FL_DCFS_Family_Setting, FL_PA_Family_Setting, FL_Relative_Care, FL_Grp_Inst_Care)

				select cohort_begin_date, date_type, qry_type, cohort_entry_year, cohort_entry_month, cohort_exit_year
, cohort_exit_month, id_prsn_child, id_removal_episode_fact, discharge_type, cd_discharge_type, first_removal_date, fl_first_removal
, state_custody_start_date, Federal_Discharge_Date, orig_federal_discharge_date, federal_discharge_reason_code, state_discharge_reason_code, removal_id_placement_result_dim_latest_end_reason_cd
, removal_plcm_discharge_reason_cd, cdc_census_mix_age_cd, census_child_group_cd, developmental_age_cd, school_age_cd, pk_gndr, cd_race_census
, census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key_cdc_census_mix, int_match_param_key_census_child_group
, int_match_param_key_developmental_age, int_match_param_key_school_age, bin_dep_cd, max_bin_los_cd, los.bin_los_cd, bin_placement_cd, cd_reporter_type, fl_cps_invs, fl_cfws
, fl_risk_only, fl_alternate_intervention, fl_frs, fl_phys_abuse, fl_sexual_abuse, fl_neglect, fl_any_legal, fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect
, fl_found_any_legal, bin_ihs_svc_cd, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements, fl_behavioral_rehabiliation_services
, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation, fl_clothing_incidentals, fl_sexually_aggressive_youth, fl_adoption_support
, fl_various, fl_medical, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, unsafe_begin, unsafe_end, trh_begin, trh_duration
, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc, prsn_cnt, extm3, extm6, extm9, extm12, extm15, extm18, extm21, extm24, extm27, extm30, extm33
, extm36, extm39, extm42, extm45, extm48, ret_to_care_m3, ret_to_care_m6, ret_to_care_m9, ret_to_care_m12, ret_to_care_m15, ret_to_care_m18, ret_to_care_m21, ret_to_care_m24
, ret_to_care_m27, ret_to_care_m30, ret_to_care_m33, ret_to_care_m36, ret_to_care_m39, ret_to_care_m42, ret_to_care_m45, ret_to_care_m48, fl_nondcfs_eps, petition_dependency_date
, fl_dep_exist, fl_reentry, nxt_reentry_date, prsn_eps_sort_asc, prsn_eps_sort_desc, Fl_Family_Setting, FL_DCFS_Family_Setting, FL_PA_Family_Setting, FL_Relative_Care, FL_Grp_Inst_Care
				from #eps eps
				join ref_Filter_los los on los.bin_los_cd < max_bin_los_cd


    truncate table prtl.prtl_pbcw3
	insert into prtl.prtl_pbcw3 ( cohort_begin_date, date_type, qry_type, cd_discharge_type, age_grouping_cd
	, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng, Removal_County_Cd
	, int_match_param_key, bin_dep_cd, bin_los_cd, bin_placement_cd, cd_reporter_type, bin_ihs_svc_cd, filter_access_type
	, fl_cps_invs, fl_alternate_intervention, fl_frs, fl_risk_only, fl_cfws, filter_allegation, fl_any_legal, fl_neglect
	, fl_sexual_abuse, fl_phys_abuse, filter_finding, fl_found_any_legal, fl_founded_neglect, fl_founded_sexual_abuse, fl_founded_phys_abuse
	, filter_service_type, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements
	, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation, fl_clothing_incidentals
	, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical, filter_budget_type, fl_budget_C12, fl_budget_C14, fl_budget_C15
	, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc,  family_setting_cnt, family_setting_DCFS_cnt, family_setting_private_agency_cnt
	, relative_care, group_inst_care_cnt, total)


	select cohort_begin_date
			,date_type
			,qry_type
			,cd_discharge_type
			,cdc_census_mix_age_cd
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key_cdc_census_mix
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
			, sum(Fl_Family_Setting) as family_setting_cnt
			, sum(fl_dcfs_family_Setting) as family_setting_DCFS_cnt
			, sum(FL_PA_Family_Setting) as family_setting_private_agency_cnt
			, sum(FL_Relative_Care) as relative_care
			, sum(FL_Grp_Inst_Care) as group_inst_care_cnt
			, sum(prsn_cnt) as total
			from #eps
			group by 
			cohort_begin_date
			,date_type
			,qry_type
			,cd_discharge_type
			,cdc_census_mix_age_cd
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key_cdc_census_mix
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

--- ALL DEPENDENCIES bin_dep_cd=0
	insert into prtl.prtl_pbcw3 ( cohort_begin_date, date_type, qry_type, cd_discharge_type, age_grouping_cd
	, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng, Removal_County_Cd
	, int_match_param_key, bin_dep_cd, bin_los_cd, bin_placement_cd, cd_reporter_type, bin_ihs_svc_cd, filter_access_type
	, fl_cps_invs, fl_alternate_intervention, fl_frs, fl_risk_only, fl_cfws, filter_allegation, fl_any_legal, fl_neglect
	, fl_sexual_abuse, fl_phys_abuse, filter_finding, fl_found_any_legal, fl_founded_neglect, fl_founded_sexual_abuse, fl_founded_phys_abuse
	, filter_service_type, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements
	, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation, fl_clothing_incidentals
	, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical, filter_budget_type, fl_budget_C12, fl_budget_C14, fl_budget_C15
	, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc,  family_setting_cnt, family_setting_DCFS_cnt, family_setting_private_agency_cnt
	, relative_care, group_inst_care_cnt, total)


	select cohort_begin_date
			,date_type
			,qry_type
			,cd_discharge_type
			,cdc_census_mix_age_cd
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key_cdc_census_mix
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
			, sum(Fl_Family_Setting) as family_setting_cnt
			, sum(fl_dcfs_family_Setting) as family_setting_DCFS_cnt
			, sum(FL_PA_Family_Setting) as family_setting_private_agency_cnt
			, sum(FL_Relative_Care) as relative_care
			, sum(FL_Grp_Inst_Care) as group_inst_care_cnt
			, sum(prsn_cnt) as total
			from #eps
			group by 
			cohort_begin_date
			,date_type
			,qry_type
			,cd_discharge_type
			,cdc_census_mix_age_cd
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key_cdc_census_mix
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

----------------------------------------------   FIRST REMOVALS
	insert into prtl.prtl_pbcw3 ( cohort_begin_date, date_type, qry_type, cd_discharge_type, age_grouping_cd
	, pk_gndr, cd_race_census, census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng, Removal_County_Cd
	, int_match_param_key, bin_dep_cd, bin_los_cd, bin_placement_cd, cd_reporter_type, bin_ihs_svc_cd, filter_access_type
	, fl_cps_invs, fl_alternate_intervention, fl_frs, fl_risk_only, fl_cfws, filter_allegation, fl_any_legal, fl_neglect
	, fl_sexual_abuse, fl_phys_abuse, filter_finding, fl_found_any_legal, fl_founded_neglect, fl_founded_sexual_abuse, fl_founded_phys_abuse
	, filter_service_type, fl_family_focused_services, fl_child_care, fl_therapeutic_services, fl_mh_services, fl_receiving_care, fl_family_home_placements
	, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, fl_transportation, fl_clothing_incidentals
	, fl_sexually_aggressive_youth, fl_adoption_support, fl_various, fl_medical, filter_budget_type, fl_budget_C12, fl_budget_C14, fl_budget_C15
	, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc,  family_setting_cnt, family_setting_DCFS_cnt, family_setting_private_agency_cnt
	, relative_care, group_inst_care_cnt, total)


	select cohort_begin_date
			,date_type
			,1 as qry_type
			,cd_discharge_type
			,cdc_census_mix_age_cd
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key_cdc_census_mix
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
			, sum(Fl_Family_Setting) as family_setting_cnt
			, sum(fl_dcfs_family_Setting) as family_setting_DCFS_cnt
			, sum(FL_PA_Family_Setting) as family_setting_private_agency_cnt
			, sum(FL_Relative_Care) as relative_care
			, sum(FL_Grp_Inst_Care) as group_inst_care_cnt
			, sum(prsn_cnt) as total
			from #eps
			where fl_first_removal=1
			group by 
			cohort_begin_date
			,date_type
			,cd_discharge_type
			,cdc_census_mix_age_cd
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,Removal_County_Cd
			,int_match_param_key_cdc_census_mix
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

							
				--select cohort_begin_date
				--,sum(FL_Family_Setting) as Family_Setting_Cnt
				--,sum(FL_DCFS_Family_Setting) as Family_Setting_DCFS_Cnt
				--,sum(FL_PA_Family_Setting) as Family_Setting_Private_Agency_Cnt
				--,sum(FL_Relative_Care) as Relative_Care
				--,sum(FL_Grp_Inst_Care) as Group_Inst_Care_Cnt
				--,count(id_prsn_child) as total_in_care
				--from #eps
				--group by cohort_begin_date
				--order by cohort_begin_date

				--select cohort_begin_date
				--,sum(Family_Setting_Cnt) as Family_Setting_Cnt
				--,sum(Family_Setting_DCFS_Cnt) as Family_Setting_DCFS_Cnt
				--,sum(Family_Setting_Private_Agency_Cnt) as Family_Setting_Private_Agency_Cnt
				--,sum(Relative_Care) as Relative_Care
				--,sum(Group_Inst_Care_Cnt) as Group_Inst_Care_Cnt
				--,sum(prtl_pbcw3.total) as total
				--from dbCoreAdministrativeTables.dbo.prtl_pbcw3
				--where month(cohort_begin_date)=1
				--group by cohort_begin_date
				--order by cohort_begin_date

				--	select cohort_begin_date
				--,sum(#eps.FL_DCFS_Family_Setting)/(count(id_prsn_child)  * 1.0000) * 100 as  "Family Setting (State Foster Home)"
				--,sum(FL_PA_Family_Setting)/(count(id_prsn_child)  * 1.0000) * 100  as  "Family Setting (Private Foster Home)"
				--,sum(FL_Relative_Care)/(count(id_prsn_child)  * 1.0000) * 100  as   "Family Setting (Kin Placement)"
				--,sum(FL_Grp_Inst_Care)/(count(id_prsn_child)  * 1.0000) * 100  as   "Non-Family Setting"
				--,count(id_prsn_child)/(count(id_prsn_child)  * 1.0000) * 100  as total_in_care
				--,sum(#eps.FL_DCFS_Family_Setting)/(count(id_prsn_child)  * 1.0000) * 100 
				--	+ sum(FL_PA_Family_Setting)/(count(id_prsn_child)  * 1.0000) * 100  
				--		+ sum(FL_Relative_Care)/(count(id_prsn_child)  * 1.0000) * 100 
				--			+ sum(FL_Grp_Inst_Care)/(count(id_prsn_child)  * 1.0000) * 100 
				--from #eps
				--group by cohort_begin_date
				--order by cohort_begin_date

				--select    cohort_begin_date   , round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as "Family Setting (State Foster Home)"
    --    , round((sum(Family_Setting_Private_Agency_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as  "Family Setting (Private Foster Home)"
    --    , round((sum(Relative_Care)* 1.0000)/(sum(total) * 1.0000) * 100,2)  as  "Family Setting (Kin Placement)"
    --    , round((sum(Group_Inst_Care_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)    as "Non-Family Setting"
				--from dbCoreAdministrativeTables.dbo.prtl_pbcw3
				--where month(cohort_begin_date)=1
				--group by cohort_begin_date
				--order by cohort_begin_date

			
--		--select * from PRTL_PBCW3 ;
end --permission
else
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end

--select * from prtl.prtl_pbcw3 where cohort_begin_date='2000-01-01'
--and date_type= 2
--and qry_type= 0
--and cd_discharge_type= 1
--and int_match_param_key=153414417
--and bin_dep_cd=1
--and bin_los_cd=2
--and bin_placement_cd=3
--and bin_ihs_svc_cd=3
--and cd_reporter_type=9
--and filter_access_type=110000
--and filter_allegation=11001
--and filter_finding=11001
--and filter_service_type=10100010000100010
--and filter_budget_type=10100011


--select * from #eps
--where cohort_begin_date='2000-01-01'
--and date_type= 2
--and qry_type= 0
--and cd_discharge_type= 1
--and int_match_param_key_cdc_census_mix=153414417
--and bin_dep_cd=1
--and bin_los_cd>=2
--and bin_placement_cd=3
--and bin_ihs_svc_cd=3
--and cd_reporter_type=9
--and power(10.0,5) + (power(10.0,4) * fl_cps_invs)  + (power(10.0,3) * fl_alternate_intervention) + (power(10.0,2) * fl_frs) + (power(10.0,1) * fl_risk_only) + (power(10.0,0) * fl_cfws) =110000
--and power(10.0,4) + (power(10.0,3) *fl_any_legal ) 
--			+ (power(10.0,2) *fl_neglect )
--				+ (power(10.0,1) *fl_sexual_abuse )
--					+ (power(10.0,0) *fl_phys_abuse )= 11001
--and power(10.0,4) 
--			+ (power(10.0,3) *fl_found_any_legal )
--					+ (power(10.0,2) *fl_founded_neglect )
--					+ (power(10.0,1) *fl_founded_sexual_abuse )
--						+ (power(10.0,0) *fl_founded_phys_abuse )=11001
--and power(10.0,16) 
--				+ (power(10.0,15) * fl_family_focused_services)  
--					+ (power(10.0,14) * fl_child_care)  
--						+ (power(10.0,13) * fl_therapeutic_services)  
--							+ (power(10.0,12) * fl_mh_services)  
--								+ (power(10.0,11) * fl_receiving_care)  
--									+ (power(10.0,10) * fl_family_home_placements)  
--										+ (power(10.0,9) * fl_behavioral_rehabiliation_services)  
--											+ (power(10.0,8) * fl_other_therapeutic_living_situations)  
--												+ (power(10.0,7) * fl_specialty_adolescent_services)  
--													+ (power(10.0,6) * fl_respite)  
--														+ (power(10.0,5) * fl_transportation)  
--															+ (power(10.0,4) * fl_clothing_incidentals)  
--																+ (power(10.0,3) * fl_sexually_aggressive_youth)  
--																	+ (power(10.0,2) * fl_adoption_support)  
--																		+ (power(10.0,1) * fl_various)  
--																			+ (power(10.0,0) * fl_medical)=10100010000100010
--and power(10.0,7) 
--			+ (power(10.0,6) * fl_budget_C12 ) 
--				+ (power(10.0,5) * fl_budget_C14 ) 
--					+ (power(10.0,4) * fl_budget_C15 ) 
--						+ (power(10,3) * fl_budget_C16 ) 
--							+ (power(10,2) * fl_budget_C18 ) 
--								+ (power(10,1) * fl_budget_C19 ) 
--									+ (power(10,0) * fl_uncat_svc ) =10100011




		--	select    cohort_begin_date   , round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as "Family Setting (State Foster Home)"
  --      , round((sum(Family_Setting_Private_Agency_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as  "Family Setting (Private Foster Home)"
  --      , round((sum(Relative_Care)* 1.0000)/(sum(total) * 1.0000) * 100,2)  as  "Family Setting (Kin Placement)"
  --      , round((sum(Group_Inst_Care_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)    as "Non-Family Setting"
		--		from dbCoreAdministrativeTables.dbo.prtl_pbcw3
		--		where month(cohort_begin_date)=1
		--		group by cohort_begin_date
		--		order by cohort_begin_date


		--						select    cohort_begin_date   , round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as "Family Setting (State Foster Home)"
  --      , round((sum(Family_Setting_Private_Agency_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as  "Family Setting (Private Foster Home)"
  --      , round((sum(Relative_Care)* 1.0000)/(sum(total) * 1.0000) * 100,2)  as  "Family Setting (Kin Placement)"
  --      , round((sum(Group_Inst_Care_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)    as "Non-Family Setting"
		--,round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2) 
		--		from prtl.prtl_pbcw3 where qry_type=0 and date_type=2 and bin_dep_cd=0 and bin_los_cd=1
		--		group by cohort_begin_date
		--		order by cohort_begin_date