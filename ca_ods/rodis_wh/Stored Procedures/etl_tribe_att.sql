CREATE PROCEDURE [rodis_wh].[etl_tribe_att]
AS
IF OBJECT_ID('rodis_wh.staging_tribe_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_tribe_att

CREATE TABLE rodis_wh.staging_tribe_att(
	id_tribe INT NULL
	,cd_tribe VARCHAR(50) NULL
	,tx_tribe VARCHAR(50) NULL
)

INSERT rodis_wh.staging_tribe_att (
	cd_tribe
	,tx_tribe
	)
SELECT DISTINCT CONVERT(VARCHAR(50), b.trib_res) [cd_tribe]
	,CONVERT(VARCHAR(50), b.trib_res) + ' - Undefined' [tx_tribe]
FROM rodis.berd b
WHERE b.trib_res IS NOT NULL

UNION

SELECT '-1' [cd_tribe]
	,'Unspecified' [tx_tribe]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_tribe_att

CREATE NONCLUSTERED INDEX idx_staging_tribe_att_id_tribe ON rodis_wh.staging_tribe_att (
	id_tribe
	)

CREATE NONCLUSTERED INDEX idx_staging_tribe_att_cd_tribe ON rodis_wh.staging_tribe_att (
	cd_tribe
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'tribe'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_tribe) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_tribe [source_key]
FROM rodis_wh.staging_tribe_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_tribe
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_tribe = k.entity_key
FROM rodis_wh.staging_tribe_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_tribe AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_tribe_att

MERGE rodis_wh.tribe_att [target]
USING rodis_wh.staging_tribe_att [source]
	ON target.id_tribe = source.id_tribe
WHEN MATCHED
	THEN
		UPDATE
		SET tx_tribe = source.tx_tribe
WHEN NOT MATCHED
	THEN
		INSERT (
			id_tribe
			,cd_tribe
			,tx_tribe
			)
		VALUES (
			source.id_tribe
			,source.cd_tribe
			,source.tx_tribe
			);

UPDATE STATISTICS rodis_wh.tribe_att

UPDATE r
SET id_tribe = k.entity_key
FROM rodis_wh.birth_familial_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_tribe_att p
		WHERE p.id_tribe = r.id_tribe
		)

DELETE FROM a
FROM rodis_wh.tribe_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_tribe_att s
		WHERE s.id_tribe = a.id_tribe
		)

UPDATE STATISTICS rodis_wh.tribe_att
