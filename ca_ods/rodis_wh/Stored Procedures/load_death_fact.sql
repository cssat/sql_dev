﻿CREATE PROCEDURE [rodis_wh].[load_death_fact]
AS
TRUNCATE TABLE rodis_wh.death_fact

INSERT rodis_wh.death_fact (
	id_death_fact
	,cd_death_fact
	,id_prsn_child
	,id_county_file_number
	,id_calendar_dim_death
	,id_calendar_dim_injury
	,id_death
	,death_id_city_of_death
	,death_id_city_of_injury
	,death_id_city_of_residence_at_death
	,death_id_education
	,death_id_birth_administration
	,death_birth_administration_id_birth_familial_child
	,death_birth_administration_child_birth_familial_id_city_current
	,death_birth_administration_child_birth_familial_id_city_birth
	,death_birth_administration_child_birth_familial_id_education
	,death_birth_administration_id_birth_familial_maternal
	,death_birth_administration_maternal_birth_familial_id_city_current
	,death_birth_administration_maternal_birth_familial_id_city_birth
	,death_birth_administration_maternal_birth_familial_id_education
	,death_birth_administration_id_birth_familial_paternal
	,death_birth_administration_paternal_birth_familial_id_city_current
	,death_birth_administration_paternal_birth_familial_id_city_birth
	,death_birth_administration_paternal_birth_familial_id_education
	,death_birth_administration_id_hospital_admission_child
	,death_birth_administration_child_hospital_admission_id_payment_primary
	,death_birth_administration_child_hospital_admission_id_payment_secondary
	,death_birth_administration_id_hospital_admission_maternal
	,death_birth_administration_maternal_hospital_admission_id_payment_primary
	,death_birth_administration_maternal_hospital_admission_id_payment_secondary
	,death_birth_administration_id_birth_child_condition
	,death_birth_administration_id_birth_child_procedure
	,death_birth_administration_id_maternal_behavior
	,death_birth_administration_id_maternal_condition
	,death_birth_administration_id_maternal_history
	,death_birth_administration_id_maternal_procedure
	,death_id_hospital_admission_last
	,death_last_hospital_admission_id_payment_primary
	,death_last_hospital_admission_id_payment_secondary
	)
SELECT df.id_death_fact
	,df.cd_death_fact
	,df.id_prsn_child
	,df.id_county_file_number
	,df.id_calendar_dim_death
	,df.id_calendar_dim_injury
	,df.id_death
	,dd.id_city_of_death [death_id_city_of_death]
	,dd.id_city_of_injury [death_id_city_of_injury]
	,dd.id_city_of_residence_at_death [death_id_city_of_residence_at_death]
	,dd.id_education [death_id_education]
	,dd.id_birth_administration
	,bad.id_birth_familial_child [death_birth_administration_id_birth_familial_child]
	,bfdc.id_city_current [death_birth_administration_child_birth_familial_id_city_current]
	,bfdc.id_city_birth [death_birth_administration_child_birth_familial_id_city_birth]
	,bfdc.id_education [death_birth_administration_child_birth_familial_id_education]
	,bad.id_birth_familial_maternal [death_birth_administration_id_birth_familial_maternal]
	,bfdm.id_city_current [death_birth_administration_maternal_birth_familial_id_city_current]
	,bfdm.id_city_birth [death_birth_administration_maternal_birth_familial_id_city_birth]
	,bfdm.id_education [death_birth_administration_maternal_birth_familial_id_education]
	,bad.id_birth_familial_paternal [death_birth_administration_id_birth_familial_paternal]
	,bfdp.id_city_current [death_birth_administration_paternal_birth_familial_id_city_current]
	,bfdp.id_city_birth [death_birth_administration_paternal_birth_familial_id_city_birth]
	,bfdp.id_education [death_birth_administration_paternal_birth_familial_id_education]
	,bad.id_hospital_admission_child [death_birth_administration_id_hospital_admission_child]
	,hadc.id_payment_primary [death_birth_administration_child_hospital_admission_id_payment_primary]
	,hadc.id_payment_secondary [death_birth_administration_child_hospital_admission_id_payment_secondary]
	,bad.id_hospital_admission_maternal [death_birth_administration_id_hospital_admission_maternal]
	,hadm.id_payment_primary [death_birth_administration_maternal_hospital_admission_id_payment_primary]
	,hadm.id_payment_secondary [death_birth_administration_maternal_hospital_admission_id_payment_secondary]
	,bad.id_birth_child_condition [death_birth_administration_id_birth_child_condition]
	,bad.id_birth_child_procedure [death_birth_administration_id_birth_child_procedure]
	,bad.id_maternal_behavior [death_birth_administration_id_maternal_behavior]
	,bad.id_maternal_condition [death_birth_administration_id_maternal_condition]
	,bad.id_maternal_history [death_birth_administration_id_maternal_history]
	,bad.id_maternal_procedure [death_birth_administration_id_maternal_procedure]
	,dd.id_hospital_admission_last [death_id_hospital_admission_last]
	,hadl.id_payment_primary [death_last_hospital_admission_id_payment_primary]
	,hadl.id_payment_secondary [death_last_hospital_admission_id_payment_secondary]
FROM rodis_wh.death_fat df
LEFT JOIN rodis_wh.death_dim dd ON dd.id_death = df.id_death
LEFT JOIN rodis_wh.birth_administration_dim bad ON bad.id_birth_administration = dd.id_birth_administration
LEFT JOIN rodis_wh.birth_familial_dim bfdc ON bfdc.id_birth_familial = bad.id_birth_familial_child
LEFT JOIN rodis_wh.birth_familial_dim bfdm ON bfdm.id_birth_familial = bad.id_birth_familial_maternal
LEFT JOIN rodis_wh.birth_familial_dim bfdp ON bfdp.id_birth_familial = bad.id_birth_familial_paternal
LEFT JOIN rodis_wh.hospital_admission_dim hadc ON hadc.id_hospital_admission = bad.id_hospital_admission_child
LEFT JOIN rodis_wh.hospital_admission_dim hadm ON hadm.id_hospital_admission = bad.id_hospital_admission_maternal
LEFT JOIN rodis_wh.hospital_admission_att hadl ON hadl.id_hospital_admission = dd.id_hospital_admission_last

UPDATE STATISTICS rodis_wh.death_fact
