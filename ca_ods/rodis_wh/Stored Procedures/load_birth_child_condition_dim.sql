CREATE PROCEDURE [rodis_wh].[load_birth_child_condition_dim]
AS
TRUNCATE TABLE rodis_wh.birth_child_condition_dim

INSERT rodis_wh.birth_child_condition_dim (
	id_birth_child_condition
	,cd_birth_child_condition
	,ms_apgar5
	,ms_apgar10
	,fl_anencephaly
	,fl_breech
	,fl_chromosome_anomaly
	,fl_diaphragmic_hernia
	,fl_downs_syndrome
	,fl_heart_malformations
	,fl_orofacial_cleft
	,fl_spinabifida
	,fl_small_for_gestational_age
	,fl_omphalocele
	,fl_meconium_mod_to_heavy
	)
SELECT id_birth_child_condition
	,cd_birth_child_condition
	,ms_apgar5
	,ms_apgar10
	,fl_anencephaly
	,fl_breech
	,fl_chromosome_anomaly
	,fl_diaphragmic_hernia
	,fl_downs_syndrome
	,fl_heart_malformations
	,fl_orofacial_cleft
	,fl_spinabifida
	,fl_small_for_gestational_age
	,fl_omphalocele
	,fl_meconium_mod_to_heavy
FROM rodis_wh.birth_child_condition_att

UPDATE STATISTICS rodis_wh.birth_child_condition_dim
