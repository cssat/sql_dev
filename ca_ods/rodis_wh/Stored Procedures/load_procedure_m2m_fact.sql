CREATE PROCEDURE [rodis_wh].[load_procedure_m2m_fact]
AS
TRUNCATE TABLE rodis_wh.procedure_m2m_fact

INSERT rodis_wh.procedure_m2m_fact (
	id_procedure_m2m
	,cd_procedure_m2m
	,id_procedure
	,id_procedure_order
	,id_hospital_admission
	,hospital_admission_id_payment_primary
	,hospital_admission_id_payment_secondary
	)
SELECT pm.id_procedure_m2m
	,pm.cd_procedure_m2m
	,pm.id_procedure
	,pm.id_procedure_order
	,pm.id_hospital_admission
	,had.id_payment_primary [hospital_admission_id_payment_primary]
	,had.id_payment_secondary [hospital_admission_id_payment_secondary]
FROM rodis_wh.procedure_m2m_fat pm
LEFT JOIN rodis_wh.hospital_admission_dim had ON had.id_hospital_admission = pm.id_hospital_admission

UPDATE STATISTICS rodis_wh.procedure_m2m_fact