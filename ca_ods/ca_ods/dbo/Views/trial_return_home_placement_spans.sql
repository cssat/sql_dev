create view dbo.trial_return_home_placement_spans
as 
select  plc.id_case
			,plc.id_removal_episode_fact
			,plc.id_placement_fact
			,evt.removal_dt
			,evt.discharge_dt
			,plc.begin_date
			,plc.end_date
			,plc.cd_end_rsn
			,plc.tx_end_rsn
			,plc.end_date trh_begin_date
			,coalesce(plc.nxt_plcmnt_date,IIF(evt.discharge_dt>dateadd(yy,18,evt.birthdate) and dateadd(yy,18,evt.birthdate)  < cutoff_date
				,dateadd(yy,18,evt.birthdate) 
				,discharge_dt)) trh_end_date
			, row_number() over (partition by evt.id_removal_episode_fact order by evt.begin_date) plcm_sort
from base.rptPlacement_Events evt
join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
join (select id_case,id_removal_episode_fact,begin_date,end_date,id_placement_fact
			,cd_end_rsn
			,tx_end_rsn
			,id_prvd_org_caregiver
			,ROW_NUMBER() over (partition by  id_removal_episode_fact order by begin_date desc,datediff(dd,begin_date,end_date)desc) row_num
			,lead(begin_date) over (partition by id_removal_episode_fact order by begin_date asc) nxt_plcmnt_date
			from base.rptPlacement_Events
			where cd_epsd_type=1 and id_prvd_org_caregiver > 0
			) plc on plc.id_placement_fact=evt.id_placement_fact
 where evt.cd_end_rsn in (38,39,40) 


