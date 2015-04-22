



CREATE VIEW [dbo].[Cube_rptPlacement_Events_Fact]
AS
SELECT
	RPE.id_removal_episode_fact
	--,RPE.rmvl_seq
	,RPE.child
	,ISNULL(CPD.ID_PEOPLE_DIM, CPD2.ID_PEOPLE_DIM) [child_id_people_dim]
	--,RPE.birthdate
	--,RPE.tx_gndr
	--,RPE.[18bday]
	--,RPE.tx_braam_race
	--,RPE.tx_multirace
	--,RPE.id_case
	--,RPE.tx_region
	--,RPE.worker_region
	--,RPE.worker_office
	--,RPE.worker_unit
	,RPE.episode_los
	--,RPE.episode_los_grp
	--,RPE.removal_dt
	,CONVERT(INT, CONVERT(VARCHAR, RPE.removal_dt, 112)) [id_calendar_dim_removal]
	--,RPE.removal_year
	--,RPE.removal_sfy_name
	--,RPE.removal_cy_name
	--,RPE.discharge_dt
	,CONVERT(INT, CONVERT(VARCHAR, RPE.discharge_dt, 112)) [id_calendar_dim_discharge]
	--,RPE.discharge_year
	--,RPE.discharge_sfy_name
	--,RPE.discharge_cy_name
	--,RPE.exit_reason
	--,RPE.last_pca
	--,RPE.last_lgl_stat
	,RPE.id_epsd
	,RPE.id_prvd_org_caregiver
	,RPE.id_provider_dim_caregiver
	,RPE.id_bsns
	--,RPE.tx_provider_type
	--,RPE.current_prvd_status
	,RPE.id_ssps
	,RPE.id_calendar_dim_begin
	,IIF(RPE.id_calendar_dim_end = 0, 99991231, RPE.id_calendar_dim_end) [id_calendar_dim_end]
	,IIF(RPE.age_plcm_begin < -1, -99, IIF(RPE.age_plcm_begin = -1, 0, ISNULL(RPE.age_plcm_begin, -99))) [age_plcm_begin_id]
	,IIF(RPE.age_plcm_begin < -1, NULL, IIF(RPE.age_plcm_begin = -1, 0, RPE.age_plcm_begin)) [age_plcm_begin]
	--,RPE.begin_date
	--,RPE.begin_year
	--,RPE.begin_year_name
	--,RPE.begin_state_fiscal_year_name
	--,RPE.begin_month
	--,RPE.begin_month_name
	--,RPE.end_date
	--,RPE.end_year
	--,RPE.end_year_name
	--,RPE.end_state_fiscal_year_name
	--,RPE.end_month
	--,RPE.end_month_name
	,IIF(RPE.age_plcm_end < -1, -99, IIF(RPE.age_plcm_end = -1, 0, ISNULL(RPE.age_plcm_end, -99))) [age_plcm_end_id]
	,IIF(RPE.age_plcm_end < -1, NULL, IIF(RPE.age_plcm_end = -1, 0, RPE.age_plcm_end)) [age_plcm_end]
	,RPE.plcmnt_days
	--,RPE.tx_plcm_setng
	--,RPE.tx_srvc
	--,RPE.tx_srvc_ctgry
	--,RPE.tx_subctgry
	--,RPE.tx_end_rsn
	--,RPE.plcmnt_type
	--,RPE.post_brs
	,RPE.brs_id
	--,RPE.brs_nm
	--,RPE.brs_bsns
	--,RPE.brs_srvc
	--,RPE.brs_srvc_ctgry
	--,RPE.brs_subctgry
	--,RPE.brs_plcm_setng
	,RPE.brs_plcmnt_days
	,RPE.days_from_rmvl
	,RPE.days_to_dsch
	--,RPE.plcmnt_seq
	--,RPE.days_to_dsch_grp
	--,RPE.days_from_rmvl_grp
	--,RPE.cd_plcm_setng
	--,RPE.rundate
	--,RPE.primary_plan
	--,RPE.alt_plan
	,RPE.id_placement_fact
	--,RPE.cd_srvc
	--,RPE.id_plcmnt_evnt
	--,RPE.cd_plcmnt_evnt
	--,RPE.prtl_cd_plcm_setng
	--,RPE.cd_epsd_type
	--,RPE.cd_end_rsn
	--,RPE.derived_county
	,IIF(RPE.id_calendar_dim_end = 0, 0, 1) [fl_exited]
	,RPF.age_at_removal_mos_id
	,RPF.age_at_exit_mos_id
	,RPF.id_calendar_dim_afcars_end
	,RPF.placement_worker_dim_id
	,RPF.placement_worker_location
	,RPF.primary_worker_dim_id
	,RPF.primary_worker_location
	,RPF.dad_people_dim_id
	,RPF.mom_people_dim_id
	,RPF.id_calendar_dim_discharge_force18
FROM base.rptPlacement_Events RPE
LEFT JOIN dbo.Cube_rptPlacement_Fact RPF ON
	RPF.id_removal_episode_fact = RPE.id_removal_episode_fact
LEFT JOIN dbo.PEOPLE_DIM CPD ON
	CPD.ID_PRSN = RPE.child
		AND CPD.DT_ROW_BEGIN <= RPE.begin_date
		AND CPD.DT_ROW_END >= RPE.begin_date
LEFT JOIN (
	SELECT
		RPE.id_placement_fact
		,PD.ID_PEOPLE_DIM
		,ROW_NUMBER() OVER(PARTITION BY RPE.id_placement_fact ORDER BY PD.DT_ROW_BEGIN) [closeness_rank]
	FROM
		base.rptPlacement_Events RPE
		INNER JOIN dbo.PEOPLE_DIM PD ON
			PD.ID_PRSN = RPE.child
				AND (RPE.begin_date <= PD.DT_ROW_BEGIN
						OR RPE.begin_date >= PD.DT_ROW_END)
	WHERE NOT EXISTS(
		SELECT
			*
		FROM dbo.PEOPLE_DIM D
		WHERE D.ID_PRSN = RPE.child
			AND D.DT_ROW_BEGIN <= RPE.begin_date
			AND D.DT_ROW_END >= RPE.begin_date
	)
) CPD2 ON
	CPD2.id_placement_fact = RPE.id_placement_fact
		AND CPD2.closeness_rank = 1
WHERE NOT EXISTS(
	SELECT
		*
	FROM dbo.vw_nondcfs_combine_adjacent_segments NCAS
	INNER JOIN dbo.CALENDAR_DIM CD ON
		CD.CALENDAR_DATE >= NCAS.cust_begin
			AND CD.CALENDAR_DATE <= NCAS.cust_end
	INNER JOIN base.rptPlacement RP ON
		NCAS.id_prsn = RP.child
			AND (CD.ID_CALENDAR_DIM = RP.id_calendar_dim_begin
				OR CD.ID_CALENDAR_DIM = RP.id_calendar_dim_afcars_end)
	WHERE RP.id_removal_episode_fact = RPE.id_removal_episode_fact
)




