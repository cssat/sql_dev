CREATE PROCEDURE [rodis_wh].[load_procedure_order_dim]
AS
TRUNCATE TABLE rodis_wh.procedure_order_dim

INSERT rodis_wh.procedure_order_dim (
	id_procedure_order
	,cd_procedure_order
	,procedure_order
	)
SELECT id_procedure_order
	,cd_procedure_order
	,procedure_order
FROM rodis_wh.procedure_order_att

UPDATE STATISTICS rodis_wh.procedure_order_dim
