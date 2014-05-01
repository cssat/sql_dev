USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_poc3ab]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter procedure [prtl].[prod_build_prtl_poc3ab](@permission_key datetime)
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
		set @chend = (select distinct dateadd(dd,-1,[quarter]) from dbo.CALENDAR_DIM where @cutoff_date = CALENDAR_DATE)


			if OBJECT_ID('tempDB..##dates') is not null drop table ##dates;
			create table ##dates(strt_date datetime,end_date datetime,date_type int,primary key(strt_date,date_type))
			
			insert into ##dates 
			select distinct [quarter] as strt_date,dateadd(dd,-1,dateadd(mm,3,([quarter]))) [end_date],1 [date_type]
			from calendar_dim
			where [quarter] between @chstart and @chend  

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
					, power(10,6) 
						+ (ce.cd_sib_age_grp * power(10,5))
						+ (ce.cd_race_census_hh * power(10,4))
						+ (ce.census_hispanic_latino_origin_cd_hh * power(10,3))
						+ (abs(xwlk.cd_office_collapse) * 1) [int_match_param_key]
					, coalesce(rpt.collapsed_cd_reporter_type,-99) as cd_reporter
					, si.fl_cps_invs
					, si.fl_alternate_intervention
					, si.fl_risk_only
					, si.fl_frs
					, si.fl_cfws
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
				 join  dbo.ref_xwalk_cd_office_dcfs xwlk on xwlk.cd_office=ce.cd_office
						join dbo.vw_intakes_screened_in si on si.id_intake_fact=ce.id_intake_fact
						 join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter	




				
			if OBJECT_ID('tempDB..##Caseload') is not null drop table ##Caseload;
			create table ##Caseload (
					  period_start datetime
					, date_type int
					, qry_type int
					, id_case int
					, id_intake_fact int
					, cd_race int
					, census_hispanic_latino_origin_cd int
					, cd_office_collapse int
					, cd_sib_age_grp int
					, int_match_param_key int
					, cd_reporter_type int
					, bin_ihs_svc_cd int
					, filter_access_type int
					, filter_allegation int
					, filter_finding int
					, filter_service_category decimal(22,0)
					, filter_service_budget decimal(16,0)
					, measure_int int
					, measure_desc varchar(50)
					, cnt_distinct_Intakes int
				)		
		

						
/**************************************** UNIQUE	 *******************************************************/
						set @qry_type=0;
						
						insert into ##Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type,
							filter_access_type,filter_allegation,filter_finding,
							bin_ihs_svc_cd,measure_int,measure_desc,cnt_distinct_Intakes)
						select  distinct
								  strt_date
								, d.date_type
								, @qry_type
								, ce.id_case 
								, 0
								, null -- ce.fam_cd_race_census
								, null -- census_hispanic_latino_origin_cd
								, null -- ce.cd_office_collapse
								, null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
									, null as bin_ihs_svc_cd
								,1
								,'Total Open on First Day'
								,1
						from ##poc3_unq ce  
						,  ##dates  d
						where ce.ihs_begin_date < strt_date
							and (ce.ihs_end_date >=strt_date )
						union all
						select  distinct
								 strt_date
								,d.date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as bin_ihs_svc_cd
								,2
								,'Total Added During Month'
								,1
						from ##poc3_unq  CE --opened between start & end and not already open on first day
					,  ##dates  d
						where CE.ihs_begin_date
								between d.strt_date  and d.end_date

						union all
						select distinct
								 strt_date
								,d.date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as bin_ihs_svc_cd
								,3
								, 'Total Closed During Month'
								,1
						from ##poc3_unq  CE -- closed between start & end and intake open
						,  ##dates  d
						where CE.ihs_end_date
								between d.strt_date and d.end_date

	
						
/**************************************** FIRST EVER	 *******************************************************/
						set @qry_type=1;	 
						insert into ##Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type
							,filter_access_type,filter_allegation,filter_finding,bin_ihs_svc_cd,measure_int,measure_desc,cnt_distinct_Intakes)
						select  distinct
								strt_date
								,d.date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as bin_ihs_svc_cd
								,1
								,'Total Open on First Day'
								,1
						from  ##poc3_frst CE -- start date prior to month start.. count if exited first day
						,  ##dates  d
						where ce.ihs_begin_date < strt_date
							and (ce.ihs_end_date >=strt_date )
						union	
						select  distinct
								 strt_date
								,d.date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
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
						,  ##dates  d
						where CE.ihs_begin_date
								between strt_date  and end_date
				
						union all
						select distinct
								 strt_date
								,d.date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.cd_office_collapse
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as bin_ihs_svc_cd
								,3
								, 'Total Closed During Month'
								,1
						from ##poc3_frst  CE -- closed between start & end and intake open
						,  ##dates  d
						where CE.ihs_end_date
								between strt_date and end_date
	

/**************************************** --ALL	 *******************************************************/
						set @qry_type=2;		 
						insert into ##Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type
							,filter_access_type,filter_allegation,filter_finding,bin_ihs_svc_cd
							,filter_service_category
							,filter_service_budget
							,measure_int,measure_desc,cnt_distinct_Intakes)
						select  
								  strt_date
								, d.date_type
								, @qry_type
								, ce.id_case 
								, 0 -- ce.id_intake_Fact
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation 
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
								, cast(power(10.0,16) --   fl_family_focused_services
									+ max(IIF(ce.cd_subctgry_poc_frc=1 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=2 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=3 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=6 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=7 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=8, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=9, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=10 , 1 * svc.multiplier , 0 ) )
									+  max(IIF(ce.cd_subctgry_poc_frc=11, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=14, 1 * svc.multiplier , 0 ) ) as decimal(22,0)) [filter_service_category]
							, cast(power(10.0,7) --   buget  
									+ max(IIF(ce.cd_budget_poc_frc=12  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=14  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=15 , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=16  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=18  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=19  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=99  , 1 * bud.multiplier , 0 ) )  as decimal(9,0)) [filter_service_budget]
								, 1
								,'Total Open on First Day'
								, count( distinct id_ihs_episode)
						from  ##poc3_all ce
						join   ##dates  d on ce.ihs_begin_date < d.strt_date
							and (ce.ihs_end_date >=d.strt_date )
						left join ref_service_cd_subctgry_poc svc on svc.cd_subctgry_poc_frc=ce.cd_subctgry_poc_frc
						left join ref_service_cd_budget_poc_frc bud on bud.cd_budget_poc_frc=ce.cd_budget_poc_frc
					group by ce.id_case	
								,d.date_type
								, d.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
						
	

						
						insert into ##caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type
							,filter_access_type,filter_allegation,filter_finding,bin_ihs_svc_cd
							,filter_service_category
							,filter_service_budget
							,measure_int,measure_desc,cnt_distinct_Intakes)
						select  --distinct
								strt_date
								, d.date_type
								, @qry_type
								, ce.id_case 
								, 0 -- ce.id_intake_Fact
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
								, cast(power(10.0,16) --   fl_family_focused_services
									+ max(IIF(ce.cd_subctgry_poc_frc=1 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=2 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=3 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=6 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=7 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=8, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=9, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=10 , 1 * svc.multiplier , 0 ) )
									+  max(IIF(ce.cd_subctgry_poc_frc=11, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=14, 1 * svc.multiplier , 0 ) ) as decimal(22,0)) [filter_service_category]
							, cast(power(10.0,7) --   buget  
									+ max(IIF(ce.cd_budget_poc_frc=12  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=14  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=15 , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=16  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=18  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=19  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=99  , 1 * bud.multiplier , 0 ) )  as decimal(9,0)) [filter_service_budget]
								,2
								,'Total Added During Month'
								, count( distinct id_ihs_episode)
						from  ##poc3_all ce
						join  ##dates  d  on CE.ihs_begin_date
								between d.strt_date  and d.end_date
						left join ref_service_cd_subctgry_poc svc on svc.cd_subctgry_poc_frc=ce.cd_subctgry_poc_frc
						left join ref_service_cd_budget_poc_frc bud on bud.cd_budget_poc_frc=ce.cd_budget_poc_frc
						group by d.date_type
								, ce.id_case	
								, d.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
						
	
						
						insert into ##caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type
							,filter_access_type,filter_allegation,filter_finding,bin_ihs_svc_cd
							,filter_service_category
							,filter_service_budget
							,measure_int,measure_desc,cnt_distinct_Intakes)
						select  --distinct
								strt_date
								, d.date_type
								, @qry_type
								, ce.id_case 
								, 0 -- ce.id_intake_Fact
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
								, cast(power(10.0,16) --   fl_family_focused_services
									+ max(IIF(ce.cd_subctgry_poc_frc=1 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=2 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=3 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=6 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=7 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=8, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=9, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=10 , 1 * svc.multiplier , 0 ) )
									+  max(IIF(ce.cd_subctgry_poc_frc=11, 1 * svc.multiplier , 0 ) )
									+ max(IIF(ce.cd_subctgry_poc_frc=14, 1 * svc.multiplier , 0 ) ) as decimal(22,0)) [filter_service_category]
							, cast(power(10.0,7) --   buget  
									+ max(IIF(ce.cd_budget_poc_frc=12  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=14  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=15 , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=16  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=18  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=19  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(ce.cd_budget_poc_frc=99  , 1 * bud.multiplier , 0 ) )  as decimal(9,0)) [filter_service_budget]
								, 3
								, 'Total Closed During Month'
								, count( distinct id_ihs_episode)
						from  ##poc3_all ce
						join  ##dates  d
						 on  CE.ihs_end_date
								between d.strt_date and d.end_date
						left join ref_service_cd_subctgry_poc svc on svc.cd_subctgry_poc_frc=ce.cd_subctgry_poc_frc
						left join ref_service_cd_budget_poc_frc bud on bud.cd_budget_poc_frc=ce.cd_budget_poc_frc
						group by  d.date_type,ce.id_case	
								, d.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.cd_office_collapse
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd

			   	
			-- update for more than one demographic/office/county per id_case in a cohort period 
				update CL
				set  cd_race=r.cd_race_census_hh
					, census_hispanic_latino_origin_cd=r.census_hispanic_latino_origin_cd_hh
					, cd_office_collapse=r.cd_office_collapse
					, cd_sib_age_grp=r.cd_sib_age_grp
					, int_match_param_key=r.int_match_param_key
					, cd_reporter_type=r.cd_reporter
					, filter_access_type = r.filter_access_type
					, filter_allegation = r.filter_allegation
					, filter_finding=r.filter_finding
					, bin_ihs_svc_cd=r.bin_ihs_svc_cd
					, filter_service_category=r.filter_service_category
				, filter_service_budget=r.filter_service_budget
				from ##Caseload CL
				left join  (
							select q.*, ROW_NUMBER() over (partition by strt_date,date_type,q.id_case 
										order by bin_ihs_svc_cd asc   
											,q.ihs_begin_date desc,ihs_end_date desc) as row_num
							from (
							select strt_date
									, end_date
									, ihs_begin_date
									, ihs_end_date
									, d.date_type
									, p3.id_case  
									, p3.cd_race_census_hh
									, p3.census_hispanic_latino_origin_cd_hh
									, p3.cd_office_collapse
									, p3.cd_sib_age_grp
									, p3.cd_reporter
									, p3.int_match_param_key
									, filter_access_type
									, filter_allegation
									, filter_finding
									, p3.bin_ihs_svc_cd
								, cast(power(10.0,16) --   fl_family_focused_services
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=1 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=2 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=3 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=6 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=7 , 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=8, 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=9, 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=10 , 1 * svc.multiplier , 0 ) )
									+  max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=11, 1 * svc.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_subctgry_poc_frc,0)=14, 1 * svc.multiplier , 0 ) ) as decimal(22,0)) [filter_service_category]
							, cast(power(10.0,7) --   buget  
									+ max(IIF(isnull(p3.cd_budget_poc_frc,0)=12  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_budget_poc_frc,0)=14  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_budget_poc_frc,0)=15 , 1 * bud.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_budget_poc_frc,0)=16  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_budget_poc_frc,0)=18  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_budget_poc_frc,0)=19  , 1 * bud.multiplier , 0 ) )
									+ max(IIF(isnull(p3.cd_budget_poc_frc,0)=99  , 1 * bud.multiplier , 0 ) )  as decimal(9,0)) [filter_service_budget]
									--	, p3.id_ihs_episode
						from  ##poc3_all p3
						join  ##dates  d
								on p3.ihs_begin_date <=d.end_date
									and p3.ihs_end_date >= d.strt_date
						left join ref_service_cd_subctgry_poc svc on svc.cd_subctgry_poc_frc=p3.cd_subctgry_poc_frc
						left join ref_service_cd_budget_poc_frc bud on bud.cd_budget_poc_frc=p3.cd_budget_poc_frc
						group by d.date_type,strt_date
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
									, p3.int_match_param_key
									, filter_access_type
									, filter_allegation
									, filter_finding
									, p3.bin_ihs_svc_cd
										) q  
								) r on r.row_num=1  
								and CL.period_start=r.strt_date
										and cl.date_type=r.date_type
										and cl.id_case=r.id_case
								where cl.int_match_param_key is null
								
											
		
	--	set @date_type=@date_type + 2;
	--	set @chstart=@start_date;
	--end		--@date_type <=2		
	
	

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
           ,[filter_access_type]
           ,[filter_allegation]
           ,[filter_finding]
           ,[filter_service_category]
		   ,filter_service_budget
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
           ,[filter_access_type]
           ,[filter_allegation]
           ,[filter_finding]
           ,[filter_service_category]
		   , filter_service_budget
           ,[cd_sib_age_grp]
           ,[cd_race]
           ,[census_hispanic_latino_origin_cd]
           ,[cd_office_collapse]
				,0
				,0
				,0
		 from ##caseload
		
CREATE NONCLUSTERED INDEX idx_pk45
ON ##Caseload([measure_int])
INCLUDE ([period_start],[date_type],[qry_type],[int_match_param_key],[cd_reporter_type],[filter_access_type],[filter_allegation],[filter_finding],[bin_ihs_svc_cd],[filter_service_category],[filter_service_budget],[cnt_distinct_Intakes])

CREATE NONCLUSTERED INDEX idx_tmp2_casework
on ##Caseload ([period_start],[date_type],[qry_type],[int_match_param_key],[cd_reporter_type],[filter_access_type],[filter_allegation],[filter_finding],[bin_ihs_svc_cd],[filter_service_category],[filter_service_budget],[measure_int])
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
		  , cl.filter_service_category
		  , cl.filter_service_budget
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
		  , cl.filter_service_category
		  , cl.filter_service_budget
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
		and q.filter_service_category=prtl_poc3ab.filter_service_category	
		and q.filter_service_budget=prtl_poc3ab.filter_service_budget


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
 		  , cl.filter_service_category
		  , cl.filter_service_budget
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
 		  , cl.filter_service_category
		  , cl.filter_service_budget
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
		and q.filter_service_category=prtl_poc3ab.filter_service_category
		and q.filter_service_budget=prtl_poc3ab.filter_service_budget

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
 		  , cl.filter_service_category
		  , cl.filter_service_budget
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
 		  , cl.filter_service_category
		  , cl.filter_service_budget
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
		and q.filter_service_category=prtl_poc3ab.filter_service_category
		and q.filter_service_budget=prtl_poc3ab.filter_service_budget	

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
