CREATE PROCEDURE [rodis_wh].[load_procedure_dim]
AS
TRUNCATE TABLE rodis_wh.procedure_dim

INSERT rodis_wh.procedure_dim (
	id_procedure
	,cd_procedure
	,tx_procedure
	)
SELECT id_procedure
	,cd_procedure
	,tx_procedure
FROM rodis_wh.procedure_att

UPDATE STATISTICS rodis_wh.procedure_dim
