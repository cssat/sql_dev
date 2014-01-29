USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_update_ref_match_ooh_parameters]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [prtl].[prod_update_ref_match_ooh_parameters]
as
update prm
set fl_in_tbl_child_episodes = 0
from dbo.ref_match_ooh_parameters prm
where fl_in_tbl_child_episodes <>0 or fl_in_tbl_child_episodes is null

update prm
set fl_in_tbl_child_episodes = 1
from base.tbl_child_episodes tce
join age_dim age on age.age_mo=tce.age_eps_begin_mos 
join dbo.ref_lookup_placement_event frstplc on frstplc.id_plcmnt_evnt=tce.init_id_plcmnt_evnt
join dbo.ref_lookup_placement_event longplc on longplc.id_plcmnt_evnt=tce.longest_id_plcmnt_evnt
join dbo.ref_lookup_ethnicity_census RC on RC.cd_race_census=tce.cd_race_census
join dbo.ref_lookup_gender G on G.CD_GNDR=tce.CD_GNDR
join dbo.ref_lookup_county cnty on cnty.County_Cd=tce.Removal_County_Cd
join dbo.ref_match_ooh_parameters prm on prm.age_grouping_cd=age.census_child_group_cd	
	and prm.match_cd_race_census=tce.cd_race_census
	and prm.match_cd_hispanic_latino_origin=tce.census_hispanic_latino_origin_cd
	and prm.match_pk_gndr=g.pk_gndr
	and prm.match_init_cd_plcm_setng=frstplc.cd_plcm_setng
	and prm.match_long_cd_plcm_setng=longplc.cd_plcm_setng
	and prm.match_county_cd=tce.Removal_County_Cd

							


-- now get the 'ALLS '
update prm
set fl_in_tbl_child_episodes = 1
from dbo.ref_match_ooh_parameters prm  
join dbo.ref_match_ooh_parameters prm2 on prm2.int_match_param_key=prm.int_match_param_key 
where prm.fl_in_tbl_child_episodes=0
and prm2.fl_in_tbl_child_episodes=1;
GO
