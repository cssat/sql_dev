
CREATE procedure [base].[prod_build_WRK_TRHEvents](@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin


		if object_ID('tempDB..#WRK_TRHEvents') is not null drop table #WRK_TRHEvents;

		declare @cutoff_date datetime
		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer;

		select tbl_child_placement_settings.*
		,case when Placement_End_Reason_Code in (38,39,40) then 1 else 0 end as TRHmark
		,cast(null as datetime) as TRH_begin
		,cast(null as datetime) as TRH_end
		,cast(0 as int) as daysTRH
		,case Placement_End_Reason_Code when 38 then 1 when 39 then 2 when 40 then 3 else 9 end as TRHtype 
		,cast(0 as int) as daysctrh_tot
		,cast(0 as int) as N_TRH
		,case when lst.last_entry is not null then 'Y' else 'N' end as FL_Last_Eps_OH_Plcmnt
		,row_number() over (
							partition by id_removal_episode_fact
							 order by id_prsn_child,id_removal_episode_fact,tbl_child_placement_settings.entry_date desc) as plcmnt_order
		into #WRK_TRHEvents
		from base.TBL_CHILD_PLACEMENT_SETTINGS
		join (select id_removal_episode_fact as iref,state_custody_start_date as eps_begin,federal_discharge_date 
				from base.TBL_CHILD_EPISODES) tce 
						on iref=id_removal_episode_fact
							and entry_date >=eps_begin
							and entry_date <=isnull(federal_discharge_date,@cutoff_date)
		left join (select tbl_child_placement_settings.id_removal_episode_fact as iref_pl
								,entry_date
								,isnull(exit_date,@cutoff_date) as exit_date
								,row_number() over (partition by tbl_child_placement_settings.id_removal_episode_fact
																	order by tbl_child_placement_settings.id_removal_episode_fact
																					,tbl_child_placement_settings.entry_date desc
																					,isnull(tbl_child_placement_settings.exit_date,@cutoff_date) desc) as  last_entry 
							from base.TBL_CHILD_PLACEMENT_SETTINGS 
							join base.TBL_CHILD_EPISODES tce on tce.id_removal_episode_fact=tbl_child_placement_settings.id_removal_episode_fact
							where CD_EPSD_TYPE=1 OR (CD_EPSD_TYPE in (1,5) and placement_end_reason_code in (38,39,40) )
							and entry_date >=tce.state_custody_start_date
							and entry_date <=isnull(tce.federal_discharge_date,@cutoff_date)
							group by  tbl_child_placement_settings.id_removal_episode_fact ,entry_date,isnull(exit_date,@cutoff_date) 
							) lst on lst.iref_pl=id_removal_episode_fact and lst.entry_date=tbl_child_placement_settings.entry_date
									and lst.exit_date=isnull(tbl_child_placement_settings.exit_date,@cutoff_date)
										and lst.last_entry=1
		--where entry_date >='1/1/2004'
		order by id_prsn_child,id_removal_episode_fact,tbl_child_placement_settings.entry_date;

		--**  compute TRH end date as begin date of next event, IF next event starts
		--**  on or after date of TRH_begin (this avoids computing spurious TRH end dates
		--**  that apparently occur BEFORE TRH begin date, which result from cases
		--**  where the TRH begin date (end of event) are concurrent with certain
		--**  temporary and administrative "events" such as hospital stays and fiscal cleanups)

		--IF (TRHmark = 1) TRH_begin = evt_end .
		--IF (TRHmark = 1 AND ID_PRSN_CHILD = LAG(ID_PRSN_CHILD)
		--   AND ID_REMOVAL_EPISODE_FACT = LAG(ID_REMOVAL_EPISODE_FACT)
		--   AND LAG(CD_EPSD_TYPE) = '1'
		--   AND LAG(evt_begin) >= evt_end)
		--   TRH_end = LAG(evt_begin) .
		--EXECUTE .

		update #WRK_TRHEvents
		set TRH_begin=exit_date
		where TRHmark=1;

		update W2
		set TRH_end=w1.entry_date
		from #WRK_TRHEvents W1
		join #WRK_TRHEvents W2 on w1.id_removal_episode_fact=W2.id_removal_episode_fact
		and W1.CD_EPSD_TYPE=1
		and W1.entry_date >=w2.exit_date
		and W2.plcmnt_order = W1.plcmnt_order + 1
		where W2.TRHmark=1;
		--select * from #WRK_TRHEvents where trh_end is not null
		--select * from #WRK_TRHEvents where id_removal_episode_fact = 100233  order by entry_date desc
		--**  skip (up to 4) intervening temporary events to determine TRH end date,
		--**  when TRH unsuccessful (child returned to out of home care in same episode)
		-- IF (TRHmark = 1 AND ID_PRSN_CHILD = LAG(ID_PRSN_CHILD)
		--   AND ID_PRSN_CHILD = LAG(ID_PRSN_CHILD,2)
		--   AND ID_REMOVAL_EPISODE_FACT = LAG(ID_REMOVAL_EPISODE_FACT)
		--   AND ID_REMOVAL_EPISODE_FACT = LAG(ID_REMOVAL_EPISODE_FACT,2)
		--   AND LAG(CD_EPSD_TYPE) = '5' AND LAG(CD_EPSD_TYPE,2) = '1'
		--   AND LAG(evt_begin,2) >= evt_end
		--   AND SYSMIS(TRH_end)) .
		--   COMPUTE TRH_end = LAG(evt_begin,2) .
		--END IF .
		--EXECUTE .

		update Evt
		set TRH_end=lag2.entry_date
		from #WRK_TRHEvents lag2
		join #WRK_TRHEvents lag1 on lag1.id_removal_episode_fact=lag2.id_removal_episode_fact
				and lag1.plcmnt_order = lag2.plcmnt_order + 1
		join #WRK_TRHEvents Evt on Evt.id_removal_episode_fact=lag2.id_removal_episode_fact
				and Evt.plcmnt_order = lag2.plcmnt_order + 2
		where  Evt.TRHmark=1 
				and lag2.CD_EPSD_TYPE=1  
				and lag1.CD_EPSD_TYPE=5
				and LAG2.entry_date >=Evt.exit_date
				and EVT.TRH_end is null



		--DO IF (TRHmark = 1 AND ID_PRSN_CHILD = LAG(ID_PRSN_CHILD)
		--   AND ID_PRSN_CHILD = LAG(ID_PRSN_CHILD,2)
		--   AND ID_PRSN_CHILD = LAG(ID_PRSN_CHILD,3)
		--   AND ID_REMOVAL_EPISODE_FACT = LAG(ID_REMOVAL_EPISODE_FACT)
		--   AND ID_REMOVAL_EPISODE_FACT = LAG(ID_REMOVAL_EPISODE_FACT,2)
		--   AND ID_REMOVAL_EPISODE_FACT = LAG(ID_REMOVAL_EPISODE_FACT,3)
		--   AND LAG(CD_EPSD_TYPE) = '5' AND LAG(CD_EPSD_TYPE,2) = '5'
		--   AND LAG(CD_EPSD_TYPE,3) = '1'
		--   AND LAG(evt_begin,3) >= evt_end 
		--   AND SYSMIS(TRH_end)) .
		--   COMPUTE TRH_end = LAG(evt_begin,3) .
		--END IF .
		--EXECUTE .

		update Evt
		set TRH_end=lag3.entry_date
		from #WRK_TRHEvents lag3
		join #WRK_TRHEvents lag2 on lag2.id_removal_episode_fact=lag3.id_removal_episode_fact
				and lag2.plcmnt_order = lag3.plcmnt_order + 1
		join #WRK_TRHEvents lag1 on lag1.id_removal_episode_fact=lag3.id_removal_episode_fact
				and lag1.plcmnt_order = lag3.plcmnt_order + 2
		join #WRK_TRHEvents Evt on Evt.id_removal_episode_fact=lag3.id_removal_episode_fact
				and Evt.plcmnt_order = lag3.plcmnt_order + 3
		where  Evt.TRHmark=1 
				and lag3.CD_EPSD_TYPE=1  
				and lag2.CD_EPSD_TYPE=5
				and lag1.CD_EPSD_TYPE=5
				and lag3.entry_date >=Evt.exit_date
				and EVT.TRH_end is null

		update Evt
		set TRH_end=lag4.entry_date
		from #WRK_TRHEvents lag4
		join #WRK_TRHEvents lag3 on lag3.id_removal_episode_fact=lag4.id_removal_episode_fact
					and lag3.plcmnt_order = lag4.plcmnt_order + 1
		join #WRK_TRHEvents lag2 on lag2.id_removal_episode_fact=lag4.id_removal_episode_fact
				and lag2.plcmnt_order = lag4.plcmnt_order + 2
		join #WRK_TRHEvents lag1 on lag1.id_removal_episode_fact=lag4.id_removal_episode_fact
				and lag1.plcmnt_order = lag4.plcmnt_order + 3
		join #WRK_TRHEvents Evt on Evt.id_removal_episode_fact=lag4.id_removal_episode_fact
				and Evt.plcmnt_order = lag4.plcmnt_order + 4
		where  Evt.TRHmark=1 
				and lag4.CD_EPSD_TYPE=1
				and lag3.CD_EPSD_TYPE=5
				and lag2.CD_EPSD_TYPE=5
				and lag1.CD_EPSD_TYPE=5
				and lag4.entry_date >=Evt.exit_date
				and EVT.TRH_end is null

		update Evt
		set TRH_end=lag5.entry_date
		from #WRK_TRHEvents lag5
		join #WRK_TRHEvents lag4 on lag4.id_removal_episode_fact=lag5.id_removal_episode_fact
					and lag4.plcmnt_order=lag5.plcmnt_order + 1
		join #WRK_TRHEvents lag3 on lag3.id_removal_episode_fact=lag5.id_removal_episode_fact
					and lag3.plcmnt_order = lag5.plcmnt_order + 2
		join #WRK_TRHEvents lag2 on lag2.id_removal_episode_fact=lag5.id_removal_episode_fact
				and lag2.plcmnt_order = lag5.plcmnt_order + 3
		join #WRK_TRHEvents lag1 on lag1.id_removal_episode_fact=lag5.id_removal_episode_fact
				and lag1.plcmnt_order = lag5.plcmnt_order + 4
		join #WRK_TRHEvents Evt on Evt.id_removal_episode_fact=lag5.id_removal_episode_fact
				and Evt.plcmnt_order = lag5.plcmnt_order + 5
		where  Evt.TRHmark=1 
				and lag5.CD_EPSD_TYPE=1
				and lag4.CD_EPSD_TYPE=5
				and lag3.CD_EPSD_TYPE=5
				and lag2.CD_EPSD_TYPE=5
				and lag1.CD_EPSD_TYPE=5
				and lag5.entry_date >=Evt.exit_date
				and EVT.TRH_end is null

		delete from #WRK_TRHEvents where TRHmark = 0
	


		update #WRK_TRHEvents
		set daysTRH = datediff(dd,TRH_begin,TRH_END)



		update #WRK_TRHEvents
		set daysctrh_tot=trhdays,N_TRH=q.N_TRH
		from (
				select ID_REMOVAL_EPISODE_FACt,SUM(daysTRH) as trhdays,count(distinct ID_PLACEMENT_FACT) as N_TRH
				 from #WRK_TRHEvents
				group by  ID_REMOVAL_EPISODE_FACt ) q 
		where  q.ID_REMOVAL_EPISODE_FACT = #WRK_TRHEvents.ID_REMOVAL_EPISODE_FACT
		--**  unduplicate by child-episode (latest TRH, then TRH to mother priority)

		alter table #WRK_TRHEvents drop column plcmnt_order;
		


		if object_ID(N'base.WRK_TRHEvents',N'U') is not null drop table base.WRK_TRHEvents;

		select distinct
			ID_PRSN_CHILD,ID_REMOVAL_EPISODE_FACT,TRH_begin,TRH_End,TRHtype,TRHmark,N_TRH,daysctrh_tot  
			,case when TRH_End is not null then 'Y' else 'N'  end as FL_RET_TO_CARE,FL_Last_Eps_OH_Plcmnt
			,cast(convert(varchar(10),getdate(),101) as datetime) as Tbl_Refresh_Dt
		into base.WRK_TRHEvents
		from  #WRK_TRHEvents

		update base.procedure_flow
		set last_run_date=getdate()
		where procedure_nm='prod_build_WRK_TRHEvents'

	end
else
	begin
		select 'Need permission key to execute this --BUILDS WRK_TRHEvents!' as [Warning]
	end
