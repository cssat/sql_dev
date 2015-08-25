CREATE PROCEDURE [rodis_wh].[etl_birth_child_procedure_att]
AS
IF OBJECT_ID('rodis_wh.staging_birth_child_procedure_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_birth_child_procedure_att

CREATE TABLE rodis_wh.staging_birth_child_procedure_att(
	id_birth_child_procedure INT NULL
	,cd_birth_child_procedure VARCHAR(50) NULL
	,fl_surfactant_replacement_therapy TINYINT NULL
	,fl_ventilation_after_delivery TINYINT NULL
	,fl_ventilation_gt_6hrs TINYINT NULL
)
INSERT rodis_wh.staging_birth_child_procedure_att (
	cd_birth_child_procedure
	,fl_surfactant_replacement_therapy
	,fl_ventilation_after_delivery
	,fl_ventilation_gt_6hrs
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_birth_child_procedure]
	,surfact [fl_surfactant_replacement_therapy]
	,ven_foll [fl_ventilation_after_delivery]
	,ven_ge6h [fl_ventilation_gt_6hrs]
FROM rodis.berd

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_birth_child_procedure]
	,CONVERT(TINYINT, NULL) [fl_surfactant_replacement_therapy]
	,CONVERT(TINYINT, NULL) [fl_ventilation_after_delivery]
	,CONVERT(TINYINT, NULL) [fl_ventilation_gt_6hrs]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_birth_child_procedure_att

CREATE NONCLUSTERED INDEX idx_staging_birth_child_procedure_att_id_birth_child_procedure ON rodis_wh.staging_birth_child_procedure_att (
	id_birth_child_procedure
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_child_procedure_att_cd_birth_child_procedure ON rodis_wh.staging_birth_child_procedure_att (
	cd_birth_child_procedure
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'birth_child_procedure'
			AND wh_table_type_id = 1 -- att
		)
DECLARE @column_id INT = (
		SELECT wh_column_id
		FROM rodis_wh.wh_column
		WHERE wh_table_id = @table_id AND wh_column_type_id = 2 -- source
		)

DECLARE @max_wh_key INT = (
		SELECT ISNULL(MAX(entity_key), 0)
		FROM rodis_wh.wh_entity_key
		)

INSERT rodis_wh.wh_entity_key(entity_key, wh_column_id, source_key)
SELECT ROW_NUMBER() OVER(ORDER BY cd_birth_child_procedure) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_birth_child_procedure [source_key]
FROM rodis_wh.staging_birth_child_procedure_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_birth_child_procedure
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_birth_child_procedure = k.entity_key
FROM rodis_wh.staging_birth_child_procedure_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_birth_child_procedure AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_birth_child_procedure_att

MERGE rodis_wh.birth_child_procedure_att [target]
USING rodis_wh.staging_birth_child_procedure_att [source]
	ON target.id_birth_child_procedure = source.id_birth_child_procedure
WHEN MATCHED
	THEN
		UPDATE
		SET cd_birth_child_procedure = source.cd_birth_child_procedure
			,fl_surfactant_replacement_therapy = source.fl_surfactant_replacement_therapy
			,fl_ventilation_after_delivery = source.fl_ventilation_after_delivery
			,fl_ventilation_gt_6hrs = source.fl_ventilation_gt_6hrs
WHEN NOT MATCHED
	THEN
		INSERT (
			id_birth_child_procedure
			,cd_birth_child_procedure
			,fl_surfactant_replacement_therapy
			,fl_ventilation_after_delivery
			,fl_ventilation_gt_6hrs
			)
		VALUES (
			source.id_birth_child_procedure
			,source.cd_birth_child_procedure
			,source.fl_surfactant_replacement_therapy
			,source.fl_ventilation_after_delivery
			,source.fl_ventilation_gt_6hrs
			);

UPDATE STATISTICS rodis_wh.birth_child_procedure_att

UPDATE r
SET id_birth_child_procedure = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_child_procedure_att p
		WHERE p.id_birth_child_procedure = r.id_birth_child_procedure
		)

DELETE FROM a
FROM rodis_wh.birth_child_procedure_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_child_procedure_att s
		WHERE s.id_birth_child_procedure = a.id_birth_child_procedure
		)

UPDATE STATISTICS rodis_wh.birth_child_procedure_att
