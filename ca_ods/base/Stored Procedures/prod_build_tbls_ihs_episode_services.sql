CREATE PROCEDURE [base].[prod_build_tbls_ihs_episode_services](@permission_key datetime, @debug smallint = 0)
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
	declare @max_case_sort int;
	declare @case_sort int;
			
	select @cutoff_date=cutoff_date from ref_last_dw_transfer;
	set @start_date=cast('1/1/1997' as datetime)
		
		
	if object_ID('tempDB..#eps') is not null drop table #eps
	
	select *,row_number() over (partition by id_case order by eps_begin,eps_end  asc) as sort_asc
	into #eps
	from (
		select distinct id_case,state_custody_start_date as eps_begin
		,isnull(federal_discharge_date,'12/31/3999') as eps_end
		from base.tbl_child_episodes ) eps

	if object_ID('tempDB..#ihs_intk') is not null drop table #ihs_intk	
		CREATE TABLE #ihs_intk
		(ID_INTAKE_FACT INT not null
		, ID_CASE INT not null
		, INV_ASS_START DATETIME not null
		, CD_RACE_CENSUS_HH INT not null
		, CENSUS_HISPANIC_LATINO_ORIGIN_CD_HH INT not null
		, cd_sib_age_grp int not null
		, frst_rfrd_date datetime not null
		, cd_asgn_type int 
		, tx_asgn_type varchar(200)
		, case_nxt_intake datetime
		, fl_cps_invs int 
		, fl_cfws int 
		, fl_frs int 
		, fl_alternate_intervention int 
		, fl_risk_only int 
		, fl_phys_abuse int 
		, fl_founded_phys_abuse int 
		, fl_sexual_abuse int 
		, fl_founded_sexual_abuse int 
		, fl_neglect int 
		, fl_founded_neglect int 
		, fl_other_maltreatment int 
		, fl_founded_other_maltreatment int 
		, fl_prior_phys_abuse int 
		, fl_founded_prior_phys_abuse int 
		, fl_prior_sexual_abuse int 
		, fl_founded_prior_sexual_abuse int 
		, fl_prior_neglect int 
		, fl_founded_prior_negelect int 
		, fl_prior_other_maltreatment int 
		, fl_founded_prior_other_maltreatment int 
		,intake_county_cd int
		,intake_zip nvarchar(10)
		, PRIMARY KEY (ID_CASE ,INV_ASS_START ,ID_INTAKE_FACT ))
		
		
		INSERT INTO #ihs_intk
		select DISTINCT id_intake_fact
				, id_case
				, inv_ass_start
				, CD_RACE_CENSUS
				, CENSUS_HISPANIC_LATINO_ORIGIN_CD
				, cd_sib_age_grp
				, TBL_INTAKES.first_intake_date
				, cd_asgn_type
				, tx_asgn_type
				, tbl_intakes.case_nxt_intake_dt
				, fl_cps_invs
				, fl_cfws
				, fl_frs
				, fl_alternate_intervention
				, fl_risk_only
				, fl_phys_abuse
				, fl_founded_phys_abuse
				, fl_sexual_abuse
				, fl_founded_sexual_abuse
				, fl_neglect
				, fl_founded_neglect
				, fl_other_maltreatment
				, fl_founded_other_maltreatment
				, fl_prior_phys_abuse
				, fl_founded_prior_phys_abuse
				, fl_prior_sexual_abuse
				, fl_founded_prior_sexual_abuse
				, fl_prior_neglect
				, fl_founded_prior_neglect
				, fl_prior_other_maltreatment
				, fl_founded_prior_other_maltreatment
				, intake_county_cd
				, intake_zip
		from base.TBL_INTAKES
		where coalesce(inv_ass_stop,'12/31/3999') >= @start_date
			and inv_ass_start <=@cutoff_date
			and fl_dlr=0
			and cd_final_decision=1
			and id_case > 0;
			
			
			
	-- 2. only want the CPS screened in for services
	if object_id('tempDB..#cps') is not null drop table #cps;
	
	SELECT HM.* ,DD.CD_INVS_DISP,DD.tx_INVS_DISP  
	 into #cps
	 FROM #ihs_intk HM
	 JOIN base.TBL_INTAKES IVF ON IVF.ID_INTAKE_FACT=HM.ID_INTAKE_FACT
	 JOIN dbo.INVESTIGATION_ASSESSMENT_FACT iaf ON IAF.ID_INVESTIGATION_ASSESSMENT_FACT=IVF.ID_INVESTIGATION_ASSESSMENT_FACT
	 JOIN dbo.DISPOSITION_DIM DD ON DD.ID_DISPOSITION_DIM=IAF.ID_DISPOSITION_DIM
	 WHERE DD.CD_INVS_DISP IN (3,4,6) and HM.cd_asgn_type=4
	 and ivf.id_investigation_assessment_fact is not null
	 
	 
	 
		 
		--DELETE CPS EXCEPT THOSE WITH SERVICES
		DELETE IH
		--select *
		 FROM #ihs_intk ih
		WHERE ih.cd_asgn_type=4 and IH.id_intake_fact not in (select id_intake_fact from #cps);			
		
		CREATE INDEX IDX_ID_CASE_INV_ASS_START_TMP ON #ihs_intk(id_case,inv_ass_start) INCLUDE (id_intake_fact,
				CD_RACE_CENSUS_HH,CENSUS_HISPANIC_LATINO_ORIGIN_CD_HH,cd_sib_age_grp);
	
		
-- start retrieving all assignments that are either designated 'out-of-home care' or cps for social workers

		
	if object_ID('tempDB..#ih_assgn_all') is not null drop table #ih_assgn_all
	SELECT  
			af.ID_CASE as id_case
		, inf.ID_INTAKE_FACT
		, inf.INV_ASS_START as rfrd_date
		, min(af.ID_ASSIGNMENT_FACT) as id_table_origin
		, max(af.id_assignment_fact) as max_id_table_origin
		, count(*) as cnt_id_table_origin
		, dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN) as ihs_begin_date
		, max(case when isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END),'12/31/3999') > coalesce(dt_case_cls,'12/31/3999')
					then dt_case_cls
		  else isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_END),'12/31/3999') 
		  end )as ihs_end_date
		, cast(null as bigint) as case_sort
		, cast(null as datetime) as first_ihs_date
		, cast(null as datetime) as latest_ihs_date
		, cast(null as int) as fl_plcmnt_prior_ihs
		, cast(null as int) as fl_plcmnt_during_ihs
		, cast(null as datetime) as plcmnt_date
		,  max(intake_county_cd) [intake_county_cd]
		,  max(intake_zip) [intake_zip]
		, datediff(dd,inv_ass_start,dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN)) as days_from_rfrd_date
		, cast(0 as int) as nbr_svc_paid 
		, cast(0 as numeric(18,2)) as total_amt_paid
		, cast(0 as int) as most_exp_cd_srvc
		, cast(null as varchar(200)) as most_exp_tx_srvc
		, cast(0 as numeric(18,2)) as total_most_exp_srvc
		, cast(0 as int) as fl_family_focused_services
		, cast(0 as int) as fl_child_care
		, cast(0 as int) as fl_therapeutic_services
		, cast(0 as int) as fl_behavioral_rehabiliation_services
		, cast(0 as int) as fl_other_therapeutic_living_situations
		, cast(0 as int) as fl_specialty_adolescent_services
		, cast(0 as int) as fl_respite
		, cast(0 as int) as fl_transportation
		, cast(0 as int) as fl_ihs_reun
		, cast(0 as int) as fl_concrete_goods
		, cast(0 as int) as fl_budget_C12
		, cast(0 as int) as fl_budget_C14
		, cast(0 as int) as fl_budget_C15
		, cast(0 as int) as fl_budget_C16
		, cast(0 as int) as fl_budget_C18
		, cast(0 as int) as fl_budget_C19
		, cast(0 as int) as fl_uncat_svc
		, aad.cd_asgn_type
		, aad.tx_asgn_type
		, cast(0 as int) as fl_force_end_date
		, cast('assignment_fact' as varchar(50)) as tbl_origin 
		, cast(1 as int) as tbl_origin_cd
		, 0 as frst_IHS_after_intk
	into #ih_assgn_all
	FROM #ihs_intk inf 
 		join dbo.ASSIGNMENT_FACT af on inf.id_case=af.id_case
			AND INF.INV_ASS_START <=dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN)
		join dbo.ASSIGNMENT_ATTRIBUTE_DIM aad on af.ID_ASSIGNMENT_ATTRIBUTE_DIM=aad.ID_ASSIGNMENT_ATTRIBUTE_DIM
		join dbo.worker_dim wd on wd.id_worker_dim=af.id_worker_dim and wd.CD_JOB_CLS in (9,10,11)
		left join base.TBL_case_dim cd on cd.id_case=af.id_case
				and dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN)<dt_case_cls
				and coalesce(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),'12/31/3999')>dt_case_opn
		WHERE  inf.id_case>0 and dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN) >= inf.INV_ASS_START and 
				dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN) < isnull(inf.case_nxt_intake,'12/31/3999')
			and (
					(
					aad.CD_ASGN_RSPNS=7 
					and aad.CD_ASGN_CTGRY=1 
					and aad.CD_ASGN_TYPE in (9,8,5)
					and	(
							(
								aad.CD_ASGN_ROLE =2 
								and  isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
											 > @start_date 
								and  isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime)) 
										<= cast('2009-01-29' as datetime)
							)
						or (
								aad.CD_ASGN_ROLE=1 
								and isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
										 > @start_date
							)
						)
					)
			or (
				CD_ASGN_CTGRY=1  and aad.CD_ASGN_TYPE=4
				and (
						(
							CD_ASGN_ROLE=2 
							AND isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
										 <= cast('2009-01-29' as datetime)
							AND  isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime)) 
										> @start_date
						)
					
					or (
							CD_ASGN_ROLE=1 
							and isnull(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),cast('12/31/3999' as datetime))
									 > @start_date
						)	
					)
				)
			)
		group by inf.id_intake_fact,af.ID_CASE,dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN) ,aad.cd_asgn_type
		, aad.tx_asgn_type,inf.INV_ASS_START
	  order by af.ID_CASE,inf.id_intake_fact,[ihs_begin_date],[ihs_end_date]


	  --if object_id('debug.ih_assgn_all_1') is not null drop table debug.ih_assgn_all_1;
	  --if @debug = 1 select * into debug.ih_assgn_all_1 from #ih_assgn_all


	  -- only want one intake per assignment
	  delete IH
	  from #ih_assgn_all IH
	  join (
			select id_case,ihs_begin_date,id_table_origin,id_intake_fact ,(days_from_rfrd_date) ,row_number() over 
			(partition by id_table_origin order by days_from_rfrd_date asc) as row_num
			from #ih_assgn_all
			--order by id_case,id_table_origin
			) q on q.id_case=IH.id_case
			and q.ihs_begin_date=IH.ihs_begin_date
			and q.id_table_origin=IH.id_table_origin
			and q.ID_INTAKE_FACT <> ih.ID_INTAKE_FACT
			and q.row_num=1

		--if object_id('debug.ih_assgn_all_2') is not null drop table debug.ih_assgn_all_2;
		--if @debug = 1 select * into debug.ih_assgn_all_2 from #ih_assgn_all


	  -- BEGIN DELETE THOSE WITH OVERLAPPING OUT OF HOME CARE ------------------------------------------------------
		update ihs
		set ihs_end_date=eps_begin
				,ihs.fl_force_end_date=1
				,ihs.plcmnt_date=tce.eps_begin
			--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from #ih_assgn_all ihs  
		join #eps tce on tce.id_case=ihs.id_case
		and tce.eps_begin < ihs.ihs_end_date
		and tce.eps_end >=ihs.ihs_begin_date 
		and eps_begin > ihs_begin_date 
		-- and state_custody_start_date < ihs_end_date


		--if object_id('debug.ih_assgn_all_3') is not null drop table debug.ih_assgn_all_3;
		--if @debug = 1 select * into debug.ih_assgn_all_3 from #ih_assgn_all

		delete ihs
		--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from #ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 


		--if object_id('debug.ih_assgn_all_4') is not null drop table debug.ih_assgn_all_4;
		--if @debug = 1 select * into debug.ih_assgn_all_4 from #ih_assgn_all
				
		update ihs
		set ihs_end_date=state_custody_start_date
		,ihs.fl_force_end_date=1
		,ihs.plcmnt_date=tce.state_custody_start_date
		--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from #ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_intake_fact=ihs.id_intake_fact
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 
		and tce.state_custody_start_date < ihs.ihs_end_date
		and state_custody_start_date > ihs_begin_date 
		-- and state_custody_start_date < ihs_end_date


		--if object_id('debug.ih_assgn_all_5') is not null drop table debug.ih_assgn_all_5;
		--if @debug = 1 select * into debug.ih_assgn_all_5 from #ih_assgn_all

		delete ihs
		from #ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_intake_fact=ihs.id_intake_fact
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 

		CREATE NONCLUSTERED INDEX  idx_temp_assgn_all on #ih_assgn_all ([id_table_origin],max_id_table_origin)

		if object_id('debug.ih_assgn_all_6') is not null drop table debug.ih_assgn_all_6;
		if @debug = 1 select * into debug.ih_assgn_all_6 from #ih_assgn_all
		
		--MERGE RECORDS 
		--- sort your data
		update ihs
		set case_sort=q.row_num
		from #ih_assgn_all ihs
		join (	select *
				, row_number() over (partition by id_case order by ihs_begin_date asc
											,ihs_end_date asc) as row_num
				from  #ih_assgn_all) q on q.id_table_origin=ihs.id_table_origin and q.max_id_table_origin=ihs.max_id_table_origin

	
		if object_id('debug.ih_assgn_all_7') is not null drop table debug.ih_assgn_all_7;
		if @debug = 1 select * into debug.ih_assgn_all_7 from #ih_assgn_all

		if object_id('tempDB..#ih_tmp') is not null drop table #ih_tmp
		select * into #ih_tmp from #ih_assgn_all;

		CREATE NONCLUSTERED INDEX idx_case_begin
		on #ih_tmp ([id_case],[ihs_begin_date])
		INCLUDE ([ID_INTAKE_FACT],[rfrd_date],[id_table_origin],[max_id_table_origin],[cnt_id_table_origin],[ihs_end_date],[case_sort],[first_ihs_date],[latest_ihs_date],[fl_plcmnt_prior_ihs],[fl_plcmnt_during_ihs],[plcmnt_date],intake_county_cd,intake_zip,[days_from_rfrd_date],[nbr_svc_paid],[total_amt_paid],[most_exp_cd_srvc],[most_exp_tx_srvc],[total_most_exp_srvc],[fl_family_focused_services],[fl_child_care],[fl_therapeutic_services]
--		,[fl_mh_services],[fl_receiving_care],[fl_family_home_placements]
		,[fl_behavioral_rehabiliation_services],[fl_other_therapeutic_living_situations],[fl_specialty_adolescent_services],[fl_respite],[fl_transportation]
		--,[fl_clothing_incidentals],[fl_sexually_aggressive_youth],[fl_adoption_support],[fl_various],[fl_medical]
		,fl_ihs_reun,fl_concrete_goods,[fl_budget_C12],[fl_budget_C14],[fl_budget_C15],[fl_budget_C16],[fl_budget_C18],[fl_budget_C19],[fl_uncat_svc],[cd_asgn_type],[tx_asgn_type],[fl_force_end_date],[tbl_origin],[tbl_origin_cd],[frst_IHS_after_intk]
		)
		

		declare @t Table (id_case int not null,
					ihs_begin_date datetime NULL,
					ihs_end_date datetime NULL,
					case_sort bigint NULL )
		
		insert into @t (id_case,ihs_begin_date,ihs_end_date,case_sort)
		select id_case ,
					ihs_begin_date ,
					ihs_end_date ,
					case_sort from #ih_tmp  order by id_case,case_sort

		if object_id('debug.t_1') is not null drop table debug.t_1;
		if @debug = 1 select * into debug.t_1 from @t


		truncate table #ih_assgn_all;

	
		insert into #ih_assgn_all
		select 
			q.id_case
			,asgn.ID_INTAKE_FACT
			,asgn.rfrd_date
			,asgn.min_id_table_origin
			,asgn.max_id_table_origin
			,asgn.cnt_id_table_origin
			,q.ihs_begin_date
			,q.ihs_end_date
			,asgn.case_sort
			,asgn.first_ihs_date
			,asgn.latest_ihs_date
			,asgn.fl_plcmnt_prior_ihs
			,asgn.fl_plcmnt_during_ihs
			,asgn.plcmnt_date
			,asgn.intake_county_cd
			,asgn.intake_zip
			,asgn.days_from_rfrd_date
			,asgn.nbr_svc_paid
			,asgn.total_amt_paid
			,asgn.most_exp_cd_srvc
			,asgn.most_exp_tx_srvc
			,asgn.total_most_exp_srvc
			,asgn.fl_family_focused_services
			,asgn.fl_child_care
			,asgn.fl_therapeutic_services
			--,asgn.fl_mh_services
			--,asgn.fl_receiving_care
			--,asgn.fl_family_home_placements
			,asgn.fl_behavioral_rehabiliation_services
			,asgn.fl_other_therapeutic_living_situations
			,asgn.fl_specialty_adolescent_services
			,asgn.fl_respite
			,asgn.fl_transportation
			--,asgn.fl_clothing_incidentals
			--,asgn.fl_sexually_aggressive_youth
			--,asgn.fl_adoption_support
			--,asgn.fl_various
			--,asgn.fl_medical
			,asgn.fl_ihs_reun
			,asgn.fl_concrete_goods
			,asgn.fl_budget_C12
			,asgn.fl_budget_C14
			,asgn.fl_budget_C15
			,asgn.fl_budget_C16
			,asgn.fl_budget_C18
			,asgn.fl_budget_C19
			,asgn.fl_uncat_svc
			,asgn.cd_asgn_type
			,asgn.tx_asgn_type
			,asgn.fl_force_end_date
			,asgn.tbl_origin
			,asgn.tbl_origin_cd
			,asgn.frst_IHS_after_intk
			from (
				select id_case, Min(ihs_begin_date) ihs_begin_date, MAX(ihs_end_date) ihs_end_date
				from
				(select id_case,v.[number],t.ihs_begin_date,t.ihs_end_date,DATEDIFF(d, ihs_begin_date, ihs_end_date) as days_between,
						  1-    DENSE_RANK() over (partition by ID_CASE order by t.ihs_begin_date+v.number) as days_to_add,      
						NewStartDate = t.ihs_begin_date+v.number,
						NewStartDateGroup =
							dateadd(d,
									1- DENSE_RANK() over (partition by id_case order by t.ihs_begin_date+v.number),
									t.ihs_begin_date+v.number)
					from   @t t
					inner join dbo.numbers v
					  on v.number <= DATEDIFF(d, ihs_begin_date, ihs_end_date)
				) X
				
				group by id_case, NewStartDateGroup ) q 
			join (	select ihs.* ,min_id_table_origin
					from #ih_tmp ihs
					join (select min(case_sort) as case_sort,id_case,ihs_begin_date ,min(id_table_origin) as min_id_table_origin
							from #ih_tmp tmp
							group by id_case,ihs_begin_date ) mindate 
							on mindate.id_case=ihs.id_case
						and mindate.ihs_begin_date=ihs.ihs_begin_date
						--  and mindate.days_from_rfrd_date=ihs.days_from_rfrd_date
						and mindate.case_sort=ihs.case_sort
						--  order by ihs.id_case,ihs.ihs_begin_date
						 ) as asgn on asgn.id_case=q.id_case and asgn.ihs_begin_date=q.ihs_begin_date

		
		if object_id('debug.ih_assgn_all_10') is not null drop table debug.ih_assgn_all_10;
		if @debug = 1 select * into debug.ih_assgn_all_10 from #ih_assgn_all


		update hall
		set id_table_origin=q.id_table_origin
			,max_id_table_origin=q.max_id_table_origin
			,cnt_id_table_origin=q.cnt_id_table_origin
		from #ih_assgn_all hall
		join (select asg.id_case,asg.ihs_begin_date,asg.ihs_end_date
					,min(tmp.id_table_origin) as id_table_origin
					,max(tmp.max_id_table_origin) as max_id_table_origin
					,sum(tmp.cnt_id_table_origin) as cnt_id_table_origin
				from #ih_assgn_all asg
				join #ih_tmp tmp on asg.id_case=tmp.id_case
				and tmp.ihs_begin_date between asg.ihs_begin_date and asg.ihs_end_date
				and tmp.ihs_end_date between  asg.ihs_begin_date and asg.ihs_end_date
				group by asg.id_case,asg.ihs_begin_date,asg.ihs_end_date
				) q on q.id_case=hall.id_case
				and q.ihs_begin_date=hall.ihs_begin_date
				and q.ihs_end_date=hall.ihs_end_date

		
		if object_id('debug.ih_assgn_all_11') is not null drop table debug.ih_assgn_all_11;
		if @debug = 1 select * into debug.ih_assgn_all_11 from #ih_assgn_all
		
		delete ihs
		--  select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from #ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 


		if object_id('debug.ih_assgn_all_12') is not null drop table debug.ih_assgn_all_12;
		if @debug = 1 select * into debug.ih_assgn_all_12 from #ih_assgn_all
  	
		update ihs
		set ihs_end_date=state_custody_start_date
		,ihs.fl_force_end_date=1
		,ihs.plcmnt_date=state_custody_start_date
		--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from #ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_intake_fact=ihs.id_intake_fact
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 
		and state_custody_start_date > ihs_begin_date 

		if object_id('debug.ih_assgn_all_13') is not null drop table debug.ih_assgn_all_13;
		if @debug = 1 select * into debug.ih_assgn_all_13 from #ih_assgn_all
	
					
----------------------------------  PAYMENT	---------------------------------------------  PAYMENT	-------------------------------------------  PAYMENT		
		
	
		  
/**********************************************************************************************************************************************  now  */

	
/****************************************************   get all in-home PAYMENT by  service begin date  ***********/		


	
			-- get all the payment details for detail table
			if object_ID('tempDB..#ihs_pay_srvc_dtl') is not null drop table #ihs_pay_srvc_dtl		
			select distinct
				cast(null as int) as id_ihs_episode
			    ,af.id_payment_fact as dtl_id_payment_fact
				,af.id_case
				,af.ID_PRSN_CHILD
				,af.CHILD_AGE
				,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN) as [srvc_dt_begin]
				,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END) as [srvc_dt_end]
				,sc.cd_srvc
				,sc.tx_srvc
				,af.am_rate
				,sum(af.am_units) as am_units
				,sum(af.am_total_paid) as am_total_paid
				,af.id_service_type_dim
				,af.id_provider_dim_service
				,std.cd_unit_rate_type
				,std.tx_unit_rate_type
				,std.cd_srvc_ctgry
				,std.tx_srvc_ctgry
				,sc.cd_budget_poc_frc
				,sc.tx_budget_poc_frc
				,sc.cd_subctgry_poc_frc
				,sc.tx_subctgry_poc_frc
				,0 as fl_force_end_date
				,id_intake_fact
				,inv_ass_start
				,case_nxt_intake
				, datediff(dd,inv_ass_start,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN)) as days_from_rfrd_date 
				,intake_county_cd
				,intake_zip
			into #ihs_pay_srvc_dtl 
			from payment_fact af
			join #ihs_intk intk on intk.id_case=af.id_case
				and intk.INV_ASS_START <=dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_SERVICE_BEGIN )
			join  dbo.SERVICE_TYPE_DIM std on std.ID_SERVICE_TYPE_DIM =af.ID_SERVICE_TYPE_DIM
			join dbo.ref_service_category sc on sc.cd_srvc=std.cd_srvc and sc.fl_ihs_svc=1
			WHERE isnull(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END),'12/31/3999') >= @start_date -- '1997-01-01'-- 
			and coalesce(dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END),'12/31/3999') < isnull(intk.case_nxt_intake,'12/31/3999')
			and  af.am_total_paid <>0
			and (af.id_case is not null or af.id_case<>0)
			group by af.id_payment_fact,af.id_case,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN)
			,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_END),sc.cd_srvc,sc.tx_srvc
			,af.am_rate,af.id_service_type_dim
				,af.id_provider_dim_service
				,std.cd_unit_rate_type
				,std.tx_unit_rate_type
				,std.cd_srvc_ctgry
				,std.tx_srvc_ctgry
				,sc.cd_budget_poc_frc
				,sc.tx_budget_poc_frc
				,sc.cd_subctgry_poc_frc
				,sc.tx_subctgry_poc_frc
				,id_intake_fact
				,inv_ass_start
				,case_nxt_intake
				, datediff(dd,inv_ass_start,dbo.IntDate_to_CalDate(ID_CALENDAR_DIM_SERVICE_BEGIN))
				,af.ID_PRSN_CHILD
				,af.CHILD_AGE
				,intake_county_cd
				,intake_zip
			
			if object_id('debug.ihs_pay_srvc_dtl_1') is not null drop table debug.ihs_pay_srvc_dtl_1;
			if @debug = 1 select * into debug.ihs_pay_srvc_dtl_1 from #ihs_pay_srvc_dtl

			  -- only want one intake per payment fact
			delete IH
			from #ihs_pay_srvc_dtl IH
	  join (
			select id_case,srvc_dt_begin,dtl_id_payment_fact,(id_intake_fact) , days_from_rfrd_date 
			,row_number() over 
			(partition by dtl_id_payment_fact order by days_from_rfrd_date  asc) as row_num
			from #ihs_pay_srvc_dtl
		
			) q on q.row_num=1
			and q.id_case=IH.id_case
			and q.srvc_dt_begin=IH.srvc_dt_begin
			and q.dtl_id_payment_fact=IH.dtl_id_payment_fact
			and q.id_intake_fact <> IH.ID_INTAKE_FACT

			if object_id('debug.ihs_pay_srvc_dtl_2') is not null drop table debug.ihs_pay_srvc_dtl_2;
			if @debug = 1 select * into debug.ihs_pay_srvc_dtl_2 from #ihs_pay_srvc_dtl



			alter table #ihs_pay_srvc_dtl
			alter column id_case int not null 
			alter table #ihs_pay_srvc_dtl
			alter column [srvc_dt_begin] datetime not null
			alter table #ihs_pay_srvc_dtl
			alter column srvc_dt_End datetime not null
			alter table #ihs_pay_srvc_dtl
			alter column dtl_id_payment_fact int not null
			--alter table #ihs_pay_srvc_dtl
			--add primary key (id_case,[srvc_dt_begin],srvc_dt_End,dtl_id_payment_fact)
		

			CREATE NONCLUSTERED INDEX idx_ihs_dtl_begin_pf on #ihs_pay_srvc_dtl([srvc_dt_begin],[dtl_id_payment_fact])
			


			
			

			

		update ihs
		set srvc_dt_end=state_custody_start_date
				,ihs.fl_force_end_date=1
			-- select min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from #ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 
		and state_custody_start_date > srvc_dt_begin 
		and state_custody_start_date < srvc_dt_end

		if object_id('debug.ihs_pay_srvc_dtl_3') is not null drop table debug.ihs_pay_srvc_dtl_3;
		if @debug = 1 select * into debug.ihs_pay_srvc_dtl_3 from #ihs_pay_srvc_dtl


		update ihs
		set srvc_dt_end=state_custody_start_date
				,ihs.fl_force_end_date=1
			-- select min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from #ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_intake_Fact=ihs.id_intake_Fact
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 
		and state_custody_start_date > srvc_dt_begin 
		and state_custody_start_date < srvc_dt_end

		if object_id('debug.ihs_pay_srvc_dtl_4') is not null drop table debug.ihs_pay_srvc_dtl_4;
		if @debug = 1 select * into debug.ihs_pay_srvc_dtl_4 from #ihs_pay_srvc_dtl



		
		delete ihs
		-- select  min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from #ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 

		if object_id('debug.ihs_pay_srvc_dtl_5') is not null drop table debug.ihs_pay_srvc_dtl_5;
		if @debug = 1 select * into debug.ihs_pay_srvc_dtl_5 from #ihs_pay_srvc_dtl


		delete ihs
		-- select  min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from #ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_intake_Fact=ihs.id_intake_Fact
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 

		if object_id('debug.ihs_pay_srvc_dtl_6') is not null drop table debug.ihs_pay_srvc_dtl_6;
		if @debug = 1 select * into debug.ihs_pay_srvc_dtl_6 from #ihs_pay_srvc_dtl


			if object_ID('tempDB..#ihs_pay_srvc_all') is not null drop table #ihs_pay_srvc_all
			SELECT distinct 
				 sc.id_case
				 ,sc.id_intake_fact
				 ,sc.inv_ass_start as rfrd_date
				 ,sc.case_nxt_intake
				 ,sc.days_from_rfrd_date
				, min(sc.dtl_id_payment_fact) as min_id_payment_fact
				, max(sc.dtl_id_payment_fact) as max_id_payment_fact
				, count(*) as cnt_id_table_origin
				, sc.[srvc_dt_begin]
				, max([srvc_dt_end]) as [srvc_dt_end]
				, cast(null as bigint) as case_sort
				, cast(null as datetime) as first_ihs_date
				, cast(null as datetime) as latest_ihs_date
				, cast(null as int) as fl_plcmnt_prior_ihs
				, cast(null as int) as fl_plcmnt_during_ihs
				, cast(null as datetime) as plcmnt_date
				,max(intake_county_cd) intake_county_cd
				,max(intake_zip) intake_zip
				--, cast(count(distinct af.id_authorization_fact)  as int) as nbr_svc_authorized
				--, sum(case when ad.cd_auth_status=2 then 1 else 0 end) as nbr_svc_paid
				--, cast(sum(case when ad.cd_auth_status=2 then  af.am_total_paid else 0 end) as numeric(18,2)) as total_amt_paid
				, 0 as nbr_svc_paid
				, cast(0  as numeric(18,2)) as total_amt_paid 
				, cast(0 as int) as most_exp_cd_srvc
				, cast(null as varchar(200)) as most_exp_tx_srvc
				, cast(0 as numeric(18,2)) as total_most_exp_srvc
				, max(case when sc.cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
				, max(case when sc.cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
				, max(case when sc.cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
				--, max(case when sc.cd_subctgry_poc_frc=4 then 1 else 0 end) as fl_mh_services
				--, max(case when sc.cd_subctgry_poc_frc=5 then 1 else 0 end) as fl_receiving_care
				--, max(case when sc.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
				, max(case when sc.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
				, max(case when sc.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
				, max(case when sc.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
				, max(case when sc.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
				, max(case when sc.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
				--, max(case when sc.cd_subctgry_poc_frc=12 then 1 else 0 end) as fl_clothing_incidentals
				--, max(case when sc.cd_subctgry_poc_frc=13 then 1 else 0 end) as fl_sexually_aggressive_youth
				--, max(case when sc.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
				--, max(case when sc.cd_subctgry_poc_frc=15 then 1 else 0 end) as fl_various
				--, max(case when sc.cd_subctgry_poc_frc=16 then 1 else 0 end) as fl_medical
				, max(case when sc.cd_subctgry_poc_frc=17 then 1 else 0 end) as fl_ihs_reun
				, max(case when sc.cd_subctgry_poc_frc=18 then 1 else 0 end) as fl_concrete_goods
				, max(case when sc.cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
				, max(case when sc.cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
				, max(case when sc.cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
				, max(case when sc.cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
				, max(case when sc.cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
				, max(case when sc.cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
				, max(case when sc.cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
				--, cd_auth_status
				--, tx_auth_status
				, cast(0 as int) as fl_force_end_date
				, cast('payment_fact' as varchar(50)) as tbl_origin 
				, cast(2 as int) as tbl_origin_cd
				, 0 as frst_IHS_after_intk
			into #ihs_pay_srvc_all
			FROM #ihs_pay_srvc_dtl sc 
			group by sc.id_case,srvc_dt_begin,sc.id_intake_fact
				 ,sc.inv_ass_start,sc.case_nxt_intake,sc.days_from_rfrd_date


		if object_id('debug.ihs_pay_srvc_all_1') is not null drop table debug.ihs_pay_srvc_all_1;
		if @debug = 1 select * into debug.ihs_pay_srvc_all_1 from #ihs_pay_srvc_all

		CREATE NONCLUSTERED INDEX idx_temp_case_pf_sbd on #ihs_pay_srvc_all ([id_case],[min_id_payment_fact],[srvc_dt_begin])
		INCLUDE ([id_intake_fact])

		CREATE NONCLUSTERED INDEX  idx_temp_pay_all
			ON #ihs_pay_srvc_all ([id_case],[srvc_dt_begin],[srvc_dt_end])

	--keep only 1 intake per	the closest one
			
	 delete IH
	  from #ihs_pay_srvc_all IH
	  join (
			select id_case,srvc_dt_begin,min_id_payment_fact,max_id_payment_fact,(id_intake_fact)
			 ,datediff(dd,rfrd_date,srvc_dt_begin) as days_from_rfrd_date,row_number() over 
			(partition by min_id_payment_fact order by datediff(dd,rfrd_date,srvc_dt_begin) asc) as row_num
			from #ihs_pay_srvc_all
		
			) q on q.row_num=1
			and q.id_case=IH.id_case
			and q.srvc_dt_begin=IH.srvc_dt_begin
			and q.min_id_payment_fact=IH.min_id_payment_fact
			and q.max_id_payment_fact=IH.max_id_payment_fact
			and q.id_intake_fact <> IH.ID_INTAKE_FACT


			if object_id('debug.ihs_pay_srvc_all_2') is not null drop table debug.ihs_pay_srvc_all_2;
			if @debug = 1 select * into debug.ihs_pay_srvc_all_2 from #ihs_pay_srvc_all

		
		-- delete from #ihs_pay_srvc_all where datediff(dd,rfrd_date,[srvc_dt_begin]) >=90

		update ihall
		set ihall.fl_force_end_date=ihs.fl_force_end_date
			,ihall.srvc_dt_end=ihs.srvc_dt_end
			,ihall.plcmnt_date=ihs.srvc_dt_end
		--select ihs.dtl_id_payment_fact,ihall.min_id_payment_fact,ihall.max_id_payment_fact
		--	,ihs.srvc_dt_begin,ihs.srvc_dt_end,ihall.srvc_dt_begin,ihall.srvc_dt_end
		from #ihs_pay_srvc_dtl ihs  
		join #ihs_pay_srvc_all ihall on  ihs.dtl_id_payment_fact between
			ihall.min_id_payment_fact and ihall.max_id_payment_fact
			and  (ihs.fl_force_end_date=1  )
			and (ihall.id_case=ihs.id_case )
		-- where dtl_id_payment_fact=3527788 and max_id_payment_fact=3527788
		where  ihall.srvc_dt_begin=ihs.srvc_dt_begin

		if object_id('debug.ihs_pay_srvc_all_3') is not null drop table debug.ihs_pay_srvc_all_3;
		if @debug = 1 select * into debug.ihs_pay_srvc_all_3 from #ihs_pay_srvc_all

	
/******************************************** MERGE    ***********************************/		

		

		CREATE NONCLUSTERED INDEX idx_tmp_pay_all
		ON #ihs_pay_srvc_all([case_sort])
		INCLUDE ([id_case],[id_intake_fact],[rfrd_date],[case_nxt_intake],[days_from_rfrd_date],[min_id_payment_fact],[max_id_payment_fact]
		,[cnt_id_table_origin],[srvc_dt_begin],[srvc_dt_end],[first_ihs_date],[latest_ihs_date],[fl_plcmnt_prior_ihs],[fl_plcmnt_during_ihs],[plcmnt_date]
		,intake_county_cd,intake_zip,[nbr_svc_paid],[total_amt_paid],[most_exp_cd_srvc],[most_exp_tx_srvc],[total_most_exp_srvc]
		,[fl_family_focused_services],[fl_child_care],[fl_therapeutic_services]
	--	,[fl_mh_services],[fl_receiving_care],[fl_family_home_placements]
		,[fl_behavioral_rehabiliation_services],[fl_other_therapeutic_living_situations],[fl_specialty_adolescent_services],[fl_respite],[fl_transportation]
	--	,[fl_clothing_incidentals],[fl_sexually_aggressive_youth],[fl_adoption_support],[fl_various],[fl_medical]
		,fl_ihs_reun,fl_concrete_goods,[fl_budget_C12],[fl_budget_C14],[fl_budget_C15]
		,[fl_budget_C16],[fl_budget_C18],[fl_budget_C19],[fl_uncat_svc],[fl_force_end_date],[tbl_origin],[tbl_origin_cd],[frst_IHS_after_intk])
			
		update A1
		set case_sort=a2.row_num
		from #ihs_pay_srvc_all a1
		join (select ROW_NUMBER() over (partition by id_case order by srvc_dt_begin asc
		,srvc_dt_end asc) as row_num ,* from #ihs_pay_srvc_all) a2 
				on a2.min_id_payment_fact=a1.min_id_payment_fact 
				and a2.max_id_payment_fact=a1.max_id_payment_fact	

		if object_id('debug.ihs_pay_srvc_all_4') is not null drop table debug.ihs_pay_srvc_all_4;
		if @debug = 1 select * into debug.ihs_pay_srvc_all_4 from #ihs_pay_srvc_all


		-- temp table for merge
		if object_ID('tempDB..#ihs') is not null drop table #ihs
		CREATE TABLE #ihs(
		id_case int NOT NULL,id_intake_fact int NOT NULL,rfrd_date datetime NOT NULL,case_nxt_intake datetime NULL,days_from_rfrd_date int NULL,
		min_id_payment_fact int NULL,max_id_payment_fact int NULL,cnt_id_table_origin int NULL,srvc_dt_begin datetime NOT NULL,srvc_dt_end datetime NULL,
		case_sort bigint NULL,first_ihs_date datetime NULL,latest_ihs_date datetime NULL,fl_plcmnt_prior_ihs int NULL,fl_plcmnt_during_ihs int NULL
		,plcmnt_date datetime NULL,
		intake_county_cd int NULL,intake_zip nvarchar(10) NULL,nbr_svc_paid int NOT NULL,total_amt_paid numeric(18, 2) NULL,most_exp_cd_srvc int NULL
		,most_exp_tx_srvc varchar(200) NULL,
		total_most_exp_srvc numeric(18, 2) NULL,fl_family_focused_services int NULL,fl_child_care int NULL,fl_therapeutic_services int NULL
		--,fl_mh_services int NULL,
		--fl_receiving_care int NULL,fl_family_home_placements int NULL
		,fl_behavioral_rehabiliation_services int NULL
		,fl_other_therapeutic_living_situations int NULL,fl_specialty_adolescent_services int NULL,
		fl_respite int NULL,fl_transportation int NULL
		--,fl_clothing_incidentals int NULL,fl_sexually_aggressive_youth int NULL,fl_adoption_support int NULL,
		--fl_various int NULL,fl_medical int NULL
		,fl_ihs_reun int NULL,fl_concrete_goods int NULL,fl_budget_C12 int NULL,fl_budget_C14 int NULL,fl_budget_C15 int NULL,fl_budget_C16 int NULL,
		fl_budget_C18 int NULL,fl_budget_C19 int NULL,fl_uncat_svc int NULL,fl_force_end_date int NULL,tbl_origin varchar(50) NULL,tbl_origin_cd int NULL,
		frst_IHS_after_intk int NOT NULL) 

		--initialize
		insert into #ihs
		select *
		from #ihs_pay_srvc_all
		
	
		delete from @t
			 
		insert into @t
		select distinct id_case,srvc_dt_begin,srvc_dt_end,case_sort from #ihs
		order by id_case,case_sort

		if object_id('debug.t_10') is not null drop table debug.t_10;
		if @debug = 1 select * into debug.t_10 from @t


		--select * from #ihs
		
		truncate table #ihs_pay_srvc_all
		insert into #ihs_pay_srvc_all
		SELECT  q.id_case
      , pay.id_intake_fact
      , pay.rfrd_date
      , pay.case_nxt_intake
      , pay.days_from_rfrd_date
      , pay.minU_id_payment_fact
      , pay.max_id_payment_fact
      , pay.cnt_id_table_origin
      , q.srvc_dt_begin
      , q.srvc_dt_end
      , pay.case_sort
      , pay.first_ihs_date
      , pay.latest_ihs_date
      , pay.fl_plcmnt_prior_ihs
      , pay.fl_plcmnt_during_ihs
      , pay.plcmnt_date
      , pay.intake_county_cd
      , pay.intake_zip
      , pay.nbr_svc_paid
      , pay.total_amt_paid
      , pay.most_exp_cd_srvc
      , pay.most_exp_tx_srvc
      , pay.total_most_exp_srvc
      , pay.fl_family_focused_services
      , pay.fl_child_care
      , pay.fl_therapeutic_services
      --, pay.fl_mh_services
      --, pay.fl_receiving_care
      --, pay.fl_family_home_placements
      , pay.fl_behavioral_rehabiliation_services
      , pay.fl_other_therapeutic_living_situations
      , pay.fl_specialty_adolescent_services
      , pay.fl_respite
      , pay.fl_transportation
      --, pay.fl_clothing_incidentals
      --, pay.fl_sexually_aggressive_youth
      --, pay.fl_adoption_support
      --, pay.fl_various
      --, pay.fl_medical
	  ,pay.fl_ihs_reun
	  ,pay.fl_concrete_goods
      , pay.fl_budget_C12
      , pay.fl_budget_C14
      , pay.fl_budget_C15
      , pay.fl_budget_C16
      , pay.fl_budget_C18
      , pay.fl_budget_C19
      , pay.fl_uncat_svc
      , pay.fl_force_end_date
      , pay.tbl_origin
      , pay.tbl_origin_cd
      , pay.frst_IHS_after_intk
	  from (
				select id_case, Min(ihs_begin_date) srvc_dt_begin, MAX(ihs_end_date) srvc_dt_end
				from
				(select id_case,v.[number],t.ihs_begin_date,t.ihs_end_date,DATEDIFF(d, ihs_begin_date, ihs_end_date) as days_between,
						  1-    DENSE_RANK() over (partition by ID_CASE order by t.ihs_begin_date+v.number) as days_to_add,      
						NewStartDate = t.ihs_begin_date+v.number,
						NewStartDateGroup =
							dateadd(d,
									1- DENSE_RANK() over (partition by id_case order by t.ihs_begin_date+v.number),
									t.ihs_begin_date+v.number)
					from   @t t
					inner join dbo.numbers v
					  on v.number <= DATEDIFF(d, ihs_begin_date, ihs_end_date)
				) X
				
				group by id_case, NewStartDateGroup ) q 
			join (select ihs.* ,minU_id_payment_fact
					from #ihs ihs
					join (select min(case_sort) as case_sort,id_case,srvc_dt_begin ,min(min_id_payment_fact) as minU_id_payment_fact
							from #ihs tmp
							group by id_case,srvc_dt_begin ) mindate 
							on mindate.id_case=ihs.id_case
						and mindate.srvc_dt_begin=ihs.srvc_dt_begin
						and mindate.case_sort=ihs.case_sort
						 ) as pay on pay.id_case=q.id_case and pay.srvc_dt_begin=q.srvc_dt_begin
		
		if object_id('debug.ihs_pay_srvc_all_10') is not null drop table debug.ihs_pay_srvc_all_10;
		if @debug = 1 select * into debug.ihs_pay_srvc_all_10 from #ihs_pay_srvc_all
				

		--update the min/max id_payment_Fact
		update hall
		set min_id_payment_fact=q.min_id_payment_fact
			,max_id_payment_fact=q.max_id_payment_fact
			,cnt_id_table_origin=q.cnt_id_table_origin

		from #ihs_pay_srvc_all hall
		join (select asg.id_case,asg.srvc_dt_begin,asg.srvc_dt_end
					,min(tmp.min_id_payment_fact) as min_id_payment_fact
					,max(tmp.max_id_payment_fact) as max_id_payment_fact
					,sum(tmp.cnt_id_table_origin) as cnt_id_table_origin
					,sum(tmp.nbr_svc_paid) as nbr_svc_paid
					,sum(tmp.total_amt_paid) as total_amt_paid
				from #ihs_pay_srvc_all asg
				join #ihs tmp on asg.id_case=tmp.id_case
				and tmp.srvc_dt_begin between asg.srvc_dt_begin and asg.srvc_dt_end
				and tmp.srvc_dt_end between  asg.srvc_dt_begin and asg.srvc_dt_end
				group by asg.id_case,asg.srvc_dt_begin,asg.srvc_dt_end
				) q on q.id_case=hall.id_case
				and q.srvc_dt_begin=hall.srvc_dt_begin
				and q.srvc_dt_end=hall.srvc_dt_end

		if object_id('debug.ihs_pay_srvc_all_11') is not null drop table debug.ihs_pay_srvc_all_11;
		if @debug = 1 select * into debug.ihs_pay_srvc_all_11 from #ihs_pay_srvc_all


update  ihall
set fl_family_focused_services = q.fl_family_focused_services
	,fl_child_care=q.fl_child_care
	,fl_therapeutic_services=q.fl_therapeutic_services
	--,fl_mh_services=q.fl_mh_services
	--,fl_receiving_care=q.fl_receiving_care
	--,fl_family_home_placements=q.fl_family_home_placements
	,fl_behavioral_rehabiliation_services=q.fl_behavioral_rehabiliation_services
	,fl_other_therapeutic_living_situations=q.fl_other_therapeutic_living_situations
	,fl_specialty_adolescent_services=q.fl_specialty_adolescent_services
	,fl_respite=q.fl_respite
	,fl_transportation=q.fl_transportation
	--,fl_clothing_incidentals=q.fl_clothing_incidentals
	--,fl_sexually_aggressive_youth=q.fl_sexually_aggressive_youth
	--,fl_adoption_support=q.fl_adoption_support
	--,fl_various=q.fl_various
	--,fl_medical=q.fl_medical
	,fl_ihs_reun=q.fl_ihs_reun
	,fl_concrete_goods=q.fl_concrete_goods
	,fl_budget_C12=q.fl_budget_C12
	,fl_budget_C14=q.fl_budget_C14
	,fl_budget_C15=q.fl_budget_C15
	,fl_budget_C16=q.fl_budget_C16
	,fl_budget_C18=q.fl_budget_C18
	,fl_budget_C19=q.fl_budget_C19
	,fl_uncat_svc=q.fl_uncat_svc
from #ihs_pay_srvc_all ihall
join (
			select 
				  pay.id_case
				, pay.srvc_dt_begin
				, max(pay.fl_family_focused_services) as fl_family_focused_services
				, max(pay.fl_child_care) as fl_child_care
				, max(pay.fl_therapeutic_services) as fl_therapeutic_services
				--, max(pay.fl_mh_services) as fl_mh_services
				--, max(pay.fl_receiving_care) as fl_receiving_care
				--, max(pay.fl_family_home_placements) as fl_family_home_placements
				, max(pay.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
				, max(pay.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
				, max(pay.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
				, max(pay.fl_respite) as fl_respite
				, max(pay.fl_transportation) as fl_transportation
				--, max(pay.fl_clothing_incidentals) as fl_clothing_incidentals
				--, max(pay.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
				--, max(pay.fl_adoption_support) as fl_adoption_support
				--, max(pay.fl_various) as fl_various
				--, max(pay.fl_medical) as fl_medical
				, max(pay.fl_ihs_reun) fl_ihs_reun
				, max(pay.fl_concrete_goods) fl_concrete_goods
				, max(pay.fl_budget_C12) as fl_budget_C12
				, max(pay.fl_budget_C14) as fl_budget_C14
				, max(pay.fl_budget_C15) as fl_budget_C15
				, max(pay.fl_budget_C16) as fl_budget_C16
				, max(pay.fl_budget_C18) as fl_budget_C18
				, max(pay.fl_budget_C19) as fl_budget_C19
				, max(pay.fl_uncat_svc) as fl_uncat_svc
		from  #ihs_pay_srvc_all hall
		join #ihs pay on pay.id_case=hall.id_case
				and pay.srvc_dt_begin between hall.srvc_dt_begin and hall.srvc_dt_end
				and pay.srvc_dt_end between hall.srvc_dt_begin and hall.srvc_dt_end
		group by pay.id_case
			,pay.srvc_dt_begin ) q on q.id_case = ihall.id_case and q.srvc_dt_begin=ihall.srvc_dt_begin


		--if object_id('debug.ihs_pay_srvc_all_12') is not null drop table debug.ihs_pay_srvc_all_12;
		--if @debug = 1 select * into debug.ihs_pay_srvc_all_12 from #ihs_pay_srvc_all


		update IHALL
		set nbr_svc_paid=q.nbr_svc_paid
		,total_amt_paid=q.total_amt_paid
		from #ihs_pay_srvc_all ihall
		join (
			select dtl.id_case,hall.srvc_dt_begin,hall.srvc_dt_end
		 , count(distinct dtl_id_payment_fact) as nbr_svc_paid
			  , cast(sum(dtl.am_total_paid) as decimal(18,2)) as total_amt_paid
		from  #ihs_pay_srvc_all hall
		join #ihs_pay_srvc_dtl dtl on hall.id_case=dtl.id_case
		and dtl.srvc_dt_begin between hall.srvc_dt_begin and hall.srvc_dt_end
		and dtl.srvc_dt_end between hall.srvc_dt_begin and hall.srvc_dt_end
		group by dtl.id_case,hall.srvc_dt_begin,hall.srvc_dt_end) q on q.id_case=ihall.id_case and q.srvc_dt_begin=ihall.srvc_dt_begin
		and q.srvc_dt_end=ihall.srvc_dt_end

 	
		--if object_id('debug.ihs_pay_srvc_all_13') is not null drop table debug.ihs_pay_srvc_all_13;
		--if @debug = 1 select * into debug.ihs_pay_srvc_all_13 from #ihs_pay_srvc_all
	
/***************************************************  FINAL TABLE **************************************************************/

				
				if OBJECT_ID('tempDB..#tbl_ihs_episodes') is not null drop table #tbl_ihs_episodes
				select 
				cast(null as int) as id_ihs_episode
				,*
				,0 as dtl_min_id_payment_fact
				,0 as dtl_max_id_payment_fact
				,cast(null as int) as cd_sib_age_grp
				,cast(null as int) as cd_race_census_hh
				,cast(null as int) as census_hispanic_latino_origin_cd
				into #tbl_ihs_episodes
				from #ih_assgn_all

				alter table #tbl_ihs_episodes
				alter column id_case int not null

				alter table #tbl_ihs_episodes
				alter column ihs_begin_date datetime not null
	
				alter table #tbl_ihs_episodes
				add primary key (id_case,ihs_begin_date)

				--if object_id('debug.tbl_ihs_episodes_1') is not null drop table debug.tbl_ihs_episodes_1; 		
				--if @debug = 1 select * into debug.tbl_ihs_episodes_1 from #tbl_ihs_episodes 


				CREATE NONCLUSTERED INDEX idx_temp_case_id_inc_dates
				ON #tbl_ihs_episodes ([id_case],[id_table_origin],[max_id_table_origin])
				INCLUDE ([ihs_begin_date],[ihs_end_date])

				-- update payments contained within assignment start and stop date
				update ihs
				set   dtl_min_id_payment_fact=auth.min_id_payment_fact
					, dtl_max_id_payment_fact=auth.max_id_payment_fact
					 , most_exp_cd_srvc = null --authcd.most_exp_cd_srvc
					 , most_exp_tx_srvc=null --authcd.most_exp_tx_srvc
					 , total_most_exp_srvc = null --auth.total_most_exp_srvc
					 , total_amt_paid=auth.total_amt_paid
					 , nbr_svc_paid=auth.nbr_svc_paid
					 , fl_family_focused_services = auth.fl_family_focused_services
					 , fl_child_care = auth.fl_child_care
					 , fl_therapeutic_services = auth.fl_therapeutic_services
					 --, fl_mh_services = auth.fl_mh_services
					 --, fl_receiving_care = auth.fl_receiving_care
					 --, fl_family_home_placements = auth.fl_family_home_placements
					 , fl_behavioral_rehabiliation_services = auth.fl_behavioral_rehabiliation_services
					 , fl_other_therapeutic_living_situations = auth.fl_other_therapeutic_living_situations
					 , fl_specialty_adolescent_services = auth.fl_specialty_adolescent_services
					 , fl_respite = auth.fl_respite
					 , fl_transportation = auth.fl_transportation
					 --, fl_clothing_incidentals = auth.fl_clothing_incidentals
					 --, fl_sexually_aggressive_youth = auth.fl_sexually_aggressive_youth
					 --, fl_adoption_support = auth.fl_adoption_support
					 --, fl_various = auth.fl_various
					 --, fl_medical = auth.fl_medical
					 ,fl_ihs_reun=auth.fl_ihs_reun
					 ,fl_concrete_goods=auth.fl_concrete_goods
					 , fl_budget_C12 = auth.fl_budget_C12
					 , fl_budget_C14 = auth.fl_budget_C14
					 , fl_budget_C15 = auth.fl_budget_C15
					 , fl_budget_C16 = auth.fl_budget_C16
					 , fl_budget_C18 = auth.fl_budget_C18
					 , fl_budget_C19 = auth.fl_budget_C19
					 , fl_uncat_svc = auth.fl_uncat_svc
					 , tbl_origin_cd=3
					 , tbl_origin='both'
				from #tbl_ihs_episodes ihs
				join  (select	ihs.id_case
							,ihs.ihs_begin_date
							,ihs.ihs_end_date
							, min(min_id_payment_fact) as min_id_payment_fact
							, max(max_id_payment_fact) as max_id_payment_fact
							 , sum(auth.total_amt_paid) as total_amt_paid
							 , sum(auth.nbr_svc_paid) as nbr_svc_paid
							 , max(auth.fl_family_focused_services) as fl_family_focused_services
							 , max(auth.fl_child_care) as fl_child_care
							 , max(auth.fl_therapeutic_services) as fl_therapeutic_services
							 --, max(auth.fl_mh_services) as fl_mh_services
							 --, max(auth.fl_receiving_care) as fl_receiving_care
							 --, max(auth.fl_family_home_placements) as fl_family_home_placements
							 , max(auth.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
							 , max(auth.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
							 , max(auth.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
							 , max(auth.fl_respite) as fl_respite
							 , max(auth.fl_transportation) as fl_transportation
							 --, max(auth.fl_clothing_incidentals) as fl_clothing_incidentals
							 --, max(auth.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
							 --, max(auth.fl_adoption_support) as fl_adoption_support
							 --, max(auth.fl_various) as fl_various
							 --, max(auth.fl_medical) as fl_medical
							  , max(auth.fl_ihs_reun) as fl_ihs_reun
							   , max(auth.fl_concrete_goods) as fl_concrete_goods
							 , max(auth.fl_budget_C12) as fl_budget_C12
							 , max(auth.fl_budget_C14) as fl_budget_C14
							 , max(auth.fl_budget_C15) as fl_budget_C15
							 , max(auth.fl_budget_C16) as fl_budget_C16
							 , max(auth.fl_budget_C18) as fl_budget_C18
							 , max(auth.fl_budget_C19) as fl_budget_C19
							 , max(auth.fl_uncat_svc) as fl_uncat_svc
						from #tbl_ihs_episodes ihs
						join  #ihs_pay_srvc_all  auth on auth.id_case=ihs.id_case 
							and auth.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
							and auth.srvc_dt_end   between ihs.ihs_begin_date and ihs.ihs_end_date
						group by ihs.id_case
							,ihs.ihs_begin_date
							,ihs.ihs_end_date
					)  auth on auth.id_case=ihs.id_case 
					and ihs.ihs_begin_date=auth.ihs_begin_date
					and ihs.ihs_end_date=auth.ihs_end_date
			
				if object_id('debug.tbl_ihs_episodes_2') is not null drop table debug.tbl_ihs_episodes_2; 		
				if @debug = 1 select * into debug.tbl_ihs_episodes_2 from #tbl_ihs_episodes 


				--insert those payments with no overlapping assignment dates
				insert into #tbl_ihs_episodes
				select 
						cast(null as int)	 as id_ihs_episode
					, auth.ID_CASE
					, auth.ID_INTAKE_FACT
					, auth.rfrd_date 
					  , auth.min_id_payment_fact
					  , auth.max_id_payment_fact
					  , auth.cnt_id_table_origin
					  , auth.srvc_dt_begin
					  , auth.srvc_dt_end
					  , auth.case_sort
					  , auth.first_ihs_date
					  , auth.latest_ihs_date
					  , auth.fl_plcmnt_prior_ihs
					  , auth.fl_plcmnt_during_ihs
					  , auth.plcmnt_date
					  , auth.intake_county_cd
					  , auth.intake_zip
					  , auth.days_from_rfrd_date
					  , auth.nbr_svc_paid
					  , auth.total_amt_paid
					  , auth.most_exp_cd_srvc
					  , auth.most_exp_tx_srvc
					  , auth.total_most_exp_srvc
					  , auth.fl_family_focused_services
					  , auth.fl_child_care
					  , auth.fl_therapeutic_services
					  --, auth.fl_mh_services
					  --, auth.fl_receiving_care
					  --, auth.fl_family_home_placements
					  , auth.fl_behavioral_rehabiliation_services
					  , auth.fl_other_therapeutic_living_situations
					  , auth.fl_specialty_adolescent_services
					  , auth.fl_respite
					  , auth.fl_transportation
					  --, auth.fl_clothing_incidentals
					  --, auth.fl_sexually_aggressive_youth
					  --, auth.fl_adoption_support
					  --, auth.fl_various
					  --, auth.fl_medical
					  ,auth.fl_ihs_reun
					  ,auth.fl_concrete_goods
					  , auth.fl_budget_C12
					  , auth.fl_budget_C14
					  , auth.fl_budget_C15
					  , auth.fl_budget_C16
					  , auth.fl_budget_C18
					  , auth.fl_budget_C19
					  , auth.fl_uncat_svc
					  , null
					  , null
					  , auth.fl_force_end_date
					  , auth.tbl_origin
					  , auth.tbl_origin_cd	
					  ,auth.frst_IHS_after_intk
				 	,min_id_payment_fact
					,max_id_payment_fact 
					,null
					,null
					,null
				from #ihs_pay_srvc_all  auth
				left join #tbl_ihs_episodes assg on auth.id_case=assg.id_case
					and auth.srvc_dt_begin between assg.ihs_begin_date and assg.ihs_end_date
					and auth.srvc_dt_end   between assg.ihs_begin_date and assg.ihs_end_date
				left join #tbl_ihs_episodes assn on auth.id_case=assn.id_case
					and auth.srvc_dt_begin between assn.ihs_begin_date and assn.ihs_end_date
					
				left join #tbl_ihs_episodes asst on auth.id_case=asst.id_case
					and auth.srvc_dt_end between asst.ihs_begin_date and asst.ihs_end_date
					
				left join #tbl_ihs_episodes wi on auth.id_case=wi.id_case
					and auth.srvc_dt_end > wi.ihs_end_date 
					and auth.srvc_dt_begin < wi.ihs_begin_date 
				where (assg.id_case is null and assn.id_case is null and asst.id_case is null  and wi.id_case is null)

				if object_id('debug.tbl_ihs_episodes_3') is not null drop table debug.tbl_ihs_episodes_3; 		
				if @debug = 1 select * into debug.tbl_ihs_episodes_3 from #tbl_ihs_episodes 

			update eps
			set case_sort=q.row_num
			from #tbl_ihs_episodes eps
			join (select row_number()  over (partition by id_case order by ihs_begin_date,ihs_end_date) as row_num,*
					from #tbl_ihs_episodes) q on q.id_case=eps.id_case and q.ihs_begin_date=eps.ihs_begin_date and q.id_table_origin=eps.id_table_origin and q.max_id_table_origin=eps.max_id_table_origin
					
				if object_id('debug.tbl_ihs_episodes_4') is not null drop table debug.tbl_ihs_episodes_4; 		
				if @debug = 1 select * into debug.tbl_ihs_episodes_4 from #tbl_ihs_episodes 


			delete from @t;
			insert into @t
			select distinct ihall.id_case,srvc_dt_begin as ihs_begin_date,srvc_dt_end as ihs_end_date ,2 -- from payment
			from #ihs_pay_srvc_all ihall
			left join #tbl_ihs_episodes eps on eps.id_case=ihall.id_case
			and ihall.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
					and ihall.srvc_dt_end   between eps.ihs_begin_date and eps.ihs_end_date 
			left join #tbl_ihs_episodes ihs on ihs.id_case=ihall.id_case
				and srvc_dt_begin <= ihs.ihs_end_date
				and srvc_dt_end >=ihs.ihs_begin_date
			where eps.id_case is null and ihs.id_case is not null
			union 
			select distinct ihall.id_case,ihs.ihs_begin_date,ihs.ihs_end_date ,1 -- from assignment
			from #ihs_pay_srvc_all ihall
			left join #tbl_ihs_episodes eps on eps.id_case=ihall.id_case
			and ihall.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
					and ihall.srvc_dt_end   between eps.ihs_begin_date and eps.ihs_end_date 
			left join #tbl_ihs_episodes ihs on ihs.id_case=ihall.id_case
				and srvc_dt_begin <= ihs.ihs_end_date
				and srvc_dt_end >=ihs.ihs_begin_date
			where eps.id_case is null and ihs.id_case is not null
			order by [id_case],ihs_begin_date

			if object_id('debug.t_20') is not null drop table debug.t_20;
			if @debug = 1 select * into debug.t_20 from @t


			-- save the records before you delete them
			if object_ID('tempDB..#tmp_eps') is not null drop table #tmp_eps
			select distinct ihs.* into #tmp_eps from #ihs_pay_srvc_all ihall
			left join #tbl_ihs_episodes eps on eps.id_case=ihall.id_case
			and ihall.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
					and ihall.srvc_dt_end   between eps.ihs_begin_date and eps.ihs_end_date 
			left join #tbl_ihs_episodes ihs on ihs.id_case=ihall.id_case
				and srvc_dt_begin <= ihs.ihs_end_date
				and srvc_dt_end >=ihs.ihs_begin_date
			where eps.id_case is null and ihs.id_case is not null


			if object_ID('tempDB..#tmp_srvc') is not null drop table #tmp_srvc
			select distinct ihall.* into #tmp_srvc from #ihs_pay_srvc_all ihall
			left join #tbl_ihs_episodes eps on eps.id_case=ihall.id_case
			and ihall.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
					and ihall.srvc_dt_end   between eps.ihs_begin_date and eps.ihs_end_date 
			left join #tbl_ihs_episodes ihs on ihs.id_case=ihall.id_case
				and srvc_dt_begin <= ihs.ihs_end_date
				and srvc_dt_end >=ihs.ihs_begin_date
			where eps.id_case is null and ihs.id_case is not null


			delete IHS
			from #ihs_pay_srvc_all ihall
			left join #tbl_ihs_episodes eps on eps.id_case=ihall.id_case
			and ihall.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
					and ihall.srvc_dt_end   between eps.ihs_begin_date and eps.ihs_end_date 
			left join #tbl_ihs_episodes ihs on ihs.id_case=ihall.id_case
				and srvc_dt_begin <= ihs.ihs_end_date
				and srvc_dt_end >=ihs.ihs_begin_date
			where eps.id_case is null and ihs.id_case is not null

			--if object_id('debug.ihs_pay_srvc_all_14') is not null drop table debug.ihs_pay_srvc_all_14;
			--if @debug = 1 select * into debug.ihs_pay_srvc_all_14 from #ihs_pay_srvc_all


			if object_id('tempDB..#tbl_both') is not null drop table #tbl_both;
			--insert into #tbl_ihs_episodes
			SELECT  distinct 
				null as id_ihs_episode
				  , qry.id_case as id_case
				  , null as ID_INTAKE_FACT
				  , cast(null as datetime)  as  rfrd_date
				  , null as id_table_origin
				  , null as max_id_table_origin
				  , null as cnt_id_table_origin
				  , qry.ihs_begin_date
				  , qry.ihs_end_date
				  , null as case_sort
				  , cast(null as datetime) as first_ihs_date
				  , cast(null as datetime) as latest_ihs_date
				  , null as fl_plcmnt_prior_ihs
				  , null as fl_plcmnt_during_ihs
				  , cast(null as datetime) as plcmnt_date
				  , null  intake_county_cd
				  , cast(null as nvarchar(10)) intake_zip
				  , null as  days_from_rfrd_date
				  , null as nbr_svc_paid
				  , cast(null as decimal(18,2)) as total_amt_paid
				  , null as most_exp_cd_srvc
				  , cast(null as varchar(200))  as most_exp_tx_srvc
				  , null as total_most_exp_srvc
				  , null as fl_family_focused_services
				  , null as fl_child_care
				  , null as fl_therapeutic_services
				  --, null as fl_mh_services
				  --, null as fl_receiving_care
				  --, null as fl_family_home_placements
				  , null as fl_behavioral_rehabiliation_services
				  , null as fl_other_therapeutic_living_situations
				  , null as fl_specialty_adolescent_services
				  , null as fl_respite
				  , null as fl_transportation
				  --, null as fl_clothing_incidentals
				  --, null as fl_sexually_aggressive_youth
				  --, null as fl_adoption_support
				  --, null as fl_various
				  --, null as fl_medical
				  , null as fl_ihs_reun
				  , null as fl_concrete_goods
				  , null as fl_budget_C12
				  , null as fl_budget_C14
				  , null as fl_budget_C15
				  , null as fl_budget_C16
				  , null as fl_budget_C18
				  , null as fl_budget_C19
				  , null as fl_uncat_svc
  				  , null as cd_asgn_type
				  , cast(null as varchar(200)) as tx_asgn_type
				  , null as fl_force_end_date 
				  , 'both' as tbl_origin
				  , 3 as tbl_origin_cd
				  , null as frst_IHS_after_intk
				  , null as min_id_payment_fact
				  , null as max_id_payment_fact
				  , null as cd_sib_age_grp
				  , null as cd_race_census_hh
				  , null as census_hispanic_latino_origin_cd
			into #tbl_both
			from (
				select id_case, Min(ihs_begin_date) ihs_begin_date, MAX(ihs_end_date) ihs_end_date
				from
				(select id_case,v.[number],t.ihs_begin_date,t.ihs_end_date,DATEDIFF(d, ihs_begin_date, ihs_end_date) as days_between,
							1-    DENSE_RANK() over (partition by ID_CASE order by t.ihs_begin_date+v.number) as days_to_add,      
						NewStartDate = t.ihs_begin_date+v.number,
						NewStartDateGroup =
							dateadd(d,
									1- DENSE_RANK() over (partition by id_case order by t.ihs_begin_date+v.number),
									t.ihs_begin_date+v.number)
					from   @t t
					inner join dbo.numbers v
						on v.number <= DATEDIFF(d, ihs_begin_date, ihs_end_date)
				) X
				group by id_case, NewStartDateGroup ) qry

			--if object_id('debug.tbl_both_1') is not null drop table debug.tbl_both_1;
			--if @debug = 1 select * into debug.tbl_both_1 from #tbl_both
		

			update bth
			set 		
				   ID_INTAKE_FACT = ihs.ID_INTAKE_FACT
				  , rfrd_date=ihs.rfrd_date
				  , id_table_origin=ihs.id_table_origin
				  , max_id_table_origin=ihs.max_id_table_origin
				  , cnt_id_table_origin= ihs.cnt_id_table_origin
				  , first_ihs_date= ihs.first_ihs_date
				  , latest_ihs_date= ihs.latest_ihs_date
				  , fl_plcmnt_prior_ihs= ihs.fl_plcmnt_prior_ihs
				  , fl_plcmnt_during_ihs= ihs.fl_plcmnt_during_ihs
				  , plcmnt_date= ihs.plcmnt_date
				  , intake_county_cd= ihs.intake_county_cd
				  , intake_zip= ihs.intake_zip
				  , days_from_rfrd_date= ihs.days_from_rfrd_date
				  , cd_asgn_type= ihs.cd_asgn_type
				  , tx_asgn_type= ihs.tx_asgn_type
				  , fl_force_end_date = ihs.fl_force_end_date
				  , frst_IHS_after_intk= ihs.frst_IHS_after_intk
				  , cd_sib_age_grp= ihs.cd_sib_age_grp
				  , cd_race_census_hh= ihs.cd_race_census_hh
				 , census_hispanic_latino_origin_cd= ihs.census_hispanic_latino_origin_cd
			from #tbl_both bth
			join #tmp_eps ihs on bth.id_case=ihs.id_case
					and ihs.ihs_begin_date = bth.ihs_begin_date 

			--if object_id('debug.tbl_both_2') is not null drop table debug.tbl_both_2;
			--if @debug = 1 select * into debug.tbl_both_2 from #tbl_both

			update bth
			set 		
				   id_table_origin=q.id_table_origin
				  , max_id_table_origin=q.max_id_table_origin
				  , cnt_id_table_origin= q.cnt_id_table_origin
				  , fl_plcmnt_prior_ihs= q.fl_plcmnt_prior_ihs
				  , fl_plcmnt_during_ihs= q.fl_plcmnt_during_ihs
			from (
			select min(ihs.id_table_origin) as id_table_origin,max(ihs.max_id_table_origin) as max_id_table_origin
				,sum(ihs.cnt_id_table_origin) as cnt_id_table_origin,max(ihs.fl_plcmnt_prior_ihs) as fl_plcmnt_prior_ihs
				,max(ihs.fl_plcmnt_during_ihs) as fl_plcmnt_during_ihs
				,bth.id_case,bth.ihs_begin_date,bth.ihs_end_date

			from #tbl_both bth
			join #tmp_eps ihs on bth.id_case=ihs.id_case
					and ihs.ihs_begin_date between bth.ihs_begin_date and bth.ihs_end_date 
					and ihs.ihs_end_date  between bth.ihs_begin_date and bth.ihs_end_date 
			where bth.id_table_origin is null
			group by bth.id_case,bth.ihs_begin_date,bth.ihs_end_date ) q
			join #tbl_both bth on  bth.id_case=q.id_case
			and bth.ihs_begin_date=q.ihs_begin_date
			and bth.ihs_end_date=q.ihs_end_date


			--if object_id('debug.tbl_both_3') is not null drop table debug.tbl_both_3;
			--if @debug = 1 select * into debug.tbl_both_3 from #tbl_both


			update bth
			set		ID_INTAKE_FACT = srvc.ID_INTAKE_FACT
				  , rfrd_date=srvc.rfrd_date
				 , frst_IHS_after_intk= srvc.frst_IHS_after_intk	
				  , days_from_rfrd_date= srvc.days_from_rfrd_date
				  , min_id_payment_fact= srvc.min_id_payment_fact
				  , max_id_payment_fact= srvc.max_id_payment_fact
				  ,intake_county_cd=srvc.intake_county_cd
				  ,intake_zip=srvc.intake_zip
			from #tbl_both bth
			join #tmp_srvc srvc on srvc.id_case=bth.id_case and srvc.srvc_dt_begin=bth.ihs_begin_date
			where bth.ID_INTAKE_FACT is null

			--if object_id('debug.tbl_both_4') is not null drop table debug.tbl_both_4;
			--if @debug = 1 select * into debug.tbl_both_4 from #tbl_both
		

			update bth
			set nbr_svc_paid=q.nbr_svc_paid
				,total_amt_paid=q.total_amt_paid
				,fl_family_focused_services=q.fl_family_focused_services
				,fl_child_care=q.fl_child_care
				,fl_therapeutic_services=q.fl_therapeutic_services
				--,fl_mh_services=q.fl_mh_services
				--,fl_receiving_care=q.fl_receiving_care
				--,fl_family_home_placements=q.fl_family_home_placements
				,fl_behavioral_rehabiliation_services=q.fl_behavioral_rehabiliation_services
				,fl_other_therapeutic_living_situations=q.fl_other_therapeutic_living_situations
				,fl_specialty_adolescent_services=q.fl_specialty_adolescent_services
				,fl_respite=q.fl_respite
				,fl_transportation=q.fl_transportation
				--,fl_clothing_incidentals=q.fl_clothing_incidentals
				--,fl_sexually_aggressive_youth=q.fl_sexually_aggressive_youth
				--,fl_adoption_support=q.fl_adoption_support
				--,fl_various=q.fl_various
				--,fl_medical=q.fl_medical
				,fl_ihs_reun=q.fl_ihs_reun
				,fl_concrete_goods=q.fl_concrete_goods
				,fl_budget_C12=q.fl_budget_C12
				,fl_budget_C14=q.fl_budget_C14
				,fl_budget_C15=q.fl_budget_C15
				,fl_budget_C16=q.fl_budget_C16
				,fl_budget_C18=q.fl_budget_C18
				,fl_budget_C19=q.fl_budget_C19
				,fl_uncat_svc=q.fl_uncat_svc
				,min_id_payment_fact=q.min_id_payment_fact
				,max_id_payment_fact=q.max_id_payment_fact
			from #tbl_both bth
			join (
				select bth.id_case
					,bth.ihs_begin_date
					,bth.ihs_end_date
					, sum(srvc.nbr_svc_paid) as nbr_svc_paid
				  , sum(srvc.total_amt_paid) as total_amt_paid
				  , max(srvc.fl_family_focused_services) as fl_family_focused_services
				  , max(srvc.fl_child_care) as fl_child_care
				  , max(srvc.fl_therapeutic_services) as fl_therapeutic_services
				  --, max(srvc.fl_mh_services) as fl_mh_services
				  --, max(srvc.fl_receiving_care) as fl_receiving_care
				  --, max(srvc.fl_family_home_placements) as fl_family_home_placements
				  , max(srvc.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
				  , max(srvc.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
				  , max(srvc.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
				  , max(srvc.fl_respite) as fl_respite
				  , max(srvc.fl_transportation) as fl_transportation
				  --, max(srvc.fl_clothing_incidentals) as fl_clothing_incidentals
				  --, max(srvc.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
				  --, max(srvc.fl_adoption_support) as fl_adoption_support
				  --, max(srvc.fl_various) as fl_various
				  --, max(srvc.fl_medical) as fl_medical
				  , max(srvc.fl_ihs_reun) as fl_ihs_reun
				  , max(srvc.fl_concrete_goods) as fl_concrete_goods
				  , max(srvc.fl_budget_C12) as fl_budget_C12
				  , max(srvc.fl_budget_C14) as fl_budget_C14
				  , max(srvc.fl_budget_C15) as fl_budget_C15
				  , max(srvc.fl_budget_C16) as fl_budget_C16
				  , max(srvc.fl_budget_C18) as fl_budget_C18
				  , max(srvc.fl_budget_C19) as fl_budget_C19 
				  , max(srvc.fl_uncat_svc) as fl_uncat_svc
				  , min(srvc.min_id_payment_fact) as min_id_payment_fact
				  , max(srvc.max_id_payment_fact) as max_id_payment_fact
		from #tbl_both bth
			join #tmp_srvc srvc on srvc.id_case=bth.id_case and srvc.srvc_dt_begin between bth.ihs_begin_date and bth.ihs_end_date
				and srvc.srvc_dt_End between bth.ihs_begin_date and bth.ihs_end_date
		group by bth.id_case,bth.ihs_begin_date,bth.ihs_end_date) q on q.id_case=bth.id_case
		and q.ihs_begin_date=bth.ihs_begin_date
		and q.ihs_end_date=bth.ihs_end_date


		--if object_id('debug.tbl_both_5') is not null drop table debug.tbl_both_5;
		--if @debug = 1 select * into debug.tbl_both_5 from #tbl_both


		insert into #tbl_ihs_episodes
		select * from #tbl_both

		--if object_id('debug.tbl_ihs_episodes_5') is not null drop table debug.tbl_ihs_episodes_5; 		
		--if @debug = 1 select * into debug.tbl_ihs_episodes_5 from #tbl_ihs_episodes 

			--select * from #ihs_pay_srvc_all pay
			--left join #tbl_ihs_episodes eps on pay.id_case=eps.id_case
			--and pay.srvc_dt_begin between ihs_begin_date and ihs_end_date
			--and pay.srvc_dt_end  between ihs_begin_date and ihs_end_date
			--where eps.id_case is null

			
			update eps
			set case_sort=q.row_num
			from #tbl_ihs_episodes eps
			join (select row_number()  over (partition by id_case order by ihs_begin_date,ihs_end_date) as row_num,*
					from #tbl_ihs_episodes) q on q.id_case=eps.id_case and q.ihs_begin_date=eps.ihs_begin_date and q.id_table_origin=eps.id_table_origin and q.max_id_table_origin=eps.max_id_table_origin

		--if object_id('debug.tbl_ihs_episodes_6') is not null drop table debug.tbl_ihs_episodes_6; 		
		--if @debug = 1 select * into debug.tbl_ihs_episodes_6 from #tbl_ihs_episodes 

			update eps
			set id_ihs_episode=q.row_num
			from #tbl_ihs_episodes eps
			join (select row_number()  over (order by id_case,ihs_begin_date,ihs_end_date) as row_num,*
					from #tbl_ihs_episodes) q on q.id_case=eps.id_case 
					and q.ihs_begin_date=eps.ihs_begin_date 
					and q.id_table_origin=eps.id_table_origin 
					and q.max_id_table_origin=eps.max_id_table_origin

		--if object_id('debug.tbl_ihs_episodes_7') is not null drop table debug.tbl_ihs_episodes_7; 		
		--if @debug = 1 select * into debug.tbl_ihs_episodes_7 from #tbl_ihs_episodes 

			update dtl
			set id_ihs_episode = null
			from #ihs_pay_srvc_dtl dtl

			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from #ihs_pay_srvc_dtl dtl
			join #tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and dtl.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
				and dtl.srvc_dt_end between eps.ihs_begin_date and eps.ihs_end_date

		--if object_id('debug.ihs_pay_srvc_all_14') is not null drop table debug.ihs_pay_srvc_all_14;
		--if @debug = 1 select * into debug.ihs_pay_srvc_all_14 from #ihs_pay_srvc_all

		--only want detail rolling up to 1 episode (double check)
			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from #ihs_pay_srvc_dtl dtl
			join (
			select eps.id_ihs_episode ,eps.ihs_begin_date,eps.ihs_end_date,dtl.dtl_id_payment_fact,row_number() over
			(partition by dtl_id_payment_fact,auth.srvc_dt_begin order by ihs_begin_date asc) as row_num
			from #ihs_pay_srvc_dtl dtl
			join #ihs_pay_srvc_all auth on auth.id_case=dtl.id_case 
					and dtl.srvc_dt_begin between auth.srvc_dt_begin and auth.srvc_dt_end
					and dtl.srvc_dt_begin between auth.srvc_dt_begin and auth.srvc_dt_end
			join #tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and eps.ihs_begin_date between auth.srvc_dt_begin and auth.srvc_dt_end
				and eps.ihs_end_date between auth.srvc_dt_begin and auth.srvc_dt_end
				and dtl.id_ihs_episode is null
				and eps.plcmnt_date is null
				-- where dtl_id_payment_fact in (8828632,9861488,9868174,10308943,10348044)
				) eps 
				on eps.dtl_id_payment_fact=dtl.dtl_id_payment_fact
			where row_num=1 and dtl.id_ihs_episode is null

		--if object_id('debug.ihs_pay_srvc_all_15') is not null drop table debug.ihs_pay_srvc_all_15;
		--if @debug = 1 select * into debug.ihs_pay_srvc_all_15 from #ihs_pay_srvc_all

		
		CREATE NONCLUSTERED INDEX  idx_id_ihs_episodes
		ON #tbl_ihs_episodes ([id_ihs_episode])
	
		-- update most expensive

			update ihs
			set   most_exp_cd_srvc = q.cd_srvc
					, most_exp_tx_srvc=q.tx_srvc
					, total_most_exp_srvc = q.total_most_exp_srvc	
			from #tbl_ihs_episodes ihs
			join (
				select auth.*,row_number() over( partition by ihs.id_case,ihs.ihs_begin_date
							,ihs.ihs_end_date order by auth.total_most_exp_srvc desc) as row_sort
				from #tbl_ihs_episodes ihs
				join  (
						select	ihs.id_ihs_episode
								, auth.cd_srvc
								, auth.tx_srvc
 								, sum(isnull(auth.am_total_paid,0)) as total_most_exp_srvc
						from #tbl_ihs_episodes ihs
							join  #ihs_pay_srvc_dtl  auth on auth.id_ihs_episode=ihs.id_ihs_episode 
						--where ihs.id_case=81785 and id_table_origin=8200531 and max_id_table_origin=8483336
					--	where ihs.id_case=553396
					  where auth.id_ihs_episode is not null
						group by ihs.id_ihs_episode
								, auth.cd_srvc
								, auth.tx_srvc
											)  auth 
											 on auth.id_ihs_episode=ihs.id_ihs_episode 
							
				) q on q.id_ihs_episode=ihs.id_ihs_episode
						and q.row_sort=1

		--if object_id('debug.tbl_ihs_episodes_8') is not null drop table debug.tbl_ihs_episodes_8; 		
		--if @debug = 1 select * into debug.tbl_ihs_episodes_8 from #tbl_ihs_episodes 
		




		update IH
		set total_amt_paid=q.total_amt_paid
			,nbr_svc_paid=q.nbr_svc_paid
			,dtl_min_id_payment_fact=q.min_id_payment_fact
			,dtl_max_id_payment_fact=q.max_id_payment_fact
			,cnt_id_table_origin = case when tbl_origin_cd=2 then q.cnt_id_table_origin else ih.cnt_id_table_origin end
		--select q.*,ih.*
		from #tbl_ihs_episodes IH
		join (select dtl.id_case,ih.id_ihs_episode
						,sum(1) as nbr_svc_paid
						,sum(isnull(dtl.am_total_paid,0) ) as total_amt_paid
						,count(distinct dtl.dtl_id_payment_fact) as cnt_id_table_origin
						,min(dtl.dtl_id_payment_fact) as min_id_payment_fact
						,max(dtl.dtl_id_payment_fact) as max_id_payment_fact
			FROM #tbl_ihs_episodes ih
			join #ihs_pay_srvc_dtl dtl on ih.id_ihs_episode=dtl.id_ihs_episode 
			where dtl.id_ihs_episode is not null
			group by dtl.id_case,ih.id_ihs_episode
			) q	on q.id_case=ih.id_case and q.id_ihs_episode=ih.id_ihs_episode

		update eps
		set first_ihs_date=frst_date,latest_ihs_date=last_date,fl_plcmnt_prior_ihs=isnull(eps.fl_plcmnt_prior_ihs,0)
			,fl_plcmnt_during_ihs=isnull(fl_plcmnt_during_ihs,0)
		from #tbl_ihs_episodes eps
		join (select id_case, min(ihs_begin_date) as frst_date
			   , max(ihs_begin_date) as last_date
			   from #tbl_ihs_episodes
			   group by id_case) q on q.id_case=eps.id_case

		--if object_id('debug.tbl_ihs_episodes_9') is not null drop table debug.tbl_ihs_episodes_9; 		
		--if @debug = 1 select * into debug.tbl_ihs_episodes_9 from #tbl_ihs_episodes 

		update eps
		set cd_sib_age_grp=intk.cd_sib_age_grp
			, cd_race_census_hh=intk.cd_race_census
			, census_hispanic_latino_origin_cd=intk.census_hispanic_latino_origin_cd
			, CD_ASGN_TYPE=case when eps.CD_ASGN_TYPE is null then intk.cd_asgn_type else eps.CD_ASGN_TYPE end
			, tx_asgn_type=case when eps.tx_asgn_type is null then intk.tx_asgn_type else eps.tx_asgn_type end
		from #tbl_ihs_episodes eps
		join 		base.tbl_intakes intk
				on intk.id_intake_Fact=eps.ID_INTAKE_FACT


		update #tbl_ihs_episodes
		set frst_IHS_after_intk=0
		
		
		update hme
		set frst_IHS_after_intk=1
		from #tbl_ihs_episodes hme
		join (
				select distinct q.id_case,q.id_intake_fact,q.id_table_origin,q.ihs_begin_date 
				 from #tbl_ihs_episodes hm
				 cross apply (select top 1
								id_case
								,id_intake_Fact
								,id_table_origin
								,ihs_begin_date
								,ihs_end_date
							from #tbl_ihs_episodes ih
							where ih.id_case=hm.id_case
							and ih.id_intake_fact=hm.id_intake_fact
							order by id_case,id_intake_Fact,ihs_begin_date asc
							) q
				 ) qry
				on qry.id_case=hme.id_case
				and qry.id_intake_fact=	hme.id_intake_fact
				and qry.id_table_origin=hme.id_table_origin
	
		
		

 		 UPDATE IH
		 SET fl_plcmnt_prior_ihs=0
		 FROM #tbl_ihs_episodes IH
		 
		 UPDATE IH
		 SET fl_plcmnt_prior_ihs=1
		 FROM #tbl_ihs_episodes IH
		 JOIN #eps TCE ON TCE.ID_CASE=ih.id_case 
		 AND TCE.eps_begin  < IH.ihs_begin_date;


		 		
		--if object_id('debug.tbl_ihs_episodes_10') is not null drop table debug.tbl_ihs_episodes_10; 		
		--if @debug = 1 select * into debug.tbl_ihs_episodes_10 from #tbl_ihs_episodes 


		if object_ID(N'base.tbl_ihs_episodes',N'U') is not null  truncate table base.tbl_ihs_episodes;
insert into base.tbl_ihs_episodes(
					id_ihs_episode
					,id_case
					,case_sort
					,ihs_begin_date
					,ihs_end_date
					,first_ihs_date
					,latest_ihs_date
				  ,intake_county_cd
				  ,intake_zip
					,fl_plcmnt_prior_ihs
					,plcmnt_date
					,days_from_rfrd_date
					,nbr_svc_paid
					,total_amt_paid
					,most_exp_cd_srvc
					,most_exp_tx_srvc
					,total_most_exp_srvc
					,fl_family_focused_services
					,fl_child_care
					,fl_therapeutic_services
					--,fl_mh_services
					--,fl_receiving_care
					--,fl_family_home_placements
					,fl_behavioral_rehabiliation_services
					,fl_other_therapeutic_living_situations
					,fl_specialty_adolescent_services
					,fl_respite
					,fl_transportation
					--,fl_clothing_incidentals
					--,fl_sexually_aggressive_youth
					--,fl_adoption_support
					--,fl_various
					--,fl_medical
					,fl_ihs_reun
					,fl_concrete_goods
					,fl_budget_C12
					,fl_budget_C14
					--,fl_budget_C15  (Disabled.  Not in Table. GH)
					--,fl_budget_C16  (Disabled.  Not in Table. GH)
					--,fl_budget_C18  (Disabled.  Not in Table. GH)
					,fl_budget_C19
					,fl_uncat_svc
					,cd_asgn_type
					,tx_asgn_type
					,fl_force_end_date
					,min_id_table_origin
					,max_id_table_origin
					,cnt_id_table_origin
					,dtl_min_id_payment_fact
					,dtl_max_id_payment_fact
					,tbl_origin
					,tbl_origin_cd
					,id_intake_fact
					,rfrd_date
					,cd_sib_age_grp
					,cd_race_census_hh
					,census_hispanic_latino_origin_cd_hh
					,fl_first_IHS_after_intake	  )
SELECT id_ihs_episode
      ,[id_case]
      ,[case_sort]
      ,[ihs_begin_date]
      ,[ihs_end_date]
      ,[first_ihs_date]
      ,[latest_ihs_date]
      ,intake_county_cd
      ,intake_zip
      ,[fl_plcmnt_prior_ihs]
      ,[plcmnt_date]
      ,days_from_rfrd_date
      ,[nbr_svc_paid]
      ,[total_amt_paid]
      ,[most_exp_cd_srvc]
      ,[most_exp_tx_srvc]
      ,[total_most_exp_srvc]
      ,[fl_family_focused_services]
      ,[fl_child_care]
      ,[fl_therapeutic_services]
      --,[fl_mh_services]
      --,[fl_receiving_care]
      --,[fl_family_home_placements]
      ,[fl_behavioral_rehabiliation_services]
      ,[fl_other_therapeutic_living_situations]
      ,[fl_specialty_adolescent_services]
      ,[fl_respite]
      ,[fl_transportation]
      --,[fl_clothing_incidentals]
      --,[fl_sexually_aggressive_youth]
      --,[fl_adoption_support]
      --,[fl_various]
      --,[fl_medical]
	  ,fl_ihs_reun
	  ,fl_concrete_goods
      ,[fl_budget_C12]
      ,[fl_budget_C14]
      --,[fl_budget_C15]  (Disabled.  Not in Table. GH)
      --,[fl_budget_C16]  (Disabled.  Not in Table. GH)
      --,[fl_budget_C18]  (Disabled.  Not in Table. GH)
      ,[fl_budget_C19]
      ,[fl_uncat_svc]
      ,[cd_asgn_type]
      ,[tx_asgn_type]
      ,[fl_force_end_date]
      ,[id_table_origin]
      ,[max_id_table_origin]
      ,[cnt_id_table_origin]
      ,[dtl_min_id_payment_fact]
      ,[dtl_max_id_payment_fact]
      ,[tbl_origin]
      ,[tbl_origin_cd]
      ,[id_intake_fact]
	  ,rfrd_date
	  ,cd_sib_age_grp
	  ,cd_race_census_hh
	  ,census_hispanic_latino_origin_cd
	  ,ihs.frst_IHS_after_intk
  FROM #tbl_ihs_episodes ihs


  

if object_ID(N'base.tbl_ihs_services',N'U') is not null  truncate table base.tbl_ihs_services;
insert into base.tbl_ihs_services
([id_ihs_episode]
      ,[dtl_id_payment_fact]
      ,[id_case]
      ,[id_prsn]
      ,[prsn_age]
      ,[srvc_dt_begin]
      ,[srvc_dt_end]
      ,[cd_srvc]
      ,[tx_srvc]
      ,[am_rate]
      ,[am_units]
      ,[am_total_paid]
      ,[id_service_type_dim]
      ,[id_provider_dim_service]
      ,[cd_unit_rate_type]
      ,[tx_unit_rate_type]
      ,[cd_srvc_ctgry]
      ,[tx_srvc_ctgry]
      ,[cd_budget_poc_frc]
      ,[tx_budget_poc_frc]
      ,[cd_subctgry_poc_frc]
      ,[tx_subctgry_poc_frc]
      ,[dur_days]
      ,[ihs_rank]
      ,[fl_no_pay])
select [id_ihs_episode]
      ,[dtl_id_payment_fact]
      ,[id_case]
      ,[id_prsn_child]
      ,[child_age]
      ,[srvc_dt_begin]
      ,[srvc_dt_end]
      ,[cd_srvc]
      ,[tx_srvc]
      ,[am_rate]
      ,[am_units]
      ,[am_total_paid]
          ,[id_service_type_dim]
      ,[id_provider_dim_service]
      ,[cd_unit_rate_type]
      ,[tx_unit_rate_type]
      ,[cd_srvc_ctgry]
      ,[tx_srvc_ctgry]
      ,[cd_budget_poc_frc]
      ,[tx_budget_poc_frc]
      ,[cd_subctgry_poc_frc]
      ,[tx_subctgry_poc_frc]
      , case when srvc_dt_end is not null and srvc_dt_end <> '12/31/3999' then datediff(dd,[srvc_dt_begin],[srvc_dt_end]) else null end
      , rank() over (partition by id_case order by srvc_dt_begin) as [ihs_rank]
	  , 0
	  from #ihs_pay_srvc_dtl
	


--select * from tbl_ihs_services where id_case=385344
--select * from tbl_ihs_episodes where id_case=385344


declare @max_pay_id int
select @max_pay_id=max(id_payment_fact) from dbo.payment_fact

insert into base.tbl_ihs_services
([id_ihs_episode]
      ,[dtl_id_payment_fact]
      ,[id_case]
      ,[id_prsn]
      ,prsn_age
      ,[srvc_dt_begin]
      ,[srvc_dt_end]
      ,[cd_srvc]
      ,[tx_srvc]
      ,[am_rate]
      ,[am_units]
      ,[am_total_paid]
      ,[id_service_type_dim]
      ,[id_provider_dim_service]
      ,[cd_unit_rate_type]
      ,[tx_unit_rate_type]
      ,[cd_srvc_ctgry]
      ,[tx_srvc_ctgry]
      ,[cd_budget_poc_frc]
      ,[tx_budget_poc_frc]
      ,[cd_subctgry_poc_frc]
      ,[tx_subctgry_poc_frc]
      ,[dur_days]
      ,[ihs_rank]
	  ,fl_no_pay)
select eps.[id_ihs_episode]
      ,@max_pay_id + eps.[id_ihs_episode]
      ,[id_case]
      ,null
      ,null
      ,ihs_begin_date
      ,ihs_end_date
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      , null
      , 1
	  , 1
	from base.TBL_ihs_episodes eps
	join (select id_ihs_episode from base.TBL_ihs_episodes 
		except 
		select id_ihs_episode from base.TBL_ihs_services) q on q.id_ihs_episode=eps.id_ihs_episode



-- update 
update base.tbl_ihs_episodes
set cd_asgn_type= intk.cd_asgn_type
, tx_asgn_type=intk.tx_asgn_type
from #ihs_intk intk
where intk.ID_INTAKE_FACT=base.tbl_ihs_episodes.id_intake_fact
and tbl_origin_cd =3;


update base.tbl_ihs_episodes
set ihs_end_date=plcmnt_date
where plcmnt_date <> ihs_end_date
and plcmnt_date > ihs_begin_date
and plcmnt_date < ihs_end_date


update base.tbl_ihs_episodes
set nxt_placement_date=q.state_custody_start_date
from  (
	select distinct eps.id_ihs_episode, eps.id_case,eps.ihs_begin_date,eps.ihs_end_date,tce.state_custody_start_date ,federal_discharge_date
		,row_number() over (partition by eps.id_case,eps.ihs_begin_date order by tce.state_custody_start_date asc) as row_num
	from  base.tbl_ihs_episodes eps 
	join base.tbl_child_episodes tce on tce.id_intake_fact=eps.id_intake_fact and tce.id_case=eps.id_case
		and tce.state_custody_start_date >= eps.ihs_begin_date
	where eps.ihs_end_date <> '12/31/3999' ) q 
where  q.id_ihs_episode=tbl_ihs_episodes.id_ihs_episode
	and row_num=1


update base.tbl_ihs_episodes
set nxt_placement_date=q.state_custody_start_date
from  (
	select distinct eps.id_ihs_episode, eps.id_case,eps.ihs_begin_date,eps.ihs_end_date,tce.state_custody_start_date ,federal_discharge_date
		,row_number() over (partition by eps.id_case,eps.ihs_begin_date order by tce.state_custody_start_date asc) as row_num
	from  base.tbl_ihs_episodes eps 
	join base.tbl_child_episodes tce on  tce.id_case=eps.id_case
		and tce.state_custody_start_date >= eps.ihs_begin_date
	where eps.ihs_end_date <> '12/31/3999' ) q 
where  q.id_ihs_episode=tbl_ihs_episodes.id_ihs_episode
	and row_num=1 and nxt_placement_date is null


	-- there is a bug in this code above.  Need to fix...  Example is id_case 1436416	with ihs_begin_dt 	2009-10-19 00:00:00.000	2010-11-30 00:00:00.000
	-- flags not set properly in code above.
	update eps
	set fl_family_focused_services=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=1

	update eps
	set fl_child_care=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=2
	
		update eps
	set fl_therapeutic_services=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=3
	
		update eps
	set fl_behavioral_rehabiliation_services=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=7
	
		update eps
	set fl_other_therapeutic_living_situations=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=8
	
		update eps
	set fl_specialty_adolescent_services=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=9
	
		update eps
	set fl_respite=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=10
	
		update eps
	set fl_transportation=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=11
	
		update eps
	set fl_ihs_reun=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=17
	
		update eps
	set fl_concrete_goods=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_subctgry_poc_frc=18


	update eps
	set int_filter_service_category=xw.int_filter_service_category
	from base.tbl_ihs_episodes eps
	join ref_service_category_flag_xwalk xw 
		on eps.fl_family_focused_services=xw.fl_family_focused_services
		and eps.fl_child_care=xw.fl_child_care
		and eps.fl_therapeutic_services=xw.fl_therapeutic_services
		and eps.fl_behavioral_rehabiliation_services=xw.fl_behavioral_rehabiliation_services
		and eps.fl_other_therapeutic_living_situations=xw.fl_other_therapeutic_living_situations
		and eps.fl_specialty_adolescent_services=xw.fl_specialty_adolescent_services
		and eps.fl_respite=xw.fl_respite
		and eps.fl_transportation=xw.fl_transportation
		and eps.fl_ihs_reun=xw.fl_ihs_reun
		and eps.fl_concrete_goods=xw.fl_concrete_goods
		and xw.fl_mh_services=0
		and xw.fl_adoption_support=0
		and xw.fl_clothing_incidentals=0
		and xw.fl_family_home_placements=0
		and xw.fl_medical=0
		and xw.fl_sexually_aggressive_youth=0
		and xw.fl_receiving_care=0
		and xw.fl_various=0

update eps
	set eps.fl_budget_C12=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_budget_poc_frc=12 and (eps.fl_budget_C12=0 or eps.fl_budget_C12 is null)

update eps
	set eps.fl_budget_C14=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_budget_poc_frc=14 and (eps.fl_budget_C14=0 or eps.fl_budget_C14 is null)

update eps
	set eps.fl_budget_C19=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_budget_poc_frc=19 and (eps.fl_budget_C19=0 or eps.fl_budget_C19 is null)

update eps
	set eps.fl_uncat_svc=1
	from base.tbl_ihs_episodes eps
	join base.tbl_ihs_services svc on eps.id_ihs_episode=svc.id_ihs_episode
	where svc.cd_budget_poc_frc=99 and (eps.fl_uncat_svc=0 or eps.fl_uncat_svc is null)

update statistics base.tbl_ihs_episodes

update statistics base.tbl_ihs_services
		--select ihs.id_ihs_episode,ihs.total_amt_paid,ihs.nbr_svc_paid
		--	,isnull(sum(svc.[am_total_paid]),0.00) as dtl_paid
		--	from base.tbl_ihs_episodes ihs
		--	join base.tbl_ihs_services svc on svc.id_ihs_episode=ihs.id_ihs_episode
		--	group by ihs.id_ihs_episode,ihs.total_amt_paid,ihs.nbr_svc_paid
		--	having total_amt_paid <> isnull(sum(svc.[am_total_paid]),0.00) 

update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_build_tbls_ihs_episode_services'





--if object_id('debug.eps') is not null drop table debug.eps;
--if @debug = 1 select * into debug.eps from #eps 

--if object_id('debug.ihs_intk') is not null drop table debug.ihs_intk;
--if @debug = 1 select * into debug.ihs_intk from #ihs_intk 

--if object_id('debug.cps') is not null drop table debug.cps;
--if @debug = 1 select * into debug.cps from #cps 

--if object_id('debug.ih_tmp') is not null drop table debug.ih_tmp;
--if @debug = 1 select * into debug.ih_tmp from #ih_tmp 

--if object_id('debug.ihs') is not null drop table debug.ihs;
--if @debug = 1 select * into debug.ihs from #ihs
	
end
