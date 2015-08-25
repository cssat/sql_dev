CREATE PROCEDURE [rodis_wh].[etl_child_sex_att]
AS
IF OBJECT_ID('rodis_wh.staging_child_sex_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_child_sex_att

CREATE TABLE rodis_wh.staging_child_sex_att(
	id_child_sex INT NULL
	,cd_child_sex VARCHAR(50) NULL
	,tx_child_sex VARCHAR(50) NULL
)

INSERT rodis_wh.staging_child_sex_att (
	cd_child_sex
	,tx_child_sex
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_child_sex]
	,CONVERT(VARCHAR(50), Value) [tx_child_sex]
FROM rodis.ref_sex

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.sex) [cd_child_sex]
	,ISNULL(CONVERT(VARCHAR(50), r.Value), CONVERT(VARCHAR(50), b.sex) + ' - Undefined') [tx_child_sex]
FROM rodis.berd b
LEFT JOIN rodis.ref_sex r ON r.Code = b.sex
WHERE b.sex IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_child_sex]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_child_sex]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_child_sex_att

CREATE NONCLUSTERED INDEX idx_staging_child_sex_att_id_child_sex ON rodis_wh.staging_child_sex_att (
	id_child_sex
	)

CREATE NONCLUSTERED INDEX idx_staging_child_sex_att_cd_child_sex ON rodis_wh.staging_child_sex_att (
	cd_child_sex
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'child_sex'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_child_sex) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_child_sex [source_key]
FROM rodis_wh.staging_child_sex_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_child_sex
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_child_sex = k.entity_key
FROM rodis_wh.staging_child_sex_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_child_sex AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_child_sex_att

MERGE rodis_wh.child_sex_att [target]
USING rodis_wh.staging_child_sex_att [source]
	ON target.id_child_sex = source.id_child_sex
WHEN MATCHED
	THEN
		UPDATE
		SET tx_child_sex = source.tx_child_sex
WHEN NOT MATCHED
	THEN
		INSERT (
			id_child_sex
			,cd_child_sex
			,tx_child_sex
			)
		VALUES (
			source.id_child_sex
			,source.cd_child_sex
			,source.tx_child_sex
			);

UPDATE STATISTICS rodis_wh.child_sex_att

UPDATE r
SET id_child_sex = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_child_sex_att p
		WHERE p.id_child_sex = r.id_child_sex
		)

DELETE FROM a
FROM rodis_wh.child_sex_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_child_sex_att s
		WHERE s.id_child_sex = a.id_child_sex
		)

UPDATE STATISTICS rodis_wh.child_sex_att
