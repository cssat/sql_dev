--USE [CA_ODS]
--GO
--/****** Object:  StoredProcedure [base].[prod_build_tbls_ihs_episode_services]    Script Date: 10/30/2013 11:44:55 AM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--/****** Object:  StoredProcedure [base].[prod_build_tbls_ihs_episode_services]    Script Date: 10/29/2013 1:10:57 PM ******/



--ALTER procedure [base].[prod_build_tbls_ihs_episode_services](@permission_key datetime)
--as 

--if @permission_key=(select cutoff_date from ref_last_DW_transfer)
--begin
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
	set @start_date=cast('1/1/1997' as datetime)
		
		
	if object_ID('tempDB..##eps') is not null drop table ##eps
	
	select *,row_number() over (partition by id_case order by eps_begin,eps_end  asc) as sort_asc
	into ##eps
	from (
		select distinct id_case,state_custody_start_date as eps_begin
		,isnull(federal_discharge_date,'12/31/3999') as eps_end
		from base.tbl_child_episodes ) eps

	if object_ID('tempDB..##ihs_intk') is not null drop table ##ihs_intk	
		CREATE TABLE ##ihs_intk
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
		, PRIMARY KEY (ID_CASE ,INV_ASS_START ,ID_INTAKE_FACT ))
		
		
		INSERT INTO ##ihs_intk
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
		from base.TBL_INTAKES
		where coalesce(inv_ass_stop,'12/31/3999') >= @start_date
			and inv_ass_start <=@cutoff_date
			and fl_reopen_case=0
			and cd_final_decision=1;
			
			
			
	-- 2. only want the CPS screened in for services
	if object_id('tempDB..##cps') is not null drop table ##cps;
	
	SELECT HM.* ,DD.CD_INVS_DISP,DD.tx_INVS_DISP  
	 into ##cps
	 FROM ##ihs_intk HM
	 JOIN base.TBL_INTAKES IVF ON IVF.ID_INTAKE_FACT=HM.ID_INTAKE_FACT
	 JOIN dbo.INVESTIGATION_ASSESSMENT_FACT iaf ON IAF.ID_INVESTIGATION_ASSESSMENT_FACT=IVF.ID_INVESTIGATION_ASSESSMENT_FACT
	 JOIN dbo.DISPOSITION_DIM DD ON DD.ID_DISPOSITION_DIM=IAF.ID_DISPOSITION_DIM
	 WHERE DD.CD_INVS_DISP IN (3,4) and HM.cd_asgn_type=4
	 and ivf.id_investigation_assessment_fact is not null
	 
		 
		--DELETE CPS EXCEPT THOSE WITH SERVICES
		DELETE IH
		--select *
		 FROM ##ihs_intk ih
		WHERE ih.cd_asgn_type=4 and IH.id_intake_fact not in (select id_intake_fact from ##cps);			
		
		CREATE INDEX IDX_ID_CASE_INV_ASS_START_TMP ON ##ihs_intk(id_case,inv_ass_start) INCLUDE (id_intake_fact,
				CD_RACE_CENSUS_HH,CENSUS_HISPANIC_LATINO_ORIGIN_CD_HH,cd_sib_age_grp);
	
		
-- start retrieving all assignments that are either designated 'out-of-home care' or cps for social workers
		
	if object_ID('tempDB..##ih_assgn_all') is not null drop table ##ih_assgn_all
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
		, cast(0 as int)  as cd_office
		, cast(null as varchar(200)) as tx_office
		, datediff(dd,inv_ass_start,dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN)) as days_from_rfrd_date
		, cast(0 as int) as nbr_svc_paid 
		, cast(0 as numeric(18,2)) as total_amt_paid
		, cast(0 as int) as most_exp_cd_srvc
		, cast(null as varchar(200)) as most_exp_tx_srvc
		, cast(0 as numeric(18,2)) as total_most_exp_srvc
		, cast(0 as int) as fl_family_focused_services
		, cast(0 as int) as fl_child_care
		, cast(0 as int) as fl_therapeutic_services
		, cast(0 as int) as fl_mh_services
		, cast(0 as int) as fl_receiving_care
		, cast(0 as int) as fl_family_home_placements
		, cast(0 as int) as fl_behavioral_rehabiliation_services
		, cast(0 as int) as fl_other_therapeutic_living_situations
		, cast(0 as int) as fl_specialty_adolescent_services
		, cast(0 as int) as fl_respite
		, cast(0 as int) as fl_transportation
		, cast(0 as int) as fl_clothing_incidentals
		, cast(0 as int) as fl_sexually_aggressive_youth
		, cast(0 as int) as fl_adoption_support
		, cast(0 as int) as fl_various
		, cast(0 as int) as fl_medical
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
	into ##ih_assgn_all
	FROM ##ihs_intk inf 
 		join dbo.ASSIGNMENT_FACT af on inf.id_case=af.id_case
			AND INF.INV_ASS_START <=dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN)
		join dbo.ASSIGNMENT_ATTRIBUTE_DIM aad on af.ID_ASSIGNMENT_ATTRIBUTE_DIM=aad.ID_ASSIGNMENT_ATTRIBUTE_DIM
		join dbo.worker_dim wd on wd.id_worker_dim=af.id_worker_dim and wd.CD_JOB_CLS in (9,10,11)
		left join base.TBL_case_dim cd on cd.id_case=af.id_case
				and dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN)<dt_case_cls
				and coalesce(dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_END),'12/31/3999')>dt_case_opn
		WHERE  dbo.IntDate_to_CalDate(af.ID_CALENDAR_DIM_BEGIN) >= inf.INV_ASS_START and 
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

	  -- only want one intake per assignment
	  delete IH
	  from ##ih_assgn_all IH
	  join (
			select id_case,ihs_begin_date,id_table_origin,id_intake_fact ,(days_from_rfrd_date) ,row_number() over 
			(partition by id_table_origin order by days_from_rfrd_date asc) as row_num
			from ##ih_assgn_all
			--order by id_case,id_table_origin
			) q on q.id_case=IH.id_case
			and q.ihs_begin_date=IH.ihs_begin_date
			and q.id_table_origin=IH.id_table_origin
			and q.ID_INTAKE_FACT <> ih.ID_INTAKE_FACT
			and q.row_num=1




	  -- BEGIN DELETE THOSE WITH OVERLAPPING OUT OF HOME CARE ------------------------------------------------------
		update ihs
		set ihs_end_date=state_custody_start_date
				,ihs.fl_force_end_date=1
				,ihs.plcmnt_date=tce.state_custody_start_date
			--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from ##ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 
		and state_custody_start_date > ihs_begin_date 
		-- and state_custody_start_date < ihs_end_date

		delete ihs
		--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from ##ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 

		
		update ihs
		set ihs_end_date=state_custody_start_date
		,ihs.fl_force_end_date=1
		,ihs.plcmnt_date=tce.state_custody_start_date
		--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from ##ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_intake_fact=ihs.id_intake_fact
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 
		and state_custody_start_date > ihs_begin_date 
		-- and state_custody_start_date < ihs_end_date




		delete ihs
		from ##ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_intake_fact=ihs.id_intake_fact
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 



		  --  END process DELETE THOSE WITH OVERLAPPING OUT OF HOME CARE ------------------------------------------------------

		-- now aggregate by end date ( this will get rid of segments contained within another with same end date)
		if object_id('tempDB..##ih_tmp') is not null drop table ##ih_tmp
		SELECT id_case
			  ,min(ID_INTAKE_FACT) as id_intake_Fact
			  ,cast(null as datetime) as rfrd_date
			  ,min(id_table_origin) as id_table_origin
			  ,max(max_id_table_origin) as max_id_table_origin
			  ,sum(cnt_id_table_origin) as cnt_id_table_origin
			  ,min(ihs_begin_date) as ihs_begin_date
			  ,ihs_end_date
			  ,case_sort
			  ,first_ihs_date
			  ,latest_ihs_date
			  ,max(fl_plcmnt_prior_ihs) as fl_plcmnt_prior_ihs
			  ,max(fl_plcmnt_during_ihs)  as fl_plcmnt_during_ihs
			  ,min(plcmnt_date) as plcmnt_date --need to update federal discharge date
			  ,min(cd_office) as cd_office
			  ,tx_office
			  ,days_from_rfrd_date
			  ,nbr_svc_paid
			  ,total_amt_paid
			  ,most_exp_cd_srvc
			  ,most_exp_tx_srvc
			  ,total_most_exp_srvc
			 , max(fl_family_focused_services) as fl_family_focused_services
			 , max(fl_child_care) as fl_child_care
			 , max(fl_therapeutic_services) as fl_therapeutic_services
			 , max(fl_mh_services) as fl_mh_services
			 , max(fl_receiving_care) as fl_receiving_care
			 , max(fl_family_home_placements) as fl_family_home_placements
			 , max(fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
			 , max(fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
			 , max(fl_specialty_adolescent_services) as fl_specialty_adolescent_services
			 , max(fl_respite) as fl_respite
			 , max(fl_transportation) as fl_transportation
			 , max(fl_clothing_incidentals) as fl_clothing_incidentals
			 , max(fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
			 , max(fl_adoption_support) as fl_adoption_support
			 , max(fl_various) as fl_various
			 , max(fl_medical) as fl_medical
			 , max(fl_budget_C12) as fl_budget_C12
			 , max(fl_budget_C14) as fl_budget_C14
			 , max(fl_budget_C15) as fl_budget_C15
			 , max(fl_budget_C16) as fl_budget_C16
			 , max(fl_budget_C18) as fl_budget_C18
			 , max(fl_budget_C19) as fl_budget_C19
			 , max(fl_uncat_svc) as fl_uncat_svc		 
			  ,cd_asgn_type
			  ,tx_asgn_type
			  ,max(fl_force_end_date) as fl_force_end_date
			  ,tbl_origin
			  ,tbl_origin_cd
			  ,0 as frst_IHS_after_intk
			  into ##ih_tmp
			from ##ih_assgn_all
			group by id_case
			  ,ihs_end_date
			  ,case_sort
			  ,first_ihs_date
			  ,latest_ihs_date
			  ,tx_office
			  ,days_from_rfrd_date
			  ,nbr_svc_paid
			  ,total_amt_paid
			  ,most_exp_cd_srvc
			  ,most_exp_tx_srvc
			  ,total_most_exp_srvc
			  ,cd_asgn_type
			  ,tx_asgn_type
			  ,tbl_origin
			  ,tbl_origin_cd
			  ,ID_INTAKE_FACT
		

		update ##ih_tmp
		set rfrd_date=intk.INV_ASS_START
		from ##ihs_intk intk where intk.ID_INTAKE_FACT=##ih_tmp.id_intake_fact

		truncate table ##ih_assgn_all
		insert into ##ih_assgn_all
		select * from ##ih_tmp



		---delete from ##ih_assgn_all where days_from_rfrd_date >=90

	
		CREATE NONCLUSTERED INDEX  idx_temp_assgn_all on ##ih_assgn_all ([id_table_origin],max_id_table_origin)
		
		update ihs
		set case_sort=q.row_num
		from ##ih_assgn_all ihs
		join (	select *
				, row_number() over (partition by id_case order by ihs_begin_date asc
											,ihs_end_date desc) as row_num
				from  ##ih_assgn_all) q on q.id_table_origin=ihs.id_table_origin and q.max_id_table_origin=ihs.max_id_table_origin


		

		set nocount off
		declare @row_num int
		/****      merge assignment segments contained within  ************************************/
   		set @row_num=1
		while @row_num > 0
		begin	
				if object_ID('tempDB..##pieces') is not null drop table ##pieces

				select distinct 1 as fl_curr,curr.*
				into ##pieces
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date between curr.ihs_begin_date and curr.ihs_end_date 
					and nxt.ihs_end_date between curr.ihs_begin_date and curr.ihs_end_date 
				union 
				select distinct 0, nxt.*
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date between curr.ihs_begin_date and curr.ihs_end_date 
					and nxt.ihs_end_date between curr.ihs_begin_date and curr.ihs_end_date 
				order by [id_case],[case_sort],fl_curr
			
				
				set @row_num=@@ROWCOUNT
				if @row_num > 0
				begin
				-- first delete the segments that are currently there
						delete IH
						from ##ih_assgn_all ih
						join ##pieces s on s.id_case=ih.id_case 
						and s.case_sort=ih.case_sort
						and s.id_table_origin=ih.id_table_origin 
						and s.max_id_table_origin=ih.max_id_table_origin
						and s.ihs_begin_date=ih.ihs_begin_date 
						and s.ihs_end_date=ih.ihs_end_date
		
		

						update curr
						set curr.cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
						--, max_id_table_origin=case when nxt.max_id_table_origin > curr.max_id_table_origin 
						--			then nxt.max_id_table_origin  else curr.max_id_table_origin  end
						--, id_table_origin=case when nxt.id_table_origin < curr.id_table_origin then nxt.id_table_origin else curr.id_table_origin end
						from ##pieces curr
						join ##pieces nxt on curr.id_case=nxt.id_case 
							and curr.case_sort + 1 =nxt.case_sort
						left join ##pieces dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
						where nxt.ihs_begin_date between curr.ihs_begin_date and curr.ihs_end_date 
							  and nxt.ihs_end_date between curr.ihs_begin_date and curr.ihs_end_date 
						and curr.fl_curr=1 and nxt.fl_curr=0

		

						insert into ##ih_assgn_all
						select 
							   id_case
							   ,ID_INTAKE_FACT
							  ,rfrd_date
							  ,id_table_origin
							  ,max_id_table_origin
							  ,cnt_id_table_origin
							  ,ihs_begin_date
							  ,ihs_end_date
							  ,case_sort
							  ,first_ihs_date
							  ,latest_ihs_date
							  ,fl_plcmnt_prior_ihs
							  ,fl_plcmnt_during_ihs
							  ,plcmnt_date
							  ,cd_office
							  ,tx_office
							  ,days_from_rfrd_date
							  ,nbr_svc_paid
							  ,total_amt_paid
							  ,most_exp_cd_srvc
							  ,most_exp_tx_srvc
							  ,total_most_exp_srvc
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
							  ,cd_asgn_type
							  ,tx_asgn_type
							  ,fl_force_end_date
							  ,tbl_origin
							  ,tbl_origin_cd
							  ,frst_IHS_after_intk		
						from ##pieces where fl_curr=1
			

				 end
				update ihs
				set case_sort=q.row_num
				from ##ih_assgn_all ihs
				join (	select *
						, row_number() over (partition by id_case order by ihs_begin_date asc
													,ihs_end_date desc) as row_num
						from  ##ih_assgn_all) q  on q.id_table_origin=ihs.id_table_origin and q.max_id_table_origin=ihs.max_id_table_origin

			  
		end


		/************************             merge overlapping assignment segments  ***********************************/
	    set @row_num=1
		while @row_num > 0
		begin	
				if object_ID('tempDB..##segs') is not null drop table ##segs

				select 1 as fl_curr,curr.*
				into ##segs
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date <=  curr.ihs_end_Date
				union 
				select 0, nxt.*
				from ##ih_assgn_all curr
				join ##ih_assgn_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.ihs_begin_date <=  curr.ihs_end_Date
				order by [id_case],[case_sort],fl_curr

				set @row_num=@@ROWCOUNT

				-- first delete the segments that are currently there
				delete IH
				from ##ih_assgn_all ih
				join ##segs s on s.id_case=ih.id_case 
				and s.case_sort=ih.case_sort
				and s.id_table_origin=ih.id_table_origin 
				and s.max_id_table_origin=ih.max_id_table_origin
				and s.ihs_begin_date=ih.ihs_begin_date 
				and s.ihs_end_date=ih.ihs_end_date
		

				update curr
				set ihs_end_date=nxt.ihs_end_date
				, curr.cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
				, max_id_table_origin=case when nxt.max_id_table_origin > curr.max_id_table_origin then nxt.max_id_table_origin  else curr.max_id_table_origin  end
			--	, id_table_origin=case when nxt.id_table_origin < curr.id_table_origin then nxt.id_table_origin else curr.id_table_origin end
				from ##segs curr
				join ##segs nxt on curr.id_case=nxt.id_case and curr.case_sort + 1 =nxt.case_sort
				left join ##segs dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
				where nxt.ihs_begin_date <=  curr.ihs_end_Date
				and curr.fl_curr=1 and nxt.fl_curr=0

		

				insert into ##ih_assgn_all
				select 
					   id_case
					  ,ID_INTAKE_FACT
					  ,rfrd_date
					  ,id_table_origin
					  ,max_id_table_origin
					  ,cnt_id_table_origin
					  ,ihs_begin_date
					  ,ihs_end_date
					  ,case_sort
					  ,first_ihs_date
					  ,latest_ihs_date
					  ,fl_plcmnt_prior_ihs
					  ,fl_plcmnt_during_ihs
					  ,plcmnt_date
					  ,cd_office
					  ,tx_office
					  ,days_from_rfrd_date
					  ,nbr_svc_paid
					  ,total_amt_paid
					  ,most_exp_cd_srvc
					  ,most_exp_tx_srvc
					  ,total_most_exp_srvc
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
					  ,cd_asgn_type
					  ,tx_asgn_type
					  ,fl_force_end_date
					  ,tbl_origin
					  ,tbl_origin_cd	
					  ,frst_IHS_after_intk	
				from ##segs where fl_curr=1


				update ihs
						set case_sort=q.row_num
						from ##ih_assgn_all ihs
						join (	select *
								, row_number() over (partition by id_case order by ihs_begin_date asc
															,ihs_end_date desc) as row_num
								from  ##ih_assgn_all) q on q.id_table_origin=ihs.id_table_origin
		end

		--get  office of worker
			
		 UPDATE IH
		 SET cd_office = ld.cd_office
				,tx_office =ld.tx_office
		 FROM ##ih_assgn_all IH
		 join dbo.assignment_fact af on ih.id_table_origin=af.id_assignment_fact
			join dbo.worker_dim wd on wd.id_worker_dim=af.id_worker_dim and wd.CD_JOB_CLS in (9,10,11)
			left join dbo.location_dim ld on ld.id_location_dim=wd.id_location_dim_worker
		
		
		delete ihs
		--  select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from ##ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 

		
  	
		update ihs
		set ihs_end_date=state_custody_start_date
		,ihs.fl_force_end_date=1
		,ihs.plcmnt_date=state_custody_start_date
		--select id_prsn_child,ihs.ihs_begin_date,ihs.ihs_end_date,tce.state_custody_start_date,tce.federal_discharge_date
		from ##ih_assgn_all ihs  
		join base.tbl_child_episodes tce on tce.id_intake_fact=ihs.id_intake_fact
		and tce.state_custody_start_date < ihs.ihs_end_date
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.ihs_begin_date 
		and state_custody_start_date > ihs_begin_date 
	
	

	---- IMPORTANT 8/22/2013 left off here
	
	--select count(distinct id_intake_fact) from ##ih_assgn_all
	--select count(distinct id_intake_fact) from tbl_ihs_episodes


--      select cd_office,tx_office,count(*) as cnt from ##ih_assgn_all group by cd_office,tx_office order by cd_office,tx_office
					
----------------------------------  PAYMENT	---------------------------------------------  PAYMENT	-------------------------------------------  PAYMENT		
		
	
		  
/**********************************************************************************************************************************************  now  */

		
		--declare @chstart datetime
		--declare @chend datetime
		--declare @startLoop datetime
		--declare @stopLoop datetime
		--declare @cutoff_date datetime
		--declare @date_type int
		--declare @qry_type int
		--declare @max_row int
		--declare @row int
		--declare @start_date datetime;
		--declare @row_num int
		
		--select @cutoff_date=cutoff_date from ref_last_dw_transfer;
		--set @start_date=cast('1/1/1997' as datetime)

/****************************************************   get all in-home PAYMENT by unique service begin date  ***********/		


		--get all in-home PAYMENT by unique service begin date
			-- get all the payment details for detail table
			if object_ID('tempDB..##ihs_pay_srvc_dtl') is not null drop table ##ihs_pay_srvc_dtl		
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
			into ##ihs_pay_srvc_dtl 
			from payment_fact af
			join ##ihs_intk intk on intk.id_case=af.id_case
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
			  -- only want one intake per payment fact
			delete IH
			from ##ihs_pay_srvc_dtl IH
	  join (
			select id_case,srvc_dt_begin,dtl_id_payment_fact,(id_intake_fact) , days_from_rfrd_date 
			,row_number() over 
			(partition by dtl_id_payment_fact order by days_from_rfrd_date  asc) as row_num
			from ##ihs_pay_srvc_dtl
		
			) q on q.row_num=1
			and q.id_case=IH.id_case
			and q.srvc_dt_begin=IH.srvc_dt_begin
			and q.dtl_id_payment_fact=IH.dtl_id_payment_fact
			and q.id_intake_fact <> IH.ID_INTAKE_FACT


			alter table ##ihs_pay_srvc_dtl
			alter column id_case int not null 
			alter table ##ihs_pay_srvc_dtl
			alter column [srvc_dt_begin] datetime not null
			alter table ##ihs_pay_srvc_dtl
			alter column srvc_dt_End datetime not null
			alter table ##ihs_pay_srvc_dtl
			alter column dtl_id_payment_fact int not null
			--alter table ##ihs_pay_srvc_dtl
			--add primary key (id_case,[srvc_dt_begin],srvc_dt_End,dtl_id_payment_fact)
		

			CREATE NONCLUSTERED INDEX idx_ihs_dtl_begin_pf on ##ihs_pay_srvc_dtl([srvc_dt_begin],[dtl_id_payment_fact])
			


			
			

			

		update ihs
		set srvc_dt_end=state_custody_start_date
				,ihs.fl_force_end_date=1
			-- select min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from ##ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 
		and state_custody_start_date > srvc_dt_begin 
		and state_custody_start_date < srvc_dt_end



		update ihs
		set srvc_dt_end=state_custody_start_date
				,ihs.fl_force_end_date=1
			-- select min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from ##ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_intake_Fact=ihs.id_intake_Fact
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 
		and state_custody_start_date > srvc_dt_begin 
		and state_custody_start_date < srvc_dt_end

		


		
		delete ihs
		-- select  min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from ##ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_case=ihs.id_case
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 

		delete ihs
		-- select  min_id_payment_fact,ihs.id_case,ihs.srvc_dt_begin,srvc_dt_end,state_custody_start_date,federal_discharge_date
		from ##ihs_pay_srvc_dtl ihs  
		join base.tbl_child_episodes tce on tce.id_intake_Fact=ihs.id_intake_Fact
		and tce.state_custody_start_date < ihs.srvc_dt_end
		and isnull(tce.federal_discharge_date,'12/31/3999') >=ihs.srvc_dt_begin 


			if object_ID('tempDB..##ihs_pay_srvc_all') is not null drop table ##ihs_pay_srvc_all
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
				, cast(null as int) as cd_office
				, cast(null as varchar(200)) as tx_office
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
				, max(case when sc.cd_subctgry_poc_frc=4 then 1 else 0 end) as fl_mh_services
				, max(case when sc.cd_subctgry_poc_frc=5 then 1 else 0 end) as fl_receiving_care
				, max(case when sc.cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
				, max(case when sc.cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
				, max(case when sc.cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
				, max(case when sc.cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
				, max(case when sc.cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
				, max(case when sc.cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
				, max(case when sc.cd_subctgry_poc_frc=12 then 1 else 0 end) as fl_clothing_incidentals
				, max(case when sc.cd_subctgry_poc_frc=13 then 1 else 0 end) as fl_sexually_aggressive_youth
				, max(case when sc.cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
				, max(case when sc.cd_subctgry_poc_frc=15 then 1 else 0 end) as fl_various
				, max(case when sc.cd_subctgry_poc_frc=16 then 1 else 0 end) as fl_medical
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
			into ##ihs_pay_srvc_all
			FROM ##ihs_pay_srvc_dtl sc 
			group by sc.id_case,srvc_dt_begin,sc.id_intake_fact
				 ,sc.inv_ass_start,sc.case_nxt_intake,sc.days_from_rfrd_date

		CREATE NONCLUSTERED INDEX idx_temp_case_pf_sbd on ##ihs_pay_srvc_all ([id_case],[min_id_payment_fact],[srvc_dt_begin])
INCLUDE ([id_intake_fact])


			  -- only want one intake per payment fact

			
	 delete IH
	  from ##ihs_pay_srvc_all IH
	  join (
			select id_case,srvc_dt_begin,min_id_payment_fact,max_id_payment_fact,(id_intake_fact)
			 ,datediff(dd,rfrd_date,srvc_dt_begin) as days_from_rfrd_date,row_number() over 
			(partition by min_id_payment_fact order by datediff(dd,rfrd_date,srvc_dt_begin) asc) as row_num
			from ##ihs_pay_srvc_all
		
			) q on q.row_num=1
			and q.id_case=IH.id_case
			and q.srvc_dt_begin=IH.srvc_dt_begin
			and q.min_id_payment_fact=IH.min_id_payment_fact
			and q.max_id_payment_fact=IH.max_id_payment_fact
			and q.id_intake_fact <> IH.ID_INTAKE_FACT


		CREATE NONCLUSTERED INDEX  idx_temp_pay_all
					ON ##ihs_pay_srvc_all ([id_case],[srvc_dt_begin],[srvc_dt_end])

		
		-- delete from ##ihs_pay_srvc_all where datediff(dd,rfrd_date,[srvc_dt_begin]) >=90

		update ihall
		set ihall.fl_force_end_date=ihs.fl_force_end_date
			,ihall.srvc_dt_end=ihs.srvc_dt_end
			,ihall.plcmnt_date=ihs.srvc_dt_end
		--select ihs.dtl_id_payment_fact,ihall.min_id_payment_fact,ihall.max_id_payment_fact
		--	,ihs.srvc_dt_begin,ihs.srvc_dt_end,ihall.srvc_dt_begin,ihall.srvc_dt_end
		from ##ihs_pay_srvc_dtl ihs  
		join ##ihs_pay_srvc_all ihall on  ihs.dtl_id_payment_fact between
			ihall.min_id_payment_fact and ihall.max_id_payment_fact
			and  (ihs.fl_force_end_date=1  )
			and (ihall.id_case=ihs.id_case )
		-- where dtl_id_payment_fact=3527788 and max_id_payment_fact=3527788
		where  ihall.srvc_dt_begin=ihs.srvc_dt_begin



	
/**************************************************************    get first start date for a unique END DATE  ***********************************/		
		
					if object_id('tempDB..##ihs') is not null drop table ##ihs
					select 
					   id_case
					  ,ID_INTAKE_FACT
					  ,rfrd_date
					  ,case_nxt_intake
					  ,min(days_from_rfrd_date) as min_days_from_rfrd_date
					  ,min(min_id_payment_fact) as min_id_payment_fact
					  ,max(max_id_payment_fact) as max_id_payment_fact
					  ,sum(cnt_id_table_origin) as cnt_id_table_origin
					  ,min(srvc_dt_begin) as srvc_dt_begin 
					  ,srvc_dt_end
					  ,case_sort
					  ,first_ihs_date
					  ,latest_ihs_date
					  ,max(fl_plcmnt_prior_ihs) as fl_plcmnt_prior_ihs
					  ,max(fl_plcmnt_during_ihs) as fl_plcmnt_during_ihs
					  ,min(plcmnt_date) as plcmnt_date
					  ,min(cd_office) as cd_office
					  ,tx_office
					  ,sum([nbr_svc_paid]) as nbr_svc_paid
					  ,sum(total_amt_paid) as total_amt_paid
					  ,most_exp_cd_srvc
					  ,most_exp_tx_srvc
					  ,total_most_exp_srvc
					 , max(fl_family_focused_services) as fl_family_focused_services
					 , max(fl_child_care) as fl_child_care
					 , max(fl_therapeutic_services) as fl_therapeutic_services
					 , max(fl_mh_services) as fl_mh_services
					 , max(fl_receiving_care) as fl_receiving_care
					 , max(fl_family_home_placements) as fl_family_home_placements
					 , max(fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
					 , max(fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
					 , max(fl_specialty_adolescent_services) as fl_specialty_adolescent_services
					 , max(fl_respite) as fl_respite
					 , max(fl_transportation) as fl_transportation
					 , max(fl_clothing_incidentals) as fl_clothing_incidentals
					 , max(fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
					 , max(fl_adoption_support) as fl_adoption_support
					 , max(fl_various) as fl_various
					 , max(fl_medical) as fl_medical
					 , max(fl_budget_C12) as fl_budget_C12
					 , max(fl_budget_C14) as fl_budget_C14
					 , max(fl_budget_C15) as fl_budget_C15
					 , max(fl_budget_C16) as fl_budget_C16
					 , max(fl_budget_C18) as fl_budget_C18
					 , max(fl_budget_C19) as fl_budget_C19
					 , max(fl_uncat_svc) as fl_uncat_svc
					  ,max(fl_force_end_date) as fl_force_end_date
					  ,tbl_origin
					  ,tbl_origin_cd
					  ,frst_IHS_after_intk
					into ##ihs
					from ##ihs_pay_srvc_all
					group by id_case
							,srvc_dt_end
							,tx_office
							,case_sort
							,first_ihs_date
							,latest_ihs_date
							,most_exp_cd_srvc
							,most_exp_tx_srvc
							,total_most_exp_srvc
							,tbl_origin
							,tbl_origin_cd
							,ID_INTAKE_FACT
							,rfrd_date
							,frst_IHS_after_intk
							,case_nxt_intake
	     
		 
		 truncate table ##ihs_pay_srvc_all

		 insert into ##ihs_pay_srvc_all (id_case,ID_INTAKE_FACT,rfrd_date
		 ,case_nxt_intake,days_from_rfrd_date,min_id_payment_fact,max_id_payment_fact
		 ,cnt_id_table_origin,srvc_dt_begin,srvc_dt_end,case_sort,first_ihs_date
		 ,latest_ihs_date,fl_plcmnt_prior_ihs,fl_plcmnt_during_ihs,plcmnt_date,cd_office
		 ,tx_office,nbr_svc_paid,total_amt_paid,most_exp_cd_srvc,most_exp_tx_srvc
		 ,total_most_exp_srvc,fl_family_focused_services,fl_child_care
		 ,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements
		 ,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations
		 ,fl_specialty_adolescent_services,fl_respite,fl_transportation
		 ,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support
		 ,fl_various,fl_medical,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16
		 ,fl_budget_C18,fl_budget_C19,fl_uncat_svc,fl_force_end_date,tbl_origin
		 ,tbl_origin_cd,frst_IHS_after_intk)
		 select id_case,ID_INTAKE_FACT,rfrd_date
		 ,case_nxt_intake,min_days_from_rfrd_date,min_id_payment_fact,max_id_payment_fact
		 ,cnt_id_table_origin,srvc_dt_begin,srvc_dt_end,case_sort,first_ihs_date
		 ,latest_ihs_date,fl_plcmnt_prior_ihs,fl_plcmnt_during_ihs,plcmnt_date,cd_office
		 ,tx_office,nbr_svc_paid,total_amt_paid,most_exp_cd_srvc,most_exp_tx_srvc
		 ,total_most_exp_srvc,fl_family_focused_services,fl_child_care
		 ,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements
		 ,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations
		 ,fl_specialty_adolescent_services,fl_respite,fl_transportation
		 ,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support
		 ,fl_various,fl_medical,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16
		 ,fl_budget_C18,fl_budget_C19,fl_uncat_svc,fl_force_end_date,tbl_origin
		 ,tbl_origin_cd,frst_IHS_after_intk from ##ihs
		 drop table ##ihs

		
		
		update A1
		set case_sort=a2.row_num
		from ##ihs_pay_srvc_all a1
		join (select ROW_NUMBER() over (partition by id_case order by srvc_dt_begin asc,srvc_dt_end desc) as row_num ,* from ##ihs_pay_srvc_all) a2 
				on a2.min_id_payment_fact=a1.min_id_payment_fact 
				and a2.max_id_payment_fact=a1.max_id_payment_fact	
	
/**********************************************************    merge segments contained within prior  ***********************************/		
		--declare @row_num int
		
		set @row_num=1
		set nocount off
		
			set @row_num=1
			while @row_num > 0
			begin	
				if object_ID('tempDB..##segwi') is not null drop table ##segwi
				select 1 as fl_curr,curr.*
				into ##segwi
				from ##ihs_pay_srvc_all curr
				join ##ihs_pay_srvc_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin between curr.srvc_dt_begin and   curr.srvc_dt_end
				and nxt.srvc_dt_end between  curr.srvc_dt_begin and   curr.srvc_dt_end
				union 
				select 0, nxt.*
				from ##ihs_pay_srvc_all curr
				join ##ihs_pay_srvc_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin between curr.srvc_dt_begin and   curr.srvc_dt_end
				and nxt.srvc_dt_end between  curr.srvc_dt_begin and   curr.srvc_dt_end
				order by [id_case],[case_sort],fl_curr

				

				set @row_num=@@ROWCOUNT

				-- first delete the segments that are currently there
				delete IH
				from ##ihs_pay_srvc_all ih
				join ##segwi s on s.id_case=ih.id_case 
				and s.case_sort=ih.case_sort
				and s.min_id_payment_fact=ih.min_id_payment_fact 
				and s.max_id_payment_fact=ih.max_id_payment_fact
				and s.srvc_dt_begin=ih.srvc_dt_begin 
				and s.srvc_dt_end=ih.srvc_dt_end

				-- now update end date 
				update curr
				set    max_id_payment_fact=case when nxt.max_id_payment_fact > curr.max_id_payment_fact then nxt.max_id_payment_fact else curr.max_id_payment_fact end
					, min_id_payment_fact = case when nxt.min_id_payment_fact < curr.min_id_payment_fact then nxt.min_id_payment_fact else curr.min_id_payment_fact end
					 , cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
					 , fl_family_focused_services=  case when nxt.fl_family_focused_services =1 then nxt.fl_family_focused_services else curr.fl_family_focused_services end
					 , fl_child_care=  case when nxt.fl_child_care =1 then nxt.fl_child_care else curr.fl_child_care end
					 , fl_therapeutic_services=  case when nxt.fl_therapeutic_services =1 then nxt.fl_therapeutic_services else curr.fl_therapeutic_services end
					 , fl_mh_services=  case when nxt.fl_mh_services =1 then nxt.fl_mh_services else curr.fl_mh_services end
					 , fl_receiving_care=  case when nxt.fl_receiving_care =1 then nxt.fl_receiving_care else curr.fl_receiving_care end
					 , fl_family_home_placements=  case when nxt.fl_family_home_placements =1 then nxt.fl_family_home_placements else curr.fl_family_home_placements end
					 , fl_behavioral_rehabiliation_services=  case when nxt.fl_behavioral_rehabiliation_services =1 then nxt.fl_behavioral_rehabiliation_services else curr.fl_behavioral_rehabiliation_services end
					 , fl_other_therapeutic_living_situations=  case when nxt.fl_other_therapeutic_living_situations =1 then nxt.fl_other_therapeutic_living_situations else curr.fl_other_therapeutic_living_situations end
					 , fl_specialty_adolescent_services=  case when nxt.fl_specialty_adolescent_services =1 then nxt.fl_specialty_adolescent_services else curr.fl_specialty_adolescent_services end
					 , fl_respite=  case when nxt.fl_respite =1 then nxt.fl_respite else curr.fl_respite end
					 , fl_transportation=  case when nxt.fl_transportation =1 then nxt.fl_transportation else curr.fl_transportation end
					 , fl_clothing_incidentals=  case when nxt.fl_clothing_incidentals =1 then nxt.fl_clothing_incidentals else curr.fl_clothing_incidentals end
					 , fl_sexually_aggressive_youth=  case when nxt.fl_sexually_aggressive_youth =1 then nxt.fl_sexually_aggressive_youth else curr.fl_sexually_aggressive_youth end
					 , fl_adoption_support=  case when nxt.fl_adoption_support =1 then nxt.fl_adoption_support else curr.fl_adoption_support end
					 , fl_various=  case when nxt.fl_various =1 then nxt.fl_various else curr.fl_various end
					 , fl_medical=  case when nxt.fl_medical =1 then nxt.fl_medical else curr.fl_medical end
					 , fl_budget_C12=  case when nxt.fl_budget_C12 =1 then nxt.fl_budget_C12 else curr.fl_budget_C12 end
					 , fl_budget_C14=  case when nxt.fl_budget_C14 =1 then nxt.fl_budget_C14 else curr.fl_budget_C14 end
					 , fl_budget_C15=  case when nxt.fl_budget_C15 =1 then nxt.fl_budget_C15 else curr.fl_budget_C15 end
					 , fl_budget_C16=  case when nxt.fl_budget_C16 =1 then nxt.fl_budget_C16 else curr.fl_budget_C16 end
					 , fl_budget_C18=  case when nxt.fl_budget_C18 =1 then nxt.fl_budget_C18 else curr.fl_budget_C18 end
					 , fl_budget_C19=  case when nxt.fl_budget_C19 =1 then nxt.fl_budget_C19 else curr.fl_budget_C19 end
					 , fl_uncat_svc=  case when nxt.fl_uncat_svc =1 then nxt.fl_uncat_svc else curr.fl_uncat_svc end
 					 , total_amt_paid = curr.total_amt_paid +  case when dup.id_case is null then nxt.total_amt_paid else 0 end
					 , nbr_svc_paid=curr.nbr_svc_paid +  case when dup.id_case is null then nxt.nbr_svc_paid else 0 end
					 , fl_plcmnt_during_ihs = case when nxt.fl_plcmnt_during_ihs = 1 then nxt.fl_plcmnt_during_ihs else curr.fl_plcmnt_during_ihs end
					 , fl_force_end_date = nxt.fl_force_end_date 
					 , plcmnt_date=case when nxt.plcmnt_date is not null then nxt.plcmnt_date else curr.plcmnt_date end
				from ##segwi curr
				join ##segwi nxt on curr.id_case=nxt.id_case 
							  and curr.case_sort + 1 =nxt.case_sort
				left join ##segwi dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
				where nxt.srvc_dt_begin between curr.srvc_dt_begin and   curr.srvc_dt_end
				and nxt.srvc_dt_end between  curr.srvc_dt_begin and   curr.srvc_dt_end
				and curr.fl_curr=1 and nxt.fl_curr=0

				
	

				 insert into ##ihs_pay_srvc_all (id_case,ID_INTAKE_FACT,rfrd_date
		 ,case_nxt_intake,days_from_rfrd_date,min_id_payment_fact,max_id_payment_fact
		 ,cnt_id_table_origin,srvc_dt_begin,srvc_dt_end,case_sort,first_ihs_date
		 ,latest_ihs_date,fl_plcmnt_prior_ihs,fl_plcmnt_during_ihs,plcmnt_date,cd_office
		 ,tx_office,nbr_svc_paid,total_amt_paid,most_exp_cd_srvc,most_exp_tx_srvc
		 ,total_most_exp_srvc,fl_family_focused_services,fl_child_care
		 ,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements
		 ,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations
		 ,fl_specialty_adolescent_services,fl_respite,fl_transportation
		 ,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support
		 ,fl_various,fl_medical,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16
		 ,fl_budget_C18,fl_budget_C19,fl_uncat_svc,fl_force_end_date,tbl_origin
		 ,tbl_origin_cd,frst_IHS_after_intk)
		 select id_case,ID_INTAKE_FACT,rfrd_date
		 ,case_nxt_intake,days_from_rfrd_date,min_id_payment_fact,max_id_payment_fact
		 ,cnt_id_table_origin,srvc_dt_begin,srvc_dt_end,case_sort,first_ihs_date
		 ,latest_ihs_date,fl_plcmnt_prior_ihs,fl_plcmnt_during_ihs,plcmnt_date,cd_office
		 ,tx_office,nbr_svc_paid,total_amt_paid,most_exp_cd_srvc,most_exp_tx_srvc
		 ,total_most_exp_srvc,fl_family_focused_services,fl_child_care
		 ,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements
		 ,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations
		 ,fl_specialty_adolescent_services,fl_respite,fl_transportation
		 ,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support
		 ,fl_various,fl_medical,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16
		 ,fl_budget_C18,fl_budget_C19,fl_uncat_svc,fl_force_end_date,tbl_origin
		 ,tbl_origin_cd,frst_IHS_after_intk	  from ##segwi where fl_curr=1




				update ihs
						set case_sort=q.row_num
						from ##ihs_pay_srvc_all ihs
						join 	(select ROW_NUMBER() over (partition by id_case order by srvc_dt_begin asc,srvc_dt_end desc) as row_num ,* 
							from ##ihs_pay_srvc_all
							) q on q.min_id_payment_fact=ihs.min_id_payment_fact
									and q.max_id_payment_fact=ihs.max_id_payment_fact
		end		
		

/*****************************************************    merge overlapping segments  ***********************************/

	--	 declare @row_num int
		set @row_num=1
		set nocount off
		
			set @row_num=1
			while @row_num > 0
			begin	
				if object_ID('tempDB..##seg') is not null drop table ##seg
				select 1 as fl_curr,curr.*
				into ##seg
				from ##ihs_pay_srvc_all curr
				join ##ihs_pay_srvc_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin <=  curr.srvc_dt_end
				union 
				select 0, nxt.*
				from ##ihs_pay_srvc_all curr
				join ##ihs_pay_srvc_all nxt on curr.id_case=nxt.id_case and nxt.case_sort=curr.case_sort + 1
				where nxt.srvc_dt_begin <=  curr.srvc_dt_end
				order by [id_case],[case_sort],fl_curr

				set @row_num=@@ROWCOUNT

				-- first delete the segments that are currently there
				delete IH
				from ##ihs_pay_srvc_all ih
				join ##seg s on s.id_case=ih.id_case 
				and s.case_sort=ih.case_sort
				and s.min_id_payment_fact=ih.min_id_payment_fact 
				and s.max_id_payment_fact=ih.max_id_payment_fact
				and s.srvc_dt_begin=ih.srvc_dt_begin 
				and s.srvc_dt_end=ih.srvc_dt_end

				-- now update end date 
				update curr
				set    max_id_payment_fact=case when nxt.max_id_payment_fact > curr.max_id_payment_fact then nxt.max_id_payment_fact else curr.max_id_payment_fact end
					 , min_id_payment_fact = case when nxt.min_id_payment_fact < curr.min_id_payment_fact then nxt.min_id_payment_fact else curr.min_id_payment_fact end
					 , cnt_id_table_origin = curr.cnt_id_table_origin + case when dup.id_case is null then nxt.cnt_id_table_origin else 0 end
					 , srvc_dt_end=nxt.srvc_dt_end
					 --, ID_INTAKE_FACT=nxt.ID_INTAKE_FACT
					 --, case_nxt_intake=nxt.case_nxt_intake
					 --, rfrd_date=nxt.rfrd_date
					 , fl_family_focused_services=  case when nxt.fl_family_focused_services =1 then nxt.fl_family_focused_services else curr.fl_family_focused_services end
					 , fl_child_care=  case when nxt.fl_child_care =1 then nxt.fl_child_care else curr.fl_child_care end
					 , fl_therapeutic_services=  case when nxt.fl_therapeutic_services =1 then nxt.fl_therapeutic_services else curr.fl_therapeutic_services end
					 , fl_mh_services=  case when nxt.fl_mh_services =1 then nxt.fl_mh_services else curr.fl_mh_services end
					 , fl_receiving_care=  case when nxt.fl_receiving_care =1 then nxt.fl_receiving_care else curr.fl_receiving_care end
					 , fl_family_home_placements=  case when nxt.fl_family_home_placements =1 then nxt.fl_family_home_placements else curr.fl_family_home_placements end
					 , fl_behavioral_rehabiliation_services=  case when nxt.fl_behavioral_rehabiliation_services =1 then nxt.fl_behavioral_rehabiliation_services else curr.fl_behavioral_rehabiliation_services end
					 , fl_other_therapeutic_living_situations=  case when nxt.fl_other_therapeutic_living_situations =1 then nxt.fl_other_therapeutic_living_situations else curr.fl_other_therapeutic_living_situations end
					 , fl_specialty_adolescent_services=  case when nxt.fl_specialty_adolescent_services =1 then nxt.fl_specialty_adolescent_services else curr.fl_specialty_adolescent_services end
					 , fl_respite=  case when nxt.fl_respite =1 then nxt.fl_respite else curr.fl_respite end
					 , fl_transportation=  case when nxt.fl_transportation =1 then nxt.fl_transportation else curr.fl_transportation end
					 , fl_clothing_incidentals=  case when nxt.fl_clothing_incidentals =1 then nxt.fl_clothing_incidentals else curr.fl_clothing_incidentals end
					 , fl_sexually_aggressive_youth=  case when nxt.fl_sexually_aggressive_youth =1 then nxt.fl_sexually_aggressive_youth else curr.fl_sexually_aggressive_youth end
					 , fl_adoption_support=  case when nxt.fl_adoption_support =1 then nxt.fl_adoption_support else curr.fl_adoption_support end
					 , fl_various=  case when nxt.fl_various =1 then nxt.fl_various else curr.fl_various end
					 , fl_medical=  case when nxt.fl_medical =1 then nxt.fl_medical else curr.fl_medical end
					 , fl_budget_C12=  case when nxt.fl_budget_C12 =1 then nxt.fl_budget_C12 else curr.fl_budget_C12 end
					 , fl_budget_C14=  case when nxt.fl_budget_C14 =1 then nxt.fl_budget_C14 else curr.fl_budget_C14 end
					 , fl_budget_C15=  case when nxt.fl_budget_C15 =1 then nxt.fl_budget_C15 else curr.fl_budget_C15 end
					 , fl_budget_C16=  case when nxt.fl_budget_C16 =1 then nxt.fl_budget_C16 else curr.fl_budget_C16 end
					 , fl_budget_C18=  case when nxt.fl_budget_C18 =1 then nxt.fl_budget_C18 else curr.fl_budget_C18 end
					 , fl_budget_C19=  case when nxt.fl_budget_C19 =1 then nxt.fl_budget_C19 else curr.fl_budget_C19 end
					 , fl_uncat_svc=  case when nxt.fl_uncat_svc =1 then nxt.fl_uncat_svc else curr.fl_uncat_svc end
 					 , total_amt_paid = curr.total_amt_paid +  case when dup.id_case is null then nxt.total_amt_paid else 0 end
					 , nbr_svc_paid=curr.nbr_svc_paid +  case when dup.id_case is null then nxt.nbr_svc_paid else 0 end
					 , fl_plcmnt_during_ihs = case when nxt.fl_plcmnt_during_ihs = 1 then nxt.fl_plcmnt_during_ihs else curr.fl_plcmnt_during_ihs end
					 , fl_force_end_date = nxt.fl_force_end_date 
					 , plcmnt_date=case when nxt.plcmnt_date is not null then nxt.plcmnt_date else curr.plcmnt_date end
				from ##seg curr
				join ##seg nxt on curr.id_case=nxt.id_case and curr.case_sort + 1 =nxt.case_sort 
				left join ##seg dup on nxt.id_case=dup.id_case
										and nxt.case_sort=dup.case_sort
										and dup.fl_curr=1
				where nxt.srvc_dt_begin <=  curr.srvc_dt_end
				and curr.fl_curr=1 and nxt.fl_curr=0


		insert into ##ihs_pay_srvc_all (id_case,ID_INTAKE_FACT,rfrd_date
		 ,case_nxt_intake,days_from_rfrd_date,min_id_payment_fact,max_id_payment_fact
		 ,cnt_id_table_origin,srvc_dt_begin,srvc_dt_end,case_sort,first_ihs_date
		 ,latest_ihs_date,fl_plcmnt_prior_ihs,fl_plcmnt_during_ihs,plcmnt_date,cd_office
		 ,tx_office,nbr_svc_paid,total_amt_paid,most_exp_cd_srvc,most_exp_tx_srvc
		 ,total_most_exp_srvc,fl_family_focused_services,fl_child_care
		 ,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements
		 ,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations
		 ,fl_specialty_adolescent_services,fl_respite,fl_transportation
		 ,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support
		 ,fl_various,fl_medical,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16
		 ,fl_budget_C18,fl_budget_C19,fl_uncat_svc,fl_force_end_date,tbl_origin
		 ,tbl_origin_cd,frst_IHS_after_intk)
		 select id_case,ID_INTAKE_FACT,rfrd_date
		 ,case_nxt_intake,days_from_rfrd_date,min_id_payment_fact,max_id_payment_fact
		 ,cnt_id_table_origin,srvc_dt_begin,srvc_dt_end,case_sort,first_ihs_date
		 ,latest_ihs_date,fl_plcmnt_prior_ihs,fl_plcmnt_during_ihs,plcmnt_date,cd_office
		 ,tx_office,nbr_svc_paid,total_amt_paid,most_exp_cd_srvc,most_exp_tx_srvc
		 ,total_most_exp_srvc,fl_family_focused_services,fl_child_care
		 ,fl_therapeutic_services,fl_mh_services,fl_receiving_care,fl_family_home_placements
		 ,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations
		 ,fl_specialty_adolescent_services,fl_respite,fl_transportation
		 ,fl_clothing_incidentals,fl_sexually_aggressive_youth,fl_adoption_support
		 ,fl_various,fl_medical,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16
		 ,fl_budget_C18,fl_budget_C19,fl_uncat_svc,fl_force_end_date,tbl_origin
		 ,tbl_origin_cd,frst_IHS_after_intk	
				from ##seg where fl_curr=1

				update ihs
						set case_sort=q.row_num
						from ##ihs_pay_srvc_all ihs
						join 	(select ROW_NUMBER() over (partition by id_case order by srvc_dt_begin asc,srvc_dt_end desc) as row_num ,* 
							from ##ihs_pay_srvc_all
							) q on q.min_id_payment_fact=ihs.min_id_payment_fact
									and q.max_id_payment_fact=ihs.max_id_payment_fact
		end

		-- force extend (all of the merge update will have to be recoded with cursor)

	set @row =1
	while @row > 0
	begin
	update ihs
	set srvc_dt_End = q.srvc_dt_end
		,min_id_payment_fact= case when q.dtl_id_payment_fact < ihs.min_id_payment_fact
			then q.dtl_id_payment_fact else ihs.min_id_payment_fact end
		,max_id_payment_fact= case when q.dtl_id_payment_fact > ihs.max_id_payment_fact
			then q.dtl_id_payment_fact else ihs.max_id_payment_fact end

	-- select ihs.id_case,ihs.srvc_dt_begin,ihs.srvc_dt_End ,q.srvc_dt_begin as dtl_srvc_dt_begin,q.srvc_dt_end as dtl_servc_dt_end
	from ##ihs_pay_srvc_all ihs 
	join (
	select s2.* from  ##ihs_pay_srvc_dtl  s2
	left join ##ihs_pay_srvc_all s1 on s1.id_case=s2.id_case
	and s2.dtl_id_payment_fact between s1.min_id_payment_fact and s1.max_id_payment_fact
	and s2.srvc_dt_begin between s1.srvc_dt_begin and s1.srvc_dt_end
	and s2.srvc_dt_end between s1.srvc_dt_begin and s1.srvc_dt_end
		where s1.ID_CASE is null ) q on q.id_case= ihs.id_case
	and q.srvc_dt_begin between  ihs.srvc_dt_begin and ihs.srvc_dt_End
	left join ##ihs_pay_srvc_all hdr on hdr.id_case=ihs.id_case and ihs.case_sort+1=hdr.case_sort
	where hdr.srvc_dt_begin >=q.srvc_dt_end or hdr.srvc_dt_begin is null

	set @row=@@ROWCOUNT
	end
	--  declare @row int
	set @row =1
	while @row > 0
	begin
	update ihs
	set srvc_dt_begin = q.srvc_dt_begin
		,min_id_payment_fact= case when q.dtl_id_payment_fact < ihs.min_id_payment_fact
			then q.dtl_id_payment_fact else ihs.min_id_payment_fact end
		,max_id_payment_fact= case when q.dtl_id_payment_fact > ihs.max_id_payment_fact
			then q.dtl_id_payment_fact else ihs.max_id_payment_fact end
	-- select hdr.srvc_dt_begin as prior_srvc_dt_begin, hdr.srvc_dt_end as prior_srvc_dt_end,
		--	ihs.id_case,ihs.srvc_dt_begin,ihs.srvc_dt_End ,q.srvc_dt_begin as dtl_srvc_dt_begin,q.srvc_dt_end as dtl_servc_dt_end
	from ##ihs_pay_srvc_all ihs 
	join (
	select s2.* from  ##ihs_pay_srvc_dtl  s2
	left join ##ihs_pay_srvc_all s1 on s1.id_case=s2.id_case
	and s2.dtl_id_payment_fact between s1.min_id_payment_fact and s1.max_id_payment_fact
	and s2.srvc_dt_begin between s1.srvc_dt_begin and s1.srvc_dt_end
	and s2.srvc_dt_end between s1.srvc_dt_begin and s1.srvc_dt_end
		where s1.ID_CASE is null ) q on q.id_case= ihs.id_case
	and q.srvc_dt_end between  ihs.srvc_dt_begin and ihs.srvc_dt_End
	left join ##ihs_pay_srvc_all hdr on hdr.id_case=ihs.id_case and ihs.case_sort-1=hdr.case_sort
	where hdr.srvc_dt_end is null or hdr.srvc_dt_end < q.srvc_dt_begin
	set @row=@@ROWCOUNT
	end

		UPDATE IH
		 SET cd_office = ld.cd_office
				,tx_office =ld.tx_office
		 FROM ##ihs_pay_srvc_all IH
		 join dbo.payment_fact af on ih.min_id_payment_fact=af.Id_payment_fact
			left join dbo.location_dim ld on ld.id_location_dim=af.id_location_dim

			--select id_case,srvc_dt_begin,srvc_dt_End from ##ihs_pay_srvc_all
			----where id_case=1702
			--except
			--select id_case,srvc_dt_begin,srvc_dt_End from clncy
			----where id_case=1702
			--except
			--select id_case,srvc_dt_begin,srvc_dt_End from ##ihs_pay_srvc_all
			--select * from ##ihs_pay_srvc_all where id_case=559471 order by srvc_dt_begin
			--select * from clncy where id_case=559471 order by srvc_dt_begin
			--select * from ##ihs_pay_srvc_dtl where id_case=559471 order by srvc_dt_begin



		

	
	

	
	
/***************************************************  FINAL TABLE **/

				
				if OBJECT_ID('tempDB..##tbl_ihs_episodes') is not null drop table ##tbl_ihs_episodes
				select 
				cast(null as int) as id_ihs_episode
				,*
				,0 as dtl_min_id_payment_fact
				,0 as dtl_max_id_payment_fact
				,cast(null as int) as cd_sib_age_grp
				,cast(null as int) as cd_race_census_hh
				,cast(null as int) as census_hispanic_latino_origin_cd
				into ##tbl_ihs_episodes
				from ##ih_assgn_all

				alter table ##tbl_ihs_episodes
				alter column id_case int not null

				alter table ##tbl_ihs_episodes
				alter column ihs_begin_date datetime not null
	
				alter table ##tbl_ihs_episodes
				add primary key (id_case,ihs_begin_date)


				CREATE NONCLUSTERED INDEX idx_temp_case_id_inc_dates
				ON ##tbl_ihs_episodes ([id_case],[id_table_origin],[max_id_table_origin])
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
					 , fl_mh_services = auth.fl_mh_services
					 , fl_receiving_care = auth.fl_receiving_care
					 , fl_family_home_placements = auth.fl_family_home_placements
					 , fl_behavioral_rehabiliation_services = auth.fl_behavioral_rehabiliation_services
					 , fl_other_therapeutic_living_situations = auth.fl_other_therapeutic_living_situations
					 , fl_specialty_adolescent_services = auth.fl_specialty_adolescent_services
					 , fl_respite = auth.fl_respite
					 , fl_transportation = auth.fl_transportation
					 , fl_clothing_incidentals = auth.fl_clothing_incidentals
					 , fl_sexually_aggressive_youth = auth.fl_sexually_aggressive_youth
					 , fl_adoption_support = auth.fl_adoption_support
					 , fl_various = auth.fl_various
					 , fl_medical = auth.fl_medical
					 , fl_budget_C12 = auth.fl_budget_C12
					 , fl_budget_C14 = auth.fl_budget_C14
					 , fl_budget_C15 = auth.fl_budget_C15
					 , fl_budget_C16 = auth.fl_budget_C16
					 , fl_budget_C18 = auth.fl_budget_C18
					 , fl_budget_C19 = auth.fl_budget_C19
					 , fl_uncat_svc = auth.fl_uncat_svc
					 , tbl_origin_cd=3
					 , tbl_origin='both'
				from ##tbl_ihs_episodes ihs
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
							 , max(auth.fl_mh_services) as fl_mh_services
							 , max(auth.fl_receiving_care) as fl_receiving_care
							 , max(auth.fl_family_home_placements) as fl_family_home_placements
							 , max(auth.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
							 , max(auth.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
							 , max(auth.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
							 , max(auth.fl_respite) as fl_respite
							 , max(auth.fl_transportation) as fl_transportation
							 , max(auth.fl_clothing_incidentals) as fl_clothing_incidentals
							 , max(auth.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
							 , max(auth.fl_adoption_support) as fl_adoption_support
							 , max(auth.fl_various) as fl_various
							 , max(auth.fl_medical) as fl_medical
							 , max(auth.fl_budget_C12) as fl_budget_C12
							 , max(auth.fl_budget_C14) as fl_budget_C14
							 , max(auth.fl_budget_C15) as fl_budget_C15
							 , max(auth.fl_budget_C16) as fl_budget_C16
							 , max(auth.fl_budget_C18) as fl_budget_C18
							 , max(auth.fl_budget_C19) as fl_budget_C19
							 , max(auth.fl_uncat_svc) as fl_uncat_svc
						from ##tbl_ihs_episodes ihs
						join  ##ihs_pay_srvc_all  auth on auth.id_case=ihs.id_case 
							and auth.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
							and auth.srvc_dt_end   between ihs.ihs_begin_date and ihs.ihs_end_date
						group by ihs.id_case
							,ihs.ihs_begin_date
							,ihs.ihs_end_date
					)  auth on auth.id_case=ihs.id_case 
					and ihs.ihs_begin_date=auth.ihs_begin_date
					and ihs.ihs_end_date=auth.ihs_end_date
			

		

				--insert those payments with no overlapping assignment dates
				insert into ##tbl_ihs_episodes
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
					  , auth.cd_office
					  , auth.tx_office
					  , auth.days_from_rfrd_date
					  , auth.nbr_svc_paid
					  , auth.total_amt_paid
					  , auth.most_exp_cd_srvc
					  , auth.most_exp_tx_srvc
					  , auth.total_most_exp_srvc
					  , auth.fl_family_focused_services
					  , auth.fl_child_care
					  , auth.fl_therapeutic_services
					  , auth.fl_mh_services
					  , auth.fl_receiving_care
					  , auth.fl_family_home_placements
					  , auth.fl_behavioral_rehabiliation_services
					  , auth.fl_other_therapeutic_living_situations
					  , auth.fl_specialty_adolescent_services
					  , auth.fl_respite
					  , auth.fl_transportation
					  , auth.fl_clothing_incidentals
					  , auth.fl_sexually_aggressive_youth
					  , auth.fl_adoption_support
					  , auth.fl_various
					  , auth.fl_medical
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
				from ##ihs_pay_srvc_all  auth
				left join ##tbl_ihs_episodes assg on auth.id_case=assg.id_case
					and auth.srvc_dt_begin between assg.ihs_begin_date and assg.ihs_end_date
					and auth.srvc_dt_end   between assg.ihs_begin_date and assg.ihs_end_date
				left join ##tbl_ihs_episodes assn on auth.id_case=assn.id_case
					and auth.srvc_dt_begin between assn.ihs_begin_date and assn.ihs_end_date
				left join ##tbl_ihs_episodes asst on auth.id_case=asst.id_case
					and auth.srvc_dt_end between asst.ihs_begin_date and asst.ihs_end_date
				left join ##tbl_ihs_episodes wi on auth.id_case=wi.id_case
					and auth.srvc_dt_end > wi.ihs_end_date 
					and auth.srvc_dt_begin < wi.ihs_begin_date 
				where (assg.id_case is null and assn.id_case is null and asst.id_case is null and wi.id_case is null)

			update eps
			set case_sort=q.row_num
			from ##tbl_ihs_episodes eps
			join (select row_number()  over (partition by id_case order by ihs_begin_date,ihs_end_date) as row_num,*
					from ##tbl_ihs_episodes) q on q.id_case=eps.id_case and q.ihs_begin_date=eps.ihs_begin_date and q.id_table_origin=eps.id_table_origin and q.max_id_table_origin=eps.max_id_table_origin





			-- force/lengthen ihs_end_date in order to associate services
			update ihs
			set   dtl_min_id_payment_fact=auth.min_id_payment_fact
				, dtl_max_id_payment_fact=auth.max_id_payment_fact
				, ihs_end_date=auth.srvc_dt_end
					, most_exp_cd_srvc = null
					, most_exp_tx_srvc=null
					, total_most_exp_srvc = null
					, total_amt_paid=auth.total_amt_paid
					, nbr_svc_paid=auth.nbr_svc_paid
					, fl_family_focused_services = auth.fl_family_focused_services
					, fl_child_care = auth.fl_child_care
					, fl_therapeutic_services = auth.fl_therapeutic_services
					, fl_mh_services = auth.fl_mh_services
					, fl_receiving_care = auth.fl_receiving_care
					, fl_family_home_placements = auth.fl_family_home_placements
					, fl_behavioral_rehabiliation_services = auth.fl_behavioral_rehabiliation_services
					, fl_other_therapeutic_living_situations = auth.fl_other_therapeutic_living_situations
					, fl_specialty_adolescent_services = auth.fl_specialty_adolescent_services
					, fl_respite = auth.fl_respite
					, fl_transportation = auth.fl_transportation
					, fl_clothing_incidentals = auth.fl_clothing_incidentals
					, fl_sexually_aggressive_youth = auth.fl_sexually_aggressive_youth
					, fl_adoption_support = auth.fl_adoption_support
					, fl_various = auth.fl_various
					, fl_medical = auth.fl_medical
					, fl_budget_C12 = auth.fl_budget_C12
					, fl_budget_C14 = auth.fl_budget_C14
					, fl_budget_C15 = auth.fl_budget_C15
					, fl_budget_C16 = auth.fl_budget_C16
					, fl_budget_C18 = auth.fl_budget_C18
					, fl_budget_C19 = auth.fl_budget_C19
					, fl_uncat_svc = auth.fl_uncat_svc
					, tbl_origin_cd=3
					, tbl_origin='both'
			--select ihs.ihs_begin_date,ihs.ihs_end_date,srvc_dt_end,auth.*
			from ##tbl_ihs_episodes ihs
			join  (select	ihs.id_case
						,ihs.ihs_begin_date
						,ihs.ihs_end_date
						, max(auth.srvc_dt_end) as srvc_dt_end
						, min(auth.min_id_payment_fact) as min_id_payment_fact
						, max(auth.max_id_payment_fact) as max_id_payment_fact
							, sum(auth.total_amt_paid) as total_amt_paid
							, sum(auth.nbr_svc_paid) as nbr_svc_paid
							, max(auth.total_most_exp_srvc) as total_most_exp_srvc
							, max(auth.fl_family_focused_services) as fl_family_focused_services
							, max(auth.fl_child_care) as fl_child_care
							, max(auth.fl_therapeutic_services) as fl_therapeutic_services
							, max(auth.fl_mh_services) as fl_mh_services
							, max(auth.fl_receiving_care) as fl_receiving_care
							, max(auth.fl_family_home_placements) as fl_family_home_placements
							, max(auth.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
							, max(auth.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
							, max(auth.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
							, max(auth.fl_respite) as fl_respite
							, max(auth.fl_transportation) as fl_transportation
							, max(auth.fl_clothing_incidentals) as fl_clothing_incidentals
							, max(auth.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
							, max(auth.fl_adoption_support) as fl_adoption_support
							, max(auth.fl_various) as fl_various
							, max(auth.fl_medical) as fl_medical
							, max(auth.fl_budget_C12) as fl_budget_C12
							, max(auth.fl_budget_C14) as fl_budget_C14
							, max(auth.fl_budget_C15) as fl_budget_C15
							, max(auth.fl_budget_C16) as fl_budget_C16
							, max(auth.fl_budget_C18) as fl_budget_C18
							, max(auth.fl_budget_C19) as fl_budget_C19
							, max(auth.fl_uncat_svc) as fl_uncat_svc
						--	select ihs.id_case,ihs2.ihs_begin_date as nxt_begin,ihs2.ihs_end_date as nxt_end,auth.srvc_dt_begin,auth.srvc_dt_end,ihs.ihs_begin_date as curr_begin,ihs.ihs_end_date as curr_end
					from ##tbl_ihs_episodes ihs --main
					-- service between main table in-home service start & stop date
					left join  ##ihs_pay_srvc_all  aut on aut.id_case=ihs.id_case 
						and aut.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
						and aut.srvc_dt_end   between ihs.ihs_begin_date and ihs.ihs_end_date
					--  payment service header begin date between main service start & stop date
					-- but payment service end date is greater than main in-home service end date
					left join ##ihs_pay_srvc_all auth on ihs.id_case=auth.id_case
		  				and auth.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
												and auth.srvc_dt_end > ihs.ihs_end_date
					--left join on next episode by case so we can see if the payment service end date is 
					-- greater than the next episode main in-home service begin date
					left join ##tbl_ihs_episodes ihs2 on ihs2.id_case=ihs.id_case
						and ihs2.case_sort=ihs.case_sort + 1 
					where aut.id_case is null  and auth.id_case is not null 
					and (ihs2.id_case is null or  (ihs2.id_case is not null and ihs2.ihs_begin_date
						> auth.srvc_dt_end))
					group by ihs.id_case
						,ihs.ihs_begin_date
						,ihs.ihs_end_date	
										)  auth on auth.id_case=ihs.id_case 
										and ihs.ihs_begin_date=auth.ihs_begin_date
										and ihs.ihs_end_date=auth.ihs_end_date

		update eps
			set case_sort=q.row_num
			from ##tbl_ihs_episodes eps
			join (select row_number()  over (partition by id_case order by ihs_begin_date,ihs_end_date) as row_num,*
					from ##tbl_ihs_episodes) q on q.id_case=eps.id_case and q.ihs_begin_date=eps.ihs_begin_date and q.id_table_origin=eps.id_table_origin and q.max_id_table_origin=eps.max_id_table_origin



			update ihs
			set   dtl_min_id_payment_fact=auth.min_id_payment_fact
				, dtl_max_id_payment_fact=auth.max_id_payment_fact
				, ihs_begin_date=auth.srvc_dt_begin
					, most_exp_cd_srvc = null
					, most_exp_tx_srvc=null
					, total_most_exp_srvc = null
					, total_amt_paid=auth.total_amt_paid
					, nbr_svc_paid=auth.nbr_svc_paid
					, fl_family_focused_services = auth.fl_family_focused_services
					, fl_child_care = auth.fl_child_care
					, fl_therapeutic_services = auth.fl_therapeutic_services
					, fl_mh_services = auth.fl_mh_services
					, fl_receiving_care = auth.fl_receiving_care
					, fl_family_home_placements = auth.fl_family_home_placements
					, fl_behavioral_rehabiliation_services = auth.fl_behavioral_rehabiliation_services
					, fl_other_therapeutic_living_situations = auth.fl_other_therapeutic_living_situations
					, fl_specialty_adolescent_services = auth.fl_specialty_adolescent_services
					, fl_respite = auth.fl_respite
					, fl_transportation = auth.fl_transportation
					, fl_clothing_incidentals = auth.fl_clothing_incidentals
					, fl_sexually_aggressive_youth = auth.fl_sexually_aggressive_youth
					, fl_adoption_support = auth.fl_adoption_support
					, fl_various = auth.fl_various
					, fl_medical = auth.fl_medical
					, fl_budget_C12 = auth.fl_budget_C12
					, fl_budget_C14 = auth.fl_budget_C14
					, fl_budget_C15 = auth.fl_budget_C15
					, fl_budget_C16 = auth.fl_budget_C16
					, fl_budget_C18 = auth.fl_budget_C18
					, fl_budget_C19 = auth.fl_budget_C19
					, fl_uncat_svc = auth.fl_uncat_svc
					, tbl_origin_cd=3
					, tbl_origin='both'
			--select ihs.ihs_begin_date,ihs.ihs_end_date,auth.*
			from ##tbl_ihs_episodes ihs
			join  (select	ihs.id_case
						,ihs.ihs_begin_date
						,ihs.ihs_end_date
						, max(auth.srvc_dt_begin) as srvc_dt_begin
						, min(auth.min_id_payment_fact) as min_id_payment_fact
						, max(auth.max_id_payment_fact) as max_id_payment_fact
							, sum(auth.total_amt_paid) as total_amt_paid
							, sum(auth.nbr_svc_paid) as nbr_svc_paid
							, max(auth.total_most_exp_srvc) as total_most_exp_srvc
							, max(auth.fl_family_focused_services) as fl_family_focused_services
							, max(auth.fl_child_care) as fl_child_care
							, max(auth.fl_therapeutic_services) as fl_therapeutic_services
							, max(auth.fl_mh_services) as fl_mh_services
							, max(auth.fl_receiving_care) as fl_receiving_care
							, max(auth.fl_family_home_placements) as fl_family_home_placements
							, max(auth.fl_behavioral_rehabiliation_services) as fl_behavioral_rehabiliation_services
							, max(auth.fl_other_therapeutic_living_situations) as fl_other_therapeutic_living_situations
							, max(auth.fl_specialty_adolescent_services) as fl_specialty_adolescent_services
							, max(auth.fl_respite) as fl_respite
							, max(auth.fl_transportation) as fl_transportation
							, max(auth.fl_clothing_incidentals) as fl_clothing_incidentals
							, max(auth.fl_sexually_aggressive_youth) as fl_sexually_aggressive_youth
							, max(auth.fl_adoption_support) as fl_adoption_support
							, max(auth.fl_various) as fl_various
							, max(auth.fl_medical) as fl_medical
							, max(auth.fl_budget_C12) as fl_budget_C12
							, max(auth.fl_budget_C14) as fl_budget_C14
							, max(auth.fl_budget_C15) as fl_budget_C15
							, max(auth.fl_budget_C16) as fl_budget_C16
							, max(auth.fl_budget_C18) as fl_budget_C18
							, max(auth.fl_budget_C19) as fl_budget_C19
							, max(auth.fl_uncat_svc) as fl_uncat_svc
						--	select ihs.id_case,ihs2.ihs_begin_date as prior_begin,ihs2.ihs_end_date as prior_end,auth.srvc_dt_begin,auth.srvc_dt_end,ihs.ihs_begin_date as curr_begin_date,ihs.ihs_end_date as curr_end_date
					from ##tbl_ihs_episodes ihs --main
					-- service between main table in-home service start & stop date
					left join  ##ihs_pay_srvc_all  aut on aut.id_case=ihs.id_case 
						and aut.srvc_dt_begin between ihs.ihs_begin_date and ihs.ihs_end_date
						and aut.srvc_dt_end   between ihs.ihs_begin_date and ihs.ihs_end_date
					--  payment service header begin date between main service start & stop date
					-- but payment service end date is greater than main in-home service end date
					left join ##ihs_pay_srvc_all auth on ihs.id_case=auth.id_case
		  				and auth.srvc_dt_end between ihs.ihs_begin_date and ihs.ihs_end_date
												and auth.srvc_dt_begin <  ihs.ihs_begin_date
					--left join on next episode by case so we can see if the payment service end date is 
					-- greater than the next episode main in-home service begin date
					left join ##tbl_ihs_episodes ihs2 on ihs2.id_case=ihs.id_case
						and ihs2.case_sort=ihs.case_sort - 1 
					where aut.id_case is null  and auth.id_case is not null 
					and (ihs2.id_case is null or  (ihs2.id_case is not null and ihs2.ihs_end_date
						< auth.srvc_dt_begin))
						--order by ihs.id_case
						--,ihs.ihs_begin_date
						--,ihs.ihs_end_date	
					group by ihs.id_case
						,ihs.ihs_begin_date
						,ihs.ihs_end_date	
										)  auth on auth.id_case=ihs.id_case 
										and ihs.ihs_begin_date=auth.ihs_begin_date
										and ihs.ihs_end_date=auth.ihs_end_date			

								

/**************************************************************************             unique id_ihs_episode   **/
			update eps
			set id_ihs_episode=q.row_num
			from ##tbl_ihs_episodes eps
			join (select row_number()  over (order by id_case,ihs_begin_date,ihs_end_date) as row_num,*
					from ##tbl_ihs_episodes) q on q.id_case=eps.id_case 
					and q.ihs_begin_date=eps.ihs_begin_date 
					and q.id_table_origin=eps.id_table_origin 
					and q.max_id_table_origin=eps.max_id_table_origin


			update dtl
			set id_ihs_episode = null
			from ##ihs_pay_srvc_dtl dtl

			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_pay_srvc_dtl dtl
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and dtl.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
				and dtl.srvc_dt_end between eps.ihs_begin_date and eps.ihs_end_date

		
				

			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_pay_srvc_dtl dtl
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and dtl.srvc_dt_begin between eps.ihs_begin_date and eps.ihs_end_date
				and dtl.id_ihs_episode is null


			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_pay_srvc_dtl dtl
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and dtl.srvc_dt_end between eps.ihs_begin_date and eps.ihs_end_date
				and dtl.id_ihs_episode is null

			update dtl
			set id_ihs_episode = lrgseg.id_ihs_episode
			from ##ihs_pay_srvc_dtl dtl
			join ##ihs_pay_srvc_dtl lrgseg on dtl.id_case=lrgseg.id_case
			and dtl.srvc_dt_begin between lrgseg.srvc_dt_begin and  lrgseg.srvc_dt_end
			and dtl.srvc_dt_end between lrgseg.srvc_dt_begin and  lrgseg.srvc_dt_end
			where dtl.id_ihs_episode is null and lrgseg.id_ihs_episode is not null


			-- only want detail rolling up to one episode
			update dtl
			set id_ihs_episode = eps.id_ihs_episode
			from ##ihs_pay_srvc_dtl dtl
			join (
			select eps.id_ihs_episode ,eps.ihs_begin_date,eps.ihs_end_date
			,dtl.dtl_id_payment_fact
			,row_number() over
			(partition by dtl_id_payment_fact,auth.srvc_dt_begin order by ihs_begin_date asc) as row_num
			from ##ihs_pay_srvc_dtl dtl
			join ##ihs_pay_srvc_all auth on auth.id_case=dtl.id_case 
					and dtl.srvc_dt_begin between auth.srvc_dt_begin and auth.srvc_dt_end
					and dtl.srvc_dt_begin between auth.srvc_dt_begin and auth.srvc_dt_end
			join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
				and eps.ihs_begin_date between auth.srvc_dt_begin and auth.srvc_dt_end
				and eps.ihs_end_date between auth.srvc_dt_begin and auth.srvc_dt_end
				and dtl.id_ihs_episode is null
				and eps.plcmnt_date is null
				-- where dtl_id_payment_fact in (8828632,9861488,9868174,10308943,10348044)
				) eps 
				on eps.dtl_id_payment_fact=dtl.dtl_id_payment_fact
			where row_num=1 and dtl.id_ihs_episode is null
				


			--select * from  ##ihs_pay_srvc_dtl where id_ihs_episode is null

			--select distinct eps.* 
			--from ##ihs_pay_srvc_all hall 
			--join ##ihs_pay_srvc_dtl DTL
			--on HALL.ID_CASE=DTL.ID_CASE 
				
			--	and dtl.srvc_dt_begin between hall.srvc_dt_begin and hall.srvc_dt_end
			--	and dtl.srvc_dt_end between hall.srvc_dt_begin and hall.srvc_dt_end
			--join ##tbl_ihs_episodes eps on eps.id_case=dtl.id_case
			--		and eps.dtl_min_id_payment_fact=hall.min_id_payment_fact
			--		and eps.dtl_max_id_payment_fact=hall.max_id_payment_fact
			--where dtl.id_ihs_episode is null
												

			--select * from ##ihs_pay_srvc_all where '2007-04-30 00:00:00.000' between srvc_dt_begin and srvc_dt_end and id_case=705129
			--select * from ##tbl_ihs_episodes where id_case=705129
			delete from ##ihs_pay_srvc_dtl where id_ihs_episode is null

			-- these are end dated placements	


	CREATE NONCLUSTERED INDEX  idx_id_ihs_episodes
		ON ##tbl_ihs_episodes ([id_ihs_episode])
	
	

	-- update most expensive
	begin tran t1
			update ihs
			set   most_exp_cd_srvc = q.cd_srvc
					, most_exp_tx_srvc=q.tx_srvc
					, total_most_exp_srvc = q.total_most_exp_srvc	
			from ##tbl_ihs_episodes ihs
			join (
				select auth.*,row_number() over( partition by ihs.id_case,ihs.ihs_begin_date
							,ihs.ihs_end_date order by auth.total_most_exp_srvc desc) as row_sort
				from ##tbl_ihs_episodes ihs
				join  (
						select	ihs.id_ihs_episode
								, auth.cd_srvc
								, auth.tx_srvc
 								, sum(isnull(auth.am_total_paid,0)) as total_most_exp_srvc
						from ##tbl_ihs_episodes ihs
							join  ##ihs_pay_srvc_dtl  auth on auth.id_ihs_episode=ihs.id_ihs_episode 
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

		commit tran t1
		


		begin tran t2

		update IH
		set total_amt_paid=q.total_amt_paid
			,nbr_svc_paid=q.nbr_svc_paid
			,dtl_min_id_payment_fact=q.min_id_payment_fact
			,dtl_max_id_payment_fact=q.max_id_payment_fact
			,cnt_id_table_origin = case when tbl_origin_cd=2 then q.cnt_id_table_origin else ih.cnt_id_table_origin end
		--select q.*,ih.*
		from ##tbl_ihs_episodes IH
		join (select dtl.id_case,ih.id_ihs_episode
						,sum(1) as nbr_svc_paid
						,sum(isnull(dtl.am_total_paid,0) ) as total_amt_paid
						,count(distinct dtl.dtl_id_payment_fact) as cnt_id_table_origin
						,min(dtl.dtl_id_payment_fact) as min_id_payment_fact
						,max(dtl.dtl_id_payment_fact) as max_id_payment_fact
			FROM ##tbl_ihs_episodes ih
			join ##ihs_pay_srvc_dtl dtl on ih.id_ihs_episode=dtl.id_ihs_episode 
			where dtl.id_ihs_episode is not null
			group by dtl.id_case,ih.id_ihs_episode
			) q	on q.id_case=ih.id_case and q.id_ihs_episode=ih.id_ihs_episode
		commit tran t2
--select * from ##tbl_ihs_episodes where id_case=385344
--select * from ##ihs_pay_srvc_dtl where id_case=385344	 

			
		begin tran t3
		delete from ##tbl_ihs_episodes where nbr_svc_paid=0 and tbl_origin_cd in (2,3)
--		 where q.id_case=39486 and ih.id_case=39486
		commit tran t3

		begin tran t4
		update eps
		set first_ihs_date=frst_date,latest_ihs_date=last_date,fl_plcmnt_prior_ihs=isnull(eps.fl_plcmnt_prior_ihs,0)
			,fl_plcmnt_during_ihs=isnull(fl_plcmnt_during_ihs,0)
		from ##tbl_ihs_episodes eps
		join (select id_case, min(ihs_begin_date) as frst_date
			   , max(ihs_begin_date) as last_date
			   from ##tbl_ihs_episodes
			   group by id_case) q on q.id_case=eps.id_case


		update eps
		set cd_sib_age_grp=intk.cd_sib_age_grp
			, cd_race_census_hh=intk.cd_race_census
			, census_hispanic_latino_origin_cd=intk.census_hispanic_latino_origin_cd
		from ##tbl_ihs_episodes eps
		join 		base.tbl_intakes intk
				on intk.id_intake_Fact=eps.ID_INTAKE_FACT

		commit tran t4
	
		
		begin tran t5
		update ##tbl_ihs_episodes
		set frst_IHS_after_intk=0
		
		
		update hme
		set frst_IHS_after_intk=1
		from ##tbl_ihs_episodes hme
		join (
				select distinct q.id_case,q.id_intake_fact,q.id_table_origin,q.ihs_begin_date 
				 from ##tbl_ihs_episodes hm
				 cross apply (select top 1
								id_case
								,id_intake_Fact
								,id_table_origin
								,ihs_begin_date
								,ihs_end_date
							from ##tbl_ihs_episodes ih
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
		 FROM ##tbl_ihs_episodes IH
		 
		 UPDATE IH
		 SET fl_plcmnt_prior_ihs=1
		 FROM ##tbl_ihs_episodes IH
		 JOIN ##eps TCE ON TCE.ID_CASE=ih.id_case 
		 AND TCE.eps_begin  < IH.ihs_begin_date;
		 commit tran t5

--select * from ##tbl_ihs_episodes where id_case=385344
--		select * from ##ihs_pay_srvc_dtl where id_case=385344
--loh
if object_ID(N'base.tbl_ihs_episodes',N'U') is not null  truncate table base.tbl_ihs_episodes;
insert into base.tbl_ihs_episodes(
					id_ihs_episode
					,id_case
					,case_sort
					,ihs_begin_date
					,ihs_end_date
					,first_ihs_date
					,latest_ihs_date
					,cd_office
					,tx_office
					,fl_plcmnt_prior_ihs
					,fl_plcmnt_during_ihs
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
      ,[cd_office]
      ,[tx_office]
      ,[fl_plcmnt_prior_ihs]
      ,[fl_plcmnt_during_ihs]
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
      ,[fl_mh_services]
      ,[fl_receiving_care]
      ,[fl_family_home_placements]
      ,[fl_behavioral_rehabiliation_services]
      ,[fl_other_therapeutic_living_situations]
      ,[fl_specialty_adolescent_services]
      ,[fl_respite]
      ,[fl_transportation]
      ,[fl_clothing_incidentals]
      ,[fl_sexually_aggressive_youth]
      ,[fl_adoption_support]
      ,[fl_various]
      ,[fl_medical]
      ,[fl_budget_C12]
      ,[fl_budget_C14]
      ,[fl_budget_C15]
      ,[fl_budget_C16]
      ,[fl_budget_C18]
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
  FROM ##tbl_ihs_episodes ihs


  

if object_ID(N'base.tbl_ihs_services',N'U') is not null  truncate table base.tbl_ihs_services;
insert into base.tbl_ihs_services
([id_ihs_episode]
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
	  from ##ihs_pay_srvc_dtl
	


--select * from tbl_ihs_services where id_case=385344
--select * from tbl_ihs_episodes where id_case=385344


declare @max_pay_id int
select @max_pay_id=max(id_payment_fact) from dbo.payment_fact

insert into base.tbl_ihs_services
([id_ihs_episode]
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




update base.tbl_ihs_episodes
set cd_asgn_type= intk.cd_asgn_type
, tx_asgn_type=intk.tx_asgn_type
from ##ihs_intk intk



update statistics base.tbl_ihs_episodes

update statistics base.tbl_ihs_services



end