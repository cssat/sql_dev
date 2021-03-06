USE CA_ODS
GO
/****** Object:  StoredProcedure [dbo].[prod_build_prtl_pbcs3]    Script Date: 11/26/2013 12:08:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure prtl.[prod_build_prtl_pbcs3](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
/***************************************************************************************
	   This script Populates table PRTl_PBCS3.
	   This table is used to  calculating the percentage
	   of families exiting in-home services (First in home service after intake)
	   who subsequently have a child enter
	   placement (out of home care) earliest placement for the case;
	    
	   Cohort is defined as families FIRST IHS after an intake with
	   in-home services worker assignment and/or receiving in-home authorizations
	   EXITING those services during the cohort period;
	    
	   placements are counted as earliest placement following 
	   in-home services end (Could be on same day)

	  
	   Uses Base tables created from Data Warehouse tables 
*******************************************************************************************/
set nocount on
	
	declare @chstart datetime
	declare @chend datetime
	declare @cutoff_date datetime;


	declare @date_type int;
	declare @loop_stop_date datetime;

	--initialize variables
	set @date_type=2;
	set @chstart='1/1/2004';
	set @cutoff_date=(select max(cutoff_date) from dbo.ref_Last_DW_Transfer);
	set @chend = (select dateadd(dd,-1,[Year]) from dbo.CALENDAR_DIM where CALENDAR_DATE=@cutoff_date)
	



	if object_ID('tempDB..#PBCS3_ALL') is not null drop table #PBCS3_ALL
	select distinct
			  [Year] as cohort_begin_date
			, 2 as date_type
	--		, ihs.id_ihs_episode
			, ihs.id_case
			, ihs.ihs_begin_date
			, ihs.ihs_end_date
			--, sc.srvc_dt_begin
			--, sc.srvc_dt_end
			, max(ihs.fl_first_IHS_after_intake) as fl_first_IHS_after_intake
			, max(ihs.nxt_placement_date ) as frst_plcmnt_aftr_IHS_end
			, max(ihs.cd_race_census_hh) as cd_race_census
			, max(ihs.census_hispanic_latino_origin_cd_hh) as census_hispanic_latino_origin_cd
			, max(xwlk.cd_office_collapse) as cd_office_collapse
			, max(ihs.cd_sib_age_grp) as cd_sib_age_grp
			, max(prm.int_match_param_key) as int_match_param_key
			, max(coalesce(rpt.collapsed_cd_reporter_type,-99)) as cd_reporter
			, max(si.filter_access_type) as filter_access_type
			, max(si.fl_cps_invs) as fl_cps_invs
			, max(si.fl_alternate_intervention) as fl_alternate_intervention
			, max(si.fl_frs) as fl_frs
			, max(si.fl_risk_only) as fl_risk_only
			, max(si.fl_cfws) as fl_cfws
			, max(si.filter_allegation) as filter_allegation
			, max(case when si.fl_phys_abuse =1 or si.fl_sexual_abuse=1 or si.fl_neglect=1 then 1 else 0 end) as fl_any_legal
			, max(si.fl_phys_abuse) as fl_phys_abuse
			, max(si.fl_sexual_abuse) as fl_sexual_abuse
			, max(si.fl_neglect) as fl_neglect
			, max(si.filter_finding) as filter_finding
			, max(si.fl_founded_any_legal) as fl_founded_any_legal					
			, max(si.fl_founded_phys_abuse) as fl_founded_phys_abuse
			, max(si.fl_founded_sexual_abuse) as fl_founded_sexual_abuse
			, max(si.fl_founded_neglect) as fl_founded_neglect
			, max(case when ihs.total_amt_paid > 0 then 1 else 2 end) as bin_ihs_svc_cd
			--,sc.cd_subctgry_poc_frc
			--,sc.cd_budget_poc_frc
			, max(datediff(dd,ihs.ihs_end_date,ihs.nxt_placement_date)) as daysIHSplc
			, max(case when sc.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
			, max(case when sc.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
			, max(case when sc.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
			, max(case when sc.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
			, max(case when sc.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
			, max(case when sc.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
			, max(case when sc.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
			, max(case when sc.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
			, max(case when sc.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
			, max(case when sc.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
			, cast(null as decimal(18,0))  as 	filter_service_type
			, max(case when sc.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
			, max(case when sc.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
			, max(case when sc.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
			, max(case when sc.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
			, max(case when sc.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
			, max(case when sc.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
			, max(case when sc.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
			, cast(null as decimal(18,0))  as 	filter_budget_type
			,max( case when nxt_placement_date is not null then 1 else 0 end) as placed
			, 0 as plcd3
			, 0 as plcd6
			, 0 as plcd9
			, 0 as plcd12
			, 0 as plcd15
			, 0 as plcd18
			, 0 as plcd21
			, 0 as plcd24
			, 0 as plcd27
			, 0 as plcd30
			, 0 as plcd33
			, 0 as plcd36
			, 0 as plcd39
			, 0 as plcd42
			, 0 as plcd45
			, 0 as plcd48
			, 0 as IHS_Order
	into #PBCS3_ALL
	from base.tbl_ihs_episodes IHS
	join dbo.calendar_dim cd on cd.calendar_date=IHS.ihs_end_date 
	join base.tbl_ihs_services sc on sc.id_ihs_episode=ihs.id_ihs_episode 
				 join  dbo.ref_xwalk_CD_OFFICE_DCFS xwlk on xwlk.cd_office=ihs.cd_office
						join dbo.ref_match_intake_parameters prm on prm.match_cd_hispanic_latino_origin=ihs.census_hispanic_latino_origin_cd_hh
							and prm.match_cd_race_census=ihs.cd_race_census_hh
							and prm.cd_sib_age_grp=ihs.cd_sib_age_grp
							and prm.match_cd_office=xwlk.cd_office_collapse
						join dbo.vw_intakes_screened_in si on si.id_intake_fact=ihs.id_intake_fact
						 join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter	
where IHS.ihs_end_date  between @chstart  and @chend
	and fl_first_IHS_after_intake = 1

	
group by [Year],ihs.id_ihs_episode
			, ihs.id_case
			, ihs.ihs_begin_date
			, ihs.ihs_end_date
  
update #PBCS3_ALL
set IHS_Order=row_num
from (select * ,row_number() 
	over (partition by cohort_begin_date,#PBCS3_ALL.id_case
							order by #PBCS3_ALL.id_case,ihs_end_date asc,ihs_begin_date asc) as row_num
								from #PBCS3_ALL) q 
where  q.id_case=#PBCS3_ALL.id_case
and q.ihs_begin_date=#PBCS3_ALL.ihs_begin_date
and q.cohort_begin_date=#PBCS3_ALL.cohort_begin_date


delete from #PBCS3_ALL where IHS_Order <> 1
update #PBCS3_ALL set plcd3=1 where placed=1 and daysIHSplc < 92;
update #PBCS3_ALL set plcd6=1 where placed=1 and daysIHSplc < 183;
update #PBCS3_ALL set plcd9=1 where placed=1 and daysIHSplc < 274;
update #PBCS3_ALL set plcd12=1 where placed=1 and daysIHSplc < 366;
update #PBCS3_ALL set plcd15=1 where placed=1 and daysIHSplc < 457;
update #PBCS3_ALL set plcd18=1 where placed=1 and daysIHSplc < 548;
update #PBCS3_ALL set plcd21=1 where placed=1 and daysIHSplc < 639;
update #PBCS3_ALL set plcd24=1 where placed=1 and daysIHSplc < 731;
update #PBCS3_ALL set plcd27=1 where placed=1 and daysIHSplc < 822;
update #PBCS3_ALL set plcd30=1 where placed=1 and daysIHSplc < 913;
update #PBCS3_ALL set plcd33=1 where placed=1 and daysIHSplc < 1004;
update #PBCS3_ALL set plcd36=1 where placed=1 and daysIHSplc < 1097;
update #PBCS3_ALL set plcd39=1 where placed=1 and daysIHSplc < 1187;
update #PBCS3_ALL set plcd42=1 where placed=1 and daysIHSplc < 1278;
update #PBCS3_ALL set plcd45=1 where placed=1 and daysIHSplc < 1370;
update #PBCS3_ALL set plcd48=1 where placed=1 and daysIHSplc < 1461;



			truncate table  prtl.prtl_pbcs3;

			insert into  prtl.prtl_pbcs3
				select 
					  cohort_begin_date 
					, date_type 
					, cd_race_census 
					, census_hispanic_latino_origin_cd 
					, cd_office_collapse
					, cd_sib_age_grp 
					, int_match_param_key 
					, cd_reporter 
					, bin_ihs_svc_cd
					, power(10.0,5) + (power(10.0,4) * fl_cps_invs)  
						+ (power(10.0,3) * fl_alternate_intervention) 
							+ (power(10.0,2) * fl_frs) 
								+ (power(10.0,1) * fl_risk_only) 
									+ (power(10.0,0) * fl_cfws) as filter_access_type
					, fl_cps_invs
					, fl_alternate_intervention
					, fl_frs 
					, fl_risk_only 
					, fl_cfws
					, power(10.0,4) + (power(10.0,3) *fl_any_legal ) 
					  + (power(10.0,2) *fl_neglect )
						 + (power(10.0,1) *fl_sexual_abuse )
							+ (power(10.0,0) *fl_phys_abuse ) as filter_allegation
					, fl_any_legal 
					, fl_phys_abuse 
					, fl_sexual_abuse 
					, fl_neglect 
					, power(10.0,4) 
					  + (power(10.0,3) *fl_founded_any_legal )
						 + (power(10.0,2) *fl_founded_neglect )
							+ (power(10.0,1) *fl_founded_sexual_abuse )
								+ (power(10.0,0) *fl_founded_phys_abuse )as filter_finding	
					, fl_founded_any_legal 
					, fl_founded_phys_abuse 
					, fl_founded_sexual_abuse 
					, fl_founded_neglect 
					, fl_family_focused_services 
					, fl_child_care 
					, fl_therapeutic_services 
					, fl_family_home_placements 
					, fl_behavioral_rehabiliation_services 
					, fl_other_therapeutic_living_situations 
					, fl_specialty_adolescent_services
					, fl_respite
					, fl_transportation
					, fl_adoption_support
					, power(10.0,16) 
						+ (power(10.0,15) * fl_family_focused_services)  
							+ (power(10.0,14) * fl_child_care)  
								+ (power(10.0,13) * fl_therapeutic_services)  
											+ (power(10.0,10) * fl_family_home_placements)  
												+ (power(10.0,9) * fl_behavioral_rehabiliation_services)  
													+ (power(10.0,8) * fl_other_therapeutic_living_situations)  
														+ (power(10.0,7) * fl_specialty_adolescent_services)  
															+ (power(10.0,6) * fl_respite)  
																+ (power(10.0,5) * fl_transportation)  
																			+ (power(10.0,2) * fl_adoption_support)   as filter_service_type 
					, fl_budget_C12 
					, fl_budget_C14 
					, fl_budget_C15 
					, fl_budget_C16 
					, fl_budget_C18 
					, fl_budget_C19
					, fl_uncat_svc
					,  power(10.0,7) 
				+ (power(10.0,6) * fl_budget_C12 ) 
					+ (power(10.0,5) * fl_budget_C14 ) 
						+ (power(10.0,4) * fl_budget_C15 ) 
							+ (power(10,3) * fl_budget_C16 ) 
								+ (power(10,2) * fl_budget_C18 ) 
									+ (power(10,1) * fl_budget_C19)
										+ (power(10,0) * fl_uncat_svc) as filter_budget_type
					, count(*) as N_Total
					, sum(plcd3) as plcd3
					, sum(plcd6) as plcd6
					, sum(plcd9) as plcd9
					, sum(plcd12) as plcd12
					, sum(plcd15) as plcd15
					, sum(plcd18) as plcd18
					, sum(plcd21) as plcd21
					, sum(plcd24) as plcd24
					, sum(plcd27) as plcd27
					, sum(plcd30) as plcd30
					, sum(plcd33) as plcd33
					, sum(plcd36) as plcd36
					, sum(plcd39) as plcd39
					, sum(plcd42) as plcd42
					, sum(plcd45) as plcd45
					, sum(plcd48) as plcd48
				from #PBCS3_ALL s3
				group by cohort_begin_date 
					, date_type 
					, cd_race_census 
					, census_hispanic_latino_origin_cd 
					, cd_office_collapse
					, cd_sib_age_grp 
					, int_match_param_key 
					, cd_reporter 
					, fl_cps_invs
					, fl_alternate_intervention
					, fl_frs 
					, fl_risk_only 
					, fl_cfws
					, fl_any_legal 
					, fl_phys_abuse 
					, fl_sexual_abuse 
					, fl_neglect 
					, fl_founded_any_legal 
					, fl_founded_phys_abuse 
					, fl_founded_sexual_abuse 
					, fl_founded_neglect 
					, bin_ihs_svc_cd
					, fl_family_focused_services 
					, fl_child_care 
					, fl_therapeutic_services 
					, fl_family_home_placements 
					, fl_behavioral_rehabiliation_services 
					, fl_other_therapeutic_living_situations 
					, fl_specialty_adolescent_services
					, fl_respite
					, fl_transportation
					, fl_adoption_support
					, fl_budget_C12 
					, fl_budget_C14 
					, fl_budget_C15 
					, fl_budget_C16 
					, fl_budget_C18 
					, fl_budget_C19
					, fl_uncat_svc



		
end --permission

else
begin
	select 'Need permission key to execute BUILDS COHORTS!' as [Warning]
end



		--select 'old S3' as [Logic_type]
		--			, cohort_begin_date
		--			,date_type
		--			,sum(N_TOTAL), sum(plcd3), sum(plcd6), sum(plcd9), sum(plcd12), sum(plcd15), sum(plcd18), sum(plcd21), sum(plcd24), sum(plcd27), sum(plcd30), sum(plcd33), sum(plcd36), sum(plcd39), sum(plcd42), sum(plcd45), sum(plcd48)
		--		 from dbCoreAdministrativeTables.dbo.prtl_pbcs3 
		--		 where date_type=2
		--		 group by cohort_begin_date
		--			,date_type

		--			union 
		--			select 'new S3' as [Logic_type]
		--			, cohort_begin_date
		--			,date_type
		--			,sum(N_TOTAL), sum(plcd3), sum(plcd6), sum(plcd9), sum(plcd12), sum(plcd15), sum(plcd18), sum(plcd21), sum(plcd24), sum(plcd27), sum(plcd30), sum(plcd33), sum(plcd36), sum(plcd39), sum(plcd42), sum(plcd45), sum(plcd48)
		--		 from prtl.prtl_pbcs3
				
		--		 group by cohort_begin_date
		--			,date_type
		--			order by cohort_begin_date,Logic_type