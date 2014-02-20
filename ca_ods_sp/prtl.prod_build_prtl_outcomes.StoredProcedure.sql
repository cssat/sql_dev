USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_outcomes]    Script Date: 2/11/2014 11:24:55 AM ******/
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
		declare @end_date datetime
		set @end_date=(select dateadd(yy,-1,cd.[year]) from dbo.calendar_dim cd where CALENDAR_DATE=@cutoff_date)
	
		declare @date_type int
		set @date_type=2
			
		set @start_date = '2000-01-01'

-------------------------------------------------------------------------------------------------------------------------------------------------------GET SUBSET OF DATA
	
	if OBJECT_ID('tempDB..#eps') is not null drop table #eps;
	SELECT cohort_entry_year as cohort_entry_date
	, 2 as date_type, 0 as qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, case  when cd_discharge_type <> 0 and [exit_within_min_month_mult3] is null then 0 else cd_discharge_type end as cd_discharge_type
	, first_removal_date, fl_first_removal
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
	, case when exit_within_min_month_mult3 = 3 or exit_within_min_month_mult3 is null then 1 else 0 end discharge_count
	, [exit_within_min_month_mult3] 
	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date
	, cast(null as int) as row_num
	, case when cd_discharge_type=0 then 48 
		when [exit_within_min_month_mult3] between 3 and 48 then  [exit_within_min_month_mult3] - 3
		when cd_discharge_type <> 0 and [exit_within_min_month_mult3] is null then 48
	 end  as max_still_in_care_month
	 , 1 as cohort_count
	 , 3 as mnth
	into #eps
	from prtl.ooh_dcfs_eps
	where cohort_entry_year between @start_date and @end_date
		--select max_bin_los_cd,id_prsn_child,id_removal_episode_fact,state_custody_start_date,Federal_Discharge_Date,dbo.fnc_datediff_mos(state_custody_start_date,federal_discharge_date) as mo
		--	 from #eps where bin_los_cd=4 and (extm9 > 0 or extm6>0 or extm3>0 or extm12>0 or extm15>0 or extm18>0 or extm21>0) and cd_discharge_type <>0



	update eps
	set row_num=q.row_num2
	from #eps eps 
	join (select tce.* ,row_number() over (-- only want one episode per cohort_period
					partition by tce.id_prsn_child,tce.cohort_entry_date
						order by id_prsn_child,cohort_entry_date asc ,state_custody_start_date asc,federal_discharge_date asc) as row_num2
						from #eps tce
						-- order by  tce.ID_PRSN_CHILD,tce.Cohort_Entry_Date
						) q on q.id_removal_episode_fact=eps.id_removal_episode_fact and q.state_custody_start_date=eps.state_custody_start_date

CREATE NONCLUSTERED INDEX idx_rownum
ON #eps ([row_num])
	CREATE NONCLUSTERED INDEX idx_temp_3
ON #eps ([id_removal_episode_fact],[state_custody_start_date])
INCLUDE ([row_num])
create nonclustered index idx_fl_first_removal on #eps(fl_first_removal)

	-- only want first in cohort period
	delete from #eps where row_num > 1;

-- insert remaining months for discharges including still in care since we changed those with a discharge after 48 months to still in care in qry above
	insert into #eps
	SELECT distinct cohort_entry_date
	, date_type, qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, cd_discharge_type
	, first_removal_date, fl_first_removal
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
	, case when n.mnth >=exit_within_min_month_mult3 and cd_discharge_type<> 0 then 1 
			when n.mnth <=#eps.max_still_in_care_month  and cd_discharge_type=0 then 1 
			when  exit_within_min_month_mult3 is null then 1 else 0 end as discharge_count
	, [exit_within_min_month_mult3] 
	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date
	, row_num
	, max_still_in_care_month
	, 0 as cohort_count
	, n.mnth
from #eps
, (select number * 3 as mnth from numbers where number between 2 and 16) n 


-- now include other months for those still in care that had discharge within 48 months
	insert into #eps
	SELECT distinct cohort_entry_date
	, date_type, qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, 0 as cd_discharge_type
	, first_removal_date, fl_first_removal
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
	-- still in care persons count as 1
	, case when n.mnth <=max_still_in_care_month then 1 else 0 end
	, [exit_within_min_month_mult3] 
	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date
	, row_num
	, max_still_in_care_month
	, 0 as cohort_count
	, n.mnth
from #eps
, (select number * 3 as mnth from numbers where number between 1 and 16) n 
where cd_discharge_type <> 0 

		
	
		-- insert first removals
		insert into #eps
		SELECT cohort_entry_date
	, date_type, fl_first_removal as qry_type, id_prsn_child, id_removal_episode_fact
	-- if child hasn't exited within 4 years for this measure include them as still in care
	, cd_discharge_type
	, first_removal_date, fl_first_removal
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
	, trh_begin, trh_duration, nonDCFS_Cust_Begin, nonDCFS_Cust_End, JRAdetn, unsafe_exit, unsafe_exit_Desc, discharge_count
	, [exit_within_min_month_mult3] 
	, fl_nondcfs_eps, petition_dependency_date, fl_dep_exist, fl_reentry, nxt_reentry_date
	, row_num
	, max_still_in_care_month
	, cohort_count
	, mnth
		from #eps eps
		where fl_first_removal=1;



			
		truncate table prtl.prtl_outcomes;
		insert into prtl.prtl_outcomes(cohort_entry_date,date_type,qry_type,cd_discharge_type,age_grouping_cd,pk_gndr,cd_race_census
		,census_Hispanic_Latino_Origin_cd,init_cd_plcm_setng,long_cd_plcm_setng,Removal_County_Cd,int_match_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd
		,cd_reporter_type,bin_ihs_svc_cd,filter_access_type,fl_cps_invs,fl_alternate_intervention,fl_frs,fl_risk_only,fl_cfws,filter_allegation
		,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal,filter_finding,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_found_any_legal,filter_service_type,fl_family_focused_services
		,fl_child_care,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services
		,fl_respite,fl_transportation,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support,fl_various,fl_medical,filter_budget_type,fl_budget_C12,fl_budget_C14,fl_budget_C15
		,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,mnth,discharge_count,cohort_count
		)
		select 
			cohort_entry_date
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
			, mnth
			,sum(discharge_count) as discharge_count
			,sum(cohort_count)		
		from #eps
		group by cohort_entry_date
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
			,bin_dep_cd
			,max_bin_los_cd
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
			,mnth

		
	
		
	

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
			
	--these are the Still in care after 48 month kids

			
	update statistics prtl.prtl_outcomes;
			
	update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_outcomes)
	  where tbl_id=4;

end
else
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end

