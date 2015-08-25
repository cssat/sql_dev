CREATE PROCEDURE [rodis_wh].[etl_ucode_att]
AS
IF OBJECT_ID('rodis_wh.staging_ucode_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_ucode_att

CREATE TABLE rodis_wh.staging_ucode_att(
	id_ucode INT NULL
	,cd_ucode VARCHAR(50) NULL
	,tx_ucode VARCHAR(50) NULL
)

INSERT rodis_wh.staging_ucode_att (
	cd_ucode
	,tx_ucode
	)
SELECT DISTINCT CONVERT(VARCHAR(50), d_ucod) [cd_ucode]
	,CONVERT(VARCHAR(50), d_ucod) + ' - Undefined' [tx_ucode]
FROM rodis.bab_died
WHERE d_ucod IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_ucode]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_ucode]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_ucode_att

CREATE NONCLUSTERED INDEX idx_staging_ucode_att_id_ucode ON rodis_wh.staging_ucode_att (
	id_ucode
	)

CREATE NONCLUSTERED INDEX idx_staging_ucode_att_cd_ucode ON rodis_wh.staging_ucode_att (
	cd_ucode
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'ucode'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_ucode) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_ucode [source_key]
FROM rodis_wh.staging_ucode_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_ucode
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_ucode = k.entity_key
FROM rodis_wh.staging_ucode_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_ucode AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_ucode_att

MERGE rodis_wh.ucode_att [target]
USING rodis_wh.staging_ucode_att [source]
	ON target.id_ucode = source.id_ucode
WHEN MATCHED
	THEN
		UPDATE
		SET tx_ucode = source.tx_ucode

WHEN NOT MATCHED
	THEN
		INSERT (
			id_ucode
			,cd_ucode
			,tx_ucode
			)
		VALUES (
			source.id_ucode
			,source.cd_ucode
			,source.tx_ucode
			);

UPDATE r
SET id_ucode = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_ucode_att p
		WHERE p.id_ucode = r.id_ucode
		)

DELETE FROM a
FROM rodis_wh.ucode_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_ucode_att s
		WHERE s.id_ucode = a.id_ucode
		)

UPDATE STATISTICS rodis_wh.ucode_att
