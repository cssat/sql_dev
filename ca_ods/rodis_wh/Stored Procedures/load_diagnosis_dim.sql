CREATE PROCEDURE [rodis_wh].[load_diagnosis_dim]
AS
TRUNCATE TABLE rodis_wh.diagnosis_dim

INSERT rodis_wh.diagnosis_dim (
	id_diagnosis
	,cd_diagnosis
	,tx_diagnosis
	)
SELECT id_diagnosis
	,cd_diagnosis
	,tx_diagnosis
FROM rodis_wh.diagnosis_att

UPDATE STATISTICS rodis_wh.diagnosis_dim
