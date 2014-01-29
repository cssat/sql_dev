USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_poc3ab]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [prtl].[prod_build_prtl_poc3ab](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin	

	  set nocount on 				
		declare @chstart datetime
		declare @chend datetime
		declare @startLoop datetime
		declare @stopLoop datetime
		declare @cutoff_date datetime
		declare @date_type int
		declare @qry_type int
		declare @max_row int
		declare @row int
		declare @start_date datetime;
		
		select @cutoff_date=cutoff_date from ref_last_dw_transfer;
		set @start_date='1/1/2004'
		
		set @qry_type=0;
		set @date_type=0;
		set @chstart=@start_date;
		set @startLoop=@chstart
		set @cutoff_date = (select cutoff_date from ref_Last_DW_Transfer)
		set @chend = (select distinct dateadd(dd,-1,[month]) from dbo.CALENDAR_DIM where @cutoff_date = CALENDAR_DATE)


			if OBJECT_ID('tempDB..##dates') is not null drop table ##dates;
			create table ##dates(strt_date datetime,end_date datetime,date_type int,primary key(strt_date,date_type))
			
			insert into ##dates 
			select distinct [Month] as strt_date,eomonth([Month]) as end_date,0 as date_type 
			from calendar_dim
			where [month] between @chstart and @chend  

			insert into ##dates
			select distinct [Year],dateadd(dd,-1,dateadd(yy,1,[Year])),2 from calendar_dim
			where [year] between @chstart and (select end_date from [dbo].[ref_last_month_qtr_yr] where date_type=2)

		

		--unique temp table
			if object_id('tempDB..##poc3_unq') is not null drop table ##poc3_unq;
			select DISTINCT ihs.id_case,(ihs_begin_date),(ihs_end_date)
					,cast(null as int) as ihs_sort
			into ##poc3_unq
			from base.tbl_ihs_episodes ihs
			where fl_first_IHS_after_intake = 1;
	

			update poc3
			set ihs_sort=q.ihs_sort
			from ##poc3_unq poc3
			join (select  id_case
						, ihs_begin_date
						, ihs_end_date
						, row_number() 
							over  (partition by id_case order by id_case, ihs_begin_date,ihs_end_date asc)
								as ihs_sort
				  from ##poc3_unq) q 
					on q.id_case=poc3.id_case 
					and q.ihs_begin_date=poc3.ihs_begin_date
					and q.ihs_end_date=poc3.ihs_end_date;

	

			if object_id('tempDB..##poc3_frst') is not null drop table ##poc3_frst;
			select DISTINCT id_case
					,(ihs_begin_date)
					,(ihs_end_date)
					,cast(null as int) as ihs_sort
			into ##poc3_frst
			from base.tbl_ihs_episodes
			where fl_first_IHS_after_intake = 1
			-- and first_ever_intake=1;
			and first_ihs_date = ihs_begin_date;
	


	
	
			update poc3
			set ihs_sort=q.ihs_sort
			from ##poc3_frst poc3
			join (select id_case
						,ihs_begin_date
						,ihs_end_date
						,row_number() over  
							(
								partition by id_case order by id_case, ihs_begin_date,ihs_end_date asc)
								as ihs_sort
				  from ##poc3_frst) q 
					on q.id_case=poc3.id_case and q.ihs_begin_date=poc3.ihs_begin_date
				  and q.ihs_end_date=poc3.ihs_end_date;

			if object_id('tempDB..##poc3_all') is not null drop table ##poc3_all;
			select distinct ce.id_case
					,ce.id_ihs_episode
					,ce.ihs_begin_date
					,ce.ihs_end_date
					,sc.srvc_dt_begin
					,sc.srvc_dt_end
					,ce.fl_first_IHS_after_intake
					,ce.cd_race_census_hh
					,ce.census_hispanic_latino_origin_cd_hh
					, xwlk.cd_office_collapse
					,ce.cd_sib_age_grp
					, prm.int_match_param_key
					, coalesce(rpt.collapsed_cd_reporter_type,-99) as cd_reporter
					, si.fl_cps_invs
					, si.filter_access_type
					, si.filter_allegation
					, si.filter_finding
					, si.fl_phys_abuse 
					, si.fl_sexual_abuse
					, si.fl_neglect
					, case when si.fl_phys_abuse =1 or si.fl_sexual_abuse=1 or si.fl_neglect=1 then 1 else 0 end as fl_any_legal
					, si.fl_founded_phys_abuse
					, si.fl_founded_sexual_abuse
					, si.fl_founded_neglect
					, si.fl_founded_any_legal								
					, case when ce.total_amt_paid > 0 then 1 else 2 end as bin_ihs_svc_cd
					,sc.cd_subctgry_poc_frc
					,sc.cd_budget_poc_frc
			into ##poc3_all
			from base.tbl_ihs_episodes ce
				 join base.tbl_ihs_services sc on sc.id_ihs_episode=ce.id_ihs_episode 
				 and sc.srvc_dt_end between ce.ihs_begin_date and ce.ihs_end_date
						and sc.srvc_dt_begin between ce.ihs_begin_date and ce.ihs_end_date
				 join  dbo.ref_xwalk_CD_OFFICE_DCFS xwlk on xwlk.cd_office=ce.cd_office
						join dbo.ref_match_intake_parameters prm on prm.match_cd_hispanic_latino_origin=ce.census_hispanic_latino_origin_cd_hh
							and prm.match_cd_race_census=ce.cd_race_census_hh
							and prm.cd_sib_age_grp=ce.cd_sib_age_grp
							and prm.match_cd_office=xwlk.cd_office_collapse
						join dbo.vw_intakes_screened_in si on si.id_intake_fact=ce.id_intake_fact
						 join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter	




				
			if OBJECT_ID('tempDB..##Caseload') is not null drop table ##Caseload;
			create table ##Caseload (
					  period_start datetime
					, date_type int
					, qry_type int
					, id_case int
					, id_intake_Fact int
					, cd_race int
					, census_hispanic_latino_origin_cd int
					, cd_office_collapse int
					, cd_sib_age_grp int
					, int_match_param_key int
					, [cd_reporter_type] int
					, [fl_cps_invs] int
					, [filter_access_type] int
					, [filter_allegation] int
					, [filter_finding]int
					, [fl_phys_abuse] int 
					, [fl_sexual_abuse]int
					, [fl_neglect] int
					, [fl_any_legal] int
					, [fl_founded_phys_abuse] int
					, [fl_founded_sexual_abuse] int
					, [fl_founded_neglect] int
					, [fl_found_any_legal] int
					, bin_ihs_svc_cd int
					, fl_family_focused_services int
					, fl_child_care  int
					, fl_therapeutic_services  int
					, fl_family_home_placements  int
					, fl_behavioral_rehabiliation_services  int
					, fl_other_therapeutic_living_situations  int
					, fl_specialty_adolescent_services  int
					, fl_respite  int
					, fl_transportation  int
					, fl_adoption_support  int
					, filter_service_type decimal(32,0)
					, fl_budget_C12 int
					, fl_budget_C14 int
					, fl_budget_C15 int
					, fl_budget_C16 int
					, fl_budget_C18 int
					, fl_budget_C19 int
					, fl_uncat_svc int
					, filter_budget_type decimal(16,0)
					, measure_int int
					, measure_desc varchar(50)
					, cnt_distinct_Intakes int
				)		
		
		while @date_type <=2
		begin
						
/**************************************** UNIQUE	 *******************************************************/
						set @qry_type=0;
						
						insert into ##Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type,fl_cps_invs
							,filter_access_type,filter_allegation,filter_finding,fl_phys_abuse
							,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse
							,fl_founded_neglect,fl_found_any_legal,bin_ihs_svc_cd,measure_int,measure_desc,cnt_distinct_Intakes)
						select  distinct
								  strt_date
								, @date_type
								, @qry_type
								, ce.id_case 
								, 0
								, null -- ce.fam_cd_race_census
								, null -- census_hispanic_latino_origin_cd
								, null -- ce.cd_office_collapse
								, null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as fl_cps_invs
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as fl_phys_abuse 
								, null as fl_sexual_abuse
								, null as fl_neglect
								, null as fl_any_legal
								, null as fl_founded_phys_abuse
								, null as fl_founded_sexual_abuse
								, null as fl_founded_neglect
								, null as fl_found_any_legal
								, null as bin_ihs_svc_cd
								,1
								,'Total Open on First Day'
								,1
						from ##poc3_unq ce  
						join  ##dates on date_type=@date_type
						where ce.ihs_begin_date < strt_date
							and (ce.ihs_end_date >=strt_date )
						union all
						select  distinct
								 strt_date
								,@date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as fl_cps_invs
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as fl_phys_abuse 
								, null as fl_sexual_abuse
								, null as fl_neglect
								, null as fl_any_legal
								, null as fl_founded_phys_abuse
								, null as fl_founded_sexual_abuse
								, null as fl_founded_neglect
								, null as fl_found_any_legal								
								, null as bin_ihs_svc_cd
								,2
								,'Total Added During Month'
								,1
						from ##poc3_unq  CE --opened between start & end and not already open on first day
						join  ##dates on date_type=@date_type
						where CE.ihs_begin_date
								between ##dates.strt_date  and ##dates.end_date

						union all
						select distinct
								 strt_date
								,@date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as fl_cps_invs
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as fl_phys_abuse   
								, null as fl_sexual_abuse
								, null as fl_neglect
								, null as fl_any_legal
								, null as fl_founded_phys_abuse
								, null as fl_founded_sexual_abuse
								, null as fl_founded_neglect
								, null as fl_found_any_legal								
								, null as bin_ihs_svc_cd
								,3
								, 'Total Closed During Month'
								,1
						from ##poc3_unq  CE -- closed between start & end and intake open
						join  ##dates on date_type=@date_type
						where CE.ihs_end_date
								between ##dates.strt_date and ##dates.end_date

	
						
/**************************************** FIRST EVER	 *******************************************************/
						set @qry_type=1;	 
						insert into ##Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type,fl_cps_invs
							,filter_access_type,filter_allegation,filter_finding,fl_phys_abuse
							,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse
							,fl_founded_neglect,fl_found_any_legal,bin_ihs_svc_cd,measure_int,measure_desc,cnt_distinct_Intakes)
						select  distinct
								strt_date
								,@date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as fl_cps_invs
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as fl_phys_abuse 
								, null as fl_sexual_abuse
								, null as fl_neglect
								, null as fl_any_legal
								, null as fl_founded_phys_abuse
								, null as fl_founded_sexual_abuse
								, null as fl_founded_neglect
								, null as fl_found_any_legal								
								, null as bin_ihs_svc_cd
								,1
								,'Total Open on First Day'
								,1
						from  ##poc3_frst CE -- start date prior to month start.. count if exited first day
						join  ##dates on date_type=@date_type
						where ce.ihs_begin_date < strt_date
							and (ce.ihs_end_date >=strt_date )
						union	
						select  distinct
								 strt_date
								,@date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as fl_cps_invs
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as fl_phys_abuse 
								, null as fl_sexual_abuse
								, null as fl_neglect
								, null as fl_any_legal
								, null as fl_founded_phys_abuse
								, null as fl_founded_sexual_abuse
								, null as fl_founded_neglect
								, null as fl_found_any_legal								
								, null as bin_ihs_svc_cd
								,2
								,'Total Added During Month'
								,1
						from ##poc3_frst  CE --opened between start & end and not already open on first day
						--left join ##Caseload CL on CL.id_case=ce.id_case
						--	and cl.qry_type=@qry_type
						--	and cl.date_type=@date_type
						--	and cl.period_start=@chstart
						--	and cl.measure_int = 1
						join  ##dates on date_type=@date_type
						where CE.ihs_begin_date
								between strt_date  and end_date
				
						union all
						select distinct
								 strt_date
								,@date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as fl_cps_invs
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as fl_phys_abuse 
								, null as fl_sexual_abuse
								, null as fl_neglect
								, null as fl_any_legal
								, null as fl_founded_phys_abuse
								, null as fl_founded_sexual_abuse
								, null as fl_founded_neglect
								, null as fl_found_any_legal								
								, null as bin_ihs_svc_cd
								,3
								, 'Total Closed During Month'
								,1
						from ##poc3_frst  CE -- closed between start & end and intake open
						join  ##dates on date_type=@date_type
						where CE.ihs_end_date
								between strt_date and end_date
	
					

	



/**************************************** --ALL	 *******************************************************/
						set @qry_type=2;		 
						insert into ##Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type,fl_cps_invs
							,filter_access_type,filter_allegation,filter_finding,fl_phys_abuse
							,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse
							,fl_founded_neglect,fl_found_any_legal,bin_ihs_svc_cd
							,fl_family_focused_services,fl_child_care,fl_therapeutic_services
							,fl_family_home_placements,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services
							,fl_respite,fl_transportation,fl_adoption_support,filter_service_type
							,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,filter_budget_type
							,measure_int,measure_desc,cnt_distinct_Intakes)
						select  
								  strt_date
								, @date_type
								, @qry_type
								, ce.id_case 
								, 0 -- ce.id_intake_Fact
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.fl_cps_invs
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.fl_phys_abuse 
								, ce.fl_sexual_abuse
								, ce.fl_neglect
								, ce.fl_any_legal
								, ce.fl_founded_phys_abuse
								, ce.fl_founded_sexual_abuse
								, ce.fl_founded_neglect
								, ce.fl_founded_any_legal								
								, ce.bin_ihs_svc_cd
								, max(case when ce.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
								, max(case when ce.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
								, max(case when ce.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
								, max(case when ce.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
								, max(case when ce.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
								, max(case when ce.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
								, max(case when ce.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
								, max(case when ce.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
								, max(case when ce.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
								, max(case when ce.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
								, cast(null as decimal(16,0))  as 	filter_service_type
								, max(case when ce.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
								, max(case when ce.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
								, max(case when ce.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
								, max(case when ce.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
								, max(case when ce.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
								, max(case when ce.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
								, max(case when ce.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
								, cast(null as decimal(16,0))  as 	filter_budget_type
								, 1
								,'Total Open on First Day'
								, count( distinct id_ihs_episode)
						from  ##poc3_all ce
						join  ##dates on date_type=@date_type
						where ce.ihs_begin_date < ##dates.strt_date
							and (ce.ihs_end_date >=##dates.strt_date )
						group by ce.id_case	
								, ##dates.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.fl_cps_invs
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.fl_phys_abuse 
								, ce.fl_sexual_abuse
								, ce.fl_neglect
								, ce.fl_any_legal
								, ce.fl_founded_phys_abuse
								, ce.fl_founded_sexual_abuse
								, ce.fl_founded_neglect
								, ce.fl_founded_any_legal
								, ce.bin_ihs_svc_cd
	

						
						insert into ##caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type,fl_cps_invs
							,filter_access_type,filter_allegation,filter_finding,fl_phys_abuse
							,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse
							,fl_founded_neglect,fl_found_any_legal,bin_ihs_svc_cd
							,fl_family_focused_services,fl_child_care,fl_therapeutic_services
							,fl_family_home_placements,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services
							,fl_respite,fl_transportation,fl_adoption_support,filter_service_type
							,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,filter_budget_type
							,measure_int,measure_desc,cnt_distinct_Intakes)
						select  --distinct
								strt_date
								, @date_type
								, @qry_type
								, ce.id_case 
								, 0 -- ce.id_intake_Fact
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.fl_cps_invs
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.fl_phys_abuse 
								, ce.fl_sexual_abuse
								, ce.fl_neglect
								, ce.fl_any_legal
								, ce.fl_founded_phys_abuse
								, ce.fl_founded_sexual_abuse
								, ce.fl_founded_neglect
								, ce.fl_founded_any_legal								
								, ce.bin_ihs_svc_cd
								, max(case when ce.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
								, max(case when ce.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
								, max(case when ce.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
								, max(case when ce.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
								, max(case when ce.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
								, max(case when ce.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
								, max(case when ce.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
								, max(case when ce.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
								, max(case when ce.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
								, max(case when ce.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
								, cast(null as decimal(16,0))  as 	filter_service_type
								, max(case when ce.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
								, max(case when ce.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
								, max(case when ce.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
								, max(case when ce.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
								, max(case when ce.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
								, max(case when ce.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
								, max(case when ce.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
								, cast(null as decimal(16,0))  as 	filter_budget_type
								,2
								,'Total Added During Month'
								, count( distinct id_ihs_episode)
						from  ##poc3_all ce
						join  ##dates on date_type=@date_type
						where CE.ihs_begin_date
								between ##dates.strt_date  and ##dates.end_date
						group by ce.id_case	
								, ##dates.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.fl_cps_invs
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.fl_phys_abuse 
								, ce.fl_sexual_abuse
								, ce.fl_neglect
								, ce.fl_any_legal
								, ce.fl_founded_phys_abuse
								, ce.fl_founded_sexual_abuse
								, ce.fl_founded_neglect
								, ce.fl_founded_any_legal
								, ce.bin_ihs_svc_cd
						
	
						
						insert into ##caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type,fl_cps_invs
							,filter_access_type,filter_allegation,filter_finding,fl_phys_abuse
							,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse
							,fl_founded_neglect,fl_found_any_legal,bin_ihs_svc_cd
							,fl_family_focused_services,fl_child_care,fl_therapeutic_services
							,fl_family_home_placements,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services
							,fl_respite,fl_transportation,fl_adoption_support,filter_service_type
							,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,filter_budget_type
							,measure_int,measure_desc,cnt_distinct_Intakes)
						select  --distinct
								strt_date
								, @date_type
								, @qry_type
								, ce.id_case 
								, 0 -- ce.id_intake_Fact
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.fl_cps_invs
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.fl_phys_abuse 
								, ce.fl_sexual_abuse
								, ce.fl_neglect
								, ce.fl_any_legal
								, ce.fl_founded_phys_abuse
								, ce.fl_founded_sexual_abuse
								, ce.fl_founded_neglect
								, ce.fl_founded_any_legal								
								, ce.bin_ihs_svc_cd
								, max(case when ce.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
								, max(case when ce.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
								, max(case when ce.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
								, max(case when ce.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
								, max(case when ce.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
								, max(case when ce.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
								, max(case when ce.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
								, max(case when ce.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
								, max(case when ce.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
								, max(case when ce.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
								, cast(null as decimal(16,0))  as 	filter_service_type
								, max(case when ce.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
								, max(case when ce.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
								, max(case when ce.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
								, max(case when ce.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
								, max(case when ce.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
								, max(case when ce.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
								, max(case when ce.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
								, cast(null as decimal(16,0))  as 	filter_budget_type
								, 3
								, 'Total Closed During Month'
								, count( distinct id_ihs_episode)
						from  ##poc3_all ce
						join  ##dates on date_type=@date_type
						where CE.ihs_end_date
								between ##dates.strt_date and ##dates.end_date
						group by ce.id_case	
								, ##dates.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.fl_cps_invs
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.fl_phys_abuse 
								, ce.fl_sexual_abuse
								, ce.fl_neglect
								, ce.fl_any_legal
								, ce.fl_founded_phys_abuse
								, ce.fl_founded_sexual_abuse
								, ce.fl_founded_neglect
								, ce.fl_founded_any_legal
								, ce.bin_ihs_svc_cd

			    update CL
				set filter_service_type=power(10.0,16)  + 
									(power(10.0,15) *   fl_family_focused_services)
									+ (power(10.0,14) * fl_child_care )
									+ (power(10.0,13) * fl_therapeutic_services  )
									+ (power(10.0,10) * fl_family_home_placements)
									+ (power(10.0,9) *  fl_behavioral_rehabiliation_services )
									+ (power(10.0,8) *  fl_other_therapeutic_living_situations )
									+ (power(10.0,7) *  fl_specialty_adolescent_services  )
									+ (power(10.0,6) *  fl_respite )
									+ (power(10,5) *    fl_transportation	 )
									+ (power(10,2) *    fl_adoption_support )
				from ##Caseload CL
				where filter_service_type is null 
						
			    update CL
				set filter_budget_type=power(10.0,7) + (power(10.0,6) * fl_budget_C12)+ (power(10.0,5) * fl_budget_C14)+ (power(10.0,4) * fl_budget_C15)
									+ (power(10.0,3) * fl_budget_C16) + (power(10.0,2) * fl_budget_C18)  + (power(10.0,1) * fl_budget_C19) + (power(10,0) * fl_uncat_svc)

				from ##Caseload CL
				where filter_budget_type  is null ;						
						
			-- update for more than one demographic/office/county per id_case in a cohort period 
				update CL
				set  cd_race=r.cd_race_census_hh
					, census_hispanic_latino_origin_cd=r.census_hispanic_latino_origin_cd_hh
					, cd_office_collapse=r.cd_office_collapse
					, cd_sib_age_grp=r.cd_sib_age_grp
					, int_match_param_key=r.int_match_param_key
					, cd_reporter_type=r.cd_reporter
					, fl_cps_invs = r.fl_cps_invs
					, filter_access_type = r.filter_access_type
					, filter_allegation = r.filter_allegation
					, filter_finding=r.filter_finding
					, fl_phys_abuse =r.fl_phys_abuse
					, fl_sexual_abuse = r.fl_sexual_abuse
					, fl_neglect= r.fl_neglect
					, fl_any_legal=r.fl_any_legal
					, fl_founded_phys_abuse=r.fl_founded_phys_abuse
					, fl_founded_sexual_abuse=r.fl_founded_sexual_abuse
					, fl_founded_neglect=r.fl_founded_neglect
					, fl_found_any_legal=r.fl_founded_any_legal
					, bin_ihs_svc_cd=r.bin_ihs_svc_cd
					, fl_family_focused_services=r.fl_family_focused_services
					, fl_child_care=r.fl_child_care
					, fl_therapeutic_services = r.fl_therapeutic_services
					, fl_family_home_placements = r.fl_family_home_placements
					, fl_behavioral_rehabiliation_services=r.fl_behavioral_rehabiliation_services
					, fl_other_therapeutic_living_situations=r.fl_other_therapeutic_living_situations
					, fl_specialty_adolescent_services=r.fl_specialty_adolescent_services
					, fl_respite=r.fl_respite
					, fl_transportation=r.fl_transportation
					, fl_adoption_support	=r.fl_adoption_support
					, filter_service_type=r.filter_service_type
					, fl_budget_C12=r.fl_budget_C12
					, fl_budget_C14=r.fl_budget_C14
					, fl_budget_C15=r.fl_budget_C15
					, fl_budget_C16=r.fl_budget_C16
					, fl_budget_C18=r.fl_budget_C18
					, fl_budget_C19=r.fl_budget_C19
					, fl_uncat_svc=r.fl_uncat_svc
					, filter_budget_type=r.filter_budget_type
				from ##Caseload CL
				left join  (
							select q.*, ROW_NUMBER() over (partition by strt_date,q.id_case 
										order by bin_ihs_svc_cd asc   
											,q.ihs_begin_date desc,ihs_end_date desc) as row_num
							from (
							select strt_date
									, end_date
									, ihs_begin_date
									, ihs_end_date
									, date_type
									, p3.id_case  
									, p3.cd_race_census_hh
									, p3.census_hispanic_latino_origin_cd_hh
									, p3.cd_office_collapse
									, p3.cd_sib_age_grp
									, p3.cd_reporter
									, p3.fl_cps_invs
									, p3.int_match_param_key
									, filter_access_type
									, filter_allegation
									, filter_finding
									, p3.fl_phys_abuse 
									, p3.fl_sexual_abuse
									, p3.fl_neglect
									, fl_any_legal
									, p3.fl_founded_phys_abuse
									, p3.fl_founded_sexual_abuse
									, p3.fl_founded_neglect
									, p3.fl_founded_any_legal	
									, p3.bin_ihs_svc_cd
									, max(case when p3.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
									, max(case when p3.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
									, max(case when p3.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
									, max(case when p3.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
									, max(case when p3.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
									, max(case when p3.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
									, max(case when p3.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
									, max(case when p3.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
									, max(case when p3.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
									, max(case when p3.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
									, power(10.0,16)  + 
									  (power(10.0,15) *   max(case when p3.cd_subctgry_poc_frc=1 then 1 else 0 end))
									+ (power(10.0,14) * max(case when p3.cd_subctgry_poc_frc=2 then 1 else 0 end))
									+ (power(10.0,13) * max(case when p3.cd_subctgry_poc_frc=3 then 1 else 0 end))
									+ (power(10.0,10) * max(case when p3.cd_subctgry_poc_frc=6 then 1 else 0 end))
									+ (power(10.0,9) *  max(case when p3.cd_subctgry_poc_frc=7 then 1 else 0 end))
									+ (power(10.0,8) *  max(case when p3.cd_subctgry_poc_frc=8 then 1 else 0 end))
									+ (power(10.0,7) *  max(case when p3.cd_subctgry_poc_frc=9 then 1 else 0 end))
									+ (power(10.0,6) *  max(case when p3.cd_subctgry_poc_frc=10 then 1 else 0 end))
									+ (power(10,5) *    max(case when p3.cd_subctgry_poc_frc=11 then 1 else 0 end))
									+ (power(10,2) *    max(case when p3.cd_subctgry_poc_frc=14 then 1 else 0 end))  as 	filter_service_type
									, max(case when p3.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
									, max(case when p3.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
									, max(case when p3.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
									, max(case when p3.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
									, max(case when p3.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
									, max(case when p3.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
									, max(case when p3.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
									, power(10.0,7) + (power(10.0,6) * max(case when p3.cd_budget_poc_frc=12 then 1 else 0 end))+ (power(10.0,5) * max(case when p3.cd_budget_poc_frc=14 then 1 else 0 end))+ (power(10.0,4) * max(case when p3.cd_budget_poc_frc=15 then 1 else 0 end))
									+ (power(10.0,3) * max(case when p3.cd_budget_poc_frc=16 then 1 else 0 end)) + (power(10.0,2) * max(case when p3.cd_budget_poc_frc=18 then 1 else 0 end))  + (power(10.0,1) * max(case when p3.cd_budget_poc_frc=19 then 1 else 0 end)) + (power(10,0) * max(case when p3.cd_budget_poc_frc=99 then 1 else 0 end))  as 	filter_budget_type
									--	, p3.id_ihs_episode
						from  ##poc3_all p3
						join  ##dates on date_type=@date_type
								where p3.ihs_begin_date <=##dates.end_date
									and p3.ihs_end_date >= ##dates.strt_date
						group by strt_date
									, end_date
									, ihs_begin_date
									, ihs_end_date
									, srvc_dt_begin
									, srvc_dt_end
									, date_type
									, p3.id_case  
									, p3.cd_race_census_hh
									, p3.census_hispanic_latino_origin_cd_hh
									, p3.cd_office_collapse
									, p3.cd_sib_age_grp
									, p3.cd_reporter
									, p3.fl_cps_invs
									, p3.int_match_param_key
									, filter_access_type
									, filter_allegation
									, filter_finding
									, p3.fl_phys_abuse 
									, p3.fl_sexual_abuse
									, p3.fl_neglect
									, fl_any_legal
									, p3.fl_founded_phys_abuse
									, p3.fl_founded_sexual_abuse
									, p3.fl_founded_neglect
									, p3.fl_founded_any_legal	
									, p3.bin_ihs_svc_cd
										) q  
								) r on r.row_num=1  
								and CL.period_start=r.strt_date
										and cl.date_type=r.date_type
										and cl.id_case=r.id_case
								where cl.cd_race is null
								and cl.cd_office_collapse is null
								and cl.cd_sib_age_grp is null
								and cl.cd_reporter_type is null
								and cl.filter_access_type is null
								and cl.filter_allegation is null
								and cl.filter_finding is null
								and cl.filter_service_type is null
								and cl.bin_ihs_svc_cd is null	
								
								
								
										
		set @date_type=@date_type + 2;
		set @chstart=@start_date;
	end		--@date_type <=2		
	
	

	--CREATE NONCLUSTERED INDEX idx_tmp_caseload
	--	ON ##Caseload([fl_child_care])
	--	INCLUDE ([qry_type],[measure_int])

	--	select bin_ihs_svc_cd,qry_type,date_type,count(*)  from ##Caseload 
	--	group by  bin_ihs_svc_cd,qry_type,date_type

	
--/*************  insert into table ************************************************************************/


	truncate table prtl.prtl_poc3ab;
	INSERT INTO [prtl].[prtl_poc3ab]
           ([qry_type]
           ,[date_type]
           ,[start_date]
           ,[start_year]
           ,[int_match_param_key]
           ,[bin_ihs_svc_cd]
           ,[cd_reporter_type]
           ,[fl_cps_invs]
           ,[filter_access_type]
           ,[filter_allegation]
           ,[filter_finding]
           ,[filter_service_type]
		   ,filter_budget_type
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
           ,[fl_family_home_placements]
           ,[fl_behavioral_rehabiliation_services]
           ,[fl_other_therapeutic_living_situations]
           ,[fl_specialty_adolescent_services]
           ,[fl_respite]
           ,[fl_transportation]
           ,[fl_adoption_support]
			,fl_budget_C12
		   ,fl_budget_C14
		   , fl_budget_C15
		   , fl_budget_C16
		   , fl_budget_C18
		   , fl_budget_C19
		   , fl_uncat_svc
           ,[cd_sib_age_group]
           ,[cd_race_census]
           ,[census_hispanic_latino_origin_cd]
           ,[cd_office]
           ,[cnt_start_date]
           ,[cnt_opened]
           ,[cnt_closed])
      
		 select distinct 
				qry_type
				,date_type
				,period_start
				,year(period_start)
           ,[int_match_param_key]
           ,[bin_ihs_svc_cd]
           ,[cd_reporter_type]
           ,[fl_cps_invs]
           ,[filter_access_type]
           ,[filter_allegation]
           ,[filter_finding]
           ,[filter_service_type]
		   , filter_budget_type
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
           ,[fl_family_home_placements]
           ,[fl_behavioral_rehabiliation_services]
           ,[fl_other_therapeutic_living_situations]
           ,[fl_specialty_adolescent_services]
           ,[fl_respite]
           ,[fl_transportation]
           ,[fl_adoption_support]
		   ,fl_budget_C12
		   ,fl_budget_C14
		   , fl_budget_C15
		   , fl_budget_C16
		   , fl_budget_C18
		   , fl_budget_C19
		   , fl_uncat_svc
           ,[cd_sib_age_grp]
           ,[cd_race]
           ,[census_hispanic_latino_origin_cd]
           ,[cd_office_collapse]
				,0
				,0
				,0
		 from ##caseload
		
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON ##Caseload([measure_int])
INCLUDE ([period_start],[date_type],[qry_type],[int_match_param_key],[cd_reporter_type],[filter_access_type],[filter_allegation],[filter_finding],[bin_ihs_svc_cd],[filter_service_type],[filter_budget_type],[cnt_distinct_Intakes])

CREATE NONCLUSTERED INDEX idx_tmp2_casework
on ##Caseload ([period_start],[date_type],[qry_type],[int_match_param_key],[cd_reporter_type],[filter_access_type],[filter_allegation],[filter_finding],[bin_ihs_svc_cd],[filter_service_type],[filter_budget_type],[measure_int])
INCLUDE ([cnt_distinct_Intakes])

	update prtl.prtl_poc3ab
	set cnt_start_date=cnt
	from (select [qry_type]
		  , [date_type]
		  , [period_start]
		  , int_match_param_key
		  , cl.bin_ihs_svc_cd
		  , cl.cd_reporter_type
		  , cl.filter_access_type
		  , cl.filter_allegation
		  , cl.filter_finding
		  , cl.filter_service_type
		  , cl.filter_budget_type
		  , sum(cnt_distinct_Intakes) as cnt 
		 from ##caseLoad cl
		 where measure_int=1
		 group by[qry_type]
		  ,[date_type]
		  ,[period_start]
		  ,int_match_param_key
		  , cl.bin_ihs_svc_cd
		  ,cl.cd_reporter_type
		  ,cl.filter_access_type
		  ,cl.filter_allegation
		  ,cl.filter_finding
		  , cl.filter_service_type
		  , cl.filter_budget_type
		 ) q
	where q.qry_type=prtl_poc3ab.qry_type
		and q.[date_type]=prtl_poc3ab.[date_type]
		and q.[period_start]=prtl_poc3ab.start_date
		and q.int_match_param_key=prtl_poc3ab.int_match_param_key
		and q.bin_ihs_svc_cd= prtl_poc3ab.bin_ihs_svc_cd
		and q.cd_reporter_type=prtl_poc3ab.cd_reporter_type
		and q.filter_access_type=prtl_poc3ab.filter_access_type
		and q.filter_allegation=prtl_poc3ab.filter_allegation
		and q.filter_finding=prtl_poc3ab.filter_finding
		and q.filter_service_type=prtl_poc3ab.filter_service_type	
		and q.filter_budget_type=prtl_poc3ab.filter_budget_type


  	update prtl.prtl_poc3ab
	set cnt_opened=cnt
	from (select [qry_type]
		  ,[date_type]
		  ,[period_start]
		  ,int_match_param_key
		  ,cl.cd_reporter_type
		  , cl.bin_ihs_svc_cd
		  ,cl.filter_access_type
		  ,cl.filter_allegation
		  ,cl.filter_finding
 		  , cl.filter_service_type
		  , cl.filter_budget_type
		 ,sum(cnt_distinct_Intakes) as cnt 
		 from ##caseLoad cl
		 where measure_int=2
		 group by[qry_type]
		  ,[date_type]
		  ,[period_start]
		  ,int_match_param_key
		  ,cl.cd_reporter_type
		  ,cl.bin_ihs_svc_cd
		  ,cl.filter_access_type
		  ,cl.filter_allegation
		  ,cl.filter_finding
 		  , cl.filter_service_type
		  , cl.filter_budget_type
		 ) q
	where q.qry_type=prtl_poc3ab.qry_type
		and q.[date_type]=prtl_poc3ab.[date_type]
		and q.[period_start]=prtl_poc3ab.start_date
		and q.int_match_param_key=prtl_poc3ab.int_match_param_key
		and q.bin_ihs_svc_cd=prtl_poc3ab.bin_ihs_svc_cd
		and q.cd_reporter_type=prtl_poc3ab.cd_reporter_type
		and q.filter_access_type=prtl_poc3ab.filter_access_type
		and q.filter_allegation=prtl_poc3ab.filter_allegation
		and q.filter_finding=prtl_poc3ab.filter_finding
		and q.filter_service_type=prtl_poc3ab.filter_service_type
		and q.filter_budget_type=prtl_poc3ab.filter_budget_type

  	update prtl.prtl_poc3ab
	set cnt_closed=cnt
	from (select [qry_type]
		  ,[date_type]
		  ,[period_start]
		  ,int_match_param_key
		  ,cl.bin_ihs_svc_cd
		  ,cl.cd_reporter_type
		  ,cl.filter_access_type
		  ,cl.filter_allegation
		  ,cl.filter_finding
 		  , cl.filter_service_type
		  , cl.filter_budget_type
		 ,sum(cnt_distinct_Intakes) as cnt 
		 from ##caseLoad cl
		 where measure_int=3
		 group by[qry_type]
		  ,[date_type]
		  ,[period_start]
		  ,int_match_param_key
		  ,cl.bin_ihs_svc_cd
		  ,cl.cd_reporter_type
		  ,cl.filter_access_type
		  ,cl.filter_allegation
		  ,cl.filter_finding
 		  , cl.filter_service_type
		  , cl.filter_budget_type
		 ) q
	where q.qry_type=prtl_poc3ab.qry_type
		and q.[date_type]=prtl_poc3ab.[date_type]
		and q.[period_start]=prtl_poc3ab.start_date
		and q.int_match_param_key=prtl_poc3ab.int_match_param_key
		and q.bin_ihs_svc_cd=prtl_poc3ab.bin_ihs_svc_cd
		and q.cd_reporter_type=prtl_poc3ab.cd_reporter_type
		and q.filter_access_type=prtl_poc3ab.filter_access_type
		and q.filter_allegation=prtl_poc3ab.filter_allegation
		and q.filter_finding=prtl_poc3ab.filter_finding			
		and q.filter_service_type=prtl_poc3ab.filter_service_type
		and q.filter_budget_type=prtl_poc3ab.filter_budget_type	

		update statistics prtl.prtl_poc3ab;
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_poc3ab)
	  where tbl_id=3;	

	
	end
else 
	begin
	select  'This procedure BUILDS COHORTS!  Need permission key to execute'  as [Warning]
	
	end
	
	


GO
