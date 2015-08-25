CREATE PROCEDURE [rodis_wh].[load_maternal_condition_dim]
AS
TRUNCATE TABLE rodis_wh.maternal_condition_dim

INSERT rodis_wh.maternal_condition_dim (
	id_maternal_condition
	,cd_maternal_condition
	,fl_amniorrhexis
	,fl_any_maternal_infection
	,fl_chronic_hypertension
	,fl_diabetes_mellitus
	,fl_failure_to_progress
	,fl_fetal_distress
	,fl_gestational_hypertension
	,fl_hepatitis_b_mom
	,fl_hepatitis_c
	,fl_herpes
	,fl_gonorrhea
	,fl_labor_complications
	,fl_other_maternal_infections
	,fl_precipitating_labor_lt_3hrs
	,fl_pregnancy_complications
	,fl_seizures
	,fl_spontaneous_delivery
	,fl_syphillis
	,id_dysfunctional_uterine_bleed
	,cd_dysfunctional_uterine_bleed
	,tx_dysfunctional_uterine_bleed
	)
SELECT mc.id_maternal_condition
	,mc.cd_maternal_condition
	,mc.fl_amniorrhexis
	,mc.fl_any_maternal_infection
	,mc.fl_chronic_hypertension
	,mc.fl_diabetes_mellitus
	,mc.fl_failure_to_progress
	,mc.fl_fetal_distress
	,mc.fl_gestational_hypertension
	,mc.fl_hepatitis_b_mom
	,mc.fl_hepatitis_c
	,mc.fl_herpes
	,mc.fl_gonorrhea
	,mc.fl_labor_complications
	,mc.fl_other_maternal_infections
	,mc.fl_precipitating_labor_lt_3hrs
	,mc.fl_pregnancy_complications
	,mc.fl_seizures
	,mc.fl_spontaneous_delivery
	,mc.fl_syphillis
	,mc.id_dysfunctional_uterine_bleed
	,dub.cd_dysfunctional_uterine_bleed
	,dub.tx_dysfunctional_uterine_bleed
FROM rodis_wh.maternal_condition_att mc
LEFT JOIN rodis_wh.dysfunctional_uterine_bleed_att dub ON dub.id_dysfunctional_uterine_bleed = mc.id_dysfunctional_uterine_bleed

UPDATE STATISTICS rodis_wh.maternal_condition_dim
