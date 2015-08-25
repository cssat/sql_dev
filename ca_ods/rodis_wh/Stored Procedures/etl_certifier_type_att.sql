CREATE PROCEDURE [rodis_wh].[etl_certifier_type_att]
AS
IF OBJECT_ID('rodis_wh.staging_certifier_type_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_certifier_type_att

CREATE TABLE rodis_wh.staging_certifier_type_att(
	id_certifier_type INT NULL
	,cd_certifier_type VARCHAR(50) NULL
	,tx_certifier_type VARCHAR(50) NULL
)

INSERT rodis_wh.staging_certifier_type_att (
	cd_certifier_type
	,tx_certifier_type
	)
SELECT DISTINCT CONVERT(VARCHAR(50), cert) [cd_certifier_type]
	,CONVERT(VARCHAR(50), cert) + ' - Undefined' [tx_certifier_type]
FROM rodis.berd
WHERE cert IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_certifier_type]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_certifier_type]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_certifier_type_att

CREATE NONCLUSTERED INDEX idx_staging_certifier_type_att_id_certifier_type ON rodis_wh.staging_certifier_type_att (
	id_certifier_type
	)

CREATE NONCLUSTERED INDEX idx_staging_certifier_type_att_cd_certifier_type ON rodis_wh.staging_certifier_type_att (
	cd_certifier_type
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'certifier_type'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_certifier_type) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_certifier_type [source_key]
FROM rodis_wh.staging_certifier_type_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_certifier_type
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_certifier_type = k.entity_key
FROM rodis_wh.staging_certifier_type_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_certifier_type AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_certifier_type_att

MERGE rodis_wh.certifier_type_att [target]
USING rodis_wh.staging_certifier_type_att [source]
	ON target.id_certifier_type = source.id_certifier_type
WHEN MATCHED
	THEN
		UPDATE
		SET tx_certifier_type = source.tx_certifier_type
WHEN NOT MATCHED
	THEN
		INSERT (
			id_certifier_type
			,cd_certifier_type
			,tx_certifier_type
			)
		VALUES (
			source.id_certifier_type
			,source.cd_certifier_type
			,source.tx_certifier_type
			);

UPDATE STATISTICS rodis_wh.certifier_type_att

UPDATE r
SET id_certifier_type = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_certifier_type_att p
		WHERE p.id_certifier_type = r.id_certifier_type
		)

DELETE FROM a
FROM rodis_wh.certifier_type_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_certifier_type_att s
		WHERE s.id_certifier_type = a.id_certifier_type
		)

UPDATE STATISTICS rodis_wh.certifier_type_att
