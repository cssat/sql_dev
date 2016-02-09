CREATE procedure [base].[prod_update_rptPlacement_with_intakes] (@permission_key datetime, @debug smallint = 0)
as
if @permission_key = (select cutoff_date from dbo.ref_Last_DW_Transfer) 
begin

		  set nocount on

		  update tce
		  set id_intake_fact=null
		  from base.rptPlacement tce;

	 -- intakes from TBL_INTAKES filtering out alternate intervention and reopen cases
		  -- where referral date within a year prior to state custody start date thru 10 days beyond state custody start date
			if object_ID('tempDB..#episodes') is not null drop table #episodes
			select tce.id_removal_episode_fact,child,si.id_intake_fact,tce.id_case as id_case_tce,inv_ass_start,inv_ass_stop,removal_dt
					,discharge_dt as discharge_dt,si.id_case as ID_CASE_SI
				,iif(si.id_case is not null,1,0)  [update_from_intakes_si]
				,0 as update_from_sibling
				,0 as update_from_vctm_fact
				,0 as update_from_tce_xwalk
				,0 as update_from_intk_part_vctm
				,0 as update_from_algtn_vctm_ars
				,0 as update_from_tce_xwalk_ars
				,0 as update_from_si_intk_reopn
				,0 as update_from_tce_xwalk_reopn				
				,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
									order by ID_REMOVAL_EPISODE_FACT,isnull(inv_ass_start,removal_dt) desc) as row_num
			
			into #episodes
			from base.rptPlacement tce
			left join base.TBL_INTAKES si on si.id_case=tce.id_case and si.cd_final_decision=1   and si.id_case > 0
			and fl_alternate_intervention=0 and fl_reopen_case=0 and fl_dlr=0
			and inv_ass_start between dateadd(dd,-365,removal_dt) and dateadd(dd,10,removal_dt)
						
			--if object_id('debug.episodes_1') is not null drop table debug.episodes_1;
			--if @debug = 1 select * into debug.episodes_1 from #episodes


	--		select * from #episodes eps where exists(select * from #episodes mult where mult.row_num > 1  and mult.id_removal_episode_fact=eps.id_removal_episode_fact)

			delete from #episodes where row_num > 1

			--if object_id('debug.episodes_2') is not null drop table debug.episodes_2;
			--if @debug = 1 select * into debug.episodes_2 from #episodes
					
			CREATE INDEX idx_child on #episodes (child) INCLUDE (id_case_tce)
			CREATE INDEX idx_id_case_tce on #episodes (id_case_tce)
			CREATE INDEX idx_id_removal_episode_fact on #episodes (id_removal_episode_fact)

			-- for those missing intakes still look at intake_victim_fact matching child
			-- , then matching to tbl_intakes screened_in on id_intake_fact
			-- filtering out alternate intervention and reopen cases
			-- where the referral date within a year prior to state custody start date thru 10 days beyond state custody start date
			update eps
			set ID_INTAKE_FACT=q.ID_INTAKE_FACT
			,inv_ass_start=q.inv_ass_start
			,inv_ass_stop=q.inv_ass_stop
			,ID_CASE_SI=q.id_CASE
			,update_from_vctm_fact=1
			,update_from_intakes_si=0
			from  #episodes eps
			join (select  ivf.ID_CASE
								,ivf.ID_INTAKE_FACT
								,ivf.ID_PRSN_VCTM 
								,intk.inv_ass_start
								,intk.inv_ass_stop
								,intk.rfrd_date
								,eps.removal_dt
								,ROW_NUMBER() over (partition by ivf.id_prsn_vctm,removal_dt
										order by abs(datediff(dd,inv_ass_start,removal_dt))  asc, ivf.ID_INTAKE_FACT) as row_num
							from dbo.INTAKE_VICTIM_FACT ivf
							join base.tbl_intakes	 intk  on ivf.ID_INTAKE_FACT=intk.ID_INTAKE_FACT  and intk.id_case > 0
							join (select distinct child,removal_dt from #episodes) eps
									on eps.child=ivf.ID_PRSN_VCTM
							where intk.inv_ass_start 
							between dateadd(dd,-365,removal_dt) and dateadd(dd,10,removal_dt)
							and intk.fl_reopen_case=0 and intk.cd_final_decision=1
							and intk.fl_alternate_intervention=0
							and intk.fl_dlr=0
						) q on q.id_prsn_vctm=eps.child
					and q.removal_dt=eps.removal_dt
					and q.row_num=1 
					and (eps.id_intake_fact is null or (eps.id_intake_fact is not null and  abs(datediff(dd,q.inv_ass_start,eps.removal_dt))<  abs(datediff(dd,eps.inv_ass_start,eps.removal_dt))));

			--if object_id('debug.episodes_3') is not null drop table debug.episodes_3;
			--if @debug = 1 select * into debug.episodes_3 from #episodes				
						
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
			,update_from_intakes_si=0
			,update_from_vctm_fact=0
			from  #episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.child,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,removal_dt,discharge_dt
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,tce.removal_dt) desc) as row_num
					from #episodes tce
					join (	select distinct eps1.child,eps1.id_case
								from base.rptPlacement eps1
								where exists(select * from base.rptPlacement eps2 where eps2.child=eps1.child and eps2.id_case <> eps1.id_case)
								--order by child
								) q2 on q2.child=tce.child and q2.ID_CASE <> tce.ID_CASE_TCE
					join base.TBL_INTAKES si on si.ID_CASE = q2.ID_CASE and si.cd_final_decision=1  and fl_alternate_intervention=0 and fl_reopen_case=0 and fl_dlr=0
							 and si.id_case > 0
					where (tce.id_intake_fact is null or abs(datediff(dd,si.inv_ass_start ,tce.removal_dt)) < abs(datediff(dd,tce.inv_ass_start ,tce.removal_dt)))
						and si.inv_ass_start between dateadd(dd,-365,tce.removal_dt) and dateadd(dd,10,tce.removal_dt)
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null or abs(datediff(dd,qry.inv_ass_start ,eps.removal_dt)) < abs(datediff(dd,eps.inv_ass_start ,eps.removal_dt))

			--if object_id('debug.episodes_4') is not null drop table debug.episodes_4;
			--if @debug = 1 select * into debug.episodes_4 from #episodes
			
						
		-- look at intake participants .... using logic to identify children associated with the intake
		if OBJECT_ID('tempDB..#intake_child') is not null drop table #intake_child
		select distinct
			intk.id_intake_fact
			,pdCur.ID_PRSN as child
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
			and datediff(yy,pd.DT_BIRTH,inv_ass_start)< 18
			where (--  Victim,  Household Member,  Identified Child,   Client
			 coalesce(cd_role1,0) in (1,8,12,19) OR
			 coalesce(cd_role2,0) in (1,8,12,19) OR
			 coalesce(cd_role3,0) in (1,8,12,19) OR
			 coalesce(cd_role4,0) in (1,8,12,19) OR
			 coalesce(cd_role5,0) in (1,8,12,19))
			 and fl_alternate_intervention=0 and fl_reopen_case=0 and fl_dlr=0
		 and intk.cd_final_decision=1 and intk.id_case > 0 ;

		-- add all the kids from intake victim fact except those we already have 	 
		insert into #intake_child
		select distinct
			intk.id_intake_fact
			,pdCur.ID_PRSN as  child
			,pdCur.dt_birth
			,dbo.fnc_datediff_yrs(pdCur.dt_birth,inv_ass_start) as age_at_referral_dt
		from base.TBL_INTAKES intk
		join dbo.intake_victim_fact ivf  
			on ivf.ID_INTAKE_FACT=intk.id_intake_fact
		  join dbo.people_dim pd 
		  on ivf.id_people_dim_child =pd.id_people_dim
		join dbo.people_dim pdCur on pdCur.ID_PRSN=pd.ID_PRSN and pdCur.IS_CURRENT=1
			and pdCur.dt_birth < inv_ass_start
			and datediff(yy,pd.DT_BIRTH,inv_ass_start)< 18
		where  intk.cd_final_decision=1 and intk.fl_alternate_intervention=0 and intk.fl_reopen_case=0 and intk.fl_dlr=0
		and not exists (select * from #intake_child ic where ic.id_intake_fact=intk.id_intake_fact
				and pdCur.id_prsn = ic.child) and intk.id_case > 0

		
		--remove adults
		--remove those also identified as parents 
		delete intk
--		select distinct intk.child
		from #intake_child intk
			join dbo.INTAKE_PARTICIPANT_FACT  
				on INTAKE_PARTICIPANT_FACT.ID_INTAKE_FACT=intk.id_intake_fact
			  join dbo.[INTAKE_PARTICIPANT_ROLES_DIM] prd 
				on prd.ID_INTAKE_PARTICIPANT_ROLES_DIM=INTAKE_PARTICIPANT_FACT.ID_INTAKE_PARTICIPANT_ROLES_DIM
			  join dbo.people_dim pd 
					on INTAKE_PARTICIPANT_FACT.id_people_dim_child =pd.id_people_dim
				where  coalesce(cd_role1,0)  in (14)  OR
				 coalesce(cd_role2,0) in (14)    OR
				 coalesce(cd_role3,0) in (14)  OR
				 coalesce(cd_role4,0)in (14)    OR
				 coalesce(cd_role5,0) in (14)  

				 

				 

		
		-- use the temp table created in steps above (#intake_child) to see if the child is associated with an intake with a different ID_CASE
		-- again filtering out alternate intervention and reopen cases
		-- where the referral date within a year prior to state custody start date thru 10 days beyond state custody start date
			update eps
			set id_intake_fact=qry.id_intake_fact
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_case
			,update_from_intk_part_vctm=1
			from  #episodes eps
			join (
					select distinct tce.id_removal_episode_fact
												,tce.child
												,si.id_intake_fact
												,si.id_case
												,si.inv_ass_start
												,si.inv_ass_stop
												,removal_dt
												,discharge_dt
												,row_number() over (partition by id_removal_episode_fact
																							order by id_removal_episode_fact
																								, isnull(si.inv_ass_start,removal_dt) desc
																								, si.id_intake_fact) as row_num
						from #episodes tce
						join #intake_child q on q.child=tce.child
						join base.TBL_INTAKES si on si.id_intake_fact=q.id_intake_fact and si.cd_final_decision=1 and fl_alternate_intervention=0 and fl_reopen_case=0 and fl_dlr=0
						where tce.ID_INTAKE_FACT is null 
							and si.inv_ass_start between dateadd(dd,-365,removal_dt) and dateadd(dd,10,removal_dt)
							and  si.id_case > 0
					) qry on qry.id_removal_episode_fact=eps.id_removal_episode_fact 
						and qry.row_num=1
			where eps.id_intake_fact is null 


			--if object_id('debug.episodes_5') is not null drop table debug.episodes_5;
			--if @debug = 1 select * into debug.episodes_5 from #episodes


			--look at allegation_fact OK for ARS ********************************************************************************************************
			 --select si.id_intake_fact,si.inv_ass_start,si.inv_ass_stop
			 --,tce.child,tce.removal_dt,tce.discharge_dt,si.id_case as id_case_SI,tce.id_case
			 --,si.fl_cps_invs,si.fl_cfws,si.fl_alternate_intervention,si.fl_frs,si.fl_risk_only ,si.fl_reopen_case
			update eps
			set id_intake_fact=qry.id_intake_fact
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,id_case_si=qry.id_case
			,update_from_algtn_vctm_ars=1
			from  #episodes eps
			join (
						select distinct tce.id_removal_episode_fact
													,tce.child
													,si.id_intake_fact
													,si.id_case
													,si.inv_ass_start
													,si.inv_ass_stop
													,removal_dt
													,discharge_dt
						,row_number() over (partition by id_removal_episode_fact
											order by id_removal_episode_fact,isnull(si.inv_ass_start,removal_dt) desc) as row_num
						from #episodes tce
						 join dbo.allegation_fact alf on alf.id_prsn_victim=tce.child
						 join dbo.abuse_type_dim atd on atd.id_abuse_type_dim=alf.id_abuse_type_dim
						 join base.tbl_intakes si on si.id_intake_fact=alf.id_intake_fact  and si.cd_final_decision=1 and fl_reopen_case=0 and fl_dlr=0
						  and si.id_case > 0
						 where tce.id_intake_fact is null 
						 and  si.inv_ass_start between dateadd(dd,-365,removal_dt) and dateadd(dd,10,removal_dt)
			 ) qry on qry.id_removal_episode_fact=eps.id_removal_episode_fact and qry.row_num=1
			where eps.id_intake_fact is null

			--if object_id('debug.episodes_6') is not null drop table debug.episodes_6;
			--if @debug = 1 select * into debug.episodes_6 from #episodes


			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_tce_xwalk_ars=1
			from  #episodes eps
			join (
						select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.child,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,removal_dt,discharge_dt
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,removal_dt) desc) as row_num
						from #episodes tce
						 join base.TBL_INTAKES si on si.id_case=tce.ID_CASE_TCE  and si.cd_final_decision=1 and fl_reopen_case=0 and fl_alternate_intervention=1 and fl_dlr=0
						  and si.id_case > 0
						 where tce.id_intake_fact is null 
						 and  si.inv_ass_start between dateadd(dd,-365,removal_dt) and dateadd(dd,10,removal_dt)
			 ) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

			--if object_id('debug.episodes_7') is not null drop table debug.episodes_7;
			--if @debug = 1 select * into debug.episodes_7 from #episodes


			-- look at reopened cases ********************************************************************************************************
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_si_intk_reopn=1
			from  #episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.ID_CASE_TCE ,child,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,removal_dt,discharge_dt
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,removal_dt) desc) as row_num
					from #episodes tce
					join base.TBL_INTAKES si on si.ID_CASE=tce.ID_CASE_TCE  and si.cd_final_decision=1  and fl_reopen_case=1 and si.fl_dlr=0
					 and si.id_case > 0
					where tce.ID_INTAKE_FACT is null 
						and si.inv_ass_start between dateadd(dd,-365,removal_dt) and dateadd(dd,10,removal_dt)
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

			--if object_id('debug.episodes_8') is not null drop table debug.episodes_8;
			--if @debug = 1 select * into debug.episodes_8 from #episodes


			--look at those kids in tbl_child_episodes with multiple ID_CASE  and fl_reopen_case=1
			update eps
			set ID_INTAKE_FACT=qry.ID_INTAKE_FACT
			,inv_ass_start=qry.inv_ass_start
			,inv_ass_stop=qry.inv_ass_stop
			,ID_CASE_SI=qry.id_CASE
			,update_from_tce_xwalk_reopn=1
			from  #episodes eps
			join (
					select distinct tce.ID_REMOVAL_EPISODE_FACT,tce.child,si.id_intake_fact,si.ID_CASE,si.inv_ass_start,si.inv_ass_stop,removal_dt,discharge_dt
						,row_number() over (partition by ID_REMOVAL_EPISODE_FACT
											order by ID_REMOVAL_EPISODE_FACT,isnull(si.inv_ass_start,tce.removal_dt) desc) as row_num
					from #episodes tce
					join (		select distinct eps1.child,eps1.id_case
								from base.rptPlacement eps1
								where exists(select * from base.rptPlacement plc where plc.child=eps1.child and plc.id_case <> eps1.id_case)
								) q2 on q2.child=tce.child and q2.ID_CASE <> tce.ID_CASE_TCE
					join base.TBL_INTAKES si on si.ID_CASE = q2.ID_CASE   and si.cd_final_decision=1 and fl_reopen_case=1 and si.fl_dlr=0
					 and si.id_case > 0
					where tce.ID_INTAKE_FACT is null 
						and si.inv_ass_start between dateadd(dd,-365,tce.removal_dt) and dateadd(dd,10,tce.removal_dt)
					) qry on qry.ID_REMOVAL_EPISODE_FACT=eps.ID_REMOVAL_EPISODE_FACT and qry.row_num=1
			where eps.ID_INTAKE_FACT is null

			--if object_id('debug.episodes_9') is not null drop table debug.episodes_9;
			--if @debug = 1 select * into debug.episodes_9 from #episodes

						
			if object_ID('tempDB..#siblings') is not null drop table #siblings;
			SELECT distinct tcps.id_prsn_child as ID_PRSN_PRIMCHILD
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
				join #episodes eps on eps.ID_REMOVAL_EPISODE_FACT=tcps.id_removal_episode_fact
				--where dbo.IntDate_To_CalDate(id_calendar_dim_begin) <= coalesce(e.discharge_dt,'12/31/3999')
				--	and isnull(dbo.IntDate_To_CalDate(id_calendar_dim_end),'12/31/3999') > e.removal_dt
					
					

			update epsib
			set ID_INTAKE_FACT=eps.ID_INTAKE_FACT
			,inv_ass_start=eps.inv_ass_start
			,inv_ass_stop=eps.inv_ass_stop
			,ID_CASE_SI=eps.id_CASE_SI
			,update_from_sibling=1
			from #episodes eps
			join #siblings s on eps.ID_REMOVAL_EPISODE_FACT=s.id_removal_episode_fact
			join #episodes epsib on epsib.child=s.ID_PRSN_SIBLING and epsib.removal_dt <=coalesce(eps.discharge_dt,'12/31/3999')
				and epsib.discharge_dt >=eps.removal_dt
			where eps.ID_INTAKE_FACT is not null and epsib.ID_INTAKE_FACT is null 
			and eps.inv_ass_start between dateadd(dd,-365,epsib.removal_dt) and dateadd(dd,10,epsib.removal_dt)

			--if object_id('debug.episodes_10') is not null drop table debug.episodes_10;
			--if @debug = 1 select * into debug.episodes_10 from #episodes


			update base.rptPlacement
			set id_intake_fact=eps.id_intake_fact
			from #episodes eps 
			where eps.ID_REMOVAL_EPISODE_FACT=rptPlacement.ID_REMOVAL_EPISODE_FACT

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
			-- from #episodes

		update base.procedure_flow
		set last_run_date=getdate()
		where procedure_nm='prod_update_rptPlacement_with_intakes'


 end
 else
 begin 
	print 'NEED PERMISSION KEY TO EXECUTE STORED PROCEDURE'
 end
