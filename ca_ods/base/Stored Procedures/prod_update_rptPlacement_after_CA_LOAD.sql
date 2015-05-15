
create procedure [base].[prod_update_rptPlacement_after_CA_LOAD]
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
		
		update base.rptPlacement_events
		set [18bday]=dateadd(yy,18,birthdate);

		update base.rptPlacement
		set [18bday]=dateadd(yy,18,birthdate);
		
		update base.rptPlacement_Events
		set id_placement_fact = pf.id_placement_fact
			,id_provider_dim_caregiver=pf.id_provider_dim_caregiver
		from placement_fact pf
		where pf.ID_REMOVAL_EPISODE_FACT=rptPlacement_Events.ID_REMOVAL_EPISODE_FACT
		and pf.ID_CALENDAR_DIM_BEGIN=rptPlacement_Events.id_calendar_dim_begin
		and pf.ID_CALENDAR_DIM_END=rptPlacement_Events.id_calendar_dim_end
		and pf.ID_EPSD=rptPlacement_Events.id_epsd;

		update base.rptPlacement_Events
		set cd_plcm_setng=ptd.cd_plcm_setng,tx_plcm_setng=ptd.TX_PLCM_SETNG
		from placement_fact pf
		join PLACEMENT_TYPE_DIM ptd on  ptd.ID_PLACEMENT_TYPE_DIM=pf.ID_PLACEMENT_TYPE_DIM
		where pf.ID_PLACEMENT_FACT=rptPlacement_Events.id_placement_fact
		and rptPlacement_Events.cd_plcm_setng is null;
		
		update base.rptPlacement
		set removal_county_cd = iif(cd_cnty=41,40,cd_cnty) -- 41 = CONVERSION, 40 = Other/Out of State

		--update rptPlacement
		--set removal_county_cd=cnty.county_cd
		-- from base.rptPlacement 
		--  join [dbCoreAdministrativeTables].[geog].[zip_boundaries_wa] zb2 on  zb2.zip=rptPlacement.zip --eft(rptPlacement.zip,3)
		--  join ref_lookup_county cnty on cnty.countyfips=zb2.countyfips

		--  update rptPlacement
		--set removal_county_cd=cnty.county_cd
		-- from base.rptPlacement 
		--  join [dbCoreAdministrativeTables].[geog].[zip_boundaries_wa] zb2 on  zb2.s3dzip=left(rptPlacement.zip,3)
		--  join ref_lookup_county cnty on cnty.countyfips=zb2.countyfips
		--  where removal_county_cd is null
			
		--update eps
		--set eps.removal_county_cd=cnty.county_cd
		--from base.rptPlacement eps
		--left join (
		--	select lrd.cd_result,lrd.tx_result,replace(ljd.tx_jurisdiction,'County','') tx_jurisdiction,dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) as eff_dt ,child,id_removal_episode_fact,removal_dt,discharge_dt
		--	, ROW_NUMBER() over ( partition by id_removal_episode_fact order by id_removal_episode_fact,dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) asc) as row_num
		--	from base.rptPlacement tce
		--	left join dbo.legal_fact lf on tce.id_case=lf.id_case and tce.child=lf.id_prsn 
		--		and dbo.IntDate_to_CalDate(lf.id_calendar_dim_effective) between dateadd(dd,-30,removal_dt) and isnull(discharge_dt,'12/31/3999')
		--	left join dbo.legal_result_dim lrd on lf.id_legal_result_dim=lrd.id_legal_result_dim
		--	left join dbo.legal_jurisdiction_dim ljd on ljd.id_legal_jurisdiction_dim=lf.id_legal_jurisdiction_dim
		--	where tce.removal_county_cd is null
		--	and  ljd.tx_jurisdiction <> '-'
		--		) q 
		--		on q.id_removal_episode_fact=eps.id_removal_episode_fact
		--				and q.row_num=1
		--		join ref_lookup_county cnty on cnty.county_desc=replace(tx_jurisdiction,'County','')
		--	where eps.removal_county_cd is null

		update  base.rptplacement_events
		set  derived_county =null

		update evt
		set  derived_county = ( case when pd2.CD_PHYS_COUNTY between 1 and 39 then pd2.CD_PHYS_COUNTY 
														when pd.CD_PHYS_COUNTY  between 1 and 39 then pd.CD_PHYS_COUNTY 
														when   wd.CD_CNTY between 1 and 39 then wd.cd_cnty else  -99 end)
		from base.rptplacement_events  evt
		join PLACEMENT_FACT pf on pf.ID_PLACEMENT_FACT=evt.id_placement_fact
		join PROVIDER_DIM pd on pf.ID_PROVIDER_DIM_CAREGIVER =pd.ID_PROVIDER_DIM
		left join provider_dim pd2 on pd2.ID_PRVD_ORG=evt.id_prvd_org_caregiver and evt.begin_date between pd2.DT_ROW_BEGIN and pd2.DT_ROW_END
		--join LOCATION_DIM ld on ld.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_PLACEMENT
		join LOCATION_DIM wd on wd.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_WORKER

		--update eps  
		--set eps.removal_county_cd=derived_county
		--from  base.rptPlacement  eps
		--join base.rptPlacement_Events evt on eps.id_removal_episode_fact=evt.id_removal_episode_fact and evt.plcmnt_seq=1
		--where eps.removal_county_cd is null

		
		update base.rptPlacement_Events
		set cd_end_rsn = prd.cd_end_rsn
		from PLACEMENT_RESULT_DIM prd 
		where prd.TX_END_RSN=base.rptPlacement_Events.tx_end_rsn

		

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
					set cd_plcmnt_evnt=plc.cd_plcmnt_evnt
					,prtl_cd_plcm_setng=plc.cd_plcm_setng
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
		join (select child,id_removal_episode_fact, removal_dt
			,ROW_NUMBER() over (partition by child order by removal_dt,discharge_dt) as child_eps_rank 
			from base.rptPlacement
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
				when discharge_dt ='12/31/9999'  then xSC.cd_discharge_type
			else 6 end,
			discharge_dt=case when (case when xw.cd_discharge_type is not null then xw.cd_discharge_type
				when xwExitRsn.cd_discharge_type is not null then xwExitRsn.cd_discharge_type
				when xwLastEndRsn.cd_discharge_type is not null then xwLastEndRsn.cd_discharge_type
				when xwE.cd_discharge_type is not null then xwE.cd_discharge_type
				when discharge_dt is null then xSC.cd_discharge_type
			else 6 end )=5 and dateadd(yy,18,birthdate) >=removal_dt then dbo.lessorDate(dateadd(yy,18,birthdate),(dw.cutoff_date)) else rpt.discharge_dt end
		from base.rptPlacement rpt
		join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
			left join [dbo].[ref_state_discharge_xwalk]  xw  on rpt.tx_dsch_rsn=xw.tx_dsch_rsn and discharge_dt is not null
			left join [dbo].[ref_state_discharge_xwalk]  xwLastEndRsn  on rpt.last_end_rsn=xw.tx_dsch_rsn  and discharge_dt is not null
			left join [dbo].[ref_state_discharge_xwalk]  xwExitRsn on rpt.exit_reason=xw.discharge_type  and discharge_dt is not null
			left join dbo.ref_state_discharge_xwalk xwE  
						on xwE.CD_DSCH_RSN=12   
							and dateadd(yy,18,birthdate) < (select cutoff_date from ref_last_dw_transfer)
												and  rpt.discharge_dt > getdate()
												and dateadd(yy,18,birthdate) >=removal_dt
			left join dbo.ref_state_discharge_xwalk xSC on xSC.state_discharge_reason_code=-99 -- still in care


			update rpt
			set dur_days=iif(discharge_dt <= cutoff_date ,  datediff(dd,removal_dt,discharge_dt) + 1,datediff(dd,removal_dt,cutoff_date) + 1)
			from base.rptPlacement rpt,ref_last_dw_transfer

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
		set dependency_dt=q.eff_date,fl_dep_exist=1
		--select id_prsn_child,tce.state_custody_start_date,tce.removal_dt,q.days_frm_state_custody,q.petition_date as petition_dependency_date
		from base.rptPlacement TCE
		join (			select distinct id_removal_episode_fact
							,FAMLINKID
							,removal_dt
							,discharge_dt
							,dateadd(dd,79,aoc.petition_date) [eff_date]
							,dependency_dt
							,datediff(dd,tce.removal_dt,dateadd(dd,79,aoc.Petition_date)) as days_frm_state_custody
							,row_number() over (partition by child ,removal_dt
									order by datediff(dd,tce.removal_dt,dateadd(dd,79,aoc.petition_date))  asc) as row_num
						from aoc.aoc_petition aoc
						join base.rptPlacement  tce on 
						 tce.child=aoc.FAMLINKID
							and dateadd(dd,79,aoc.petition_date) >= dateadd(dd,-79,dateadd(yy,-1,tce.removal_dt ))
									and dateadd(dd,79,aoc.petition_date) < isnull(tce.discharge_dt,(select cutoff_date from ref_last_dw_transfer))
						and petition ='DEPENDENCY PETITION' 
				) q on q.id_removal_episode_fact=tce.id_removal_episode_fact  
					and q.row_num=1
		-- update those with same child 
		-- , same dependency date keeping the smallest date difference from removal
		--  for dependency date
		-- and updating the dates with the larger spans to null
		update rpt
		set dependency_dt=null,fl_dep_exist=0
		from  base.rptPlacement  rpt 
		join (
		select id_removal_episode_fact 
				, rpt.child
				, rpt.dependency_dt 
				,removal_dt
				,ROW_NUMBER() over (partition by rpt.child 
							order by abs(datediff(dd,removal_dt,rpt.dependency_dt)) asc) as row_num
		from base.rptPlacement  rpt
		join (select child,dependency_dt,count(*) as cnt 
				from base.rptPlacement 
				where dependency_dt is not null 
				group by child,dependency_dt having count(*) > 1
				) q
		on rpt.child=q.child  and rpt.dependency_dt=q.dependency_dt
		) qry on qry.id_removal_episode_fact=rpt.id_removal_episode_fact
			and qry.row_num > 1;
					
	  -- now get any that are in legal fact
	   	update rpt
		set dependency_dt=eff_dt,fl_dep_exist=1
		from  base.rptPlacement  rpt 
		join vw_dependency_legal_fact dlf on dlf.id_removal_episode_fact=rpt.id_removal_episode_fact
			and dlf.filter_by_closest=1
	   where rpt.dependency_dt is null;


			update rpt
			set bin_dep_cd=  null
			from base.rptPlacement rpt


			update rptPlacement
		set dependency_dt=null,fl_dep_exist=0
		from base.rptPlacement 
		where fl_dep_exist=1 and bin_dep_cd is null and dependency_dt < removal_dt

	
			update rpt
			set bin_dep_cd=  ref.bin_dep_cd
			from base.rptPlacement rpt
				join dbo.[ref_filter_dependency] ref
			on  coalesce(dependency_dt,removal_dt) between dateadd(dd,diff_days_from,removal_dt)
					and dateadd(dd,diff_days_thru,removal_dt)
					and ref.fl_dep_exist=rpt.fl_dep_exist and rpt.bin_dep_cd is null



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
and ref.bin_placement_cd <>0

update base.rptPlacement 
set bin_placement_cd= ref.bin_placement_cd
from ref_filter_nbr_placement ref
where nbr_events between ref.nbr_placement_from and ref.nbr_placement_thru
and rptPlacement.bin_placement_cd = 0
and ref.bin_placement_cd <>0


update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_update_rptPlacement_after_CA_LOAD'




