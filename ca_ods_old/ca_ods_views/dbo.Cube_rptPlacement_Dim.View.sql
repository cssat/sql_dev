USE [CA_ODS]
GO
/****** Object:  View [dbo].[Cube_rptPlacement_Dim]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Cube_rptPlacement_Dim]
AS
SELECT
	RP.id_placement_fact
	--,RP.id_removal_episode_fact
	,RP.child
	,RP.id_case
	,RP.cd_region
	,RP.tx_region
	,RP.cd_office
	,RP.tx_office
	,RP.cd_county
	,RP.tx_county
	--,RP.primary_worker
	--,RP.worker_unit
	--,RP.cd_worker_region
	--,RP.worker_region
	--,RP.cd_worker_office
	--,RP.worker_office
	--,RP.cd_worker_county
	--,RP.worker_county
	,RP.episode_los_grp
	,RP.placement_los_grp
	,RP.removal_dt
	,RP.id_calendar_dim_begin
	,RP.id_epsd
	,RP.latest_plcmnt_dt
	,RP.latest_plcmnt_end_dt
	,RP.last_end_rsn
	,RP.id_prvd_org_caregiver
	,RP.discharge_dt
	,RP.id_calendar_dim_afcars_end
	,RP.cd_epsd_type
	,RP.tx_epsd_type
	,RP.birthdate
	,RP.[18bday]
	,RP.child_age
	,RP.tx_braam_race
	,RP.setting
	,RP.tx_subctgry
	,RP.relative
	,RP.cd_rel
	,RP.tx_rel
	,RP.current_setting
	,RP.current_service
	,RP.removal
	,RP.[exit]
	,RP.exit_reason
	,RP.tx_lgl_stat
	,RP.tx_plcm_dsch_rsn
	,RP.tx_dsch_rsn
	,RP.trh
	,RP.ts_up
	,RP.runtime
	,COALESCE(RP.mom_id, -99) [mom_id]
	,COALESCE(RP.dad_id, -99) [dad_id]
	,RP.placement_worker_id
	,RP.placement_worker_region_cd
	,RP.placement_worker_region
	,RP.placement_worker_office_cd
	,RP.placement_worker_office
	,RP.placement_worker_county_cd
	,RP.placement_worker_county
	,RP.placement_worker_unit
	,RP.placement_workerint_level
	,RP.placement_workerint_reason
	,RP.town
	,RP.zip
	,RP.cd_cnty
	,RP.staddress_type
	,RP.town_type
	,RP.zip_type
	,RP.cnty_type
	,RP.state
	--,RP.fl_abandonment
	--,RP.fl_caretaker_inability_cope
	--,RP.fl_child_abuse_alcohol
	--,RP.fl_child_abuses_drug
	--,RP.fl_child_behavior_problems
	--,RP.fl_inadequate_housng
	--,RP.fl_neglect
	--,RP.fl_parent_abuse_alcohol
	--,RP.fl_parent_death
	--,RP.fl_parent_drug_abuse
	--,RP.fl_parent_incarceration
	--,RP.fl_physical_abuse
	--,RP.fl_sex_abuse
	--,RP.fl_relinquishment
	,RP.cd_primary_ppln
	,RP.primary_ppln
	,RP.cd_alt_ppln
	,RP.alt_ppln
	,RP.lf_dt
	,RP.multi_race_mask
	,RP.tx_multirace
	,RP.cd_hspnc
	,RP.tx_hspnc
	,RP.tx_tribe_name
	,RP.[re-entry]
	--,RP.fl_false
	,RP.dt_case_cls
	,RP.[h&s]
	,RP.visit_span
	--,RP.vpa_lngth
	,RP.cd_rmvl_mnr
	,RP.tx_rmvl_mnr
	,RP.cd_placement_care_auth
	,RP.tx_placement_care_auth
	,RP.orig_cd_plcm_dsch_rsn
	,RP.orig_tx_plcm_dsch_rsn
	--,RP.fl_child_clinically_diagnosed
	,RP.dependency_dt
	--,RP.fl_dep_exist
	,RP.id_intake_fact
	,RP.age_at_removal_mos
	,RP.first_removal_dt
	,RP.latest_removal_dt
	,RP.child_eps_rank
	--,RP.child_cnt_episodes
	,RP.cd_race_census
	,RP.census_hispanic_latino_origin_cd
	,RP.initial_id_placement_fact
	,RP.longest_id_placement_fact
	,RP.next_reentry_date
	--,RP.days_to_reentry
	,RP.cd_discharge_type
	,ISNULL(RP.max_bin_los_cd, -99) [max_bin_los_cd]
	,RP.bin_dep_cd
	,RP.bin_ihs_svc_cd
	--,RP.dur_days
	,RP.exit_within_month_mult3
	,RP.nxt_reentry_within_min_month_mult3
	--,RP.nbr_events
	,RP.bin_placement_cd
	--,RP.nbr_ooh_events
	,RP.init_cd_plcm_setng
	,RP.cd_gndr
	,RP.tx_gndr
FROM base.rptPlacement RP
WHERE NOT EXISTS(
	SELECT
		*
	FROM dbo.vw_nondcfs_combine_adjacent_segments NCAS
	INNER JOIN dbo.CALENDAR_DIM CD ON
		CD.CALENDAR_DATE >= NCAS.cust_begin
			AND CD.CALENDAR_DATE <= NCAS.cust_end
	WHERE NCAS.id_prsn = RP.child
		AND (CD.ID_CALENDAR_DIM = RP.id_calendar_dim_begin
			OR CD.ID_CALENDAR_DIM = RP.id_calendar_dim_afcars_end)
)



GO
