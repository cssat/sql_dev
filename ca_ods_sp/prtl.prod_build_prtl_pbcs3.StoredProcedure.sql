USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_pbcs3]    Script Date: 9/22/2014 10:10:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [prtl].[prod_build_prtl_pbcs3](@permission_key datetime)
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
			, 0 as qry_type
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
			, max(ihs.intake_county_cd) as intake_county_cd
			, max(ihs.cd_sib_age_grp) as cd_sib_age_grp
			, max(power(10,6) 
					+ (power(10,5) * ihs.cd_sib_age_grp)
					+ (power(10,4) * ihs.cd_race_census_hh)
					+ (power(10,3) * ihs.census_hispanic_latino_origin_cd_hh)
					+ abs(ihs.intake_county_cd)) [int_match_param_key]
			, max(coalesce(rpt.collapsed_cd_reporter_type,-99)) as cd_reporter
			, max(si.filter_access_type) as filter_access_type
			, max(si.fl_cps_invs) as fl_cps_invs
			, max(si.fl_alternate_intervention) as fl_alternate_intervention
			, max(si.fl_frs) as fl_frs
			, max(si.fl_risk_only) as fl_risk_only
			, max(si.fl_cfws) as fl_cfws
			, max(si.fl_far) as fl_far
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
			, max(datediff(dd,ihs.ihs_end_date,ihs.nxt_placement_date)) as daysIHSplc
			, max(case when sc.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
			, max(case when sc.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
			, max(case when sc.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
			, max(case when sc.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
			, max(case when sc.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
			, max(case when sc.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
			, max(case when sc.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
			, max(case when sc.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
			, max(case when sc.cd_subctgry_poc_frc=17 then 1 else 0 end) as fl_ihs_reun
			, max(case when sc.cd_subctgry_poc_frc=18 then 1 else 0 end) as fl_concrete_goods
			, cast(null as decimal(21,0))  [filter_service_type]
			, max(case when sc.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
			, max(case when sc.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
			--, max(case when sc.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
			--, max(case when sc.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
			--, max(case when sc.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
			, max(case when sc.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
			, max(case when sc.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
			, cast(null as decimal(18,0))  as 	filter_budget_type
			,max( case when nxt_placement_date is not null then 1 else 0 end) as placed
					, 0 as IHS_Order
			, cast(null as int) as min_placed_within_month
			, 1 as cnt_case
	into #PBCS3_ALL  
	from base.tbl_ihs_episodes ihs
	join dbo.calendar_dim cd on cd.calendar_date=IHS.ihs_end_date 
	join base.tbl_ihs_services sc on sc.id_ihs_episode=ihs.id_ihs_episode 
	join dbo.vw_intakes_screened_in si on si.id_intake_fact=ihs.id_intake_fact
	join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter	
where IHS.ihs_end_date  between @chstart  and @chend
	and fl_first_IHS_after_intake = 1 and fl_dlr=0
group by [Year],ihs.id_ihs_episode
			, ihs.id_case
			, ihs.ihs_begin_date
			, ihs.ihs_end_date



insert into #pbcs3_all
	select distinct
		  [Year] as cohort_begin_date
			, 2 as date_type
			, 1 as qry_type
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
			, max(ihs.intake_county_cd) as intake_county_cd
			, max(ihs.cd_sib_age_grp) as cd_sib_age_grp
			, max(power(10,6) 
					+ (power(10,5) * ihs.cd_sib_age_grp)
					+ (power(10,4) * ihs.cd_race_census_hh)
					+ (power(10,3) * ihs.census_hispanic_latino_origin_cd_hh)
					+ abs(ihs.intake_county_cd)) [int_match_param_key]
			, max(coalesce(rpt.collapsed_cd_reporter_type,-99)) as cd_reporter
			, max(si.filter_access_type) as filter_access_type
			, max(si.fl_cps_invs) as fl_cps_invs
			, max(si.fl_alternate_intervention) as fl_alternate_intervention
			, max(si.fl_frs) as fl_frs
			, max(si.fl_risk_only) as fl_risk_only
			, max(si.fl_cfws) as fl_cfws
			,max(si.fl_far) [fl_far]
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
			--, select * from ref_service_cd_subctgry_poc  where fl_ihs_svc=1
			, max(datediff(dd,ihs.ihs_end_date,ihs.nxt_placement_date)) as daysIHSplc
			, max(case when sc.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
			, max(case when sc.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
			, max(case when sc.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
			, max(case when sc.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
			, max(case when sc.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
			, max(case when sc.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
			, max(case when sc.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
			, max(case when sc.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
			, max(case when sc.cd_subctgry_poc_frc=17 then 1 else 0 end) as fl_ihs_reun
			, max(case when sc.cd_subctgry_poc_frc=18 then 1 else 0 end) as fl_concrete_goods
			, cast(null as decimal(21,0))  as 	filter_service_type
			, max(case when sc.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
			, max(case when sc.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
			--, max(case when sc.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
			--, max(case when sc.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
			--, max(case when sc.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
			, max(case when sc.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
			, max(case when sc.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
			, cast(null as int)  as 	filter_budget_type
			,max( case when nxt_placement_date is not null then 1 else 0 end) as placed
			--, 0 as plcd3
			--, 0 as plcd6
			--, 0 as plcd9
			--, 0 as plcd12
			--, 0 as plcd15
			--, 0 as plcd18
			--, 0 as plcd21
			--, 0 as plcd24
			--, 0 as plcd27
			--, 0 as plcd30
			--, 0 as plcd33
			--, 0 as plcd36
			--, 0 as plcd39
			--, 0 as plcd42
			--, 0 as plcd45
			--, 0 as plcd48
			, 0 as IHS_Order
			, cast(null as int) as min_placed_within_month
			, 1 as cnt_case
	from base.tbl_ihs_episodes ihs
	join dbo.calendar_dim cd on cd.calendar_date=IHS.ihs_end_date 
	join base.tbl_ihs_services sc on sc.id_ihs_episode=ihs.id_ihs_episode 
						join dbo.vw_intakes_screened_in si on si.id_intake_fact=ihs.id_intake_fact
						 join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter	
where IHS.ihs_end_date  between @chstart  and @chend
	and fl_first_IHS_after_intake = 1 and fl_dlr=0
	and ihs.first_ihs_date=ihs.ihs_begin_date 
group by [Year],ihs.id_ihs_episode
			, ihs.id_case
			, ihs.ihs_begin_date
			, ihs.ihs_end_date


  
update #PBCS3_ALL
set IHS_Order=row_num
from (select * ,row_number() 
	over (partition by cohort_begin_date,#PBCS3_ALL.id_case,qry_type
							order by #PBCS3_ALL.id_case,ihs_end_date asc,ihs_begin_date asc) as row_num
								from #PBCS3_ALL
								) q 
where  q.id_case=#PBCS3_ALL.id_case
and q.ihs_begin_date=#PBCS3_ALL.ihs_begin_date
and q.cohort_begin_date=#PBCS3_ALL.cohort_begin_date





delete from #PBCS3_ALL where IHS_Order <> 1

update #PBCS3_ALL set min_placed_within_month=3  where placed=1 and daysIHSplc < 92;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 6 else min_placed_within_month end  where placed=1 and daysIHSplc < 183;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 9 else min_placed_within_month end    where placed=1 and daysIHSplc < 274;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 12 else min_placed_within_month end    where placed=1 and daysIHSplc < 366;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 15 else min_placed_within_month end    where placed=1 and daysIHSplc < 457;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 18 else min_placed_within_month end    where placed=1 and daysIHSplc < 548;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 21 else min_placed_within_month end    where placed=1 and daysIHSplc < 639;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 24 else min_placed_within_month end    where placed=1 and daysIHSplc < 731;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 27 else min_placed_within_month end    where placed=1 and daysIHSplc < 822;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 30 else min_placed_within_month end   where placed=1 and daysIHSplc < 913;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 33 else min_placed_within_month end    where placed=1 and daysIHSplc < 1004;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 36 else min_placed_within_month end    where placed=1 and daysIHSplc < 1097;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 39 else min_placed_within_month end    where placed=1 and daysIHSplc < 1187;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 42 else min_placed_within_month end    where placed=1 and daysIHSplc < 1278;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 45 else min_placed_within_month end    where placed=1 and daysIHSplc < 1370;
update #PBCS3_ALL set min_placed_within_month=case when min_placed_within_month is null then 48 else min_placed_within_month end    where placed=1 and daysIHSplc < 1461;

update #PBCS3_ALL
set  filter_service_type=(select multiplier from ref_service_cd_subctgry_poc where cd_subctgry_poc_frc=0)
						+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_family_focused_services') * fl_family_focused_services)  
							+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_child_care') * fl_child_care)  
								+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_therapeutic_services') * fl_therapeutic_services)  
												+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_behavioral_rehabiliation_services') * fl_behavioral_rehabiliation_services)  
													+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_other_therapeutic_living_situations') * fl_other_therapeutic_living_situations)  
														+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_specialty_adolescent_services') * fl_specialty_adolescent_services)  
															+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_respite') * fl_respite)  
																+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_transportation') * fl_transportation)  
																			+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_ihs_reun') * fl_ihs_reun)  
																				+ ((select multiplier from ref_service_cd_subctgry_poc where  fl_name='fl_concrete_goods') * fl_concrete_goods)  
			,filter_budget_type=(select multiplier from ref_service_cd_budget_poc_frc where cd_budget_poc_frc=0)
				+ ((select multiplier from ref_service_cd_budget_poc_frc where  fl_name='fl_budget_C12') * fl_budget_C12 ) 
					+ ((select multiplier from ref_service_cd_budget_poc_frc where  fl_name='fl_budget_C14') * fl_budget_C14 ) 
						--+ ((select multiplier from ref_service_cd_budget_poc_frc where  fl_name='fl_budget_C15') * fl_budget_C15 ) 
						--	+ ((select multiplier from ref_service_cd_budget_poc_frc where  fl_name='fl_budget_C16') * fl_budget_C16 ) 
						--		+ ((select multiplier from ref_service_cd_budget_poc_frc where  fl_name='fl_budget_C18')* fl_budget_C18 ) 
									+ ((select multiplier from ref_service_cd_budget_poc_frc where  fl_name='fl_budget_C19') * fl_budget_C19)
										+ ((select multiplier from ref_service_cd_budget_poc_frc where  fl_name='fl_uncat_svc') * fl_uncat_svc) 


			ALTER TABLE prtl.prtl_pbcs3 NOCHECK CONSTRAINT ALL;
			truncate table  prtl.prtl_pbcs3;

			insert into  prtl.prtl_pbcs3
				select 
					  cohort_begin_date 
					, date_type 
					, qry_type
					, cd_race_census 
					, census_hispanic_latino_origin_cd 
					, intake_county_cd
					, cd_sib_age_grp 
					, int_match_param_key 
					, cd_reporter 
					, bin_ihs_svc_cd
					, (select cd_multiplier from ref_filter_access_type where cd_access_type=0 )
								+  fl_far * (select cd_multiplier from ref_filter_access_type where fl_name='fl_far')
								+  fl_cps_invs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cps_invs')
								+ fl_alternate_intervention  * (select cd_multiplier from ref_filter_access_type where fl_name='fl_alternate_intervention')
								+ fl_frs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_frs')
								+ fl_risk_only * (select cd_multiplier from ref_filter_access_type where fl_name='fl_risk_only')
								+ fl_cfws * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cfws')   [filter_access_type]
					,(select cd_multiplier from ref_filter_allegation where cd_allegation=0)
									+ ( [fl_phys_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_phys_abuse'))
									+ ([fl_sexual_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_sexual_abuse'))
									+ ([fl_neglect] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_neglect'))
									+ ([fl_any_legal] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal')) [filter_allegation]
					,(select cd_multiplier from ref_filter_finding where cd_finding=0)
								+ ([fl_founded_phys_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_phys_abuse'))
								+ ([fl_founded_sexual_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_sexual_abuse'))
								+ ([fl_founded_neglect] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_neglect'))
								+ (fl_founded_any_legal * (select cd_multiplier from ref_filter_finding where fl_name='fl_any_finding_legal')) [filter_finding]
								--  select * from ref_service_cd_subctgry_poc
					, int_filter_service_category
					--  select * from ref_service_cd_budget_poc_frc
					,   filter_budget_type
					, isnull(min_placed_within_month,99999) as min_placed_within_month
					,sum(cnt_case) as cnt_case
				from #PBCS3_ALL s3
				join ref_service_category_flag_xwalk xw on xw.filter_service_category=s3.filter_service_type
				group by cohort_begin_date 
					, date_type 
					, qry_type
					, min_placed_within_month
					, cd_race_census 
					, census_hispanic_latino_origin_cd 
					, intake_county_cd
					, cd_sib_age_grp 
					, int_match_param_key 
					, cd_reporter 
					, fl_cps_invs
					, fl_alternate_intervention
					, fl_frs 
					, fl_risk_only 
					, fl_cfws
					, fl_far
					, fl_any_legal 
					, fl_phys_abuse 
					, fl_sexual_abuse 
					, fl_neglect 
					, fl_founded_any_legal 
					, fl_founded_phys_abuse 
					, fl_founded_sexual_abuse 
					, fl_founded_neglect 
					, bin_ihs_svc_cd
					, int_filter_service_category
					, filter_budget_type


			ALTER TABLE prtl.prtl_pbcs3 CHECK CONSTRAINT ALL;
			update statistics prtl.prtl_pbcs3;

			update prtl.prtl_tables_last_update		
			set last_build_date=getdate()
				,row_count=(select count(*) from prtl.prtl_pbcs3)
			where tbl_id=7;	

			--select * from prtl.prtl_tables_last_update where tbl_id=7
			--select count(*) from prtl.prtl_pbcs3
		
end --permission

else
begin
	select 'Need permission key to execute BUILDS COHORTS!' as [Warning]
end




