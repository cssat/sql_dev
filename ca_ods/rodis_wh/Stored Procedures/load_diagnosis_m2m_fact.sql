CREATE PROCEDURE [rodis_wh].[load_diagnosis_m2m_fact]
AS
TRUNCATE TABLE rodis_wh.diagnosis_m2m_fact

INSERT rodis_wh.diagnosis_m2m_fact (
	id_diagnosis_m2m
	,cd_diagnosis_m2m
	,id_diagnosis
	,id_diagnosis_order
	,id_hospital_admission
	,hospital_admission_id_payment_primary
	,hospital_admission_id_payment_secondary
	)
SELECT dm.id_diagnosis_m2m
	,dm.cd_diagnosis_m2m
	,dm.id_diagnosis
	,dm.id_diagnosis_order
	,dm.id_hospital_admission
	,had.id_payment_primary [hospital_admission_id_payment_primary]
	,had.id_payment_secondary [hospital_admission_id_payment_secondary]
FROM rodis_wh.diagnosis_m2m_fat dm
LEFT JOIN rodis_wh.hospital_admission_dim had ON had.id_hospital_admission = dm.id_hospital_admission

UPDATE STATISTICS rodis_wh.diagnosis_m2m_fact
