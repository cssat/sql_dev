
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
		set @chend = (select distinct dateadd(dd,-1,[quarter]) from dbo.CALENDAR_DIM where @cutoff_date = CALENDAR_DATE)


			if OBJECT_ID('tempDB..#dates') is not null drop table #dates;
			create table #dates(strt_date datetime,end_date datetime,date_type int,primary key(strt_date,date_type))
			
			insert into #dates 
			select distinct [quarter] as strt_date,dateadd(dd,-1,dateadd(mm,3,([quarter]))) [end_date],1 [date_type]
			from calendar_dim
			where [quarter] between @chstart and @chend  

			insert into #dates
			select distinct [Year],dateadd(dd,-1,dateadd(yy,1,[Year])),2 from calendar_dim
			where [year] between @chstart and (select end_date from [dbo].[ref_last_month_qtr_yr] where date_type=2)

		

		--unique temp table
			if object_id('tempDB..#poc3_unq') is not null drop table #poc3_unq;
			select DISTINCT ihs.id_case,(ihs_begin_date),(ihs_end_date)
					,cast(null as int) as ihs_sort
			into #poc3_unq
			from base.tbl_ihs_episodes ihs
			where fl_first_IHS_after_intake = 1;
	

			update poc3
			set ihs_sort=q.ihs_sort
			from #poc3_unq poc3
			join (select  id_case
						, ihs_begin_date
						, ihs_end_date
						, row_number() 
							over  (partition by id_case order by id_case, ihs_begin_date,ihs_end_date asc)
								as ihs_sort
				  from #poc3_unq) q 
					on q.id_case=poc3.id_case 
					and q.ihs_begin_date=poc3.ihs_begin_date
					and q.ihs_end_date=poc3.ihs_end_date;

	

			if object_id('tempDB..#poc3_frst') is not null drop table #poc3_frst;
			select DISTINCT id_case
					,(ihs_begin_date)
					,(ihs_end_date)
					,cast(null as int) as ihs_sort
			into #poc3_frst
			from base.tbl_ihs_episodes
			where fl_first_IHS_after_intake = 1
			-- and first_ever_intake=1;
			and first_ihs_date = ihs_begin_date;
	


	
	
			update poc3
			set ihs_sort=q.ihs_sort
			from #poc3_frst poc3
			join (select id_case
						,ihs_begin_date
						,ihs_end_date
						,row_number() over  
							(
								partition by id_case order by id_case, ihs_begin_date,ihs_end_date asc)
								as ihs_sort
				  from #poc3_frst) q 
					on q.id_case=poc3.id_case and q.ihs_begin_date=poc3.ihs_begin_date
				  and q.ihs_end_date=poc3.ihs_end_date;

			if object_id('tempDB..#poc3_all') is not null drop table #poc3_all;
			select distinct ce.id_case
					,ce.id_ihs_episode
					,ce.ihs_begin_date
					,ce.ihs_end_date
					,ce.fl_first_IHS_after_intake
					,ce.cd_race_census_hh
					,ce.census_hispanic_latino_origin_cd_hh
					, ce.intake_county_cd
					,ce.cd_sib_age_grp
					, power(10,6) 
						+ (ce.cd_sib_age_grp * power(10,5))
						+ (ce.cd_race_census_hh * power(10,4))
						+ (ce.census_hispanic_latino_origin_cd_hh * power(10,3))
						+ (abs(ce.intake_county_cd) * 1) [int_match_param_key]
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
					, iif(ce.total_amt_paid > 0 , 1 , 2 )  bin_ihs_svc_cd
					, max(case when sc.cd_subctgry_poc_frc=1 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_family_focused_services
					, max(case when sc.cd_subctgry_poc_frc=2 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_child_care
					, max(case when sc.cd_subctgry_poc_frc=3 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_therapeutic_services
					, max(case when sc.cd_subctgry_poc_frc=7 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_behavioral_rehabiliation_services
					, max(case when sc.cd_subctgry_poc_frc=8 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_other_therapeutic_living_situations
					, max(case when sc.cd_subctgry_poc_frc=9 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_specialty_adolescent_services
					, max(case when sc.cd_subctgry_poc_frc=10 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_respite
					, max(case when sc.cd_subctgry_poc_frc=11 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_transportation
					, max(case when sc.cd_subctgry_poc_frc=17 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_ihs_reun
					, max(case when sc.cd_subctgry_poc_frc=18 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_concrete_goods
					, cast(null as decimal(21,0)) [filter_service_category]
					, 1 as int_filter_service_category
					, max(case when sc.cd_budget_poc_frc=12 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_budget_C12
					, max(case when sc.cd_budget_poc_frc=14 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_budget_C14
					--, max(case when sc.cd_budget_poc_frc=15 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_budget_C15
					--, max(case when sc.cd_budget_poc_frc=16 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_budget_C16
					--, max(case when sc.cd_budget_poc_frc=18 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_budget_C18
					, max(case when sc.cd_budget_poc_frc=19 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_budget_C19
					, max(case when sc.cd_budget_poc_frc=99 then 1 else 0 end ) over (partition by sc.id_ihs_episode	order by sc.srvc_dt_begin,srvc_dt_end)  fl_uncat_svc
					, cast(null as decimal(18,0)) filter_service_budget
			into #poc3_all
			from base.tbl_ihs_episodes ce
				 join base.tbl_ihs_services sc on sc.id_ihs_episode=ce.id_ihs_episode 
				 and sc.srvc_dt_end between ce.ihs_begin_date and ce.ihs_end_date
						and sc.srvc_dt_begin between ce.ihs_begin_date and ce.ihs_end_date
						join dbo.vw_intakes_screened_in si on si.id_intake_fact=ce.id_intake_fact
						 join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=si.cd_reporter	
			where fl_first_IHS_after_intake = 1

		  update #poc3_all
		  set filter_service_category= cast((select multiplier from ref_service_cd_subctgry_poc where cd_subctgry_poc_frc=0)
								+ fl_family_focused_services *   (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_focused_services') 
								+ fl_child_care *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_child_care')  
								+ fl_therapeutic_services *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_therapeutic_services')  
								+ fl_behavioral_rehabiliation_services *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_behavioral_rehabiliation_services')   
								+ fl_other_therapeutic_living_situations *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_other_therapeutic_living_situations')   
								+ fl_specialty_adolescent_services *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_specialty_adolescent_services')   
								+ fl_respite *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_respite')   
								+ fl_transportation *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_transportation')   
								+ fl_ihs_reun *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_ihs_reun')  
								+ fl_concrete_goods *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_concrete_goods')  
								 as decimal(21,0))
				,filter_service_budget =   cast((select multiplier from [ref_service_cd_budget_poc_frc] where cd_budget_poc_frc='0')
									 +  fl_budget_C12 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C12')
									 +  fl_budget_C14 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C14')
									 --+  fl_budget_C15 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C15')
									 --+  fl_budget_C16 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C16')
									 --+  fl_budget_C18 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C18')
									 +  fl_budget_C19 *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_budget_C19')
									 +  fl_uncat_svc *  (select multiplier from [ref_service_cd_budget_poc_frc] where fl_name='fl_uncat_svc') as decimal(9,0));

			
	if OBJECT_ID('tempDB..#temp') is not null drop table #temp;
		select [id_case]
					  ,[id_ihs_episode]
					  ,[ihs_begin_date]
					  ,[ihs_end_date]
					  ,[fl_first_IHS_after_intake]
					  ,[cd_race_census_hh]
					  ,[census_hispanic_latino_origin_cd_hh]
					  ,[intake_county_cd]
					  ,[cd_sib_age_grp]
					  ,[int_match_param_key]
					  ,[cd_reporter]
					  ,[fl_cps_invs]
					  ,[fl_alternate_intervention]
					  ,[fl_risk_only]
					  ,[fl_frs]
					  ,[fl_cfws]
					  ,[filter_access_type]
					  ,[filter_allegation]
					  ,[filter_finding]
					  ,[fl_phys_abuse]
					  ,[fl_sexual_abuse]
					  ,[fl_neglect]
					  ,[fl_any_legal]
					  ,[fl_founded_phys_abuse]
					  ,[fl_founded_sexual_abuse]
					  ,[fl_founded_neglect]
					  ,[fl_founded_any_legal]
					  ,[bin_ihs_svc_cd]
					   ,max([filter_service_category]) [filter_service_category]
					  , max([filter_service_budget]) [filter_service_budget]
		into #temp
		from #poc3_all
		group by [id_case]
					  ,[id_ihs_episode]
					  ,[ihs_begin_date]
					  ,[ihs_end_date]
					  ,[fl_first_IHS_after_intake]
					  ,[cd_race_census_hh]
					  ,[census_hispanic_latino_origin_cd_hh]
					  ,[intake_county_cd]
					  ,[cd_sib_age_grp]
					  ,[int_match_param_key]
					  ,[cd_reporter]
					  ,[fl_cps_invs]
					  ,[fl_alternate_intervention]
					  ,[fl_risk_only]
					  ,[fl_frs]
					  ,[fl_cfws]
					  ,[filter_access_type]
					  ,[filter_allegation]
					  ,[filter_finding]
					  ,[fl_phys_abuse]
					  ,[fl_sexual_abuse]
					  ,[fl_neglect]
					  ,[fl_any_legal]
					  ,[fl_founded_phys_abuse]
					  ,[fl_founded_sexual_abuse]
					  ,[fl_founded_neglect]
					  ,[fl_founded_any_legal]
					  ,[bin_ihs_svc_cd]



	  truncate table 	#poc3_all
	  	insert into #poc3_all ([id_case]
      ,[id_ihs_episode]
      ,[ihs_begin_date]
      ,[ihs_end_date]
      ,[fl_first_IHS_after_intake]
      ,[cd_race_census_hh]
      ,[census_hispanic_latino_origin_cd_hh]
      ,[intake_county_cd]
      ,[cd_sib_age_grp]
      ,[int_match_param_key]
      ,[cd_reporter]
      ,[fl_cps_invs]
      ,[fl_alternate_intervention]
      ,[fl_risk_only]
      ,[fl_frs]
      ,[fl_cfws]
      ,[filter_access_type]
      ,[filter_allegation]
      ,[filter_finding]
      ,[fl_phys_abuse]
      ,[fl_sexual_abuse]
      ,[fl_neglect]
      ,[fl_any_legal]
      ,[fl_founded_phys_abuse]
      ,[fl_founded_sexual_abuse]
      ,[fl_founded_neglect]
      ,[fl_founded_any_legal]
      ,[bin_ihs_svc_cd],int_filter_service_category
	  ,filter_service_category,filter_service_budget)
		select  [id_case]
      ,[id_ihs_episode]
      ,[ihs_begin_date]
      ,[ihs_end_date]
      ,[fl_first_IHS_after_intake]
      ,[cd_race_census_hh]
      ,[census_hispanic_latino_origin_cd_hh]
      ,[intake_county_cd]
      ,[cd_sib_age_grp]
      ,[int_match_param_key]
      ,[cd_reporter]
      ,[fl_cps_invs]
      ,[fl_alternate_intervention]
      ,[fl_risk_only]
      ,[fl_frs]
      ,[fl_cfws]
      ,[filter_access_type]
      ,[filter_allegation]
      ,[filter_finding]
      ,[fl_phys_abuse]
      ,[fl_sexual_abuse]
      ,[fl_neglect]
      ,[fl_any_legal]
      ,[fl_founded_phys_abuse]
      ,[fl_founded_sexual_abuse]
      ,[fl_founded_neglect]
      ,[fl_founded_any_legal]
      ,[bin_ihs_svc_cd],int_filter_service_category,#temp.filter_service_category,filter_service_budget
		from #temp
		join ref_service_category_flag_xwalk xw 
		on  xw.filter_service_category=#temp.filter_service_category


			--select * from #poc3_all  where id_ihs_episode=54902
			--order by id_ihs_episode

			--select * from base.tbl_ihs_services where id_ihs_episode=54902


			-- select id_ihs_episode,count(distinct cd_budget_poc_frc) from base.tbl_ihs_services group by id_ihs_episode having count(distinct cd_budget_poc_frc) > 1	
			if OBJECT_ID('tempDB..#Caseload') is not null drop table #Caseload;
			create table #Caseload (
					  period_start datetime
					, date_type int
					, qry_type int
					, id_case int
					, id_intake_fact int
					, cd_race int
					, census_hispanic_latino_origin_cd int
					, intake_county_cd int
					, cd_sib_age_grp int
					, int_match_param_key int
					, cd_reporter_type int
					, bin_ihs_svc_cd int
					, filter_access_type int
					, filter_allegation int
					, filter_finding int
					, filter_service_category decimal(21,0)
					, int_filter_service_category int
					, filter_service_budget int
					, measure_int int
					, measure_desc varchar(50)
					, cnt_distinct_Intakes int
				)		
		

						
/**************************************** UNIQUE	 *******************************************************/
						set @qry_type=0;
						
						insert into #Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,intake_county_cd,cd_sib_age_grp,int_match_param_key,cd_reporter_type,
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
								, null -- ce.intake_county_cd
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
						from #poc3_unq ce  
						,  #dates  d
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
								,null -- ce.intake_county_cd
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
						from #poc3_unq  CE --opened between start & end and not already open on first day
					,  #dates  d
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
								,null -- ce.intake_county_cd
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
						from #poc3_unq  CE -- closed between start & end and intake open
						,  #dates  d
						where CE.ihs_end_date
								between d.strt_date and d.end_date

	
						
/**************************************** FIRST EVER	 *******************************************************/
						set @qry_type=1;	 
						insert into #Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,intake_county_cd,cd_sib_age_grp,int_match_param_key,cd_reporter_type
							,filter_access_type,filter_allegation,filter_finding,bin_ihs_svc_cd,measure_int,measure_desc,cnt_distinct_Intakes)
						select  distinct
								strt_date
								,d.date_type
								,@qry_type
								,ce.id_case 
								,0
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.intake_county_cd
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
						from  #poc3_frst CE -- start date prior to month start.. count if exited first day
						,  #dates  d
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
								,null -- ce.intake_county_cd
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
						from #poc3_frst  CE --opened between start & end and not already open on first day
						--left join #Caseload CL on CL.id_case=ce.id_case
						--	and cl.qry_type=@qry_type
						--	and cl.date_type=@date_type
						--	and cl.period_start=@chstart
						--	and cl.measure_int = 1
						,  #dates  d
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
								,null -- ce.intake_county_cd
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
						from #poc3_frst  CE -- closed between start & end and intake open
						,  #dates  d
						where CE.ihs_end_date
								between strt_date and end_date
	
	
/**************************************** --ALL	 *******************************************************/
						set @qry_type=2;		 
						insert into #Caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,intake_county_cd,cd_sib_age_grp,int_match_param_key,cd_reporter_type
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
								--, ce.cd_race_census_hh
								--, ce.census_hispanic_latino_origin_cd_hh
								--, ce.intake_county_cd
								--, ce.cd_sib_age_grp
								--, ce.int_match_param_key
								--, ce.cd_reporter
								--, ce.filter_access_type
								--, ce.filter_allegation 
								--, ce.filter_finding
								--, ce.bin_ihs_svc_cd
								-- select * from ref_service_cd_subctgry_poc 
							--	, cast(( select multiplier from ref_service_cd_subctgry_poc  where cd_subctgry_poc_frc=0)  --   fl_family_focused_services
							--		+ max(IIF(ce.cd_subctgry_poc_frc=1 , 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=2 , 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=3 , 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=6 , 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=7 , 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=8, 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=9, 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=10 , 1 * svc.multiplier , 0 ) )
							--		+  max(IIF(ce.cd_subctgry_poc_frc=11, 1 * svc.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_subctgry_poc_frc=14, 1 * svc.multiplier , 0 ) ) as decimal(22,0)) [filter_service_category]
							--, cast(( select multiplier from ref_service_cd_budget_poc_frc  where cd_budget_poc_frc=0)--   buget  
							--		+ max(IIF(ce.cd_budget_poc_frc=12  , 1 * bud.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_budget_poc_frc=14  , 1 * bud.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_budget_poc_frc=15 , 1 * bud.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_budget_poc_frc=16  , 1 * bud.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_budget_poc_frc=18  , 1 * bud.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_budget_poc_frc=19  , 1 * bud.multiplier , 0 ) )
							--		+ max(IIF(ce.cd_budget_poc_frc=99  , 1 * bud.multiplier , 0 ) )  as decimal(9,0)) [filter_service_budget]
								,null -- ce.fam_cd_race_census
								,null -- census_hispanic_latino_origin_cd
								,null -- ce.intake_county_cd
								,null -- ce.cd_sib_age_grp
								, null as int_match_param_key
								, null as cd_reporter_type
								, null as filter_access_type
								, null as filter_allegation
								, null as filter_finding
								, null as bin_ihs_svc_cd
								, null [filter_service_category]
								, null [filter_service_budget]
								, 1
								,'Total Open on First Day'
								, count( distinct id_case)
						from  #poc3_all ce
						join   #dates  d on ce.ihs_begin_date < d.strt_date
							and (ce.ihs_end_date >=d.strt_date )
						--left join ref_service_cd_subctgry_poc svc on svc.cd_subctgry_poc_frc=ce.cd_subctgry_poc_frc
						--left join ref_service_cd_budget_poc_frc bud on bud.cd_budget_poc_frc=ce.cd_budget_poc_frc
					group by ce.id_case	
								,d.date_type
								, d.strt_date
								--, ce.cd_race_census_hh
								--, ce.census_hispanic_latino_origin_cd_hh
								--, ce.intake_county_cd
								--, ce.cd_sib_age_grp
								--, ce.int_match_param_key
								--, ce.cd_reporter
								--, ce.filter_access_type
								--, ce.filter_allegation
								--, ce.filter_finding
								--, ce.bin_ihs_svc_cd
						
	--select date_type,qry_type,period_start,sum(cnt_distinct_Intakes) cnt
	--from #Caseload
	--where measure_int=1
	--group by date_type,qry_type,period_start
	--order by period_start,date_type,qry_type

						
						insert into #caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,intake_county_cd,cd_sib_age_grp,int_match_param_key,cd_reporter_type
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
								, ce.intake_county_cd
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
								, max(filter_service_category)
								, max([filter_service_budget])
								,2
								,'Total Added During Month'
								, count( distinct id_ihs_episode)
						from  #poc3_all ce
						join  #dates  d  on CE.ihs_begin_date
								between d.strt_date  and d.end_date
						group by d.date_type
								, ce.id_case	
								, d.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.intake_county_cd
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
						
	
						
						insert into #caseload
						(period_start,date_type,qry_type,id_case,id_intake_Fact,cd_race,census_hispanic_latino_origin_cd
							,intake_county_cd,cd_sib_age_grp,int_match_param_key,cd_reporter_type
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
								, ce.intake_county_cd
								, ce.cd_sib_age_grp
								, ce.int_match_param_key
								, ce.cd_reporter
								, ce.filter_access_type
								, ce.filter_allegation
								, ce.filter_finding
								, ce.bin_ihs_svc_cd
								, max([filter_service_category])
							, max([filter_service_budget])
								, 3
								, 'Total Closed During Month'
								, count( distinct id_ihs_episode)
						from  #poc3_all ce
						join  #dates  d
						 on  CE.ihs_end_date
								between d.strt_date and d.end_date
						group by  d.date_type,ce.id_case	
								, d.strt_date
								, ce.cd_race_census_hh
								, ce.census_hispanic_latino_origin_cd_hh
								, ce.intake_county_cd
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
					, intake_county_cd=r.intake_county_cd
					, cd_sib_age_grp=r.cd_sib_age_grp
					, int_match_param_key=r.int_match_param_key
					, cd_reporter_type=r.cd_reporter
					, filter_access_type = r.filter_access_type
					, filter_allegation = r.filter_allegation
					, filter_finding=r.filter_finding
					, bin_ihs_svc_cd=r.bin_ihs_svc_cd
					, filter_service_category=r.filter_service_category
				, filter_service_budget=r.filter_service_budget
				from #Caseload CL
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
									, p3.intake_county_cd
									, p3.cd_sib_age_grp
									, p3.cd_reporter
									, p3.int_match_param_key
									, filter_access_type
									, filter_allegation
									, filter_finding
									, p3.bin_ihs_svc_cd
								,  max([filter_service_category]) [filter_service_category]
							, max([filter_service_budget]) [filter_service_budget]
									--	, p3.id_ihs_episode
						from  #poc3_all p3
						join  #dates  d
								on p3.ihs_begin_date <=d.end_date
									and p3.ihs_end_date >= d.strt_date
						group by d.date_type,strt_date
									, end_date
									, ihs_begin_date
									, ihs_end_date
									, date_type
									, p3.id_case  
									, p3.cd_race_census_hh
									, p3.census_hispanic_latino_origin_cd_hh
									, p3.intake_county_cd
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
								
											
		update #Caseload
		set int_filter_service_category=xw.int_filter_service_category
		from ref_service_category_flag_xwalk xw 
		where  xw.filter_service_category=#caseload.filter_service_category
	--	set @date_type=@date_type + 2;
	--	set @chstart=@start_date;
	--end		--@date_type <=2		
	
	

	--CREATE NONCLUSTERED INDEX idx_tmp_caseload
	--	ON #Caseload([fl_child_care])
	--	INCLUDE ([qry_type],[measure_int])

	--	select bin_ihs_svc_cd,qry_type,date_type,count(*)  from #Caseload 
	--	group by  bin_ihs_svc_cd,qry_type,date_type

	
--/*************  insert into table ************************************************************************/
CREATE NONCLUSTERED INDEX idx_pk45
ON #Caseload([measure_int])
INCLUDE ([period_start],[date_type],[qry_type],[int_match_param_key],[cd_reporter_type],[filter_access_type],[filter_allegation],[filter_finding],[bin_ihs_svc_cd],[filter_service_category],[filter_service_budget],[cnt_distinct_Intakes])

CREATE NONCLUSTERED INDEX idx_tmp2_casework
on #Caseload ([period_start],[date_type],[qry_type],[int_match_param_key],[cd_reporter_type],[filter_access_type],[filter_allegation],[filter_finding],[bin_ihs_svc_cd],[filter_service_category],[filter_service_budget],[measure_int])
INCLUDE ([cnt_distinct_Intakes])


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
           ,[county_cd]
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
           ,[int_filter_service_category]
		   , filter_service_budget
           ,[cd_sib_age_grp]
           ,[cd_race]
           ,[census_hispanic_latino_origin_cd]
           ,[intake_county_cd]
				,0
				,0
				,0
		 from #caseload
		


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
		  , cl.int_filter_service_category
		  , cl.filter_service_budget
		  , sum(cnt_distinct_Intakes) as cnt 
		 from #caseLoad cl
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
		  , cl.int_filter_service_category
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
		and q.int_filter_service_category=prtl_poc3ab.filter_service_category	
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
 		  , cl.int_filter_service_category
		  , cl.filter_service_budget
		 ,sum(cnt_distinct_Intakes) as cnt 
		 from #caseLoad cl
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
 		  , cl.int_filter_service_category
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
		and q.int_filter_service_category=prtl_poc3ab.filter_service_category
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
 		  , cl.int_filter_service_category
		  , cl.filter_service_budget
		 ,sum(cnt_distinct_Intakes) as cnt 
		 from #caseLoad cl
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
 		  , cl.int_filter_service_category
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
		and q.int_filter_service_category=prtl_poc3ab.filter_service_category
		and q.filter_service_budget=prtl_poc3ab.filter_service_budget	

		update statistics prtl.prtl_poc3ab;
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_poc3ab)
	  where tbl_id=3;	

	  --		select * from prtl.prtl_tables_last_update where tbl_id=3
			--select count(*) from prtl.prtl_poc3ab
	
	end
else 
	begin
	select  'This procedure BUILDS COHORTS!  Need permission key to execute'  as [Warning]
	
	end
	
	



