USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_child_episodes]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [base].[prod_update_tbl_child_episodes]
as 

declare @cutoff_date datetime
set @cutoff_date=(select cutoff_date from ref_last_dw_transfer);



update base.tbl_child_episodes
set dur_trh_days = 0

update base.tbl_child_episodes
set dur_trh_days =pl.trh_days
from (select id_Removal_episode_fact,sum(datediff(dd,trh_begin_date,isnull(trh_end_date,@cutoff_date)) + 1) as trh_days
		from base.tbl_child_placement_settings
		where trh_begin_date is not null
		group by id_Removal_episode_fact) pl 
where pl.id_Removal_episode_fact=tbl_child_episodes.id_Removal_episode_fact

update base.tbl_child_episodes
set longest_cd_plcmnt_evnt = null


update tce
set longest_cd_plcmnt_evnt=null,longest_id_plcmnt_evnt=null
	,dur_days_longest_plcm=null
from base.tbl_child_episodes tce

update tce
set longest_cd_plcmnt_evnt=pl.cd_plcmnt_evnt,longest_id_plcmnt_evnt=pl.id_plcmnt_evnt
	,dur_days_longest_plcm=pl.dur_days
from base.tbl_child_episodes tce
cross apply (select top 1 pl.id_Removal_episode_fact,cd_plcmnt_evnt,pl.id_plcmnt_evnt,pl.dur_days
			from base.tbl_child_placement_settings pl
			where pl.id_Removal_episode_fact=tce.id_Removal_episode_fact
				and pl.cd_epsd_type=1
			order  by id_Removal_episode_fact,dur_days desc) pl

update base.tbl_child_episodes 
set longest_id_plcmnt_evnt=14,
longest_cd_plcmnt_evnt='PUK'
where longest_cd_plcmnt_evnt is null


update base.tbl_child_episodes
set cnt_ooh_plcm = 0,cnt_plcm=0

update base.tbl_child_episodes
set cnt_ooh_plcm =pl.plcm_ooh_total,cnt_plcm=plcm_total
from (select distinct id_Removal_episode_fact,plcm_ooh_total,plcm_total
		from base.tbl_child_placement_settings
		--order by id_Removal_episode_fact
		) pl 
where pl.id_Removal_episode_fact=tbl_child_episodes.id_Removal_episode_fact


update base.tbl_child_episodes
set cnt_trh=q.cnt_trh
from (select id_removal_episode_fact,count(*) as cnt_trh
		from base.tbl_child_placement_settings
		where trial_return_home_cd=1
		group by id_removal_episode_fact) q 
		where q.id_removal_episode_Fact=tbl_child_episodes.id_removal_episode_Fact






delete from base.TBL_CHILD_PLACEMENT_SETTINGS where id_removal_episode_fact not in (select id_removal_episode_fact from base.TBL_CHILD_EPISODES)



GO
