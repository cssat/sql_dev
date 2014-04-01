alter procedure base.prod_update_rptPlacement_after_basetables
as

		update base.rptPlacement_Events
		set end_date='9999-12-31'
		where end_date is null;

		update base.rptPlacement_Events
		set discharge_dt='9999-12-31'
		where discharge_dt is null;

		update base.rptPlacement
		set discharge_dt='9999-12-31'
		where discharge_dt is null;


		update base.rptPlacement_Events
		set id_placement_fact = pf.id_placement_fact
			,id_provider_dim_caregiver=pf.ID_PROVIDER_DIM_CAREGIVER
		from placement_fact pf
		where pf.ID_REMOVAL_EPISODE_FACT=rptPlacement_Events.ID_REMOVAL_EPISODE_FACT
		and pf.ID_CALENDAR_DIM_BEGIN=rptPlacement_Events.id_calendar_dim_begin
		and pf.ID_CALENDAR_DIM_END=rptPlacement_Events.id_calendar_dim_end
		and pf.ID_EPSD=rptPlacement_Events.id_epsd;


		update evt
		set  derived_county = (case when isnull( case when ld.CD_CNTY not between 1 and 39 then null else ld.cd_cnty end,wd.CD_CNTY)=0 then -99 else isnull( case when ld.CD_CNTY not between 1 and 39 then null else ld.cd_cnty end,wd.CD_CNTY) end)
		from base.rptplacement_events  evt
		join PLACEMENT_FACT pf on pf.ID_PLACEMENT_FACT=evt.id_placement_fact
		--  join PROVIDER_DIM pd on pf.ID_PROVIDER_DIM_CAREGIVER =pd.ID_PROVIDER_DIM
		join LOCATION_DIM ld on ld.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_PLACEMENT
		join LOCATION_DIM wd on wd.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_WORKER
	
		

		
		update base.rptPlacement_Events
		set cd_end_rsn = prd.cd_end_rsn
		from PLACEMENT_RESULT_DIM prd where prd.TX_END_RSN=base.rptPlacement_Events.tx_end_rsn

		

		update  base.rptPlacement_events
		set  rptPlacement_events.cd_epsd_type = ptd.cd_epsd_type
		from placement_fact pf
		join PLACEMENT_TYPE_DIM ptd on pf.ID_PLACEMENT_TYPE_DIM=pf.ID_PLACEMENT_TYPE_DIM
		where pf.id_placement_fact=rptPlacement_events.id_placement_fact


		update base.rptPlacement_events
		set cd_srvc=std.CD_SRVC
		from PLACEMENT_FACT pf 
		join SERVICE_TYPE_DIM std on pf.ID_SERVICE_TYPE_DIM=std.ID_SERVICE_TYPE_DIM
		where rptPlacement_events.id_placement_fact=pf.ID_PLACEMENT_FACT

		update base.rptPlacement_Events
		set id_plcmnt_evnt=case when cd_plcm_setng=1 then 1
										when cd_plcm_setng in (6,8) then 2
										when cd_plcm_setng=2 then 3
										when cd_plcm_setng in (4,7,14,16) then 4
										when cd_plcm_setng in (3,9) then 5
										when cd_plcm_setng=5 then 6
										when cd_plcm_setng =17 then 8
										when cd_plcm_setng in (10,11) then 9
										when cd_plcm_setng in (12,13) then 10
										when cd_plcm_setng =15 then 11
										when cd_plcm_setng =18 then 13
									end 

					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt
					from base.rptPlacement_Events r
					,dbo.ref_lookup_placement_event plc 
					where plc.id_plcmnt_evnt=10
					and R.id_plcmnt_evnt is null



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from base.rptPlacement_Events R
					join dbo.ref_lookup_placement_event plc on plc.id_plcmnt_evnt=11
					where  cd_srvc=342 and R.id_plcmnt_evnt=10;




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from base.rptPlacement_Events R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=3
					where  cd_srvc=1758 and R.id_plcmnt_evnt=10;



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from base.rptPlacement_Events R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=10
					where  cd_srvc=245000 and R.id_plcmnt_evnt=10;




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from base.rptPlacement_Events R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=5
					where  cd_srvc=2



					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from base.rptPlacement_Events R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=12
					where  cd_srvc in (405,1768)




					update R
					set id_plcmnt_evnt=plc.id_plcmnt_evnt 
					from base.rptPlacement_Events R
					join [ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=7
					where  cd_srvc in (1776,1777)

				
					update R
					set cd_plcmnt_evnt=plc.cd_plcmnt_evnt,prtl_cd_plcm_setng=plc.cd_plcm_setng
					from base.rptPlacement_Events r
					,dbo.ref_lookup_placement_event plc 
					where R.id_plcmnt_evnt=plc.id_plcmnt_evnt




		update base.rptPlacement
		set cd_race_census = pd.cd_race_census, census_Hispanic_Latino_Origin_cd=pd.census_Hispanic_Latino_Origin_cd,cd_gndr=pd.CD_GNDR,pk_gndr=g.pk_gndr
		from PEOPLE_DIM pd 
		left join ref_lookup_gender g on g.cd_gndr=pd.cd_gndr
		where
		pd.id_prsn=rptPlacement.child and pd.IS_CURRENT=1


		update rpt
		set child_cnt_episodes = q.episode_count,latest_removal_dt=q.latest_removal_dt,first_removal_dt=q.first_removal_dt
			,age_at_removal_mos=dbo.fnc_datediff_mos(rpt.BIRTHDATE,rpt.REMOVAL_DT)
		from base.rptPlacement rpt
		join (select child,count(*) as episode_count,max(removal_dt) as latest_removal_dt,min(removal_dt) as first_removal_dt
				from base.rptPlacement rpt
				group by child) q on q.child=rpt.child


		update rpt
		set child_eps_rank = epsOrder.child_eps_rank 
		from base.rptPlacement rpt
		join (select child,id_removal_episode_fact, removal_dt,ROW_NUMBER() over (partition by child order by removal_dt) as child_eps_rank from base.rptPlacement
			) epsOrder on epsOrder.id_removal_episode_fact=rpt.id_removal_episode_fact

		update rpt
		set next_reentry_date=nxt.removal_dt, days_to_reentry=datediff(dd,rpt.discharge_dt,nxt.removal_dt)
		from base.rptPlacement rpt
		join base.rptPlacement nxt on rpt.child=nxt.child and rpt.child_eps_rank + 1 = nxt.child_eps_rank
		where rpt.child_eps_rank <> rpt.child_cnt_episodes

	
		update rpt
		set longest_id_placement_fact=q.id_placement_fact
		from base.rptPlacement  rpt
		join (select id_removal_episode_fact,id_placement_Fact,rptPlacement_Events.plcmnt_days,ROW_NUMBER() over (partition by id_removal_episode_fact order by plcmnt_days desc) as row_num
			from base.rptPlacement_Events ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact and q.row_num=1


		update rpt
		set [long_cd_plcm_setng] = prtl_cd_plcm_setng
		from base.rptPlacement  rpt
		join base.rptPlacement_Events pe on pe.id_placement_fact=rpt.longest_id_placement_fact


		update rpt
		set initial_id_placement_fact=q.id_placement_fact
		from base.rptPlacement  rpt
		join (select id_removal_episode_fact,id_placement_Fact,rptPlacement_Events.id_calendar_dim_begin,rptPlacement_Events.plcmnt_days , ROW_NUMBER() over (partition by id_removal_episode_fact order by id_calendar_dim_begin, rptPlacement_Events.plcmnt_days  desc) as row_num
			from base.rptPlacement_Events ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact and q.row_num=1

		update rpt
		set  [init_cd_plcm_setng]= prtl_cd_plcm_setng
		from base.rptPlacement  rpt
		join base.rptPlacement_Events pe on pe.id_placement_fact=rpt.initial_id_placement_fact


		update rpt
		set cd_discharge_type = case when xw.cd_discharge_type is not null then xw.cd_discharge_type
				when xwExitRsn.cd_discharge_type is not null then xwExitRsn.cd_discharge_type
				when xwLastEndRsn.cd_discharge_type is not null then xwLastEndRsn.cd_discharge_type
				when xwE.cd_discharge_type is not null then xwE.cd_discharge_type
				when discharge_dt is null then xSC.cd_discharge_type
			else 6 end,
			discharge_dt=case when (case when xw.cd_discharge_type is not null then xw.cd_discharge_type
				when xwExitRsn.cd_discharge_type is not null then xwExitRsn.cd_discharge_type
				when xwLastEndRsn.cd_discharge_type is not null then xwLastEndRsn.cd_discharge_type
				when xwE.cd_discharge_type is not null then xwE.cd_discharge_type
				when discharge_dt is null then xSC.cd_discharge_type
			else 6 end )=5 then dbo.lessorDate(dateadd(yy,18,birthdate),coalesce(rpt.discharge_dt,'12/31/3999')) else rpt.discharge_dt end
		from base.rptPlacement rpt
			left join [dbo].[ref_state_discharge_xwalk]  xw  on rpt.tx_dsch_rsn=xw.tx_dsch_rsn and discharge_dt is not null
			left join [dbo].[ref_state_discharge_xwalk]  xwLastEndRsn  on rpt.last_end_rsn=xw.tx_dsch_rsn  and discharge_dt is not null
			left join [dbo].[ref_state_discharge_xwalk]  xwExitRsn on rpt.exit_reason=xw.discharge_type  and discharge_dt is not null
			left join dbo.ref_state_discharge_xwalk xwE  
						on xwE.CD_DSCH_RSN=12   
							and dateadd(yy,18,birthdate) < (select cutoff_date from ref_last_dw_transfer)
												and  rpt.discharge_dt is null
			left join dbo.ref_state_discharge_xwalk xSC on xSC.state_discharge_reason_code=-99 -- still in care


			update rpt
			set dur_days=datediff(dd,removal_dt,isnull(discharge_dt,(select cutoff_date from ref_last_dw_transfer)) + 1)
			from base.rptPlacement rpt

		update rpt
		set max_bin_los_cd=q.max_bin_los_cd
		from base.rptPlacement rpt
		join (select id_removal_episode_Fact,max(bin_los_cd) as max_bin_los_cd
				from base.rptPlacement rpt
				join [ref_filter_los] on  rpt.dur_days between dur_days_from and dur_days_thru
					group by id_removal_episode_Fact) q
					on q.id_removal_episode_fact=rpt.id_removal_episode_fact

	
		update TCE
		set dependency_dt= null , fl_dep_exist= 0
		from base.rptPlacement TCE

		update TCE
		set dependency_dt=q.petition_date,fl_dep_exist=1
		--select id_prsn_child,tce.state_custody_start_date,tce.removal_dt,q.days_frm_state_custody,q.petition_date as petition_dependency_date
		from base.rptPlacement TCE
		join (			select distinct id_removal_episode_fact
							,FAMLINKID
							,removal_dt
							,discharge_dt
							,petition_date
							,dependency_dt
							,datediff(dd,tce.removal_dt,Petition_date) as days_frm_state_custody
							,row_number() over (partition by child ,removal_dt
									order by datediff(dd,tce.removal_dt,Petition_date)  asc) as row_num
						from aoc.aoc_petition aoc
						join base.rptPlacement  tce on 
						 tce.child=aoc.FAMLINKID
						--and (datediff(dd,aoc.Petition_date,tce.state_custody_start_date) <=365
							and Petition_date >= tce.removal_dt 
									and Petition_date < isnull(tce.discharge_dt,(select cutoff_date from ref_last_dw_transfer))
						and petition ='DEPENDENCY PETITION' 
				) q on q.id_removal_episode_fact=tce.id_removal_episode_fact  
					and q.row_num=1
		-- update those with same child , same dependency date keeping the smallest date difference from removal for dependency date
		-- and updating the dates with the larger spans to null
		update rpt
		set dependency_dt=null,fl_dep_exist=0
		from  base.rptPlacement  rpt 
		join (
		select id_removal_episode_fact 
				, rpt.child
				, rpt.dependency_dt ,removal_dt,ROW_NUMBER() over (partition by rpt.child order by abs(datediff(dd,removal_dt,rpt.dependency_dt)) asc) as row_num
		from base.rptPlacement  rpt
		join (select child,dependency_dt,count(*) as cnt 
				from base.rptPlacement 
				where dependency_dt is not null 
				group by child,dependency_dt having count(*) > 1
				) q
		on rpt.child=q.child  and rpt.dependency_dt=q.dependency_dt
		) qry on qry.id_removal_episode_fact=rpt.id_removal_episode_fact
			and qry.row_num > 1;
		

					
	
		update rpt
		set dependency_dt=q.petition_date,fl_dep_exist=1
		--select rpt.child,rpt.removal_dt,rpt.discharge_dt,q.days_frm_state_custody,q.petition_date as petition_dependency_date
		from base.rptPlacement  rpt
		join   (
					select FAMLINKID
						,Petition_date
						,min(abs(datediff(dd,aoc.Petition_date,tce.removal_dt)) )as days_frm_state_custody
						from AOC.aoc_petition aoc
						join base.rptPlacement  tce on tce.child=aoc.FAMLINKID
						left join (select child,dependency_dt 
								from base.rptPlacement where dependency_dt is not null) usd
							on usd.child=aoc.FAMLINKID
								and usd.dependency_dt=aoc.petition_date
						where
						 usd.dependency_dt is null
						and abs(datediff(dd,aoc.Petition_date,tce.removal_dt)) <=365
						and aoc.Petition_date < tce.removal_dt
						and petition ='DEPENDENCY PETITION' 
						group by FAMLINKID,Petition_date
						) q on q.FAMLINKID=rpt.child 
						and abs(datediff(dd,q.Petition_date,rpt.removal_dt)) =q.days_frm_state_custody
						and q.Petition_date < rpt.removal_dt
		left join (select child,dependency_dt 
					from base.rptPlacement  
					where dependency_dt is not null) usd
							on usd.child=rpt.child
								and usd.dependency_dt=rpt.dependency_dt
		where usd.child is null and 
		  rpt.dependency_dt is null
		
			update rpt
			set bin_dep_cd=  null
			from base.rptPlacement rpt


			update rpt
			set bin_dep_cd=  ref.bin_dep_cd
			from base.rptPlacement rpt
				join dbo.[ref_filter_dependency] ref
			on  coalesce(dependency_dt,removal_dt) between dateadd(dd,diff_days_from,removal_dt)
					and dateadd(dd,diff_days_thru,removal_dt)
					and ref.fl_dep_exist=rpt.fl_dep_exist


		update tce
		set  exit_within_month_mult3=
			case when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 3 then 3
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 6 then 6
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 9 then 9
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 12 then 12
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 15 then 15
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 18 then 18
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 21then 21
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 24 then 24
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 27 then 27
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 30 then 30
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 33 then 33
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 36 then 36
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 39 then 39
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 42 then 42
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 45 then 45
				 when dbo.fnc_datediff_mos(removal_dt,discharge_dt) < 48 then 48
			end
		from   base.rptPlacement tce

		
		update tce
		set nxt_reentry_within_min_month_mult3= 
			case when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 3 then 3
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 6 then 6
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 9 then 9
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 12 then 12
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 15 then 15
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 18 then 18
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 21then 21
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 24 then 24
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 27 then 27
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 30 then 30
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 33 then 33
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 36 then 36
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 39 then 39
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 42 then 42
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 45 then 45
				 when dbo.fnc_datediff_mos(discharge_dt,next_reentry_date) < 48 then 48
			end
			from   base.rptPlacement tce

			
update rpt
set  filter_service_category =  coalesce(q.filter_service_category,power(10.0,16))
from base.rptPlacement rpt 
left join (
select rpt.id_removal_episode_fact, power(10.0,16) + cast((
	  (max(coalesce(fl_family_focused_services,0)) * power(10.0,15))
	+  (max(coalesce(fl_child_care,0)) * power(10.0,14))
	+  (max(coalesce(fl_therapeutic_services,0)) * power(10.0,13))
	+  (max(coalesce(fl_mh_services,0)) * power(10.0,12))
	+  (max(coalesce(fl_receiving_care,0)) * power(10.0,11))
	+  (max(coalesce(fl_family_home_placements,0)) * power(10.0,10))
	+  (max(coalesce(fl_behavioral_rehabiliation_services,0)) * power(10.0,9))
	+  (max(coalesce(fl_other_therapeutic_living_situations,0)) * power(10.0,8))
	+  (max(coalesce(fl_specialty_adolescent_services,0)) * power(10.0,7))
	+  (max(coalesce(fl_respite,0)) * power(10.0,6))
	+  (max(coalesce(fl_transportation,0)) * power(10.0,5))
	+  (max(coalesce(fl_clothing_incidentals,0)) * power(10.0,4))
	+  (max(coalesce(fl_sexually_aggressive_youth,0)) * power(10.0,3))
	+  (max(coalesce(fl_adoption_support,0)) * power(10.0,2)
	+  (max(coalesce(fl_various,0)) * power(10.0,1))
	+  (max(coalesce(fl_medical,0))))) as decimal(18,0)) as filter_service_category
from base.rptPlacement rpt
 join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=rpt.id_removal_episode_fact
 group by rpt.id_removal_episode_fact ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact


 update rpt
set  filter_service_budget =  coalesce(q.filter_service_budget,power(10.0,7))
from base.rptPlacement rpt 
left join (
select rpt.id_removal_episode_fact, power(10.0,7) + cast((
	+  (max(coalesce(fl_budget_C12,0))  * power(10.0,6))
	+  (max(coalesce(fl_budget_C14,0))  * power(10.0,5))
	+  (max(coalesce(fl_budget_C15,0))  * power(10.0,4))
	+  (max(coalesce(fl_budget_C16,0))  * power(10.0,3))
	+  (max(coalesce(fl_budget_C18,0))  * power(10.0,2)
	+  (max(coalesce(fl_budget_C19,0))  * power(10.0,1))
	+  (max(coalesce(fl_uncat_svc,0)) ))) as decimal(7,0)) as filter_service_budget
from base.rptPlacement rpt
  join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=rpt.id_removal_episode_fact
 group by rpt.id_removal_episode_fact ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact



 update rpt
 set  [nbr_events]= cnt_events
 from   base.rptPlacement rpt 
 join (select e.id_removal_episode_fact,count(distinct e.id_placement_fact) as cnt_events
		from base.rptPlacement_Events  e
		group by e.id_removal_episode_fact
		) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact

 update rpt
 set  nbr_ooh_events= cnt_events
 from   base.rptPlacement rpt 
 join (select e.id_removal_episode_fact,count(distinct e.id_placement_fact) as cnt_events
		from base.rptPlacement_Events  e
		where CD_EPSD_TYPE=1
		group by e.id_removal_episode_fact
		) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact
		

update base.rptPlacement 
set bin_placement_cd= ref.bin_placement_cd
from ref_filter_nbr_placement ref
where nbr_ooh_events between ref.nbr_placement_from and ref.nbr_placement_thru

update base.rptPlacement 
set bin_placement_cd= ref.bin_placement_cd
from ref_filter_nbr_placement ref
where nbr_events between ref.nbr_placement_from and ref.nbr_placement_thru
and rptPlacement.bin_placement_cd is null



