USE [CA_ODS]
GO

/****** Object:  View [base].[tbl_child_episodes_ca]    Script Date: 6/2/2014 2:11:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [base].[tbl_child_episodes_ca]
AS


SELECT
	P.child [id_prsn_child]
	,P.id_case
	,iif(P.removal_county_cd between 1 and 39,P.removal_county_cd,-99) [removal_county_cd]
	, iif(P.removal_county_cd between 1 and 39,cP.county_desc,'-')[removal_county]
	,frstRem.removal_dt [first_removal_date]
	,lastRem.removal_dt [latest_removal_date]
	,convert(datetime,cast((P.id_calendar_dim_begin) as varchar(8)),112) [state_custody_start_date]
	,P.id_calendar_dim_begin
	,ref.id_calendar_dim_end
	,iif(ref.id_calendar_dim_end=0,null,convert(datetime,cast((ref.ID_CALENDAR_DIM_END) as varchar(8)),112)) [state_discharge_date]
	,P.tx_dsch_rsn [state_discharge_reason]
	,DRD.CD_DSCH_RSN [state_discharge_reason_code]
	,P.discharge_dt [federal_discharge_date]
	,IIF ( P.discharge_dt< getdate() and DATEADD(YEAR, 18, P.birthdate) < P.discharge_dt and DATEADD(YEAR, 18, P.birthdate) <  cast('2014-02-21'  as datetime) , DATEADD(YEAR, 18, P.birthdate) , p.discharge_dt) [federal_discharge_date_force_18]
	,COALESCE(DRD.CD_DSCH_RSN, PRD.CD_END_RSN) [federal_discharge_reason_code]
	,COALESCE(P.tx_dsch_rsn, P.tx_plcm_dsch_rsn) [federal_discharge_reason]
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
	,P.tx_braam_race
	,REF.ID_PEOPLE_DIM_CHILD [id_people_dim_child]
FROM base.rptPlacement P
LEFT JOIN ref_lookup_county cP on cP.county_cd=P.[removal_county_cd]
LEFT JOIN ( 
	SELECT 
		PE.*
		,RANK() OVER(PARTITION BY PE.id_removal_episode_fact ORDER BY PE.begin_date ASC, COALESCE(PE.end_date, '12/31/9999') ASC) [PlacementOrderAsc]
	FROM base.rptPlacement_Events PE
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
		AND LP.[PlacementOrderDesc] = 1
LEFT JOIN dbo.REMOVAL_EPISODE_FACT REF ON
	REF.ID_REMOVAL_EPISODE_FACT = P.id_removal_episode_fact
LEFT JOIN dbo.DISCHARGE_REASON_DIM DRD ON
	DRD.ID_DISCHARGE_REASON_DIM = REF.ID_DISCHARGE_REASON_DIM
LEFT JOIN dbo.PLACEMENT_RESULT_DIM PRD ON
	PRD.ID_PLACEMENT_RESULT_DIM = REF.ID_PLACEMENT_RESULT_DIM_LATEST
LEFT JOIN (
	SELECT
		CD_PLCM_SETNG
		,TX_PLCM_SETNG
	FROM dbo.PLACEMENT_TYPE_DIM
	GROUP BY 
		CD_PLCM_SETNG
		,TX_PLCM_SETNG
) PTD ON
	PTD.CD_PLCM_SETNG = P.init_cd_plcm_setng
LEFT JOIN dbo.PEOPLE_DIM PD ON
	PD.ID_PEOPLE_DIM = REF.ID_PEOPLE_DIM_CHILD
LEFT JOIN (
	select * ,ROW_NUMBER() over (partition by CHILD order by removal_dt asc,discharge_dt asc) row_num_child 
	from base.rptPlacement 
		) frstRem on frstRem.child=p.child and frstRem.row_num_child=1
LEFT JOIN (
	select * ,ROW_NUMBER() over (partition by CHILD order by removal_dt desc,discharge_dt desc) row_num_child 
	from base.rptPlacement 
		) lastRem on lastRem.child=p.child and lastRem.row_num_child=1


GO

