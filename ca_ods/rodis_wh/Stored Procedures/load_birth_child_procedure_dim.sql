CREATE PROCEDURE [rodis_wh].[load_birth_child_procedure_dim]
AS
TRUNCATE TABLE rodis_wh.birth_child_procedure_dim

INSERT rodis_wh.birth_child_procedure_dim (
	id_birth_child_procedure
	,cd_birth_child_procedure
	,fl_surfactant_replacement_therapy
	,fl_ventilation_after_delivery
	,fl_ventilation_gt_6hrs
	)
SELECT id_birth_child_procedure
	,cd_birth_child_procedure
	,fl_surfactant_replacement_therapy
	,fl_ventilation_after_delivery
	,fl_ventilation_gt_6hrs
FROM rodis_wh.birth_child_procedure_att

UPDATE STATISTICS rodis_wh.birth_child_procedure_dim
