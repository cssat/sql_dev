USE [CA_ODS]
GO

/****** Object:  View [base].[tbl_child_episodes]    Script Date: 4/2/2014 8:39:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [base].[tbl_child_episodes]
AS
SELECT
	P.child [id_prsn_child]
	,P.id_case
	,P.first_removal_dt [first_removal_date]
	,P.latest_removal_dt [latest_removal_date]
	,P.tx_region [removal_region]
	,P.cd_county [removal_county_cd]
	,P.tx_county  [removal_county]
	,dbo.IntDate_to_CalDate(P.id_calendar_dim_begin) [state_custody_start_date]
	,P.id_calendar_dim_begin
	,FP.id_calendar_dim_end
	,dbo.IntDate_to_CalDate(P.id_calendar_dim_begin) [state_discharge_date]
	,P.tx_dsch_rsn [state_discharge_reason]
	,DRD.CD_DSCH_RSN [state_discharge_reason_code]
	,P.discharge_dt [federal_discharge_date]
	,CASE WHEN DATEADD(YEAR, 18, P.birthdate) < P.discharge_dt THEN DATEADD(YEAR, 18, P.birthdate) ELSE p.discharge_dt END [federal_discharge_date_force_18]
	,FDRX.federal_discharge_reason_code
	,FDRX.federal_category_label [federal_discharge_reason]
	,ISNULL(FP.cd_plcm_setng, -99)  [initial_plcm_setting_for_removal_cd]
	,FP.tx_plcm_setng [initial_plcm_setting_for_removal]
	,FP.id_plcmnt_evnt [init_id_plcmnt_evnt]
	,FP.cd_plcmnt_evnt [init_cd_plcmnt_evnt]
	,LP.cd_plcm_setng [last_plcm_setting_for_removal_cd]
	,LP.tx_plcm_setng [last_plcm_setting_for_removal]
	,LP.id_plcmnt_evnt [last_id_plcmnt_evnt]
	,LP.cd_plcmnt_evnt [last_cd_plcmnt_evnt]
	,FPD.CD_PHYS_COUNTY [removal_county_initial_placement_caregiver_cd]
	,RLC.county_desc [removal_county_initial_placement_caregiver]
	,LD.cd_office [removal_initial_placement_worker_office_cd]
	,RXO.tx_office_collapse [removal_initial_placement_worker_office]
	,LD.CD_CNTY [removal_initial_placement_worker_office_county_cd]
	,RLCFPW.county_desc [removal_initial_placement_worker_office_county]
	,PRD.TX_END_RSN [removal_id_placement_result_dim_latest_end_reason]
	,PRD.CD_END_RSN [removal_id_placement_result_dim_latest_end_reason_cd]
	,DRD.TX_PLCM_DSCH_RSN [removal_plcm_discharge_reason]
	,DRD.CD_PLCM_DSCH_RSN [removal_plcm_discharge_reason_cd]
	,P.fl_child_clinically_diagnosed [disability_diagnosis]
	,PD.FL_PHYS_DISABLED [diability_physical]
	,PD.FL_VIS_HEARING_IMPR [disability_sensory]
	,PD.FL_MNTAL_RETARDATN [disability_mr]
	,PD.FL_EMOTION_DSTRBD [disability_emotional]
	,PD.FL_OTHR_SPC_CARE [disability_other]
	,REF.FL_ABUSE [removal_abuse]
	,P.fl_abandonment [removal_abandon]
	,P.fl_relinquishment [removal_relinquishment]
	,P.fl_child_abuse_alcohol [removal_child_alcohol_abuse]
	,P.fl_child_behavior_problems [removal_child_behavior]
	,P.fl_child_abuses_drug [removal_child_drug_abuse]
	,CASE
		WHEN PD.FL_PHYS_DISABLED = 'Y'
			OR PD.FL_VIS_HEARING_IMPR = 'Y'
			OR PD.FL_MNTAL_RETARDATN = 'Y'
			OR PD.FL_EMOTION_DSTRBD = 'Y'
			OR PD.FL_OTHR_SPC_CARE = 'Y'
			OR P.fl_child_clinically_diagnosed = 1 THEN 1
		ELSE 0
	END [removal_child_disability]
	,P.fl_inadequate_housng [removal_inadequate_housing]
	,P.fl_neglect [removal_neglect]
	,P.fl_parent_abuse_alcohol [removal_parent_alcohol_abuse]
	,P.fl_parent_drug_abuse [removal_parent_drug_abuse]
	,P.fl_caretaker_inability_cope [removal_parent_incapacity]
	,P.fl_physical_abuse [removal_physical_abuse]
	,P.fl_sex_abuse [removal_sexual_abuse]
	,P.fl_parent_death [removal_parent_death]
	,P.fl_parent_incarceration [removal_incarceration]
	,REF.CHILD_AGE_REMOVAL_BEGIN [child_age_removal_begin]
	,REF.CHILD_AGE_REMOVAL_END [child_age_removal_end]
	,P.id_removal_episode_fact
	,P.cd_gndr
	,P.tx_gndr
	,P.birthdate [dt_birth]
	,BR.cd_braam_race
	,P.tx_braam_race
	,CONVERT(INT, NULL) [invs_county_cd]-- IC.invs_county_cd
	,CONVERT(VARCHAR(200), NULL) [invs_county] -- IC.invs_county
	,P.cd_worker_county [removal_id_location_dim_worker_county_cd]
	,P.worker_county [removal_id_location_dim_worker_county]
	,REF.ID_PEOPLE_DIM_CHILD [id_people_dim_child]
	,P.cd_race_census
	,P.census_hispanic_latino_origin_cd
	,P.dependency_dt [petition_dependency_date]
	,P.age_at_removal_mos [age_eps_begin_mos]
	,P.dur_days
	,CASE WHEN P.dur_days <= 7 THEN 1 ELSE 0 END [fl_dur_7]
	,CASE WHEN P.dur_days <= 90 THEN 1 ELSE 0 END [fl_dur_90]
	,TRH.dur_trh_days
	,TRH.cnt_trh
	,P.child_cnt_episodes [eps_total]
	,P.child_eps_rank [eps_rank]
	,COALESCE(GT7.eps_total_gt7, 0) [eps_total_gt7]
	,COALESCE(GT7.eps_rank_gt7, 0) [eps_rank_gt7]
	,CASE WHEN P.discharge_dt IS NULL THEN 0 ELSE 1 END [fl_close]
	,FP.id_provider_dim_caregiver [frst_plc_id_provider]
	,LP.id_provider_dim_caregiver [lst_plc_id_provider]
	,LPE.cd_plcmnt_evnt [longest_cd_plcmnt_evnt]
	,LPE.id_plcmnt_evnt [longest_id_plcmnt_evnt]
	,DATEDIFF(DAY, LPE.begin_date, LPE.end_date) + 1 [dur_days_longest_plcm]
	,RPTPE.cnt_ooh_plcm
	,RPTPE.cnt_plcm
	,LEAD(dbo.IntDate_to_CalDate(P.id_calendar_dim_begin), 1) OVER(PARTITION BY P.child ORDER BY dbo.IntDate_to_CalDate(P.id_calendar_dim_begin) ASC) [nxt_eps_date]
	,GT7.nxt_eps_date_gt7
	,P.id_intake_fact
	,REF.ID_PRSN_PARENT_PRIMARY [primary_parent_id_prsn]
	,FSD.CD_CRTKR [fam_structure_cd]
	,FSD.TX_CRTKR [fam_structure_tx]
	,P.bin_dep_cd
	,P.fl_dep_exist
	,P.max_bin_los_cd
	,P.bin_ihs_svc_cd
FROM base.rptPlacement P
LEFT JOIN ( 
	SELECT 
		*
		,RANK() OVER(PARTITION BY id_removal_episode_fact ORDER BY begin_date ASC, COALESCE(end_date, '12/31/9999') ASC) [PlacementOrderAsc]
	FROM base.rptPlacement_Events
) FP ON 
	FP.id_removal_episode_fact = P.id_removal_episode_fact
		AND FP.PlacementOrderAsc = 1
LEFT JOIN ( 
	SELECT 
		*
		,ROW_NUMBER() OVER(PARTITION BY id_removal_episode_fact ORDER BY begin_date DESC, COALESCE(end_date, '12/31/9999') DESC) [PlacementOrderDesc]
	FROM base.rptPlacement_Events
) LP ON 
	LP.id_removal_episode_fact = P.id_removal_episode_fact
		AND LP.PlacementOrderDesc = 1
LEFT JOIN dbo.REMOVAL_EPISODE_FACT REF ON
	REF.ID_REMOVAL_EPISODE_FACT = P.id_removal_episode_fact
LEFT JOIN dbo.DISCHARGE_REASON_DIM DRD ON
	DRD.ID_DISCHARGE_REASON_DIM = REF.ID_DISCHARGE_REASON_DIM
LEFT JOIN dbo.PLACEMENT_RESULT_DIM PRD ON
	PRD.ID_PLACEMENT_RESULT_DIM = REF.ID_PLACEMENT_RESULT_DIM_LATEST
LEFT JOIN dbo.PEOPLE_DIM PD ON
	PD.ID_PEOPLE_DIM = REF.ID_PEOPLE_DIM_CHILD
LEFT JOIN dbo.FAMILY_STRUCTURE_DIM FSD ON
	FSD.ID_FAMILY_STRUCTURE_DIM = REF.ID_FAMILY_STRUCTURE_DIM
LEFT JOIN dbo.ref_braam_race BR ON
	BR.tx_braam_race = P.tx_braam_race
LEFT JOIN dbo.PLACEMENT_FACT PF ON
	PF.ID_PLACEMENT_FACT = FP.id_placement_fact
LEFT JOIN dbo.PROVIDER_DIM FPD ON
	FPD.ID_PROVIDER_DIM = FP.id_provider_dim_caregiver
		AND FPD.TX_PHYS_COUNTY != '-'
LEFT JOIN dbo.ref_lookup_county RLC ON
	RLC.county_cd = FPD.CD_PHYS_COUNTY
LEFT JOIN dbo.LOCATION_DIM LD ON
	LD.ID_LOCATION_DIM = PF.ID_LOCATION_DIM_WORKER
LEFT JOIN dbo.ref_federal_discharge_reason_xwalk FDRX ON
	FDRX.state_discharge_reason_code = DRD.CD_DSCH_RSN
--LEFT JOIN (
--	SELECT
--		IP.id_case
--		,ILD.CD_CNTY [invs_county_cd]
--		,ILD.TX_CNTY [invs_county]
--		,ROW_NUMBER() OVER(
--			PARTITION BY IP.id_case, dbo.IntDate_to_CalDate(IP.id_calendar_dim_begin) 
--			ORDER BY IP.id_case, dbo.IntDate_to_CalDate(IP.id_calendar_dim_begin), ABS(DATEDIFF(DAY, dbo.IntDate_to_CalDate(CASE 
--				WHEN IAF.ID_CALENDAR_DIM_LEVEL1_APPROVED = 0 THEN IAF.ID_CALENDAR_DIM_LEVEL2_APPROVED 
--				WHEN IAF.ID_CALENDAR_DIM_LEVEL1_APPROVED > IAF.ID_CALENDAR_DIM_LEVEL2_APPROVED AND IAF.ID_CALENDAR_DIM_LEVEL2_APPROVED != 0 THEN IAF.ID_CALENDAR_DIM_LEVEL2_APPROVED 
--				ELSE IAF.ID_CALENDAR_DIM_LEVEL1_APPROVED END), dbo.IntDate_to_CalDate(IP.id_calendar_dim_begin)))) [sort_cnt]
--		,ROW_NUMBER() OVER(PARTITION BY IP.id_case ORDER BY IAF.ID_INVESTIGATION_ASSESSMENT_FACT DESC) [inv_assmt_fact_sort_desc]
--	FROM base.rptPlacement IP
--	LEFT JOIN INVESTIGATION_ASSESSMENT_FACT IAF ON
--		IAF.ID_CASE = IP.id_case
--	LEFT JOIN WORKER_DIM WD ON
--		IAF.ID_WORKER_DIM = WD.ID_WORKER_DIM
--	LEFT JOIN LOCATION_DIM ILD ON
--		ILD.ID_LOCATION_DIM = WD.ID_LOCATION_DIM_WORKER
--) IC ON
--	IC.ID_CASE = P.id_case
--		AND IC.sort_cnt = 1
--		AND IC.inv_assmt_fact_sort_desc = 1
LEFT JOIN (
	SELECT
		cd_office
		,tx_office
		,tx_office_collapse
	FROM dbo.ref_xwalk_cd_office_dcfs
	GROUP BY
		cd_office
		,tx_office
		,tx_office_collapse
) RXO ON
	RXO.cd_office = LD.CD_OFFICE
LEFT JOIN dbo.ref_lookup_county RLCFPW ON
	RLCFPW.county_cd = LD.CD_CNTY
LEFT JOIN (
	SELECT 
		id_removal_episode_fact
		,COUNT(*) OVER(PARTITION BY child) [eps_total_gt7]
		,ROW_NUMBER() OVER(PARTITION BY child ORDER BY dbo.IntDate_to_CalDate(id_calendar_dim_begin) ASC) [eps_rank_gt7]
		,LEAD(dbo.IntDate_to_CalDate(id_calendar_dim_begin), 1) OVER(PARTITION BY child ORDER BY dbo.IntDate_to_CalDate(id_calendar_dim_begin) ASC) [nxt_eps_date_gt7]
	FROM base.rptPlacement
	WHERE DATEDIFF(DAY, dbo.IntDate_to_CalDate(id_calendar_dim_begin), dbo.IntDate_to_CalDate(id_calendar_dim_afcars_end)) + 1 > 7
) GT7 ON
	GT7.id_removal_episode_fact = P.id_removal_episode_fact
LEFT JOIN base.rptPlacement_Events LPE ON
	LPE.id_placement_fact = P.longest_id_placement_fact
LEFT JOIN (
	SELECT
		id_removal_episode_fact
		,SUM(CASE WHEN cd_epsd_type = 1 THEN 1 ELSE 0 END) [cnt_ooh_plcm]
		,COUNT(*) [cnt_plcm]
	FROM base.rptPlacement_Events
	GROUP BY
		id_removal_episode_fact
) RPTPE ON
	RPTPE.id_removal_episode_fact = P.id_removal_episode_fact
LEFT JOIN (
	SELECT
		id_removal_episode_fact
		,COUNT(*) [cnt_trh]
		,SUM(DATEDIFF(DAY, trh_begin_date, CASE WHEN trh_end_date = '12/31/9999' THEN dbo.cutoff_date() ELSE COALESCE(trh_end_date, dbo.cutoff_date()) END) + 1) [dur_trh_days]
	FROM base.tbl_child_placement_settings
	WHERE trial_return_home_cd = 1
	GROUP BY
		id_removal_episode_fact
) TRH ON
	TRH.id_removal_episode_fact = P.id_removal_episode_fact


GO

