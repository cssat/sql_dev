CREATE PROCEDURE [rodis_wh].[load_diagnosis_order_dim]
AS
TRUNCATE TABLE rodis_wh.diagnosis_order_dim

INSERT rodis_wh.diagnosis_order_dim (
	id_diagnosis_order
	,cd_diagnosis_order
	,diagnosis_order
	)
SELECT id_diagnosis_order
	,cd_diagnosis_order
	,diagnosis_order
FROM rodis_wh.diagnosis_order_att

UPDATE STATISTICS rodis_wh.diagnosis_order_dim
