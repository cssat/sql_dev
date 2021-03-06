USE CA_ODS
GO


alter procedure  [prtl].[prod_build_prtl_poc2ab](@permission_key datetime) 
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
								 , isnull(rpt.collapsed_cd_reporter_type,-99) as cd_reporter_type
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
								 , ISNULL(G.PK_GNDR,3) as pk_gndr
								  ,xwlk.cd_office_collapse  as cd_office
								 , prm.int_match_param_key

						into #intakes
						from base.tbl_intakes tce 
						join dbo.CALENDAR_DIM ent on ent.CALENDAR_DATE= tce.inv_ass_start
						left join dbo.calendar_dim ext on ext.CALENDAR_DATE=tce.inv_ass_stop
						 --join dbo.ref_Age_Groupings_census Age on CHILD_AGE_REMOVAL_BEGIN >=Age.age_begin and CHILD_AGE_REMOVAL_BEGIN < age.Age_LessThan_End
							--	and age.age_grouping_cd between 1 and 4 
						--join age_dim age on age.age_mo=tce.age_eps_begin_mos 
						left join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
						left join dbo.ref_lookup_gender G on G.pk_gndr=tce.pk_gndr
						left join dbo.ref_xwalk_CD_OFFICE_DCFS xwlk on xwlk.cd_office=tce.cd_office
						-- left join dbo.vw_intakes_screened_in si on si.id_intake_fact=tce.id_intake_fact
						left join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=tce.cd_reporter
						left join dbo.ref_match_intake_parameters prm on 
									prm.match_cd_sib_age_grp=tce.cd_sib_age_grp	
								and prm.match_cd_race_census=tce.cd_race_census
								and prm.match_cd_hispanic_latino_origin=tce.census_hispanic_latino_origin_cd
								and prm.match_pk_gndr=g.pk_gndr
								and prm.match_cd_office=xwlk.cd_office_collapse
					
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
		
				    create index idx_case_start_stop on #intakes(id_case,inv_ass_start,inv_ass_stop)
					create index idx_id_intake_fact on #intakes(id_intake_fact);
					create index idx_first_start on #intakes(first_intake_date,inv_ass_start);
					create index idx_stop_date on #intakes(inv_ass_stop);
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
									[pk_gndr] [int] NOT NULL,
									cd_office [int] NOT NULL,
									cnt_first int not null default 0,
									cnt_entries int not null default 0,
									cnt_exits int  not null default 0,
									);


insert into #intk (qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,pk_gndr
,cd_office,int_match_param_key,cnt_first)

/*************************************  qry_type ALL    ALL   ***********************************************************/
							SELECT 2 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,int_match_param_key
								  ,count( id_case) as cnt_ref
						 
						  from #intakes
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   inv_ass_start < cd.[Month]
						  and inv_ass_stop >=cd.[Month]
						
						  group by    cd.[month] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
				UNION ALL
							SELECT 2 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count( id_case) as cnt_eps
						  from #intakes
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    inv_ass_start < cd.[Year]
						  and inv_ass_stop >=cd.[Year]
						
						  group by   cd.[Year] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						 
						  from #intakes
						  join (select distinct [month] from  dbo.CALENDAR_DIM
									where	[month] between  @startDate and @last_month_end
								)  cd on 
						   inv_ass_start < cd.[Month]
						  and inv_ass_stop >=cd.[Month]
						  where rfrd_date=first_intake_date
						
						  group by   cd.[month] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
							SELECT 1 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						  from #intakes
						  join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    inv_ass_start < cd.[Year]
						  and inv_ass_stop >=cd.[Year]
						 where rfrd_date=first_intake_date
						  group by   cd.[Year] 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
		UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,0 as date_type
								  ,cd.[month]  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc) as row_num
								from #intakes 
								join (select distinct [month] from  dbo.CALENDAR_DIM
										where	[month] between  @startDate and @last_month_end
									)  cd on inv_ass_start < cd.[Month]
											and inv_ass_stop >=cd.[Month]
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact

						
						  group by   cd.[month] 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
				UNION ALL
							SELECT 0 as qry_type
								  ,2 as date_type
								  ,cd.[Year]  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc) as row_num
								from #intakes 
								join (select distinct [Year] from  dbo.CALENDAR_DIM
									where	[Year] between  @startDate and @last_year_end
								)  cd on    inv_ass_start < cd.[Year]
									and inv_ass_stop >=cd.[Year]
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact
						  group by   cd.[Year] 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
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
									[pk_gndr] [int] NOT NULL,
									cd_office [int] NOT NULL,
									cnt_entries int not null default 0,
												);


insert into #entries (qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,pk_gndr
,cd_office,int_match_param_key,cnt_entries)


							SELECT 2 as qry_type
								  ,0 as date_type
								  ,entry_month_date as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,int_match_param_key
								  ,count( id_case) as cnt_ref
						 
						  from #intakes
						   where entry_month_date between @startDate and @last_month_end
						
						  group by    entry_month_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
				UNION ALL
							SELECT 2 as qry_type
								  ,2 as date_type
								  ,entry_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count( id_case) as cnt_eps
						  from #intakes
						  where entry_year_date between  @startdate and  @last_year_end
						
						  group by  entry_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,0 as date_type
								  ,entry_month_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						 
						  from #intakes
						  where entry_month_date between @startDate and @last_month_end
						  and rfrd_date=first_intake_date
						
						  group by   entry_month_date
									  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
							SELECT 1 as qry_type
								  ,2 as date_type
								  ,entry_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						  from #intakes
						 where entry_year_date between  @startdate and  @last_year_end
						 and rfrd_date=first_intake_date
						  group by   entry_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
		UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,0 as date_type
								  ,entry_month_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes
						  join (select id_case,id_intake_fact,rfrd_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc) as row_num
								from #intakes 
								where entry_month_date between @startDate and @last_month_end
									
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact
						  where entry_month_date between @startDate and @last_month_end
						  group by   entry_month_date
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
				UNION ALL
							SELECT 0 as qry_type
								  ,2 as date_type
								  ,entry_year_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_eps
						  from #intakes
						 join (select id_case,id_intake_fact,rfrd_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc) as row_num
								from #intakes 
								where entry_year_date between  @startdate and  @last_year_end
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact
						 where entry_year_date between  @startdate and  @last_year_end
						  group by   entry_year_date 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
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
									[pk_gndr] [int] NOT NULL,
									cd_office [int] NOT NULL,
									cnt_exits int not null default 0,
												);


insert into #exits (qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,pk_gndr
,cd_office,int_match_param_key,cnt_exits)


							SELECT 2 as qry_type
								  ,0 as date_type
								  ,exit_month_date as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,int_match_param_key
								  ,count( id_case) as cnt_ref
						 
						  from #intakes
						   where exit_month_date between @startDate and @last_month_end
						
						  group by    exit_month_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
				UNION ALL
							SELECT 2 as qry_type
								  ,2 as date_type
								  ,exit_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count( id_case) as cnt_ref
						  from #intakes
						  where exit_year_date between  @startdate and  @last_year_end
						
						  group by  exit_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,0 as date_type
								  ,exit_month_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						 
						  from #intakes
						  where exit_month_date between @startDate and @last_month_end
						  and rfrd_date=first_intake_date
						
						  group by   exit_month_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
				UNION ALL
							SELECT 1 as qry_type
								  ,2 as date_type
								  ,exit_year_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						  from #intakes
						 where exit_year_date between  @startdate and  @last_year_end
						 and rfrd_date=first_intake_date
						  group by   exit_year_date
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
		UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,0 as date_type
								  ,exit_month_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes
						  join (select id_case,id_intake_fact,rfrd_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc) as row_num
								from #intakes 
								where exit_month_date between @startDate and @last_month_end
									
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact
						  where exit_month_date between @startDate and @last_month_end
						  group by   exit_month_date
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
				UNION ALL
							SELECT 0 as qry_type
								  ,2 as date_type
								  ,exit_year_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_eps
						  from #intakes
						 join (select id_case,id_intake_fact,rfrd_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
								  ,cd_office
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case  order by id_case,rfrd_date asc) as row_num
								from #intakes 
								where exit_year_date between  @startdate and  @last_year_end
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact
						 where exit_year_date between  @startdate and  @last_year_end
						  group by   exit_year_date 
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
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
								  ,q.[pk_gndr]
								  ,q.cd_office
								  ,q.[int_match_param_key]
					ORDER BY date_type,qry_type,[start_date],int_match_param_key;

-- update those there on first day
			update AE
			set cnt_entries= ent.cnt_entries
			from #intk ae
			join #entries ent
				  on ae.qry_type = ent.qry_type and
				ae.date_type = ent.date_type and
				ae.[start_date] = ent.[start_date] and
						ae.[cd_reporter_type] = ent.[cd_reporter_type] and
				ae.[fl_cps_invs] = ent.[fl_cps_invs] and
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
				ae.[pk_gndr] = ent.[pk_gndr] and
				ae.cd_office= ent.cd_office  and
				ae.[int_match_param_key] = ent.[int_match_param_key];
		
			

insert into #intk(qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,pk_gndr
,cd_office,int_match_param_key,cnt_entries)
/******************   insert entries with NO FIRST DAY **********************************************************************/
						select
									qry_type
								  ,date_type
								  ,[start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
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
								  ,[pk_gndr]
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
								  ,[pk_gndr]
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
				ae.[pk_gndr] = ext.[pk_gndr] and
				ae.cd_office= ext.cd_office  and
				ae.[int_match_param_key] = ext.[int_match_param_key] 	


/******************   insert exits with NO FIRST DAY **********************************************************************/

insert into #intk(qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,pk_gndr
,cd_office,int_match_param_key,cnt_entries)
					select 
						qry_type
						,date_type
						,[start_date]
						,[cd_reporter_type]
						,[fl_cps_invs]
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
						,[pk_gndr]
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
						,[pk_gndr]
						,cd_office
						,[int_match_param_key],cnt_exits
					from #intk

			
CREATE NONCLUSTERED INDEX idx_insert_qry_poc2
	ON #intk ([date_type],[qry_type])
	INCLUDE ([start_date],[cd_reporter_type],[fl_cps_invs]
	,[fl_phys_abuse],[fl_sexual_abuse],[fl_neglect],[fl_any_legal],[fl_founded_phys_abuse],[fl_founded_sexual_abuse]
	,[fl_founded_neglect],[fl_found_any_legal]
	,cd_sib_age_group,[cd_race_census],[census_hispanic_latino_origin_cd],[pk_gndr]
	,cd_office,[int_match_param_key],[cnt_first],[cnt_entries],[cnt_exits])

	--select date_type,qry_type,start_date,sum(cnt_first) as tot_pit
	--,sum(cnt_entries) as tot_entry,sum(cnt_exits) as tot_exit
	--,sum(cnt_first) + sum(cnt_entries) - sum(cnt_exits) as nxt_mnth
	--from #intk 
	--where qry_type=2 and date_type=0
	--group by date_type,qry_type,start_date
	--order by qry_type desc,  date_type asc, start_date asc;

	if object_ID(N'prtl.prtl_poc2ab',N'U') is not null truncate table prtl.prtl_poc2ab;
	
	-- declare @qry_type int
	set @qry_type=0
	while @qry_type <=2
	begin
	
			begin tran t1
			insert into prtl.prtl_poc2ab
			  ([qry_type]
           ,[date_type]
           ,[start_date]
           ,[start_year]
           ,[int_match_param_key]
           ,[cd_reporter_type]
           ,[fl_cps_invs]
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
           ,[fl_found_any_legal]
           ,[cd_sib_age_group]
           ,[cd_race_census]
           ,[census_hispanic_latino_origin_cd]
           ,[pk_gndr]
           ,[cd_office]
           ,[cnt_start_date]
           ,[cnt_entries]
           ,[cnt_exits])
				
			select 
				[qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,year(start_date)
				   ,[int_match_param_key]
				   ,[cd_reporter_type]
				   ,[fl_cps_invs]
				   ,case when fl_cps_invs=1 then power(10.0,5) + (power(10.0,4) * fl_cps_invs) else power(10.0,5) end as [filter_access_type]
					,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,[cd_sib_age_group]
				   ,[cd_race_census]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[cd_office]
				   ,[cnt_first]
				   ,[cnt_entries]
				   ,[cnt_exits]
				from #intk
				where qry_type=@qry_type and date_type=0;

				commit tran t1
				set @qry_type=@qry_type + 1;
		end


			begin tran t2
			insert into prtl.prtl_poc2ab
			  ([qry_type]
           ,[date_type]
           ,[start_date]
           ,[start_year]
           ,[int_match_param_key]
           ,[cd_reporter_type]
           ,[fl_cps_invs]
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
           ,[fl_found_any_legal]
           ,[cd_sib_age_group]
           ,[cd_race_census]
           ,[census_hispanic_latino_origin_cd]
           ,[pk_gndr]
           ,[cd_office]
           ,[cnt_start_date]
           ,[cnt_entries]
           ,[cnt_exits])
				
			select 
				[qry_type]
				   ,[date_type]
				   ,[start_date]
				   ,year(start_date)
				   ,[int_match_param_key]
				   ,[cd_reporter_type]
				   ,[fl_cps_invs]
				   ,case when fl_cps_invs=1 then power(10.0,5) + (power(10.0,4) * fl_cps_invs) else power(10.0,5) end as [filter_access_type]
					,power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + (fl_any_legal * 1000) as filter_allegation
				   ,power(10,4) + (([fl_founded_phys_abuse] * 1 ) + ([fl_founded_sexual_abuse] * 10) +  ([fl_founded_neglect] * 100)) + (fl_found_any_legal * 1000) as filter_finding
				   ,[fl_phys_abuse]
				   ,[fl_sexual_abuse]
				   ,[fl_neglect]
				   ,[fl_any_legal]
				   ,[fl_founded_phys_abuse]
				   ,[fl_founded_sexual_abuse]
				   ,[fl_founded_neglect]
				   ,[fl_found_any_legal]
				   ,[cd_sib_age_group]
				   ,[cd_race_census]
				   ,[census_hispanic_latino_origin_cd]
				   ,[pk_gndr]
				   ,[cd_office]
				   ,[cnt_first]
				   ,[cnt_entries]
				   ,[cnt_exits]
				from #intk
				where date_type=2;

				commit tran t2;


		update statistics prtl.prtl_poc2ab;
	  		

		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end
