


CREATE VIEW [dbo].[Cube_rptPlacement_Events_Dim]
AS
SELECT
	RPE.id_removal_episode_fact
	,RPE.rmvl_seq
	--,RPE.child
	,RPE.birthdate
	,RPE.tx_gndr
	,RPE.[18bday]
	,RPE.tx_braam_race
	,RPE.tx_multirace
	,RPE.id_case
	,RPE.tx_region
	,RPE.worker_region
	,RPE.worker_office
	,RPE.worker_unit
	,RPE.episode_los
	,RPE.episode_los_grp
	--,RPE.removal_dt
	--,RPE.removal_year
	--,RPE.removal_sfy_name
	--,RPE.removal_cy_name
	--,RPE.discharge_dt
	--,RPE.discharge_year
	--,RPE.discharge_sfy_name
	--,RPE.discharge_cy_name
	,RPE.exit_reason
	,RPE.last_pca
	,RPE.last_lgl_stat
	--,RPE.id_epsd
	--,RPE.id_prvd_org_caregiver
	--,RPE.id_bsns
	,RPE.tx_provider_type
	,RPE.current_prvd_status
	--,RPE.id_ssps
	--,RPE.id_calendar_dim_begin
	--,RPE.id_calendar_dim_end
	--,RPE.age_plcm_begin
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
	--,RPE.age_plcm_end
	,RPE.plcmnt_days
	,RPE.cd_plcm_setng
	,RPE.tx_plcm_setng
	,RPE.cd_srvc
	,RPE.tx_srvc
	,REPLACE(RPE.tx_srvc_ctgry, 'Inactive: ', '') [tx_srvc_ctgry]
	,RPE.tx_subctgry
	,RPE.cd_end_rsn
	,RPE.tx_end_rsn
	,RPE.plcmnt_type
	,RPE.plcmnt_seq
	,RPE.post_brs
	,RPE.brs_id
	,RPE.brs_nm
	,RPE.brs_bsns
	,RPE.brs_srvc
	,RPE.brs_srvc_ctgry
	,RPE.brs_subctgry
	,RPE.brs_plcm_setng
	,RPE.brs_plcmnt_days
	,RPE.days_to_dsch
	,RPE.days_to_dsch_grp
	,RPE.days_from_rmvl
	,RPE.days_from_rmvl_grp
	,RPE.rundate
	,RPE.primary_plan
	,RPE.alt_plan
	,RPE.id_placement_fact
	--,RPE.id_plcmnt_evnt
	,RPE.cd_plcmnt_evnt
	,RLPE.cd_plcmnt_evnt_desc
	,RPE.prtl_cd_plcm_setng
	,RLP.tx_plcm_setng [prtl_tx_plcm_setng]
	,RPE.cd_epsd_type
	,RPE.derived_county [exit_county_cd]
	,RLC.county_desc [exit_county_tx]
	,RLC.cd_region [exit_region_cd]
	,RLC.tx_region [exit_region_tx]
	,RLC.old_region_cd [exit_old_region_cd]
	,RLC.old_region_tx [exit_old_region_tx]
	--,RPE.id_provider_dim_caregiver
FROM base.rptPlacement_Events RPE
LEFT JOIN dbo.ref_lookup_placement_event RLPE ON
	RLPE.id_plcmnt_evnt = RPE.id_plcmnt_evnt
LEFT JOIN dbo.ref_lookup_plcmnt RLP ON
	RLP.cd_plcm_setng = RPE.prtl_cd_plcm_setng
LEFT JOIN (
	SELECT
		RLC.county_cd
		,RLC.county_desc
		,RLC.cd_region
		,LD.TX_REGION [tx_region]
		,RLC.old_region_cd
		,LD.TX_REGION [old_region_tx]
	FROM dbo.ref_lookup_county RLC
	LEFT JOIN dbo.LOCATION_DIM LD ON
		LD.CD_REGION = RLC.cd_region
			AND LD.IS_CURRENT = 1
	LEFT JOIN dbo.LOCATION_DIM OLD ON
		OLD.CD_REGION = RLC.old_region_cd
			AND LD.IS_CURRENT = 1
	GROUP BY
		RLC.county_cd
		,RLC.county_desc
		,RLC.cd_region
		,LD.TX_REGION
		,RLC.old_region_cd
		,LD.TX_REGION
) RLC ON
	RLC.county_cd = RPE.derived_county
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



