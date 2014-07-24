USE [CA_ODS]
GO

/****** Object:  View [base].[tbl_child_episodes]    Script Date: 7/24/2014 9:21:24 AM ******/
DROP VIEW [base].[tbl_child_episodes]
GO

/****** Object:  View [base].[tbl_child_episodes]    Script Date: 7/24/2014 9:21:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [base].[tbl_child_episodes]
AS
SELECT 
	P.child [id_prsn_child]
	,P.id_case
	,P.first_removal_dt [first_removal_date]
	,P.latest_removal_dt [latest_removal_date]
	,p.tx_region [removal_region]
	,iif(P.removal_county_cd between 1 and 39,P.removal_county_cd,-99) [removal_county_cd]
	, iif(P.removal_county_cd between 1 and 39,cP.county_desc,'-')[removal_county]
	,dbo.IntDate_to_CalDate(P.id_calendar_dim_begin) [state_custody_start_date]
	,P.id_calendar_dim_begin
	,FP.id_calendar_dim_end
	,dbo.IntDate_to_CalDate(P.id_calendar_dim_begin) [state_discharge_date]
	,P.tx_dsch_rsn [state_discharge_reason]
	,DRD.CD_DSCH_RSN [state_discharge_reason_code]
	,P.discharge_dt [federal_discharge_date]
	,IIF( DATEADD(YEAR, 18, P.birthdate) < P.discharge_dt , DATEADD(YEAR, 18, P.birthdate) , p.discharge_dt )  [federal_discharge_date_force_18]
	,COALESCE(DRD.CD_DSCH_RSN, PRD.CD_END_RSN) [federal_discharge_reason_code]
	,COALESCE(DRD.tx_dsch_rsn, PRD.tx_end_rsn) [federal_discharge_reason]
	,P.init_cd_plcm_setng [initial_plcm_setting_for_removal_cd]
	,PTD.TX_PLCM_SETNG [initial_plcm_setting_for_removal]
	,FP.id_plcmnt_evnt [init_id_plcmnt_evnt]
	,FP.cd_plcmnt_evnt [init_cd_plcmnt_evnt]
	,LP.cd_plcm_setng [last_plcm_setting_for_removal_cd]
	,LP.tx_plcm_setng [last_plcm_setting_for_removal]
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
	,P.fl_relinquishment [removal_relinqueshment]
	,P.fl_child_abuse_alcohol [removal_child_acohol_abuse]
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
	,REF.ID_PEOPLE_DIM_CHILD [id_people_dim_child]
	,P.cd_race_census
	,P.census_hispanic_latino_origin_cd
	,P.dependency_dt [petition_dependency_date]
	,P.dur_days
	,CASE WHEN P.dur_days <= 7 THEN 1 ELSE 0 END [fl_dur_7]
	,CASE WHEN P.dur_days <= 90 THEN 1 ELSE 0 END [fl_dur_90]
	,P.child_cnt_episodes
	,P.child_eps_rank
	,P.id_intake_fact
	,P.bin_dep_cd
	,P.fl_dep_exist
	,P.max_bin_los_cd
	,P.bin_ihs_svc_cd
	,p.age_at_removal_mos [age_eps_begin_mos]
	,p.long_cd_plcm_setng
	,p.init_cd_plcm_setng
	,datediff(dd,lngplc.begin_date,lngplc.end_date)  dur_days_longest_plcm
	,lp.cnt_plcm [cnt_plcm]
	,RANK() over (partition by p.child order by p.removal_dt asc,p.discharge_dt asc) [eps_rank]
	,eps_tot.eps_cnt [eps_total]
	,p.cd_discharge_type
FROM base.rptPlacement P
LEFT JOIN ref_lookup_county cP on cP.county_cd=P.[removal_county_cd]
LEFT JOIN ( 
	SELECT 
		PE.*
		,row_number() OVER(PARTITION BY PE.id_removal_episode_fact ORDER BY PE.begin_date ASC, COALESCE(PE.end_date, '12/31/9999') ASC) [PlacementOrderAsc]
	FROM base.rptPlacement_Events PE
) FP ON 
	FP.id_removal_episode_fact = P.id_removal_episode_fact
		AND FP.PlacementOrderAsc = 1
LEFT JOIN ( 
	SELECT 
		*
		,ROW_NUMBER() OVER(PARTITION BY id_removal_episode_fact ORDER BY begin_date DESC, COALESCE(end_date, '12/31/9999') DESC) [PlacementOrderdesc]
		,ROW_NUMBER() OVER(PARTITION BY id_removal_episode_fact ORDER BY begin_date asc, COALESCE(end_date, '12/31/9999') asc) as cnt_plcm
	FROM base.rptPlacement_Events
) LP ON 
	LP.id_removal_episode_fact = P.id_removal_episode_fact
		AND LP.[PlacementOrderdesc] = 1
LEFT JOIN dbo.REMOVAL_EPISODE_FACT REF ON
	REF.ID_REMOVAL_EPISODE_FACT = P.id_removal_episode_fact
LEFT JOIN dbo.DISCHARGE_REASON_DIM DRD ON
	DRD.ID_DISCHARGE_REASON_DIM = REF.ID_DISCHARGE_REASON_DIM
LEFT JOIN dbo.PLACEMENT_RESULT_DIM PRD ON
	PRD.ID_PLACEMENT_RESULT_DIM = REF.ID_PLACEMENT_RESULT_DIM_LATEST
LEFT JOIN (
	SELECT distinct
		CD_PLCM_SETNG
		,TX_PLCM_SETNG
	FROM dbo.PLACEMENT_TYPE_DIM
	where TX_PLCM_SETNG <> 'Failed' 
	GROUP BY 
		CD_PLCM_SETNG
		,TX_PLCM_SETNG
		
) PTD ON
	PTD.CD_PLCM_SETNG = P.init_cd_plcm_setng
LEFT JOIN dbo.PEOPLE_DIM PD ON
	PD.ID_PEOPLE_DIM = REF.ID_PEOPLE_DIM_CHILD
LEFT JOIN dbo.ref_braam_race BR ON
	BR.tx_braam_race = P.tx_braam_race
left join base.rptPlacement_Events lngplc on lngplc.id_placement_fact=p.longest_id_placement_fact
left join (select child,count(distinct id_removal_episode_fact) as eps_cnt from base.rptPlacement group by child) eps_tot on eps_tot.child=p.child











GO


