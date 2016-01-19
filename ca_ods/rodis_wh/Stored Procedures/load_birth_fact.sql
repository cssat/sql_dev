﻿CREATE PROCEDURE [rodis_wh].[load_birth_fact]
AS
TRUNCATE TABLE rodis_wh.birth_fact

INSERT rodis_wh.birth_fact (
	id_birth_fact
	,cd_birth_fact
	,id_prsn_child
	,id_prsn_mother
	,id_calendar_dim_birth_child
	,qt_child_weight
	,ms_maternal_bmi
	,qt_child_head_circum
	,qt_paternal_age
	,qt_child_age_est_gest
	,qt_child_age_gest
	,qt_maternal_age
	,qt_maternal_height
	,qt_preconception_maternal_weight
	,qt_maternal_weight
	,ms_maternal_weight_gain
	,am_median_income_tract
	,id_birth_administration
	,birth_administration_id_birth_familial_child
	,birth_administration_child_birth_familial_id_city_current
	,birth_administration_child_birth_familial_id_city_birth
	,birth_administration_child_birth_familial_id_education
	,birth_administration_id_birth_familial_maternal
	,birth_administration_maternal_birth_familial_id_city_current
	,birth_administration_maternal_birth_familial_id_city_birth
	,birth_administration_maternal_birth_familial_id_education
	,birth_administration_id_birth_familial_paternal
	,birth_administration_paternal_birth_familial_id_city_current
	,birth_administration_paternal_birth_familial_id_city_birth
	,birth_administration_paternal_birth_familial_id_education
	,birth_administration_id_hospital_admission_child
	,birth_administration_child_hospital_admission_id_payment_primary
	,birth_administration_child_hospital_admission_id_payment_secondary
	,birth_administration_id_hospital_admission_maternal
	,birth_administration_maternal_hospital_admission_id_payment_primary
	,birth_administration_maternal_hospital_admission_id_payment_secondary
	,birth_administration_id_birth_child_condition
	,birth_administration_id_birth_child_procedure
	,birth_administration_id_maternal_behavior
	,birth_administration_id_maternal_condition
	,birth_administration_id_maternal_history
	,birth_administration_id_maternal_procedure
	)
SELECT bf.id_birth_fact
	,bf.cd_birth_fact
	,bf.id_prsn_child
	,bf.id_prsn_mother
	,bf.id_calendar_dim_birth_child
	,bf.qt_child_weight
	,bf.ms_maternal_bmi
	,bf.qt_child_head_circum
	,bf.qt_paternal_age
	,bf.qt_child_age_est_gest
	,bf.qt_child_age_gest
	,bf.qt_maternal_age
	,bf.qt_maternal_height
	,bf.qt_preconception_maternal_weight
	,bf.qt_maternal_weight
	,bf.ms_maternal_weight_gain
	,bf.am_median_income_tract
	,bf.id_birth_administration
	,bad.id_birth_familial_child [birth_administration_id_birth_familial_child]
	,bfdc.id_city_current [birth_administration_child_birth_familial_id_city_current]
	,bfdc.id_city_birth [birth_administration_child_birth_familial_id_city_birth]
	,bfdc.id_education [birth_administration_child_birth_familial_id_education]
	,bad.id_birth_familial_maternal [birth_administration_id_birth_familial_maternal]
	,bfdm.id_city_current [birth_administration_maternal_birth_familial_id_city_current]
	,bfdm.id_city_birth [birth_administration_maternal_birth_familial_id_city_birth]
	,bfdm.id_education [birth_administration_maternal_birth_familial_id_education]
	,bad.id_birth_familial_paternal [birth_administration_id_birth_familial_paternal]
	,bfdp.id_city_current [birth_administration_paternal_birth_familial_id_city_current]
	,bfdp.id_city_birth [birth_administration_paternal_birth_familial_id_city_birth]
	,bfdp.id_education [birth_administration_paternal_birth_familial_id_education]
	,bad.id_hospital_admission_child [birth_administration_id_hospital_admission_child]
	,hadc.id_payment_primary [birth_administration_child_hospital_admission_id_payment_primary]
	,hadc.id_payment_secondary [birth_administration_child_hospital_admission_id_payment_secondary]
	,bad.id_hospital_admission_maternal [birth_administration_id_hospital_admission_maternal]
	,hadm.id_payment_primary [birth_administration_maternal_hospital_admission_id_payment_primary]
	,hadm.id_payment_secondary [birth_administration_maternal_hospital_admission_id_payment_secondary]
	,bad.id_birth_child_condition [birth_administration_id_birth_child_condition]
	,bad.id_birth_child_procedure [birth_administration_id_birth_child_procedure]
	,bad.id_maternal_behavior [birth_administration_id_maternal_behavior]
	,bad.id_maternal_condition [birth_administration_id_maternal_condition]
	,bad.id_maternal_history [birth_administration_id_maternal_history]
	,bad.id_maternal_procedure [birth_administration_id_maternal_procedure]
FROM rodis_wh.birth_fat bf
LEFT JOIN rodis_wh.birth_administration_dim bad ON bad.id_birth_administration = bf.id_birth_administration
LEFT JOIN rodis_wh.birth_familial_dim bfdc ON bfdc.id_birth_familial = bad.id_birth_familial_child
LEFT JOIN rodis_wh.birth_familial_dim bfdm ON bfdm.id_birth_familial = bad.id_birth_familial_maternal
LEFT JOIN rodis_wh.birth_familial_dim bfdp ON bfdp.id_birth_familial = bad.id_birth_familial_paternal
LEFT JOIN rodis_wh.hospital_admission_dim hadc ON hadc.id_hospital_admission = bad.id_hospital_admission_child
LEFT JOIN rodis_wh.hospital_admission_dim hadm ON hadm.id_hospital_admission = bad.id_hospital_admission_maternal

UPDATE STATISTICS rodis_wh.birth_fact