USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_child_episodes_with_intakes]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [base].[prod_update_tbl_child_episodes_with_intakes] (@permission_key datetime)
as
if @permission_key = (select cutoff_date from dbo.ref_Last_DW_Transfer) 
begin

		  set nocount on
	 -- intakes from TBL_INTAKES filtering out alternate intervention and reopen cases
		  -- where referral date within a year prior to state custody start date thru 10 days beyond state custody start date
			if object_ID('tempDB..##episodes') is not null drop table ##episodes
			select tce.ID_REMOVAL_EPISODE_FACT,id_prsn_child,si.id_intake_fact,tce.id_case as ID_CASE_TCE,inv_ass_start,inv_ass_stop,state_custody_start_date,FEDERAL_DISCHARGE_DATE_FORCE_18 as Federal_Discharge_Date,si.id_case as ID_CASE_SI
				,0 as update_from_sibling
				,0 as update_from_vctm_fact
				,0 as update_from_tce_xwalk
				,0 as update_from_intk_part_vctm
				,0 as update_from_algtn_vctm_ars
				,0 as update_from_tce_xwalk_ars
				,0 as update_from_si_intk_reopn
				,0 as update_from_tce_xwalk_reopn				
				,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
									order by ID_REMOVAL_EPISODE_FACT,isnull(inv_ass_start,state_custody_start_date) desc) as row_num
			
			into ##episodes
			from base.TBL_CHILD_EPISODES tce
			left join base.TBL_INTAKES si on si.id_case=tce.id_case and si.cd_final_decision=1   
			and fl_alternate_intervention=0 and fl_reopen_case=0
			and inv_ass_start between dateadd(dd,-365,State_Custody_Start_Date) and dateadd(dd,10,State_Custody_Start_Date)

			delete from ##episodes where row_num > 1

			-- for those missing intakes still look at intake_victim_fact matching child, then matching to tbl_intakes screened_in on id_intake_fact
			-- filtering out alternate intervention and reopen cases
			-- where the referral date within a year prior to state custody start date thru 10 days beyond state custody start date
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_vctm_fact=1
			from  ##episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT
									,id_prsn_child
									,si.id_intake_fact
									,si.ID_CASE
									,si.inv_ass_start
									,si.inv_ass_stop
									,state_custody_start_date
									,Federal_Discharge_Date
									,row_number() over (
										partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT
											   ,isnull(si.inv_ass_start,state_custody_start_date) desc) as row_num
					from ##episodes tce
					join (select distinct ID_CASE,ID_INTAKE_FACT,ID_PRSN_VCTM 
							from dbo.INTAKE_VICTIM_FACT
						) q on q.ID_PRSN_VCTM=tce.ID_PRSN_CHILD
					--join TBL_INTAKES si on si.ID_INTAKE_FACT=q.ID_INTAKE_FACT 
					join base.TBL_INTAKES si on si.ID_CASE=q.ID_CASE 
							and si.cd_final_decision=1  
							and  fl_alternate_intervention=0
							and fl_reopen_case=0
					where (tce.ID_INTAKE_FACT is null or abs(datediff(dd,si.inv_ass_start ,state_custody_start_date)) < abs(datediff(dd,tce.inv_ass_start ,state_custody_start_date)))
						and si.inv_ass_start between dateadd(dd,-365,State_Custody_Start_Date) and dateadd(dd,10,State_Custody_Start_Date)
					--	order by tce.id_removal_episode_fact,[row_num] asc
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null or abs(datediff(dd,qry.inv_ass_start ,eps.state_custody_start_date)) < abs(datediff(dd,eps.inv_ass_start ,eps.state_custody_start_date))

			-- use crosswalk of cases identified with this child matching to TBL_INTAKES as in prior query but matching on crosswalk case identified
			-- for the child 
			-- filtering out alternate intervention and reopen cases
			-- where the referral date within a year prior to state custody start date thru 10 days beyond state custody start date
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_tce_xwalk=1
			from  ##episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.ID_PRSN_CHILD,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,state_custody_start_date,Federal_Discharge_Date
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,tce.state_custody_start_date) desc) as row_num
					from ##episodes tce
					join (		select distinct eps1.id_prsn_child,eps1.id_case
								from base.tbl_child_episodes eps1
								join ( -- use crosswalk of cases identified with this child
									select id_prsn_child,count(distinct id_case) as cnt_case 
									from base.tbl_child_episodes 
									group by ID_PRSN_CHILD having count(distinct id_case) > 1 
									) q on q.id_prsn_child=eps1.ID_PRSN_CHILD  
								) q2 on q2.id_prsn_child=tce.ID_PRSN_CHILD and q2.ID_CASE <> tce.ID_CASE_TCE
					join base.TBL_INTAKES si on si.ID_CASE = q2.ID_CASE and si.cd_final_decision=1  and fl_alternate_intervention=0 and fl_reopen_case=0
					where (tce.ID_INTAKE_FACT is null or abs(datediff(dd,si.inv_ass_start ,state_custody_start_date)) < abs(datediff(dd,tce.inv_ass_start ,state_custody_start_date)))
						and si.inv_ass_start between dateadd(dd,-365,tce.State_Custody_Start_Date) and dateadd(dd,10,tce.State_Custody_Start_Date)
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null or abs(datediff(dd,qry.inv_ass_start ,eps.state_custody_start_date)) < abs(datediff(dd,eps.inv_ass_start ,eps.state_custody_start_date))
			
			
		-- look at intake participants .... using logic to identify children associated with the intake
		if OBJECT_ID('tempDB..#intake_child') is not null drop table #intake_child
		select distinct
			intk.id_intake_fact
			,pdCur.ID_PRSN as ID_PRSN_CHILD
			,pdCur.dt_birth
			,dbo.fnc_datediff_yrs(pdCur.dt_birth,inv_ass_start) as age_at_referral_dt
		into #intake_child
		from base.TBL_INTAKES intk
		join dbo.INTAKE_PARTICIPANT_FACT  
			on INTAKE_PARTICIPANT_FACT.ID_INTAKE_FACT=intk.id_intake_fact
		  join dbo.[INTAKE_PARTICIPANT_ROLES_DIM] prd 
			on prd.ID_INTAKE_PARTICIPANT_ROLES_DIM=INTAKE_PARTICIPANT_FACT.ID_INTAKE_PARTICIPANT_ROLES_DIM
		  join dbo.people_dim pd 
				on INTAKE_PARTICIPANT_FACT.id_people_dim_child =pd.id_people_dim
		  join dbo.people_dim pdCur on pdCur.ID_PRSN=pd.ID_PRSN and pdCur.IS_CURRENT=1
			and pdCur.dt_birth < inv_ass_start
			where (--  Victim,  Household Member,  Identified Child,   Client
			 coalesce(cd_role1,0) in (1,8,12,19) OR
			 coalesce(cd_role2,0) in (1,8,12,19) OR
			 coalesce(cd_role3,0) in (1,8,12,19) OR
			 coalesce(cd_role4,0) in (1,8,12,19) OR
			 coalesce(cd_role5,0) in (1,8,12,19))
			 and fl_alternate_intervention=0 and fl_reopen_case=0
		 and intk.cd_final_decision=1 ;

		-- add all the kids from intake victim fact except those we already have 	 
		insert into #intake_child
		select distinct
			intk.id_intake_fact
			,pdCur.ID_PRSN as  ID_PRSN_CHILD
			,pdCur.dt_birth
			,dbo.fnc_datediff_yrs(pdCur.dt_birth,inv_ass_start) as age_at_referral_dt
		from base.TBL_INTAKES intk
		join dbo.intake_victim_fact ivf  
			on ivf.ID_INTAKE_FACT=intk.id_intake_fact
		  join dbo.people_dim pd 
		  on ivf.id_people_dim_child =pd.id_people_dim
		join dbo.people_dim pdCur on pdCur.ID_PRSN=pd.ID_PRSN and pdCur.IS_CURRENT=1
			and pdCur.dt_birth < inv_ass_start
		where  intk.cd_final_decision=1 and intk.fl_alternate_intervention=0 and intk.fl_reopen_case=0
		except
		select * from  #intake_child;
		
		--remove adults
		delete from #intake_child where age_at_referral_dt > 17;


		-- use the temp table created in steps above (#intake_child) to see if the child is associated with an intake with a different ID_CASE
		-- again filtering out alternate intervention and reopen cases
		-- where the referral date within a year prior to state custody start date thru 10 days beyond state custody start date
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_intk_part_vctm=1
			from  ##episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.ID_PRSN_CHILD,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,state_custody_start_date,Federal_Discharge_Date
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,state_custody_start_date) desc) as row_num
					from ##episodes tce
					join #intake_child q on q.ID_PRSN_CHILD=tce.ID_PRSN_CHILD
					join base.TBL_INTAKES si on si.ID_INTAKE_FACT=q.ID_INTAKE_FACT and si.cd_final_decision=1 and fl_alternate_intervention=0 and fl_reopen_case=0
					where tce.ID_INTAKE_FACT is null 
						and si.inv_ass_start between dateadd(dd,-365,State_Custody_Start_Date) and dateadd(dd,10,State_Custody_Start_Date)
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

			--look at allegation_fact OK for ARS ********************************************************************************************************
			 --select si.id_intake_fact,si.inv_ass_start,si.inv_ass_stop
			 --,tce.id_prsn_child,tce.state_custody_start_date,tce.federal_discharge_date,si.id_case as id_case_SI,tce.id_case
			 --,si.fl_cps_invs,si.fl_cfws,si.fl_alternate_intervention,si.fl_frs,si.fl_risk_only ,si.fl_reopen_case
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_algtn_vctm_ars=1
			from  ##episodes eps
			join (
						select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.ID_PRSN_CHILD,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,state_custody_start_date,Federal_Discharge_Date
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,state_custody_start_date) desc) as row_num
						from ##episodes tce
						 join dbo.allegation_fact alf on alf.id_prsn_victim=tce.id_prsn_child
						 join dbo.abuse_type_dim atd on atd.id_abuse_type_dim=alf.id_abuse_type_dim
						 join base.TBL_INTAKES si on si.id_intake_fact=alf.id_intake_fact  and si.cd_final_decision=1 and fl_reopen_case=0
						 where tce.id_intake_fact is null 
						 and  si.inv_ass_start between dateadd(dd,-365,State_Custody_Start_Date) and dateadd(dd,10,State_Custody_Start_Date)
			 ) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_tce_xwalk_ars=1
			from  ##episodes eps
			join (
						select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.ID_PRSN_CHILD,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,state_custody_start_date,Federal_Discharge_Date
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,state_custody_start_date) desc) as row_num
						from ##episodes tce
						 join base.TBL_INTAKES si on si.id_case=tce.ID_CASE_TCE  and si.cd_final_decision=1 and fl_reopen_case=0 and fl_alternate_intervention=1
						 where tce.id_intake_fact is null 
						 and  si.inv_ass_start between dateadd(dd,-365,State_Custody_Start_Date) and dateadd(dd,10,State_Custody_Start_Date)
			 ) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

			-- look at reopened cases ********************************************************************************************************
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_si_intk_reopn=1
			from  ##episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.ID_CASE_TCE ,id_prsn_child,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,state_custody_start_date,Federal_Discharge_Date
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,state_custody_start_date) desc) as row_num
					from ##episodes tce
					join base.TBL_INTAKES si on si.ID_CASE=tce.ID_CASE_TCE  and si.cd_final_decision=1  and fl_reopen_case=1
					where tce.ID_INTAKE_FACT is null 
						and si.inv_ass_start between dateadd(dd,-365,State_Custody_Start_Date) and dateadd(dd,10,State_Custody_Start_Date)
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

			--look at those kids in tbl_child_episodes with multiple ID_CASE  and fl_reopen_case=1
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_tce_xwalk_reopn=1
			from  ##episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.ID_PRSN_CHILD,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,state_custody_start_date,Federal_Discharge_Date
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,tce.state_custody_start_date) desc) as row_num
					from ##episodes tce
					join (		select distinct eps1.id_prsn_child,eps1.id_case
								from base.tbl_child_episodes eps1
								join ( -- use crosswalk of cases identified with this child
									select id_prsn_child,count(distinct id_case) as cnt_case from base.tbl_child_episodes 
									group by ID_PRSN_CHILD having count(distinct id_case) > 1 ) q on q.id_prsn_child=eps1.ID_PRSN_CHILD  
								) q2 on q2.id_prsn_child=tce.ID_PRSN_CHILD and q2.ID_CASE <> tce.ID_CASE_TCE
					join base.TBL_INTAKES si on si.ID_CASE = q2.ID_CASE   and si.cd_final_decision=1 and fl_reopen_case=1
					where tce.ID_INTAKE_FACT is null 
						and si.inv_ass_start between dateadd(dd,-365,tce.State_Custody_Start_Date) and dateadd(dd,10,tce.State_Custody_Start_Date)
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

						
			if object_ID('tempDB..#siblings') is not null drop table #siblings;
							SELECT distinct tcps.ID_PRSN_CHILD as ID_PRSN_PRIMCHILD
										, tcps.ID_REMOVAL_EPISODE_FACT
										, eps.id_case_tce
										, eps.ID_INTAKE_FACT
										, eps.inv_ass_start
										, eps.inv_ass_stop
										,ID_SIBLING_RELATIONSHIP_FACT
										, ID_CALENDAR_DIM_BEGIN
										, ID_CALENDAR_DIM_END
										, ID_CASE_DIM_CHILD
										, ID_PEOPLE_DIM_CHILD
										, ID_PEOPLE_DIM_SIBLING
										, TX_RELATIONSHIP_TYPE
										, FL_SIBLING_IN_PLACEMENT
										, FL_TOGETHER
										, CHILD_AGE
										, SIBLING_AGE
										, sib.ID_PRSN_CHILD
										, ID_PRSN_SIBLING
										, ID_CASE_CHILD  
										, dbo.IntDate_To_CalDate(id_calendar_dim_begin) as sibrel_begin
										, dbo.IntDate_To_CalDate(id_calendar_dim_end) as sibrel_end
										, case when charindex('Full ',TX_RELATIONSHIP_TYPE)>0 then 1
										  when charindex('Half ',TX_RELATIONSHIP_TYPE)>0 then 2
										  when charindex('Sibling',TX_RELATIONSHIP_TYPE)>0 then 2
										  else 3 end as sibtypc
										, case when charindex('Full ',TX_RELATIONSHIP_TYPE)>0  then 1 else 0 end as Fullsib
										, case when charindex('Half ',TX_RELATIONSHIP_TYPE)>0  or charindex('Sibling',TX_RELATIONSHIP_TYPE)>0  then 1 else 0 end as Halfsib
										, case when charindex('Step ',TX_RELATIONSHIP_TYPE)>0 then 1 else 0 end as Stepsib
								--**  compute flag of sibling in QUALIFYING placement
					
								into  #siblings
								FROM dbo.SIBLING_RELATIONSHIP_FACT sib
								join base.TBL_CHILD_PLACEMENT_SETTINGS tcps on tcps.id_placement_fact=sib.ID_PLACEMENT_FACT
								join ##episodes eps on eps.ID_REMOVAL_EPISODE_FACT=tcps.id_removal_episode_fact
								--where dbo.IntDate_To_CalDate(id_calendar_dim_begin) <= coalesce(e.Federal_Discharge_Date,'12/31/3999')
								--	and isnull(dbo.IntDate_To_CalDate(id_calendar_dim_end),'12/31/3999') > e.State_Custody_Start_Date
								

			update epsib
			set ID_INTAKE_FACT=eps.ID_INTAKE_FACT
			,inv_ass_start=eps.inv_ass_start
			,inv_ass_stop=eps.inv_ass_stop
			,ID_CASE_SI=eps.id_CASE_SI
			,update_from_sibling=1
			from ##episodes eps
			join #siblings s on eps.ID_REMOVAL_EPISODE_FACT=s.id_removal_episode_fact
			join ##episodes epsib on epsib.ID_PRSN_CHILD=s.ID_PRSN_SIBLING and epsib.State_Custody_Start_Date <=coalesce(eps.Federal_Discharge_Date,'12/31/3999')
				and epsib.Federal_Discharge_Date >=eps.State_Custody_Start_Date
			where eps.ID_INTAKE_FACT is not null and epsib.ID_INTAKE_FACT is null 
			and eps.inv_ass_start between dateadd(dd,-365,epsib.State_Custody_Start_Date) and dateadd(dd,10,epsib.State_Custody_Start_Date)


			update base.TBL_CHILD_EPISODES
			set id_intake_fact=null

			update base.TBL_CHILD_EPISODES
			set id_intake_fact=eps.id_intake_fact
			from ##episodes eps 
			where eps.ID_REMOVAL_EPISODE_FACT=TBL_CHILD_EPISODES.ID_REMOVAL_EPISODE_FACT

			--select count(*) as cnt
			--	, sum(case when id_intake_fact is not null then 1 else 0 end) as cnt_intakes
			--	, sum(update_from_sibling) as update_from_sibling
			--	, sum(update_from_vctm_fact) as update_from_vctm_fact
			--	, sum(update_from_tce_xwalk) as update_from_tce_xwalk
			--	, sum(update_from_intk_part_vctm) as update_from_intk_part_vctm
			--	, sum(update_from_algtn_vctm_ars) as update_from_algtn_vctm_ars
			--	, sum(update_from_tce_xwalk_ars) as update_from_tce_xwalk_ars
			--	, sum(update_from_si_intk_reopn) as update_from_si_intk_reopn
			--	, sum(update_from_tce_xwalk_reopn)	 as update_from_tce_xwalk_reopn
			-- from ##episodes
 end
 else
 begin 
	print 'NEED PERMISSION KEY TO EXECUTE STORED PROCEDURE'
 end
GO
