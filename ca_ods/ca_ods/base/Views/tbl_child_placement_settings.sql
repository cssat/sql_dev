

CREATE VIEW [base].[tbl_child_placement_settings]
AS
SELECT
	PE.child [id_prsn_child]
	,PE.id_calendar_dim_begin [entry_date_int]
	,PE.id_calendar_dim_end [exit_date_int]
	,PE.begin_date [entry_date]
	,dbo.IntDate_to_CalDate(PE.id_calendar_dim_end) [exit_date]
	,LD.CD_CNTY [removal_county_cd]
	,LD.TX_CNTY [removal_county]
	,COALESCE(PD.CD_PHYS_COUNTY, -99) [placement_provider_caregiver_county_code]
	,CASE WHEN PD.TX_PHYS_COUNTY = 'Failed' THEN '-' ELSE PD.TX_PHYS_COUNTY END [placement_provider_caregiver_county]
	,PF.ID_PROVIDER_DIM_CAREGIVER [placement_provider_caregiver_id]
	,PE.cd_plcm_setng [placement_setting_type_code]
	,PE.tx_plcm_setng [placement_setting_type]
	,PE.cd_epsd_type
	,PTD.TX_EPSD_TYPE [tx_epsd_type]
	,PE.cd_end_rsn [placement_end_reason_code]
	,PE.tx_end_rsn [placement_end_reason]
	,DRD.CD_DSCH_RSN [placement_discharge_reason_code]
	,DRD.TX_DSCH_RSN [placement_discharge_reason]
	,PCAD.CD_PLACEMENT_CARE_AUTH [placement_care_auth_cd]
	,CASE WHEN PCAD.CD_PLACEMENT_CARE_AUTH IS NULL THEN NULL ELSE PCAD.TX_PLACEMENT_CARE_AUTH END [placement_care_auth]
	,PCAD.CD_TRIBE [placement_care_auth_tribe_cd]
	,CASE WHEN PCAD.CD_TRIBE IS NULL THEN NULL ELSE PCAD.TX_TRIBE END [placement_care_auth_tribe]
	,CASE WHEN PE.cd_end_rsn IN (38, 39, 40) THEN 1 ELSE 0 END [trial_return_home_cd]
	,CONVERT(VARCHAR(1), CASE WHEN PE.cd_end_rsn IN (38, 39, 40) THEN 'Y' ELSE 'N' END) [trial_return_home]
	,CASE WHEN PE.cd_end_rsn IN (38, 39, 40) THEN PE.end_date ELSE NULL END [trh_begin_date]
	,CASE
		WHEN PE.cd_end_rsn IN (38, 39, 40) AND PE.discharge_dt IS NOT NULL AND PES.rank_desc = 1 AND PES.sub_rank = 1 AND PE.discharge_dt >= PE.end_date THEN PE.discharge_dt
		WHEN PE.cd_end_rsn IN (38, 39, 40) AND PE.discharge_dt IS NOT NULL AND PES.rank_desc = 1 AND PES.sub_rank = 1 AND PE.discharge_dt < PE.end_date THEN PE.end_date
		WHEN PE.cd_end_rsn IN (38, 39, 40) AND PES.rank_desc != 1 THEN COALESCE(PES.next_begin_date, PE.discharge_dt)
		ELSE NULL
	END [trh_end_date]
	,PE.cd_srvc
	,PE.tx_srvc
	,PE.id_plcmnt_evnt
	,PE.cd_plcmnt_evnt
	,PE.id_removal_episode_fact
	,PE.id_placement_fact
	,DATEDIFF(DAY, PE.begin_date, COALESCE(PE.end_date, dbo.cutoff_date())) + 1 [dur_days]
	,CASE WHEN DATEDIFF(DAY, PE.begin_date, COALESCE(PE.end_date, dbo.cutoff_date())) + 1 <= 7 THEN 1 ELSE 0 END [fl_dur_7]
	,CASE WHEN DATEDIFF(DAY, PE.begin_date, COALESCE(PE.end_date, dbo.cutoff_date())) + 1 <= 90 THEN 1 ELSE 0 END [fl_dur_90]
	,PES.plcm_rank
	,PES.plcm_total
	,OOH.plcm_ooh_rank
	,OOH.plcm_ooh_total
	,CASE WHEN REF.ID_CALENDAR_DIM_AFCARS_END IS NOT NULL THEN 1 ELSE 0 END [fl_close]
	,CASE WHEN OOH.plcm_ooh_rank_desc = 1 AND OOH.plcm_ooh_sub_rank = 1 THEN 1 ELSE 0 END [fl_lst_ooh_plcm]
	,CASE WHEN PES.rank_desc = 1 AND PES.sub_rank = 1 THEN 1 ELSE 0 END [fl_lst_plcm]
	,PE.id_case
	,PE.age_plcm_begin [child_age_plcm_begin]
	,PE.age_plcm_end [child_age_plcm_end]
	,CASE WHEN PES.plcm_rank = 1 AND PES.sub_rank = 1 THEN 1 ELSE 0 END [fl_frst_plcm_in_eps]
FROM base.rptPlacement_Events PE 
LEFT JOIN dbo.REMOVAL_EPISODE_FACT REF ON
	REF.ID_REMOVAL_EPISODE_FACT = PE.id_removal_episode_fact
LEFT JOIN dbo.PLACEMENT_FACT PF ON
	PF.ID_PLACEMENT_FACT = PE.id_placement_fact
LEFT JOIN dbo.LOCATION_DIM LD ON
	LD.ID_LOCATION_DIM = PF.ID_LOCATION_DIM_PLACEMENT
LEFT JOIN dbo.PROVIDER_DIM PD ON
	PD.ID_PROVIDER_DIM = PF.ID_PROVIDER_DIM_CAREGIVER
LEFT JOIN dbo.PLACEMENT_TYPE_DIM PTD ON
	PTD.ID_PLACEMENT_TYPE_DIM = PF.ID_PLACEMENT_TYPE_DIM
LEFT JOIN dbo.DISCHARGE_REASON_DIM DRD ON
	DRD.ID_DISCHARGE_REASON_DIM = PF.ID_PLACEMENT_DISCHARGE_REASON_DIM
LEFT JOIN dbo.PLACEMENT_CARE_AUTH_DIM PCAD ON
	PCAD.ID_PLACEMENT_CARE_AUTH_DIM = PF.ID_PLACEMENT_CARE_AUTH_DIM
		AND PF.ID_PLACEMENT_CARE_AUTH_DIM >= 1
		AND PCAD.IS_CURRENT = 1
LEFT JOIN (
	SELECT
		PE.id_removal_episode_fact
		,PE.id_placement_fact
		,PE.begin_date
		,PE.end_date
		,MIN(PER.next_begin_date) [next_begin_date]
		,MIN(PER.plcm_rank) [plcm_rank]
		,MAX(PER.rank_desc) [rank_desc]
		,RANK() OVER(PARTITION BY PE.id_removal_episode_fact, MIN(PER.plcm_rank) ORDER BY PE.begin_date, COALESCE(PE.end_date, '12/31/9999') DESC) [sub_rank]
		,COUNT(*) OVER(PARTITION BY PE.id_removal_episode_fact) [plcm_total]
	FROM base.rptPlacement_Events PE
	LEFT JOIN (
		SELECT
			PE.id_removal_episode_fact
			,PE.id_placement_fact
			,PE.begin_date
			,PE.end_date
			,RANK() OVER(PARTITION BY PE.id_removal_episode_fact ORDER BY PE.begin_date) [plcm_rank]
			,RANK() OVER(PARTITION BY PE.id_removal_episode_fact ORDER BY PE.begin_date DESC) [rank_desc]
			,LEAD(PE.begin_date, 1) OVER(PARTITION BY PE.id_removal_episode_fact ORDER BY PE.begin_date) [next_begin_date]
		FROM base.rptPlacement_Events PE
		WHERE 
			NOT EXISTS (
				SELECT
					*
				FROM base.rptPlacement_Events PEI
				WHERE
					PEI.id_removal_episode_fact = PE.id_removal_episode_fact
						AND PEI.id_placement_fact != PE.id_placement_fact
						AND PEI.begin_date <= PE.begin_date
						AND PEI.end_date >= PE.end_date
			)
	) PER ON
		PER.id_removal_episode_fact = PE.id_removal_episode_fact
			AND (PER.id_placement_fact = PE.id_placement_fact
				OR (PER.id_placement_fact != PE.id_placement_fact
					AND PER.begin_date <= PE.begin_date
					AND PER.end_date >= PE.end_date))
	GROUP BY
		PE.id_removal_episode_fact
		,PE.id_placement_fact
		,PE.begin_date
		,PE.end_date
) PES ON
	PES.id_removal_episode_fact = PE.id_removal_episode_fact
		AND PES.id_placement_fact = PE.id_placement_fact
		AND PES.begin_date = PE.begin_date
LEFT JOIN (
	SELECT
		PE.id_removal_episode_fact
		,PE.id_placement_fact
		,PE.begin_date
		,PE.end_date
		,MIN(PER.plcm_ooh_rank) [plcm_ooh_rank]
		,MAX(PER.plcm_ooh_rank_desc) [plcm_ooh_rank_desc]
		,RANK() OVER(PARTITION BY PE.id_removal_episode_fact, MIN(PER.plcm_ooh_rank) ORDER BY PE.begin_date, COALESCE(PE.end_date, '12/31/9999') DESC) [plcm_ooh_sub_rank]
		,COUNT(*) OVER(PARTITION BY PE.id_removal_episode_fact) [plcm_ooh_total]
	FROM base.rptPlacement_Events PE
	LEFT JOIN (
		SELECT
			PE.id_removal_episode_fact
			,PE.id_placement_fact
			,PE.begin_date
			,PE.end_date
			,RANK() OVER(PARTITION BY PE.id_removal_episode_fact ORDER BY PE.begin_date) [plcm_ooh_rank]
			,RANK() OVER(PARTITION BY PE.id_removal_episode_fact ORDER BY PE.begin_date DESC) [plcm_ooh_rank_desc]
		FROM base.rptPlacement_Events PE
		WHERE PE.cd_epsd_type = 1
			AND NOT EXISTS (
				SELECT
					*
				FROM base.rptPlacement_Events PEI
				WHERE PEI.cd_epsd_type = 1
					AND PEI.id_removal_episode_fact = PE.id_removal_episode_fact
					AND PEI.id_placement_fact != PE.id_placement_fact
					AND PEI.begin_date <= PE.begin_date
					AND PEI.end_date >= PE.end_date
			)
	) PER ON
		PER.id_removal_episode_fact = PE.id_removal_episode_fact
			AND (PER.id_placement_fact = PE.id_placement_fact
				OR (PER.id_placement_fact != PE.id_placement_fact
					AND PER.begin_date <= PE.begin_date
					AND PER.end_date >= PE.end_date))
	WHERE PE.cd_epsd_type = 1
	GROUP BY
		PE.id_removal_episode_fact
		,PE.id_placement_fact
		,PE.begin_date
		,PE.end_date
) OOH ON
	OOH.id_removal_episode_fact = PE.id_removal_episode_fact
		AND OOH.id_placement_fact = PE.id_placement_fact
		AND OOH.begin_date = PE.begin_date


