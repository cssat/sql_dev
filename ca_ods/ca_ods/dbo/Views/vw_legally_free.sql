

--if OBJECT_ID('tempDB..##legfree') is not null drop table ##legfree

CREATE view [dbo].[vw_legally_free]
as 
with cte_legally_free as (
	SELECT
		tce.id_prsn_child 
		,tce.id_removal_episode_fact
		,isnull(g.pk_gndr, 3) [pk_gndr]
		,tce.eps_total
		,tce.cd_race_census [cd_race_census]
		,tce.child_age_removal_begin
		,tce.child_age_removal_end
		,tce.census_hispanic_latino_origin_cd
		,tce.state_custody_start_date
		,tce.state_discharge_date
		,dbo.IntDate_to_CalDate(max(lf.id_calendar_dim_effective)) [legally_free_date] 
		,tce.federal_discharge_date
		,tce.Federal_Discharge_Date_Force_18
		,count(DISTINCT lf.id_legal_fact) [count_of_results] 
		,max(iif(lrd.cd_result = 47, 1, 0)) [fl_maternal_relinquish]
		,max(iif(lrd.cd_result = 48, 1, 0)) [fl_paternal_relinquish]
		,max(iif(lrd.cd_result = 56, 1, 0)) [fl_maternal_term]
		,max(iif(lrd.cd_result = 57, 1, 0)) [fl_paternal_term]
		,max(iif(lrd.cd_result = 58, 1, 0)) [fl_maternal_term_reversed]
		,max(iif(lrd.cd_result = 59, 1, 0)) [fl_paternal_term_reversed]
		,max(iif(lrd.cd_result = 60, 1, 0)) [fl_unknown_father_term]
		,tce.federal_discharge_reason_code
		,tce.state_discharge_reason_code
		,tce.state_discharge_reason 
		,ljd.cd_jurisdiction
		,ljd.tx_jurisdiction
		,IIF(tce.Federal_Discharge_Date_Force_18 < = dw.cutoff_date AND tce.Federal_Discharge_Date > dw.cutoff_date, 'Emancipation', tce.Federal_Discharge_Reason) [Federal_Discharge_Reason_Force]
		,tce.federal_discharge_reason
		,datediff(dd, tce.State_Custody_Start_Date, dbo.IntDate_to_CalDate(max(lf.ID_CALENDAR_DIM_EFFECTIVE))) [custody_to_term]
		,row_number() OVER (partition BY tce.id_prsn_child ORDER BY datediff(dd, tce.State_Custody_Start_Date, dbo.IntDate_to_CalDate(max(lf.ID_CALENDAR_DIM_EFFECTIVE))) ASC, ljd.tx_jurisdiction desc) [row_num] 
		,tce.cnt_plcm
		,IIF(tce.Federal_Discharge_Date_Force_18 > dw.cutoff_date
			,datediff(dd, dbo.IntDate_to_CalDate(max(lf.id_calendar_dim_effective)), dw.cutoff_date) + 1
			,datediff(dd, dbo.IntDate_to_CalDate(max(lf.id_calendar_dim_effective)), tce.Federal_Discharge_Date_Force_18) + 1 
		) [term_to_perm]
		,IIF(tce.Federal_Discharge_Date_Force_18 > dw.cutoff_date AND tce.federal_discharge_date > dw.cutoff_date, 0, 1) [discharge_flag]
	FROM base.tbl_child_episodes tce
	JOIN ref_last_dw_transfer dw on 1=1
	JOIN dbo.legal_fact lf ON tce.id_prsn_child = lf.id_prsn
		AND lf.id_calendar_dim_effective > CONVERT(INT, CONVERT(VARCHAR, tce.state_custody_start_date, 112))
		AND lf.ID_CALENDAR_DIM_EFFECTIVE > 19980129
	JOIN dbo.legal_result_dim lrd ON lrd.id_legal_result_dim = lf.id_legal_result_dim 
		AND lrd.cd_result IN (47, 48, 56, 57, 58, 59, 60) --termination of parental rights
	LEFT JOIN dbo.legal_jurisdiction_dim ljd ON ljd.id_legal_jurisdiction_dim = lf.id_legal_jurisdiction_dim
	LEFT JOIN dbo.ref_lookup_gender g on g.cd_gndr = tce.cd_gndr
	GROUP BY
		tce.id_prsn_child 
		,tce.state_custody_start_date
		,tce.state_discharge_date
		,tce.Federal_Discharge_Date_Force_18
		,tce.federal_discharge_reason_code
		,tce.federal_discharge_reason
		,tce.state_discharge_reason_code
		,tce.state_discharge_reason
		,tce.federal_discharge_date
		,tce.cnt_plcm
		,ljd.tx_jurisdiction
		,ljd.cd_jurisdiction
		,tce.eps_total
		,tce.cd_race_census
		,tce.child_age_removal_begin
		,tce.child_age_removal_end
		,tce.census_hispanic_latino_origin_cd
		,ISNULL(g.pk_gndr, 3)
		,dw.cutoff_date
		,tce.id_removal_episode_fact
)

select 
	lf.id_removal_episode_fact
	,lf.id_prsn_child
	,lf.pk_gndr
	,lf.eps_total
	,lf.cd_race_census
	,lf.child_age_removal_begin
	,lf.child_age_removal_end
	,lf.census_hispanic_latino_origin_cd
	,lf.state_custody_start_date
	,lf.state_discharge_date
	,lf.legally_free_date
	,lf.federal_discharge_date
	,lf.federal_discharge_date_force_18
	,lf.count_of_results
	,lf.federal_discharge_reason_code
	,lf.state_discharge_reason_code
	,lf.cd_jurisdiction
	,lf.tx_jurisdiction
	,iif(fl_maternal_relinquish = 1 and fl_paternal_relinquish = 1, 1, 0) [fl_both_parent_relinquish]
	,iif(fl_maternal_term = 1 and fl_maternal_term_reversed = 0 and (fl_paternal_term = 1 or fl_unknown_father_term = 1) and fl_paternal_term_reversed = 0, 1, 0) [both_parents_termed]
	,iif(lf.Federal_Discharge_Reason_Force IN ('Deceased', 'Transfer to Private Agency Authority', '-'), 'Other', lf.Federal_Discharge_Reason_Force) [Federal_Discharge_Reason_Force]
	,lf.federal_discharge_reason
	,lf.custody_to_term
	,lf.cnt_plcm
	,lf.term_to_perm
	,iif(lf.Federal_Discharge_Reason_Force IN ('Deceased', 'Transfer to Private Agency Authority', '-'), 1, lf.discharge_flag) [discharge_flag]
--into ##legfree
from cte_legally_free lf
where lf.row_num = 1
	and lf.federal_discharge_reason_code <> 1
	and lf.term_to_perm >= 0
	--and not exists(select * from vw_legally_free vlf where vlf.id_prsn_child=lf.id_prsn_child);
				

				





