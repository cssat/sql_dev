USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_poc2ab]    Script Date: 4/21/2014 2:02:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure  [prtl].[prod_build_prtl_poc2ab](@permission_key datetime) 
as 
set nocount on
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
		declare @date_type int
		declare @startDate datetime
		declare @endDate datetime
		declare @last_month_end datetime
		declare @last_year_end datetime

		declare @stopLoop datetime
		declare @cutoff_date datetime
		declare @qry_type int
		


		set @date_type=0
		set @startDate='2004-01-01'
		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer	
		set @endDate = (select dateadd(mm,-1,[month] ) from dbo.CALENDAR_DIM where CALENDAR_DATE=@cutoff_date);
		set @last_month_end=(select dateadd(mm,-1,[month]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		set @last_year_end=(select dateadd(yy,-1,[year]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	

		--  print @endDate;
		
		if object_ID('tempDB..#intakes') is not null drop table #intakes;
		select		distinct
								 0 as qry_type -- unique
								 ,@date_type  as date_type --month
								 ,@startDate  as startdate
								 ,@endDate as stopdate
								 ,tce.id_case
								 ,tce.first_intake_date
								 ,tce.latest_intake_date
								 ,tce.inv_ass_start
								 ,isnull(tce.inv_ass_stop,'12/31/3999') as inv_ass_stop
								 ,tce.rfrd_date
								 ,ent.[month] as entry_month_date
								 ,ent.[Year] as entry_year_date
								 ,ext.[month] as exit_month_date
								 ,ext.[YEAR] as exit_year_date
								, tce.id_intake_fact
								 ,  isnull(rpt.collapsed_cd_reporter_type,-99) as cd_reporter_type
								  , isnull(tce.[fl_cps_invs],0) as fl_cps_invs
								  , isnull(tce.[fl_cfws],0) as fl_cfws
								  , isnull(tce.[fl_risk_only],0) as [fl_risk_only]
								  , isnull(tce.[fl_alternate_intervention],0) as [fl_alternate_intervention]
								  , isnull(tce.[fl_frs],0) as [fl_frs]
								  , fl_phys_abuse
								  , fl_sexual_abuse
								  , fl_neglect
								  , case when fl_phys_abuse>0
										  or fl_sexual_abuse > 0
										   or  fl_neglect > 0 then 1 else 0 end as fl_any_legal
								  , fl_founded_phys_abuse
								  , fl_founded_sexual_abuse
								  , fl_founded_neglect
								  , fl_founded_any_legal
								 , tce.cd_sib_age_grp as cd_sib_age_grp
								 , tce.[CD_RACE_Census]  as cd_race_census
								 , tce.census_hispanic_latino_origin_cd
								  ,xwlk.cd_office_collapse  as cd_office
								 , power(10,6) 
										+ (power(10,5) * tce.cd_sib_age_grp ) 
										+ (power(10,4) *   tce.cd_race_census)
										+ (power(10,3)*  tce.census_hispanic_latino_origin_cd)
										+ (power(10,0) * abs(xwlk.cd_office_collapse) ) [int_match_param_key]
								 , 0 as fl_initref_cohort_month
								 , 0 as fl_initref_cohort_year
								 , 0 as fl_frstexit_cohort_month
								 , 0 as fl_frstexit_cohort_year
						into #intakes
						from base.tbl_intakes tce 
						join dbo.CALENDAR_DIM ent on ent.CALENDAR_DATE= tce.inv_ass_start
						left join dbo.calendar_dim ext on ext.CALENDAR_DATE=cast(convert(varchar(10),tce.inv_ass_stop,121) as datetime)
						left join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
						left join dbo.ref_xwalk_CD_OFFICE_DCFS xwlk on xwlk.cd_office=tce.cd_office
						left join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=tce.cd_reporter
						--REMOVE EPISODES FOR KIDS 18 AND AOVER
					WHERE (tce.inv_ass_start <= ISNULL(TCE.inv_ass_stop,'12/31/3999')
					and ((tce.inv_ass_start <=@startDate and ISNULL(TCE.inv_ass_stop,'12/31/3999') >=@startDate)
							or tce.inv_ass_start >=@startDate))
					and tce.cd_final_decision=1 
					and tce.fl_reopen_case=0
					and tce.fl_dlr=0 
					and (fl_cfws = 1 or fl_frs=1 or fl_risk_only=1 or fl_alternate_intervention=1
							or fl_cps_invs=1)
					and tce.cd_spvr_rsn in (1,2,3)
					and tce.cd_access_type in (1,2,4)
					ORDER BY  tce.id_case,TCE.inv_ass_start
		
			
			
				    
					update intk
					set intk.fl_initref_cohort_month=row_num
					from #intakes intk
					join (select *,row_number() over (partition by id_case,entry_month_date order by rfrd_date asc,id_intake_fact asc) row_num
					from #intakes
					) q on  q.id_intake_fact=intk.id_intake_fact and row_num=1
					

					update intk
					set intk.fl_initref_cohort_year=row_num
					from #intakes intk
					join (select *,row_number() over (partition by id_case,entry_year_date order by rfrd_date asc,inv_ass_stop,id_intake_fact asc) row_num
					from #intakes
					) q on  q.id_intake_fact=intk.id_intake_fact and row_num=1
					
										
					update intk
					set intk.fl_frstexit_cohort_month=row_num
					from #intakes intk
					join (select *,row_number() over (partition by id_case,exit_month_date order by inv_ass_stop asc,id_intake_fact asc) row_num
					from #intakes
					) q on  q.id_intake_fact=intk.id_intake_fact and row_num=1
					
	
					update intk
					set intk.fl_frstexit_cohort_year=row_num
					from #intakes intk
					join (select *,row_number() over (partition by id_case,exit_year_date order by inv_ass_stop asc,id_intake_fact asc) row_num
					from #intakes
					) q on  q.id_intake_fact=intk.id_intake_fact and row_num=1
									
					create index idx_case_start_stop on #intakes(id_case,inv_ass_start,inv_ass_stop)
					create index idx_id_intake_fact on #intakes(id_intake_fact);
					create index idx_first_start on #intakes(first_intake_date,rfrd_date,fl_initref_cohort_month);
					create index idx_first_start2 on #intakes(first_intake_date,rfrd_date,fl_initref_cohort_year);
					create index idx_stop_date on #intakes(inv_ass_stop,fl_frstexit_cohort_year);
					create index idx_stop_date2 on #intakes(inv_ass_stop,fl_frstexit_cohort_year);
					
					update statistics #intakes;


				
				

/***********************************************************  POINT IN TIME       **************************/

if object_id('tempDB..#intk') is not null drop table #intk;
	CREATE TABLE #intk(
								[qry_type] [int] NOT NULL,
									[date_type] [int] NOT NULL,
									[start_date] [datetime] NOT NULL,
									[int_match_param_key] [bigint] NULL,
										[cd_reporter_type] [int] NOT NULL,
									[fl_cps_invs] [int] NOT NULL,
									fl_alternate_intervention int not null,
									fl_risk_only int not null,
									fl_frs int not null,
									fl_cfws int not null,
									[fl_phys_abuse] [int] NOT NULL,
									[fl_sexual_abuse] [int] NOT NULL,
									[fl_neglect] [int] NOT NULL,
									[fl_any_legal] [int] NOT NULL,
									[fl_founded_phys_abuse] [int] NOT NULL,
									[fl_founded_sexual_abuse] [int] NOT NULL,
									[fl_founded_neglect] [int] NOT NULL,
									[fl_found_any_legal] [int] NOT NULL,
									cd_sib_age_group int  NOT NULL,
									[cd_race_census] [int] NOT NULL,
									[census_hispanic_latino_origin_cd] [int]NOT NULL,
									cd_office [int] NOT NULL,
									cnt_first int not null default 0,
									cnt_entries int not null default 0,
									cnt_exits int  not null default 0,
									);


insert into #intk (qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs,fl_alternate_intervention,
									fl_risk_only ,
									fl_frs,
									fl_cfws,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
,cd_office,int_match_param_key,cnt_first)

/*************************************  qry_type ALL    ALL   ***********************************************************/
							SELECT 2 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								   ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,int_match_param_key
								  ,count( distinct id_intake_fact) as cnt_ref
						 
						  from #intakes
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   inv_ass_start < cd.[Month]
						  and inv_ass_stop >=cd.[Month]
						
						  group by    cd.[month] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,int_match_param_key
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,cd_office
				UNION ALL
							SELECT 2 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(  distinct id_intake_fact) as cnt_eps
						  from #intakes
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    inv_ass_start < cd.[Year]
						  and inv_ass_stop >=cd.[Year]
						
						  group by   cd.[Year] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count( distinct id_intake_fact) as cnt_ref
						 
						  from #intakes
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   inv_ass_start < cd.[Month]
						  and inv_ass_stop >=cd.[Month]
						  where rfrd_date=first_intake_date
						and fl_initref_cohort_month=1
						  group by   cd.[month] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
							SELECT 1 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count( distinct id_intake_fact) as cnt_ref
						  from #intakes
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    inv_ass_start < cd.[Year]
						  and inv_ass_stop >=cd.[Year]
						 where rfrd_date=first_intake_date
							and fl_initref_cohort_year=1
						  group by   cd.[Year] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
		UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on inv_ass_start < cd.[Month]
										and inv_ass_stop >=cd.[Month]
						  join (select id_case,id_intake_fact,rfrd_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc,id_intake_fact asc) as row_num
								from #intakes 
								join (select distinct [month] from  dbo.CALENDAR_DIM
										where	[month] between  @startDate and @last_month_end
									)  cd on inv_ass_start < cd.[Month]
											and inv_ass_stop >=cd.[Month]
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact

						
						  group by   cd.[month] 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
				UNION ALL
							SELECT 0 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_eps
						  from #intakes
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    inv_ass_start < cd.[Year]
						  and inv_ass_stop >=cd.[Year]
						 join (select id_case,id_intake_fact,rfrd_date 
									  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws								  
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc,id_intake_fact asc) as row_num
								from #intakes 
								join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    inv_ass_start < cd.[Year]
									and inv_ass_stop >=cd.[Year]
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact
						  group by   cd.[Year] 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
					ORDER BY date_type,qry_type,[start_date],int_match_param_key


	

if object_id('tempDB..#entries') is not null drop table #entries;
	CREATE TABLE #entries(
								[qry_type] [int] NOT NULL,
									[date_type] [int] NOT NULL,
									[start_date] [datetime] NOT NULL,
									[int_match_param_key] [bigint] NULL,
									[cd_reporter_type] [int] NOT NULL,
									[fl_cps_invs] [int] NOT NULL,
									fl_alternate_intervention int not null,
									fl_risk_only int not null,
									fl_frs int not null,
									fl_cfws int not null,
									[fl_phys_abuse] [int] NOT NULL,
									[fl_sexual_abuse] [int] NOT NULL,
									[fl_neglect] [int] NOT NULL,
									[fl_any_legal] [int] NOT NULL,
									[fl_founded_phys_abuse] [int] NOT NULL,
									[fl_founded_sexual_abuse] [int] NOT NULL,
									[fl_founded_neglect] [int] NOT NULL,
									[fl_found_any_legal] [int] NOT NULL,
									cd_sib_age_group int  NOT NULL,
									[cd_race_census] [int] NOT NULL,
									[census_hispanic_latino_origin_cd] [int]NOT NULL,
									cd_office [int] NOT NULL,
									cnt_entries int not null default 0,
												);

insert into #entries (qry_type,date_type,start_date,cd_reporter_type,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
,cd_office,int_match_param_key,cnt_entries)


							SELECT 2 as qry_type
								  ,0 as date_type
								  ,entry_month_date as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								   ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,int_match_param_key
								  ,count( id_case) as cnt_ref
						 
						  from #intakes
						   where entry_month_date between @startDate and @last_month_end
						
						  group by    entry_month_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,int_match_param_key
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
				UNION ALL
							SELECT 2 as qry_type
								  ,2 as date_type
								  ,entry_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count( id_case) as cnt_eps
						  from #intakes
						  where entry_year_date between  @startdate and  @last_year_end
						
						  group by  entry_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,0 as date_type
								  ,entry_month_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						 
						  from #intakes
						  where entry_month_date between @startDate and @last_month_end
						  and rfrd_date=first_intake_date
							and fl_initref_cohort_month=1
						
						  group by   entry_month_date
									  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
							SELECT 1 as qry_type
								  ,2 as date_type
								  ,entry_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						  from #intakes
						 where entry_year_date between  @startdate and  @last_year_end
						 and rfrd_date=first_intake_date
						 and fl_initref_cohort_year=1
						  group by   entry_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
		UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,0 as date_type
								  ,entry_month_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes q
						  where entry_month_date between @startDate and @last_month_end
						  and fl_initref_cohort_month=1
						  group by   entry_month_date
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
				UNION ALL
							SELECT 0 as qry_type
								  ,2 as date_type
								  ,entry_year_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_eps
						  from #intakes q
						 where entry_year_date between  @startdate and  @last_year_end
						 and fl_initref_cohort_year=1
						  group by   entry_year_date 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
					ORDER BY date_type,qry_type,[start_date],int_match_param_key;

	

if object_id('tempDB..#exits') is not null drop table #exits;
	CREATE TABLE #exits(
								[qry_type] [int] NOT NULL,
									[date_type] [int] NOT NULL,
									[start_date] [datetime] NOT NULL,
									[int_match_param_key] [bigint] NULL,
									[cd_reporter_type] [int] NOT NULL,
									[fl_cps_invs] [int] NOT NULL,
									fl_alternate_intervention int not null,
									fl_risk_only int not null,
									fl_frs int not null,
									fl_cfws int not null,
									[fl_phys_abuse] [int] NOT NULL,
									[fl_sexual_abuse] [int] NOT NULL,
									[fl_neglect] [int] NOT NULL,
									[fl_any_legal] [int] NOT NULL,
									[fl_founded_phys_abuse] [int] NOT NULL,
									[fl_founded_sexual_abuse] [int] NOT NULL,
									[fl_founded_neglect] [int] NOT NULL,
									[fl_found_any_legal] [int] NOT NULL,
									cd_sib_age_group int  NOT NULL,
									[cd_race_census] [int] NOT NULL,
									[census_hispanic_latino_origin_cd] [int]NOT NULL,
									cd_office [int] NOT NULL,
									cnt_exits int not null default 0,
												);


insert into #exits (qry_type,date_type,start_date,cd_reporter_type,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
,cd_office,int_match_param_key,cnt_exits)


							SELECT 2 as qry_type
								  ,0 as date_type
								  ,exit_month_date as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,int_match_param_key
								  ,count( id_case) as cnt_ref
						 
						  from #intakes
						   where exit_month_date between @startDate and @last_month_end
						
						  group by    exit_month_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,int_match_param_key
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
				UNION ALL
							SELECT 2 as qry_type
								  ,2 as date_type
								  ,exit_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count( id_case) as cnt_ref
						  from #intakes
						  where exit_year_date between  @startdate and  @last_year_end
						
						  group by  exit_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,0 as date_type
								  ,exit_month_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						 
						  from #intakes
						  where exit_month_date between @startDate and @last_month_end
						  and rfrd_date=first_intake_date
						  and fl_initref_cohort_month=1
						  group by   exit_month_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
							SELECT 1 as qry_type
								  ,2 as date_type
								  ,exit_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						  from #intakes
						 where exit_year_date between  @startdate and  @last_year_end
						 and rfrd_date=first_intake_date
						 and  fl_initref_cohort_year=1
						  group by   exit_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,fl_founded_any_legal
								  ,cd_sib_age_grp
								  ,cd_race_census
								  ,[census_hispanic_latino_origin_cd]
								  ,cd_office
								  ,[int_match_param_key]
		UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,0 as date_type
								  ,exit_month_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws
								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes q
						  where exit_month_date between @startDate and @last_month_end
						  and fl_frstexit_cohort_month=1
						  group by   exit_month_date
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws

								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  
								  ,q.cd_office
								  ,q.[int_match_param_key]
				UNION ALL
							SELECT 0 as qry_type
								  ,2 as date_type
								  ,exit_year_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws

								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_eps
						  from #intakes q
						 where exit_year_date between  @startdate and  @last_year_end
						 and fl_frstexit_cohort_year=1
						  group by   exit_year_date 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws

								  ,q.[fl_phys_abuse]
								  ,q.[fl_sexual_abuse]
								  ,q.[fl_neglect]
								  ,q.[fl_any_legal]
								  ,q.[fl_founded_phys_abuse]
								  ,q.[fl_founded_sexual_abuse]
								  ,q.[fl_founded_neglect]
								  ,q.fl_founded_any_legal
								  ,q.cd_sib_age_grp
								  ,q.cd_race_census
								  ,q.[census_hispanic_latino_origin_cd]
								  ,q.cd_office
								  ,q.[int_match_param_key]
					ORDER BY date_type,qry_type,[start_date],int_match_param_key;

-- update those there on first day
			update AE
			set cnt_entries= ent.cnt_entries
			from #intk ae
			join #entries ent
				  on ae.[start_date] = ent.[start_date] and
				ae.qry_type = ent.qry_type and
				ae.date_type = ent.date_type and
				ae.[cd_reporter_type] = ent.[cd_reporter_type] and
				ae.[fl_cps_invs] = ent.[fl_cps_invs] and
				ae.fl_alternate_intervention=ent.fl_alternate_intervention and
				ae.fl_risk_only = ent. fl_risk_only and
				ae.fl_frs= ent. fl_frs and
				ae.fl_cfws= ent. fl_cfws and
				ae.[fl_phys_abuse] = ent.[fl_phys_abuse] and
				ae.[fl_sexual_abuse] = ent.[fl_sexual_abuse] and
				ae.[fl_neglect] = ent.[fl_neglect] and
				ae.[fl_any_legal] = ent.[fl_any_legal] and
				ae.[fl_founded_phys_abuse] = ent.[fl_founded_phys_abuse] and
				ae.[fl_founded_sexual_abuse] = ent.[fl_founded_sexual_abuse] and
				ae.[fl_founded_neglect] = ent.[fl_founded_neglect] and
				ae.[fl_found_any_legal] = ent.[fl_found_any_legal] and
				ae.cd_sib_age_group = ent.cd_sib_age_group and
				ae.[cd_race_census] = ent.[cd_race_census] and
				ae.[census_hispanic_latino_origin_cd] = ent.[census_hispanic_latino_origin_cd] and
				ae.cd_office= ent.cd_office  and
				ae.[int_match_param_key] = ent.[int_match_param_key];
		
			

insert into #intk(qry_type,date_type,start_date,cd_reporter_type,								  [fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
,cd_office,int_match_param_key,cnt_entries)
/******************   insert entries with NO FIRST DAY **********************************************************************/
						select
									qry_type
								  ,date_type
								  ,[start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,[fl_found_any_legal]
								  ,cd_sib_age_group
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key],cnt_entries
								from #entries
								except
								select 
									qry_type
								  ,date_type
								  ,[start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	
								  ,[fl_phys_abuse]
								  ,[fl_sexual_abuse]
								  ,[fl_neglect]
								  ,[fl_any_legal]
								  ,[fl_founded_phys_abuse]
								  ,[fl_founded_sexual_abuse]
								  ,[fl_founded_neglect]
								  ,[fl_found_any_legal]
								  ,cd_sib_age_group
								  ,[cd_race_census]
								  ,[census_hispanic_latino_origin_cd]
								  
								  ,cd_office
								  ,[int_match_param_key],cnt_entries
								from #intk

			update AE
			set cnt_exits= ext.cnt_exits
			from #intk ae
			join #exits ext
					on ae.qry_type = ext.qry_type and
				ae.date_type = ext.date_type and
				ae.[start_date] = ext.[start_date] and
				ae.[cd_reporter_type] = ext.[cd_reporter_type] and
				ae.[fl_cps_invs] = ext.[fl_cps_invs] and
				ae.fl_alternate_intervention=ext.fl_alternate_intervention and
				ae.fl_risk_only=ext.fl_risk_only and 
				ae.fl_frs=ext.fl_frs and 
				ae.fl_cfws=ext.fl_cfws and 
				ae.[fl_phys_abuse] = ext.[fl_phys_abuse] and
				ae.[fl_sexual_abuse] = ext.[fl_sexual_abuse] and
				ae.[fl_neglect] = ext.[fl_neglect] and
				ae.[fl_any_legal] = ext.[fl_any_legal] and
				ae.[fl_founded_phys_abuse] = ext.[fl_founded_phys_abuse] and
				ae.[fl_founded_sexual_abuse] = ext.[fl_founded_sexual_abuse] and
				ae.[fl_founded_neglect] = ext.[fl_founded_neglect] and
				ae.[fl_found_any_legal] = ext.[fl_found_any_legal] and
				ae.cd_sib_age_group = ext.cd_sib_age_group and
				ae.[cd_race_census] = ext.[cd_race_census] and
				ae.[census_hispanic_latino_origin_cd] = ext.[census_hispanic_latino_origin_cd] and
				ae.cd_office= ext.cd_office  and
				ae.[int_match_param_key] = ext.[int_match_param_key] 	;


/******************   insert exits with NO FIRST DAY **********************************************************************/

insert into #intk(qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs	
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
,cd_office,int_match_param_key,cnt_entries)
					select 
						qry_type
						,date_type
						,[start_date]
						,[cd_reporter_type]
						,[fl_cps_invs]
						,fl_alternate_intervention
						,fl_risk_only
						,fl_frs
						,fl_cfws	
						,[fl_phys_abuse]
						,[fl_sexual_abuse]
						,[fl_neglect]
						,[fl_any_legal]
						,[fl_founded_phys_abuse]
						,[fl_founded_sexual_abuse]
						,[fl_founded_neglect]
						,[fl_found_any_legal]
						,cd_sib_age_group
						,[cd_race_census]
						,[census_hispanic_latino_origin_cd]
						
						,cd_office
						,[int_match_param_key],cnt_exits
					from #exits
					except
					select 
						qry_type
						,date_type
						,[start_date]
						,[cd_reporter_type]
						,[fl_cps_invs]
						,fl_alternate_intervention
						,fl_risk_only
						,fl_frs
						,fl_cfws	
						,[fl_phys_abuse]
						,[fl_sexual_abuse]
						,[fl_neglect]
						,[fl_any_legal]
						,[fl_founded_phys_abuse]
						,[fl_founded_sexual_abuse]
						,[fl_founded_neglect]
						,[fl_found_any_legal]
						,cd_sib_age_group
						,[cd_race_census]
						,[census_hispanic_latino_origin_cd]
						
						,cd_office
						,[int_match_param_key],cnt_exits
					from #intk

			
CREATE NONCLUSTERED INDEX idx_insert_qry_poc2
	ON #intk ([date_type],[qry_type])
	INCLUDE ([start_date],[cd_reporter_type],[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws
	,[fl_phys_abuse],[fl_sexual_abuse],[fl_neglect],[fl_any_legal],[fl_founded_phys_abuse],[fl_founded_sexual_abuse]
	,[fl_founded_neglect],[fl_found_any_legal]
	,cd_sib_age_group,[cd_race_census],[census_hispanic_latino_origin_cd]
	,cd_office,[int_match_param_key],[cnt_first],[cnt_entries],[cnt_exits])

	--select date_type,qry_type,start_date,sum(cnt_first) as tot_pit
	--,sum(cnt_entries) as tot_entry,sum(cnt_exits) as tot_exit
	--,sum(cnt_first) + sum(cnt_entries) - sum(cnt_exits) as nxt_mnth
	--from #intk 
	--where qry_type=2 and date_type=0
	--group by date_type,qry_type,start_date
	--order by qry_type desc,  date_type asc, start_date asc;

	if object_ID(N'prtl.prtl_poc2ab',N'U') is not null truncate table prtl.prtl_poc2ab;
			insert into prtl.prtl_poc2ab
			  ([qry_type]
           ,[date_type]
           ,[start_date]
           ,[start_year]
           ,[int_match_param_key]
           ,[cd_reporter_type]
           ,[filter_access_type]
           ,[filter_allegation]
           ,[filter_finding]
           ,[cd_sib_age_group]
           ,[cd_race_census]
           ,[census_hispanic_latino_origin_cd]
           ,[cd_office]
           ,[cnt_start_date]
           ,[cnt_opened]
           ,[cnt_closed])
				
			select 
				[qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,year(start_date)
				   ,[int_match_param_key]
				   ,[cd_reporter_type]
				   ,power(10,5) +  fl_cps_invs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cps_invs')
											  + fl_alternate_intervention  * (select cd_multiplier from ref_filter_access_type where fl_name='fl_alternate_intervention')
											  + fl_frs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_frs')
											  + fl_risk_only * (select cd_multiplier from ref_filter_access_type where fl_name='fl_risk_only')
											  + fl_cfws * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cfws')   [filter_access_type]
					,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) [filter_allegation]
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) [filter_finding]
				   ,[cd_sib_age_group]
				   ,[cd_race_census]
				   ,[census_hispanic_latino_origin_cd]
				   ,[cd_office]
				   ,[cnt_first]
				   ,[cnt_entries]
				   ,[cnt_exits]
				from #intk




		


		update statistics prtl.prtl_poc2ab;
	  update prtl.prtl_tables_last_update		
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.prtl_poc2ab)
	  where tbl_id=2;	

		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end

