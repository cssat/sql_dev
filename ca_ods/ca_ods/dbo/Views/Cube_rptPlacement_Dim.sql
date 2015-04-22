






CREATE VIEW [dbo].[Cube_rptPlacement_Dim]
AS
SELECT
	RP.id_placement_fact
	,RP.id_removal_episode_fact
	,RP.child
	,RP.id_case
	,ISNULL(RLC.cd_region, RP.cd_region) [cd_region]
	,IIF(ISNULL(RLC.cd_region, RP.cd_region) = 0, 'Failed', ISNULL(RLC.tx_region, RP.TX_REGION)) [tx_region]
	,ISNULL(RLC.old_region_cd, RP.cd_region) [cd_old_region]
	,IIF(ISNULL(RLC.old_region_cd, RP.cd_region) = 0, 'Failed', ISNULL(RLC.old_region_tx, RP.tx_region)) [tx_old_region]
	,RP.cd_office
	,RP.tx_office
	,IIF(ROD.cd_office_collapse = -99,
		CONVERT(INT, CONVERT(VARCHAR, ROD.cd_office_collapse) + CONVERT(VARCHAR, ABS(ISNULL(RLC.cd_region, RP.cd_region)))),
		ROD.cd_office_collapse
	) [cd_office_collapse]
	,IIF(ROD.cd_office_collapse = -99,
		ROD.tx_office_collapse + ' - ' + IIF(ISNULL(RLC.cd_region, RP.cd_region) = 0, 'Failed', ISNULL(RLC.tx_region, RP.tx_region)),
		ROD.tx_office_collapse
		) [tx_office_collapse]
	,RP.cd_county
	,RP.tx_county
	,ISNULL(IIF(RP.cd_county = 41, -89, CONVERT(INT, RCC.court_cd)), -99) [court_cd]
	,ISNULL(IIF(RP.cd_county = 41, 'CONVERSION', RCC.court), 'Unknown') [court]
	,IIF(RP.cd_cnty = 41, -99, ISNULL(RP.cd_cnty, -99)) [cd_removal_county]
	,IIF(RP.cd_cnty = 41, 'Unknown', ISNULL(RMVLLC.tx_county, 'Unknown')) [tx_removal_county]
	,IIF(RP.cd_cnty = 40, -99, ISNULL(RMVLLC.cd_region, 11)) [cd_removal_region]
	,IIF(RP.cd_cnty = 40, 'Unknown', ISNULL(RMVLLC.tx_region, 'CONVERSION')) [tx_removal_region]
	,IIF(RP.cd_cnty = 40, -99, ISNULL(RMVLLC.old_region_cd, 11)) [cd_old_removal_region]
	,IIF(RP.cd_cnty = 40, 'Unknown', ISNULL(RMVLLC.old_region_tx, 'CONVERSION')) [tx_old_removal_region]
	,RP.primary_worker
	,RP.worker_unit
	,ISNULL(WRLC.cd_region, RP.cd_worker_region) [cd_worker_region]
	,IIF(ISNULL(WRLC.cd_region, RP.cd_worker_region) = 0, 'Failed', ISNULL(WRLC.tx_region, RP.worker_region)) [worker_region]
	,ISNULL(WRLC.old_region_cd, RP.cd_worker_region) [cd_worker_old_region]
	,IIF(ISNULL(WRLC.old_region_cd, RP.cd_worker_region) = 0, 'Failed', ISNULL(WRLC.old_region_tx, RP.worker_region)) [worker_old_region]
	,IIF(RP.worker_office = 'Failed', -999, RP.cd_worker_office) [cd_worker_office]
	,RP.worker_office
	,IIF(WROD.cd_office_collapse = -99,
		CONVERT(INT, CONVERT(VARCHAR, WROD.cd_office_collapse) + CONVERT(VARCHAR, ABS(ISNULL(WRLC.cd_region, RP.cd_worker_region)))),
		WROD.cd_office_collapse
	) [cd_worker_office_collapse]
	,IIF(WROD.cd_office_collapse = -99,
		WROD.tx_office_collapse + ' - ' + IIF(ISNULL(WRLC.cd_region, RP.cd_worker_region) = 0, 'Failed', ISNULL(WRLC.tx_region, RP.worker_region)),
		WROD.tx_office_collapse
	) [worker_office_collapse]
	,IIF(RP.worker_county = 'Failed', -999, RP.cd_worker_county) [cd_worker_county]
	,RP.worker_county
	,ISNULL(IIF(RP.cd_worker_county = 41, -89, CONVERT(INT, WRCC.court_cd)), -99) [cd_worker_court]
	,ISNULL(IIF(RP.cd_worker_county = 41, 'CONVERSION', WRCC.court), 'Unknown') [worker_court]
	,RP.episode_los_grp
	,ISNULL(RP.placement_los_grp, 'Unspecified') [placement_los_grp]
	,RP.removal_dt
	,RP.id_calendar_dim_begin
	,RP.id_epsd
	,RP.latest_plcmnt_dt
	,RP.latest_plcmnt_end_dt
	,ISNULL(RP.last_end_rsn, '-') [last_end_rsn]
	,RP.id_prvd_org_caregiver
	,RP.discharge_dt
	,IIF(DATEADD(YEAR, 18, RP.birthdate) < RLDT.cutoff_date AND DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt) [discharge_dt_force_18]
	,RP.id_calendar_dim_afcars_end
	,RP.cd_epsd_type
	,RP.tx_epsd_type
	,RP.birthdate
	,RP.[18bday]
	,ISNULL(RP.child_age, -99) [child_age]
	,IIF(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)) < -12
		,-99
		,IIF(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)) < 0
			,0
			,ISNULL(dbo.fnc_datediff_mos(RP.birthdate, IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, DATEADD(YEAR, 18, RP.birthdate), RP.discharge_dt)), -99)
		)
	) [age_at_exit_mos]
	,RP.tx_braam_race
	,RP.setting
	,RP.tx_subctgry
	,RP.[relative]
	,RP.cd_rel
	,RP.tx_rel
	,IIF(RP.current_setting = 1, 'Yes', 'No') [current_setting]
	,RP.current_service
	,RP.removal
	,RP.[exit]
	,ISNULL(RP.exit_reason, 'Unspecified') [exit_reason]
	,LPD.derived_county [exit_county_cd]
	,LPD.county_desc [exit_county_tx]
	,ERLC.cd_region [exit_region_cd]
	,ERLC.tx_region [exit_region_tx]
	,ERLC.old_region_cd [exit_old_region_cd]
	,ERLC.old_region_tx [exit_old_region_tx]
	,ISNULL(RP.tx_lgl_stat, 'Unknown') [tx_lgl_stat]
	,ISNULL(RP.tx_plcm_dsch_rsn, 'Unspecified') [tx_plcm_dsch_rsn]
	,ISNULL(RP.tx_dsch_rsn, '-') [tx_dsch_rsn]
	,RP.trh
	,RP.ts_up
	,RP.runtime
	,ISNULL(RP.mom_id, -99) [mom_id]
	,ISNULL(RP.dad_id, -99) [dad_id]
	,RP.placement_worker_id
	,ISNULL(PWRLC.cd_region, RP.placement_worker_region_cd) [placement_worker_region_cd]
	,IIF(ISNULL(PWRLC.cd_region, RP.placement_worker_region_cd) = 0, 'Failed', ISNULL(PWRLC.tx_region, RP.placement_worker_region)) [placement_worker_region]
	,ISNULL(PWRLC.old_region_cd, RP.placement_worker_region_cd) [placement_worker_old_region_cd]
	,IIF(ISNULL(PWRLC.old_region_cd, RP.placement_worker_region_cd) = 0, 'Failed', ISNULL(PWRLC.old_region_tx, RP.placement_worker_region)) [placement_worker_old_region]
	,RP.placement_worker_office_cd
	,ISNULL(RP.placement_worker_office, '-') [placement_worker_office]
	,IIF(PWROD.cd_office_collapse = -99,
		CONVERT(INT, CONVERT(VARCHAR, PWROD.cd_office_collapse) + CONVERT(VARCHAR, ABS(ISNULL(PWRLC.cd_region, RP.placement_worker_region_cd)))),
		PWROD.cd_office_collapse
	) [placement_worker_office_collapse_cd]
	,IIF(PWROD.cd_office_collapse = -99,
		PWROD.tx_office_collapse + ' - ' + IIF(ISNULL(PWRLC.cd_region, RP.placement_worker_region_cd) = 0, 'Failed', ISNULL(PWRLC.tx_region, RP.placement_worker_region)),
		PWROD.tx_office_collapse
	) [placement_worker_office_collapse]
	,RP.placement_worker_county_cd
	,ISNULL(RP.placement_worker_county, '-') [placement_worker_county]
	,ISNULL(IIF(RP.placement_worker_county_cd = 41, -89, CONVERT(INT, PWRCC.court_cd)), -99) [placement_worker_court_cd]
	,ISNULL(IIF(RP.placement_worker_county_cd = 41, 'CONVERSION', PWRCC.court), 'Unknown') [placement_worker_court]
	,RP.placement_worker_unit
	,RP.placement_workerint_level
	,RP.placement_workerint_reason
	,ISNULL(RP.town, 'Unspecified') [town]
	,ISNULL(RP.zip, '0 0') [zip]
	,RP.staddress_type
	,RP.town_type
	,RP.zip_type
	,RP.cnty_type
	,ISNULL(RP.[state], 'XX') [state]
	,IIF(RP.fl_abandonment = 1, 'Yes', 'No') [fl_abandonment]
	,IIF(RP.fl_caretaker_inability_cope = 1, 'Yes', 'No') [fl_caretaker_inability_cope]
	,IIF(RP.fl_child_abuse_alcohol = 1, 'Yes', 'No') [fl_child_abuse_alcohol]
	,IIF(RP.fl_child_abuses_drug = 1, 'Yes', 'No') [fl_child_abuses_drug]
	,IIF(RP.fl_child_behavior_problems = 1, 'Yes', 'No') [fl_child_behavior_problems]
	,IIF(RP.fl_inadequate_housng = 1, 'Yes', 'No') [fl_inadequate_housng]
	,IIF(RP.fl_neglect = 1, 'Yes', 'No') [fl_neglect]
	,IIF(RP.fl_parent_abuse_alcohol = 1, 'Yes', 'No') [fl_parent_abuse_alcohol]
	,IIF(RP.fl_parent_death = 1, 'Yes', 'No') [fl_parent_death]
	,IIF(RP.fl_parent_drug_abuse = 1, 'Yes', 'No') [fl_parent_drug_abuse]
	,IIF(RP.fl_parent_incarceration = 1, 'Yes', 'No') [fl_parent_incarceration]
	,IIF(RP.fl_physical_abuse = 1, 'Yes', 'No') [fl_physical_abuse]
	,IIF(RP.fl_sex_abuse = 1, 'Yes', 'No') [fl_sex_abuse]
	,IIF(RP.fl_relinquishment = 1, 'Yes', 'No') [fl_relinquishment]
	,ISNULL(RP.cd_primary_ppln, -99) [cd_primary_ppln]
	,ISNULL(RP.primary_ppln, 'Unspecified') [primary_ppln]
	,ISNULL(RP.cd_alt_ppln, -99) [cd_alt_ppln]
	,ISNULL(RP.alt_ppln, 'Unspecified') [alt_ppln]
	,RP.lf_dt
	,RP.multi_race_mask
	,RP.tx_multirace
	,ISNULL(RP.cd_hspnc, '-') [cd_hspnc]
	,RP.tx_hspnc
	,ISNULL(RP.tx_tribe_name, '-') [tx_tribe_name]
	,RP.[re-entry]
	--,RP.fl_false
	,RP.dt_case_cls
	,RP.[h&s]
	,RP.visit_span
	--,RP.vpa_lngth
	,RP.cd_rmvl_mnr
	,RP.tx_rmvl_mnr
	,ISNULL(RP.cd_placement_care_auth, -99) [cd_placement_care_auth]
	,ISNULL(RP.tx_placement_care_auth, 'Unspecified') [tx_placement_care_auth]
	,ISNULL(RP.orig_cd_plcm_dsch_rsn, -99) [orig_cd_plcm_dsch_rsn]
	,ISNULL(RP.orig_tx_plcm_dsch_rsn, 'Unspecified') [orig_tx_plcm_dsch_rsn]
	,IIF(RP.fl_child_clinically_diagnosed = 1, 'Yes', 'No') [fl_child_clinically_diagnosed]
	,RP.dependency_dt
	,IIF(RP.fl_dep_exist = 1, 'Yes', 'No') [fl_dep_exist]
	,RP.id_intake_fact
	,ISNULL(RP.age_at_removal_mos, -99) [age_at_removal_mos]
	,RP.first_removal_dt
	,RP.latest_removal_dt
	,RP.child_eps_rank
	--,RP.child_cnt_episodes
	,RP.cd_race_census
	,RLEC.tx_race_census
	,RP.census_hispanic_latino_origin_cd
	,RLHLC.census_hispanic_latino_origin
	,RP.initial_id_placement_fact
	,RP.longest_id_placement_fact
	,RP.next_reentry_date
	--,RP.days_to_reentry
	,IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, SDX.def_cd_discharge_type, RP.cd_discharge_type) [cd_discharge_type] -- use the code for Emancipated if the child turned 18 before the federal discharge date
	,IIF(DATEADD(YEAR, 18, RP.birthdate) < RP.discharge_dt, SDX.def_tx_discharge_type, SDX.tx_discharge_type) [tx_discharge_type] -- use the code for Emancipated if the child turned 18 before the federal discharge date
	,ISNULL(RP.max_bin_los_cd, 0) [max_bin_los_cd]
	,RFLOS.bin_los_desc
	,RP.bin_dep_cd
	,RFD.bin_dep_desc
	,RP.bin_ihs_svc_cd
	,RFIHS.bin_ihs_svc_tx
	--,RP.dur_days
	,ISNULL(RP.exit_within_month_mult3, -99) [exit_within_month_mult3]
	,ISNULL(RP.nxt_reentry_within_min_month_mult3, -99) [nxt_reentry_within_min_month_mult3]
	--,RP.nbr_events
	,RP.bin_placement_cd
	,RFNP.bin_placement_desc
	--,RP.nbr_ooh_events
	,RP.init_cd_plcm_setng
	,RLPI.tx_plcm_setng [init_tx_plcm_setng]
	,RP.long_cd_plcm_setng
	,RLPL.tx_plcm_setng [long_tx_plcm_setng]
	,ISNULL(RP.cd_gndr, '-') [cd_gndr]
	,RP.tx_gndr
FROM base.rptPlacement RP
LEFT JOIN (
	SELECT
		RLC.county_cd
		,RLC.county_desc [tx_county]
		,RLC.cd_region
		,LD.TX_REGION [tx_region]
		,RLC.old_region_cd
		,OLD.TX_REGION [old_region_tx]
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
		,OLD.TX_REGION
) RLC ON
	RLC.county_cd = RP.cd_county
LEFT JOIN (
	SELECT
		RLC.county_cd
		,RLC.county_desc [tx_county]
		,RLC.cd_region
		,LD.TX_REGION [tx_region]
		,RLC.old_region_cd
		,OLD.TX_REGION [old_region_tx]
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
		,OLD.TX_REGION
) RMVLLC ON
	RMVLLC.county_cd = RP.cd_cnty
LEFT JOIN (
	SELECT
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION [tx_region]
		,RLC.old_region_cd
		,OLD.TX_REGION [old_region_tx]
	FROM dbo.ref_lookup_county RLC
	LEFT JOIN dbo.LOCATION_DIM LD ON
		LD.CD_REGION = RLC.cd_region
			AND LD.IS_CURRENT = 1
	LEFT JOIN dbo.LOCATION_DIM OLD ON
		OLD.CD_REGION = RLC.old_region_cd
			AND LD.IS_CURRENT = 1
	GROUP BY
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION
		,RLC.old_region_cd
		,OLD.TX_REGION
) WRLC ON
	WRLC.county_cd = RP.cd_worker_county
LEFT JOIN (
	SELECT
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION [tx_region]
		,RLC.old_region_cd
		,OLD.TX_REGION [old_region_tx]
	FROM dbo.ref_lookup_county RLC
	LEFT JOIN dbo.LOCATION_DIM LD ON
		LD.CD_REGION = RLC.cd_region
			AND LD.IS_CURRENT = 1
	LEFT JOIN dbo.LOCATION_DIM OLD ON
		OLD.CD_REGION = RLC.old_region_cd
			AND LD.IS_CURRENT = 1
	GROUP BY
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION
		,RLC.old_region_cd
		,OLD.TX_REGION
) PWRLC ON
	PWRLC.county_cd = RP.placement_worker_county_cd
LEFT JOIN (
	SELECT
		cd_office
		,cd_office_collapse
		,tx_office_collapse
	FROM dbo.ref_xwalk_cd_office_dcfs
	GROUP BY
		cd_office
		,cd_office_collapse
		,tx_office_collapse
) ROD ON
	ROD.cd_office = RP.cd_office
LEFT JOIN (
	SELECT
		cd_office
		,cd_office_collapse
		,tx_office_collapse
	FROM dbo.ref_xwalk_cd_office_dcfs
	GROUP BY
		cd_office
		,cd_office_collapse
		,tx_office_collapse
) WROD ON
	WROD.cd_office = RP.cd_worker_office
LEFT JOIN (
	SELECT
		cd_office
		,cd_office_collapse
		,tx_office_collapse
	FROM dbo.ref_xwalk_cd_office_dcfs
	GROUP BY
		cd_office
		,cd_office_collapse
		,tx_office_collapse
) PWROD ON
	PWROD.cd_office = RP.placement_worker_office_cd
LEFT JOIN dbCoreAdministrativeTables.dbo.ref_county_court_xwalk RCC ON
	RCC.county_cd = RP.cd_county
LEFT JOIN dbCoreAdministrativeTables.dbo.ref_county_court_xwalk WRCC ON
	WRCC.county_cd = RP.cd_worker_county
LEFT JOIN dbCoreAdministrativeTables.dbo.ref_county_court_xwalk PWRCC ON
	PWRCC.county_cd = RP.placement_worker_county_cd
LEFT JOIN (
	SELECT
		RPE.id_removal_episode_fact
		,RPE.derived_county
		,RLC.county_desc
		,ROW_NUMBER() OVER(PARTITION BY RPE.id_removal_episode_fact ORDER BY RPE.begin_date DESC, RPE.id_placement_fact DESC) [row_num_desc]
	FROM base.rptPlacement_Events RPE 
	LEFT JOIN dbo.ref_lookup_county RLC ON
		RLC.county_cd = RPE.derived_county
) LPD ON
	LPD.id_removal_episode_fact = RP.id_removal_episode_fact
		AND LPD.row_num_desc = 1
LEFT JOIN (
	SELECT
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION [tx_region]
		,RLC.old_region_cd
		,OLD.TX_REGION [old_region_tx]
	FROM dbo.ref_lookup_county RLC
	LEFT JOIN dbo.LOCATION_DIM LD ON
		LD.CD_REGION = RLC.cd_region
			AND LD.IS_CURRENT = 1
	LEFT JOIN dbo.LOCATION_DIM OLD ON
		OLD.CD_REGION = RLC.old_region_cd
			AND LD.IS_CURRENT = 1
	GROUP BY
		RLC.county_cd
		,RLC.cd_region
		,LD.TX_REGION
		,RLC.old_region_cd
		,OLD.TX_REGION
) ERLC ON
	ERLC.county_cd = LPD.derived_county
LEFT JOIN (
	SELECT DISTINCT
		DT.cd_discharge_type
		,DT.discharge_type [tx_discharge_type]
		,DEF.cd_discharge_type [def_cd_discharge_type]
		,DEF.tx_discharge_type [def_tx_discharge_type]
	FROM dbo.ref_state_discharge_xwalk DT
	CROSS JOIN (
		SELECT DISTINCT
			cd_discharge_type
			,discharge_type [tx_discharge_type]
		FROM dbo.ref_state_discharge_xwalk
		WHERE cd_discharge_type = 5
	) DEF
) SDX ON
	SDX.cd_discharge_type = RP.cd_discharge_type
LEFT JOIN dbo.ref_lookup_plcmnt RLPI ON
	RLPI.cd_plcm_setng = RP.init_cd_plcm_setng
LEFT JOIN dbo.ref_lookup_plcmnt RLPL ON
	RLPL.cd_plcm_setng = RP.long_cd_plcm_setng
LEFT JOIN dbo.ref_filter_dependency RFD ON
	RFD.bin_dep_cd = RP.bin_dep_cd
LEFT JOIN dbo.ref_filter_ihs_services RFIHS ON
	RFIHS.bin_ihs_svc_cd = RP.bin_ihs_svc_cd
LEFT JOIN dbo.ref_filter_nbr_placement RFNP ON
	RFNP.bin_placement_cd = RP.bin_placement_cd
LEFT JOIN dbo.ref_lookup_hispanic_latino_census RLHLC ON
	RLHLC.census_hispanic_latino_origin_cd = RP.census_hispanic_latino_origin_cd
LEFT JOIN dbo.ref_lookup_ethnicity_census RLEC ON
	RLEC.cd_race_census = RP.cd_race_census
LEFT JOIN dbo.ref_filter_los RFLOS ON
	RFLOS.bin_los_cd = ISNULL(RP.max_bin_los_cd, 0)
CROSS JOIN dbo.ref_last_dw_transfer RLDT
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








