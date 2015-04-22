

CREATE procedure  [prtl].[prod_build_prtl_poc2ab](@permission_key datetime) 
as 
set nocount on
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
	
	if object_id('tempDB..#myDates') is not null drop table #myDates;
	create table #mydates(date_type int,startDate datetime,endDate datetime)
		

	insert into  #mydates
	select 1,'2004-01-01', dateadd(mm,-3,[quarter] ) 
	from calendar_dim ,ref_last_dw_transfer where CALENDAR_DATE=cutoff_date
	union
	select 2,	'2004-01-01',	dateadd(yy,-1,[year]) 
	from calendar_dim ,ref_last_dw_transfer where CALENDAR_DATE=cutoff_date

	if object_id('tempDB..#cohortDates') is not null drop table #cohortDates;
	select distinct [quarter]  [cohort_date] ,date_type 
	into #cohortDates
	from  dbo.CALENDAR_DIM,#mydates
	where	[quarter] between  startDate and enddate and date_type=1
	union 
	select distinct [YEAR] ,date_type from  dbo.CALENDAR_DIM,#mydates
	where	[YEAR] between  startDate and enddate and date_type=2
	
	if object_ID('tempDB..#intakes') is not null drop table #intakes;
	select		distinct
				0 as qry_type -- unique
				,date_type  as date_type --month
				,startDate  as startdate
				,endDate as stopdate
				,tce.id_case
				,tce.first_intake_date
				,tce.latest_intake_date
				,tce.intake_grouper
				,tce.intk_grp_seq_nbr
				,tce.inv_ass_start
				,isnull(tce.inv_ass_stop,'12/31/3999') as inv_ass_stop
				,tce.intk_grp_inv_ass_start
				,tce.intk_grp_inv_ass_stop
				,tce.rfrd_date
				,iif(date_type=1,ent.[quarter],ent.[Year]) [cohort_entry_date]
				,iif(date_type=1,ext.[quarter],ext.[Year])  [cohort_exit_date]
				,iif(date_type=1,ent_intk_grp.[quarter] ,ent_intk_grp.[Year]) [intk_grp_cohort_entry_date]
				, iif(date_type=1,ext_intk_grp.[quarter],ext_intk_grp.[YEAR]) [intk_grp_cohort_exit_date]
				, tce.id_intake_fact
				,  isnull(rpt.collapsed_cd_reporter_type,-99) as cd_reporter_type
				, isnull(tce.[fl_cps_invs],0) as fl_cps_invs
				, isnull(tce.[fl_cfws],0) as fl_cfws
				, isnull(tce.[fl_risk_only],0) as [fl_risk_only]
				, isnull(tce.[fl_alternate_intervention],0) as [fl_alternate_intervention]
				, isnull(tce.[fl_frs],0) as [fl_frs]
				,isnull(tce.fl_dlr,0) [fl_dlr]
				,isnull(tce.fl_far,0)  [fl_far]
				, fl_phys_abuse
				, fl_sexual_abuse
				, fl_neglect
				, IIF( fl_phys_abuse>0
						or fl_sexual_abuse > 0
						or  fl_neglect > 0 , 1 , 0) [fl_any_legal]
				, fl_founded_phys_abuse
				, fl_founded_sexual_abuse
				, fl_founded_neglect
				, fl_founded_any_legal
				,tce.cd_sib_age_grp
				,tce.cd_race_census
				,tce.census_hispanic_latino_origin_cd
				,iif(tce.intake_county_cd=0,-99,tce.intake_county_cd) [intake_county_cd]
				, power(10,6) 
					+ (power(10,5) * tce.cd_sib_age_grp ) 
					+ (power(10,4) *   tce.cd_race_census)
					+ (power(10,3)*  tce.census_hispanic_latino_origin_cd)
					+ (power(10,0) * abs(iif(tce.intake_county_cd=0,-99,tce.intake_county_cd)) ) [int_match_param_key]
				,iif(cnt_intk_grp_phys_abuse>0,1,0) [intk_grp_phys_abuse]
				,iif(cnt_intk_grp_sexual_abuse>0,1,0) [intk_grp_sexual_abuse]
				,iif(cnt_intk_grp_neglect>0,1,0)[intk_grp_neglect]
				,iif(cnt_intk_grp_allegation_any>0,1,0) [intk_grp_allegation_any]
				,iif(cnt_intk_grp_founded_phys_abuse>0,1,0) [intk_grp_founded_phys_abuse]
				,iif(cnt_intk_grp_founded_sexual_abuse>0,1,0) [intk_grp_founded_sexual_abuse]
				,iif(cnt_intk_grp_founded_neglect>0,1,0) [intk_grp_founded_neglect]
				,iif(cnt_intk_grp_founded_any_legal>0,1,0) [intk_grp_founded_any_legal]
				, tce.intk_grp_fl_cps_invs
				,tce.intk_grp_fl_risk_only
				,tce.intk_grp_fl_far
				,tce.intk_grp_fl_alternate_intervention
				,tce.intk_grp_fl_cfws
				,tce.intk_grp_fl_frs
				,tce.intk_grp_fl_dlr
				  ,rpt2.collapsed_cd_reporter_type [intk_grp_cd_reporter_type]
				, tce.intk_grp_cd_sib_age_grp 
				, tce.intk_grp_cd_race_census  
				, tce.intk_grp_census_hispanic_latino_origin_cd 
				,iif(tce.intk_grp_intake_county_cd=0,-99,tce.intk_grp_intake_county_cd) [intk_grp_intake_county_cd]
				, power(10,6) 
					+ (power(10,5) * tce.intk_grp_cd_sib_age_grp ) 
					+ (power(10,4) *   tce.intk_grp_cd_race_census)
					+ (power(10,3)*  tce.intk_grp_census_hispanic_latino_origin_cd)
					+ (power(10,0) * abs(iif(tce.intk_grp_intake_county_cd=0,-99,tce.intk_grp_intake_county_cd) ) ) [intk_grp_int_match_param_key]
				, 0 as fl_initref_cohort_date
				, 0 as fl_frstexit_cohort_date
		into #intakes
		from vw_intakes_screened_in  tce 
		join #mydates on 1=1
		join dbo.CALENDAR_DIM ent on ent.ID_CALENDAR_DIM= convert(int,convert(varchar(8),tce.inv_ass_start,112))
		left join dbo.calendar_dim ext on ext.ID_CALENDAR_DIM=convert(int,convert(varchar(8),tce.inv_ass_stop,112)) and tce.inv_ass_stop is not null
		left join dbo.CALENDAR_DIM ent_intk_grp on ent_intk_grp.ID_CALENDAR_DIM= convert(int,convert(varchar(8),tce.intk_grp_inv_ass_start,112))
		left join dbo.calendar_dim ext_intk_grp on ext_intk_grp.ID_CALENDAR_DIM=convert(int,convert(varchar(8),tce.intk_grp_inv_ass_stop,112))
					and tce.intk_grp_inv_ass_stop is not null
		--left join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
		left join dbo.ref_xwlk_reporter_type rpt on rpt.cd_reporter_type=tce.cd_reporter
		left join dbo.ref_xwlk_reporter_type rpt2 on rpt2.cd_reporter_type=tce.intk_grp_cd_reporter_type
	WHERE tce.id_case>0 
	and (tce.inv_ass_start <= ISNULL(TCE.inv_ass_stop,'12/31/3999')
	and ((tce.inv_ass_start <=startDate and ISNULL(TCE.inv_ass_stop,'12/31/3999') >=startDate)
			or tce.inv_ass_start >=startDate))
	and tce.cd_final_decision=1 
	and tce.fl_reopen_case=0
	and (fl_cfws = 1 or fl_frs=1 or fl_risk_only=1 or fl_alternate_intervention=1
			or fl_cps_invs=1 or   tce.fl_dlr=1 or tce.fl_far=1)
	--  and tce.cd_spvr_rsn in (1,2,3)
	and tce.cd_access_type in (1,2,4)
	ORDER BY  tce.id_case,TCE.inv_ass_start

			    		
		update intk
		set intk.fl_initref_cohort_date=row_num
		from #intakes intk
		join (select *,row_number() over (
					partition by id_case
										,cohort_entry_date
										,date_type 
					order by rfrd_date asc,id_intake_fact asc) row_num
		from #intakes
		) q on  q.id_intake_fact=intk.id_intake_fact and row_num=1 
		where intk.date_type=q.date_type
					

			
										
		update intk
		set intk.fl_frstexit_cohort_date=row_num
		from #intakes intk
		join (select *,row_number() over (
				partition by id_case
								,cohort_exit_date
								,date_type 
				order by inv_ass_stop asc,id_intake_fact asc) row_num
		from #intakes
		) q on  q.id_intake_fact=intk.id_intake_fact and row_num=1
		where intk.date_type=q.date_type
	
				--select cohort_entry_date,count( id_case)
				--from #intakes
				--where date_type=2 and qry_type=0 and fl_initref_cohort_date=1 and cohort_entry_date >='2004-01-01'
				--group by cohort_entry_date
				--order by cohort_entry_date

				--	select id_case,date_type,cohort_exit_date,sum(fl_frstexit_cohort_date) from #intakes group by id_case,date_type,cohort_exit_date
				--having sum(fl_frstexit_cohort_date)>1
						
				--select id_case,date_type,cohort_entry_date,sum(fl_initref_cohort_date) from #intakes group by id_case,date_type,cohort_entry_date
				--having sum(fl_initref_cohort_date)>1
												
		create index idx_case_start_stop on #intakes(id_case,inv_ass_start,inv_ass_stop)
		create index idx_id_intake_fact on #intakes(id_intake_fact);
		create index idx_first_start on #intakes(first_intake_date,rfrd_date,fl_initref_cohort_date);
		create index idx_first_start2 on #intakes(first_intake_date,rfrd_date,fl_initref_cohort_date);
		create index idx_stop_date on #intakes(inv_ass_stop,fl_frstexit_cohort_date);
		create index idx_stop_date2 on #intakes(inv_ass_stop,fl_frstexit_cohort_date);
					
		update statistics #intakes;
					
		--select id_case,date_type,startdate,stopdate,intake_grouper,intk_grp_seq_nbr
		--					,fl_initref_cohort_date,cohort_entry_date,fl_frstexit_cohort_date,cohort_exit_date
		--from #intakes order by id_case,date_type,intake_grouper,intk_grp_seq_nbr
				

	--loh		

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
									fl_dlr int not null,
									fl_far int not null,
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
									intake_county_cd [int] NOT NULL,
									cnt_first int not null default 0,
									cnt_entries int not null default 0,
									cnt_exits int  not null default 0,
									);


			insert into #intk (qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs,fl_alternate_intervention,
						fl_risk_only ,
						fl_frs,
						fl_cfws,fl_dlr,fl_far,fl_phys_abuse
						,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
						,fl_found_any_legal
						,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
						,intake_county_cd,int_match_param_key,cnt_first)

/*************************************  qry_type ALL    ALL   ***********************************************************/
							SELECT 2 [qry_type]
								  ,md.[date_type]
								  ,[cohort_date]   [start_date]
								  ,intk_grp_cd_reporter_type
								  ,intk_grp_fl_cps_invs
								  ,intk_grp_fl_alternate_intervention
								  ,intk_grp_fl_risk_only
								  ,intk_grp_fl_frs
								  ,intk_grp_fl_cfws
								  ,intk_grp_fl_dlr
								  ,intk_grp_fl_far
								  ,intk_grp_phys_abuse
								  ,intk_grp_sexual_abuse
								  ,intk_grp_neglect
								  ,intk_grp_allegation_any
								  ,intk_grp_founded_phys_abuse
								  ,intk_grp_founded_sexual_abuse
								  ,intk_grp_founded_neglect
								  ,intk_grp_founded_any_legal
								   ,intk_grp_cd_sib_age_grp
								  ,intk_grp_cd_race_census
								  ,intk_grp_census_hispanic_latino_origin_cd
								  ,intk_grp_intake_county_cd
								  ,intk_grp_int_match_param_key
								  ,count( distinct intake_grouper) as cnt_ref
						  from #intakes
						  join #mydates md on md.date_type=#intakes.date_type
						  join #cohortDates  cd on 
						   intk_grp_inv_ass_start < cd.[cohort_date]
						  and intk_grp_inv_ass_stop >=cd.[cohort_date]
						  and cd.date_type=md.date_type
						  group by    [cohort_date]   ,md.date_type
								  ,intk_grp_cd_reporter_type
								  ,intk_grp_fl_cps_invs
								  ,intk_grp_fl_alternate_intervention
								  ,intk_grp_fl_risk_only
								  ,intk_grp_fl_frs
								  ,intk_grp_fl_cfws
								  ,intk_grp_fl_dlr
								  ,intk_grp_fl_far
								  ,intk_grp_phys_abuse
								  ,intk_grp_sexual_abuse
								  ,intk_grp_neglect
								  ,intk_grp_allegation_any
								  ,intk_grp_founded_phys_abuse
								  ,intk_grp_founded_sexual_abuse
								  ,intk_grp_founded_neglect
								  ,intk_grp_founded_any_legal
								   ,intk_grp_cd_sib_age_grp
								  ,intk_grp_cd_race_census
								  ,intk_grp_census_hispanic_latino_origin_cd
								  ,intk_grp_intake_county_cd
								  ,intk_grp_int_match_param_key
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,md.[date_type]
								  ,cd.cohort_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws,fl_dlr,fl_far
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
								  ,intake_county_cd
								  ,[int_match_param_key]
								  ,count( distinct id_intake_fact) as cnt_ref
						  from #intakes
						  join #mydates md on md.date_type=#intakes.date_type
						  join #cohortDates  cd on  inv_ass_start < cd.[cohort_date]
						  and inv_ass_stop >=cd.[cohort_date]
						  and md.date_type=cd.date_type
						  where rfrd_date=first_intake_date
						and fl_initref_cohort_date=1
						  group by   cd.[cohort_date] ,md.date_type
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws,fl_dlr,fl_far
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
								  ,intake_county_cd
								  ,[int_match_param_key]
		UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,q.[date_type]
								  ,cd.cohort_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws,q.fl_dlr,q.fl_far
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
								  ,q.intake_county_cd
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes
						  join #mydates md on md.date_type=#intakes.date_type
						   join #cohortDates  cd on  inv_ass_start < cd.[cohort_date]
						  and inv_ass_stop >=cd.[cohort_date]
						  and md.date_type=cd.date_type
						  join (select md.date_type
								,id_case,id_intake_fact
								,rfrd_date 
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws,fl_dlr,fl_far
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
								  ,intake_county_cd
								  ,[int_match_param_key]
						  		  ,row_number() over 
									(partition by id_case,md.date_type  ,cd.cohort_date
									 order by rfrd_date asc,id_intake_fact asc) as row_num
								from #intakes 
								 join #mydates md on md.date_type=#intakes.date_type
								join #cohortDates  cd on  inv_ass_start < cd.[cohort_date]
									 and inv_ass_stop >=cd.[cohort_date]
									 and md.date_type=cd.date_type
								) q on q.row_num=1 and q.id_intake_fact=#intakes.id_intake_fact 
										and q.date_type=#intakes.date_type
							  group by   cd.cohort_date ,q.date_type
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws,q.fl_dlr,q.fl_far
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
								  ,q.intake_county_cd
								  ,q.[int_match_param_key]
		
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
									fl_dlr int not null,
									fl_far int not null,
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
									intake_county_cd [int] NOT NULL,
									cnt_entries int not null default 0,
												);

						insert into #entries (qry_type,date_type,start_date,cd_reporter_type,[fl_cps_invs]
														  ,fl_alternate_intervention
														  ,fl_risk_only
														  ,fl_frs
														  ,fl_cfws,fl_dlr,fl_far	,fl_phys_abuse
						,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
						,fl_found_any_legal
						,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
						,intake_county_cd,int_match_param_key,cnt_entries)


							SELECT 2 as qry_type
								  ,md. [date_type]
								  ,intk_grp_cohort_entry_date as [start_date]
								   ,intk_grp_cd_reporter_type
								  ,intk_grp_fl_cps_invs
								  ,intk_grp_fl_alternate_intervention
								  ,intk_grp_fl_risk_only
								  ,intk_grp_fl_frs
								  ,intk_grp_fl_cfws
								  ,intk_grp_fl_dlr
								  ,intk_grp_fl_far
								  ,intk_grp_phys_abuse
								  ,intk_grp_sexual_abuse
								  ,intk_grp_neglect
								  ,intk_grp_allegation_any
								  ,intk_grp_founded_phys_abuse
								  ,intk_grp_founded_sexual_abuse
								  ,intk_grp_founded_neglect
								  ,intk_grp_founded_any_legal
								   ,intk_grp_cd_sib_age_grp
								  ,intk_grp_cd_race_census
								  ,intk_grp_census_hispanic_latino_origin_cd
								  ,intk_grp_intake_county_cd
								  ,intk_grp_int_match_param_key
								  ,count( distinct intake_grouper) as cnt_ref
						  from #intakes
						  join #mydates md on md.date_type=#intakes.date_type
						   and  intk_grp_cohort_entry_date between md.startDate and md.endDate
						  group by    md. [date_type]
									,intk_grp_cohort_entry_date 
								   ,intk_grp_cd_reporter_type
								  ,intk_grp_fl_cps_invs
								  ,intk_grp_fl_alternate_intervention
								  ,intk_grp_fl_risk_only
								  ,intk_grp_fl_frs
								  ,intk_grp_fl_cfws
								  ,intk_grp_fl_dlr
								  ,intk_grp_fl_far
								  ,intk_grp_phys_abuse
								  ,intk_grp_sexual_abuse
								  ,intk_grp_neglect
								  ,intk_grp_allegation_any
								  ,intk_grp_founded_phys_abuse
								  ,intk_grp_founded_sexual_abuse
								  ,intk_grp_founded_neglect
								  ,intk_grp_founded_any_legal
								   ,intk_grp_cd_sib_age_grp
								  ,intk_grp_cd_race_census
								  ,intk_grp_census_hispanic_latino_origin_cd
								  ,intk_grp_intake_county_cd
								  ,intk_grp_int_match_param_key
				
				UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,md.[date_type]
								  ,cohort_entry_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_dlr,fl_far
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
								  ,intake_county_cd
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						  from #intakes
						  join #mydates md on md.date_type=#intakes.date_type
						  and cohort_entry_date between md.startDate and md.endDate
						  where  rfrd_date=first_intake_date
							and fl_initref_cohort_date=1
						  group by  md.date_type, cohort_entry_date
									  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_dlr,fl_far
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
								  ,intake_county_cd
								  ,[int_match_param_key]
					UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,q.[date_type]
								  ,q.cohort_entry_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws,q.fl_dlr,q.fl_far
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
								  ,q.intake_county_cd
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes q
						  join #mydates md on md.date_type=q.date_type
						  where cohort_entry_date between md.startDate and md.endDate
						  and q.fl_initref_cohort_date=1
						  group by   q.cohort_entry_date
								,q.date_type
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws,q.fl_dlr,q.fl_far
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
								  ,q.intake_county_cd
								  ,q.[int_match_param_key]

			--select start_date,sum(cnt_entries)
			--from #entries
			--where date_type=2 and qry_type=0 and start_date >='2004-01-01'
			--group by start_date
			--order by start_date	

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
									fl_dlr int not null,
									fl_far int not null,
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
									intake_county_cd [int] NOT NULL,
									cnt_exits int not null default 0,
												);


						insert into #exits (qry_type,date_type,start_date,cd_reporter_type,[fl_cps_invs]
														  ,fl_alternate_intervention
														  ,fl_risk_only
														  ,fl_frs
														  ,fl_cfws	,fl_dlr,fl_far,fl_phys_abuse
														,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
														,fl_found_any_legal
														,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
														,intake_county_cd,int_match_param_key,cnt_exits)


							SELECT 2 as qry_type
								  ,md.[date_type]
								  ,intk_grp_cohort_exit_date as [start_date]
								   ,intk_grp_cd_reporter_type
								  ,intk_grp_fl_cps_invs
								  ,intk_grp_fl_alternate_intervention
								  ,intk_grp_fl_risk_only
								  ,intk_grp_fl_frs
								  ,intk_grp_fl_cfws
								  ,intk_grp_fl_dlr
								  ,intk_grp_fl_far
								  ,intk_grp_phys_abuse
								  ,intk_grp_sexual_abuse
								  ,intk_grp_neglect
								  ,intk_grp_allegation_any
								  ,intk_grp_founded_phys_abuse
								  ,intk_grp_founded_sexual_abuse
								  ,intk_grp_founded_neglect
								  ,intk_grp_founded_any_legal
								   ,intk_grp_cd_sib_age_grp
								  ,intk_grp_cd_race_census
								  ,intk_grp_census_hispanic_latino_origin_cd
								  ,intk_grp_intake_county_cd
								  ,intk_grp_int_match_param_key [int_match_param_key]
								  ,count( distinct intake_grouper) as cnt_ref
						  from #intakes
						  join #mydates md on md.date_type=#intakes.date_type
						  where intk_grp_cohort_exit_date between md.startDate and md.endDate
						  group by    intk_grp_cohort_exit_date
									,md.date_type
									,intk_grp_cd_reporter_type
									,intk_grp_fl_cps_invs
									,intk_grp_fl_alternate_intervention
									,intk_grp_fl_risk_only
									,intk_grp_fl_frs
									,intk_grp_fl_cfws
									,intk_grp_fl_dlr
									,intk_grp_fl_far
									,intk_grp_phys_abuse
									,intk_grp_sexual_abuse
									,intk_grp_neglect
									,intk_grp_allegation_any
									,intk_grp_founded_phys_abuse
									,intk_grp_founded_sexual_abuse
									,intk_grp_founded_neglect
									,intk_grp_founded_any_legal
									,intk_grp_cd_sib_age_grp
									,intk_grp_cd_race_census
									,intk_grp_census_hispanic_latino_origin_cd
									,intk_grp_intake_county_cd
									,intk_grp_int_match_param_key
							UNION ALL
				----FIRST 
							SELECT 1 as qry_type
								  ,	md.[date_type]
								  ,cohort_exit_date  as [start_date]
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_dlr,fl_far
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
								  
								  ,intake_county_cd
								  ,[int_match_param_key]
								  ,count(distinct id_case) as cnt_ref
						 
						  from #intakes
						  join #mydates md on md.date_type=#intakes.date_type
						  where cohort_exit_date between md.startDate and md.endDate
						  and rfrd_date=first_intake_date
						  and fl_initref_cohort_date=1
						  group by   cohort_exit_date,md.date_type
								  ,[cd_reporter_type]
								  ,[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_dlr,fl_far
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
								  
								  ,intake_county_cd
								  ,[int_match_param_key]
			UNION ALL
			-- unique is NOT same as all as you can have many open intakes for the same case on the same day
						SELECT 0 as qry_type
								  ,q.[date_type]
								  ,cohort_exit_date  as [start_date]
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws,q.fl_dlr,q.fl_far
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
								  ,q.intake_county_cd
								  ,q.[int_match_param_key]
								  ,count(distinct q.id_case) as cnt_referrals
						  from #intakes q
						  join #mydates md on md.date_type=q.date_type
						  where cohort_exit_date between md.startDate and md.endDate
						  and fl_frstexit_cohort_date=1
						  group by   cohort_exit_date
								,q.date_type
								  ,q.[cd_reporter_type]
								  ,q.[fl_cps_invs]
								  ,q.fl_alternate_intervention
								  ,q.fl_risk_only
								  ,q.fl_frs
								  ,q.fl_cfws,q.fl_dlr,q.fl_far
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
								  ,q.intake_county_cd
								  ,q.[int_match_param_key]
								ORDER BY date_type,qry_type,[start_date],int_match_param_key;

--select  e.start_date,sum(e.cnt_exits)
--from #exits  e
--where qry_type=2 and date_type=2
--group by e.start_date
--order by e.start_date

	
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
				ae.fl_dlr=ent.fl_dlr and 
				ae.fl_far=ent.fl_far and
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
				ae.intake_county_cd= ent.intake_county_cd  and
				ae.[int_match_param_key] = ent.[int_match_param_key];
		
			

insert into #intk(qry_type,date_type,start_date,cd_reporter_type,
								  [fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_dlr,fl_far,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
,intake_county_cd,int_match_param_key,cnt_entries)
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
								  ,fl_cfws	,fl_dlr,fl_far
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
									  ,intake_county_cd
								  ,[int_match_param_key]
								  ,cnt_entries
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
								  ,fl_cfws	,fl_dlr,fl_far
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
									  ,intake_county_cd
								  ,[int_match_param_key]
								  ,cnt_entries
								from #intk
--select  e.start_date,sum(e.cnt_entries)
--from #intk  e
--where qry_type=0 and date_type=2
--group by e.start_date
--order by e.start_date



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
				ae.fl_dlr=ext.fl_dlr and
				ae.fl_far=ext.fl_far and
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
				ae.intake_county_cd= ext.intake_county_cd  and
				ae.[int_match_param_key] = ext.[int_match_param_key] 	;


/******************   insert exits with NO FIRST DAY NO ENTRIES **********************************************************************/

insert into #intk(qry_type,date_type,start_date,cd_reporter_type,fl_cps_invs	
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws	,fl_dlr,fl_far,fl_phys_abuse
,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect
,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd
,intake_county_cd,int_match_param_key,cnt_exits)
					select 
						qry_type
						,date_type
						,[start_date]
						,[cd_reporter_type]
						,[fl_cps_invs]
						,fl_alternate_intervention
						,fl_risk_only
						,fl_frs
						,fl_cfws	,fl_dlr,fl_far
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
						
						,intake_county_cd
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
						,fl_cfws	,fl_dlr,fl_far
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
						
						,intake_county_cd
						,[int_match_param_key],cnt_exits
					from #intk

			
CREATE NONCLUSTERED INDEX idx_insert_qry_poc2
	ON #intk ([date_type],[qry_type])
	INCLUDE ([start_date],[cd_reporter_type],[fl_cps_invs]
								  ,fl_alternate_intervention
								  ,fl_risk_only
								  ,fl_frs
								  ,fl_cfws,fl_dlr,fl_far
	,[fl_phys_abuse],[fl_sexual_abuse],[fl_neglect],[fl_any_legal],[fl_founded_phys_abuse],[fl_founded_sexual_abuse]
	,[fl_founded_neglect],[fl_found_any_legal]
	,cd_sib_age_group,[cd_race_census],[census_hispanic_latino_origin_cd]
	,intake_county_cd,[int_match_param_key],[cnt_first],[cnt_entries],[cnt_exits])

	--select date_type,qry_type,start_date,sum(cnt_first) as tot_pit
	--,sum(cnt_entries) as tot_entry,sum(cnt_exits) as tot_exit
	--,sum(cnt_first) + sum(cnt_entries) - sum(cnt_exits) as nxt_mnth
	--from #intk 
	--where qry_type=2 and date_type=0
	--group by date_type,qry_type,start_date
	--order by qry_type desc,  date_type asc, start_date asc;
	alter table prtl.prtl_poc2ab NOCHECK CONSTRAINT ALL;
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
           ,[county_cd]
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
				   , (select cd_multiplier from ref_filter_access_type where cd_access_type=0 )
				   							+  fl_dlr * (select cd_multiplier from ref_filter_access_type where fl_name='fl_dlr')
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
						+ ([fl_found_any_legal] * (select cd_multiplier from ref_filter_finding where fl_name='fl_any_finding_legal')) [filter_finding]
				   ,[cd_sib_age_group]
				   ,[cd_race_census]
				   ,[census_hispanic_latino_origin_cd]
				   ,[intake_county_cd]
				   ,[cnt_first]
				   ,[cnt_entries]
				   ,[cnt_exits]
				from #intk

				alter table prtl.prtl_poc2ab CHECK CONSTRAINT ALL;




		


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

