CREATE PROCEDURE [rodis_wh].[etl_kotelchuck_index_att]
AS
IF OBJECT_ID('rodis_wh.staging_kotelchuck_index_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_kotelchuck_index_att

CREATE TABLE rodis_wh.staging_kotelchuck_index_att(
	id_kotelchuck_index INT NULL
	,cd_kotelchuck_index VARCHAR(50) NULL
	,tx_kotelchuck_index VARCHAR(50) NULL
)

INSERT rodis_wh.staging_kotelchuck_index_att (
	cd_kotelchuck_index
	,tx_kotelchuck_index
	)
SELECT DISTINCT CONVERT(VARCHAR(50), moindex4) [cd_kotelchuck_index]
	,CONVERT(VARCHAR(50), moindex4) + ' - Undefined' [tx_kotelchuck_index]
FROM rodis.berd
WHERE moindex4 IS NOT NULL

UNION

SELECT '-1' [cd_kotelchuck_index]
	,'Unspecified' [tx_kotelchuck_index]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_kotelchuck_index_att

CREATE NONCLUSTERED INDEX idx_staging_kotelchuck_index_att_id_kotelchuck_index ON rodis_wh.staging_kotelchuck_index_att (
	id_kotelchuck_index
	)

CREATE NONCLUSTERED INDEX idx_staging_kotelchuck_index_att_cd_kotelchuck_index ON rodis_wh.staging_kotelchuck_index_att (
	cd_kotelchuck_index
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'kotelchuck_index'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_kotelchuck_index) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_kotelchuck_index [source_key]
FROM rodis_wh.staging_kotelchuck_index_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_kotelchuck_index
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_kotelchuck_index = k.entity_key
FROM rodis_wh.staging_kotelchuck_index_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_kotelchuck_index AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_kotelchuck_index_att

MERGE rodis_wh.kotelchuck_index_att [target]
USING rodis_wh.staging_kotelchuck_index_att [source]
	ON target.id_kotelchuck_index = source.id_kotelchuck_index
WHEN MATCHED
	THEN
		UPDATE
		SET tx_kotelchuck_index = source.tx_kotelchuck_index

WHEN NOT MATCHED
	THEN
		INSERT (
			id_kotelchuck_index
			,cd_kotelchuck_index
			,tx_kotelchuck_index
			)
		VALUES (
			source.id_kotelchuck_index
			,source.cd_kotelchuck_index
			,source.tx_kotelchuck_index
			);

UPDATE STATISTICS rodis_wh.kotelchuck_index_att

UPDATE r
SET id_kotelchuck_index = k.entity_key
FROM rodis_wh.maternal_behavior_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_kotelchuck_index_att p
		WHERE p.id_kotelchuck_index = r.id_kotelchuck_index
		)

DELETE FROM a
FROM rodis_wh.kotelchuck_index_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_kotelchuck_index_att s
		WHERE s.id_kotelchuck_index = a.id_kotelchuck_index
		)

UPDATE STATISTICS rodis_wh.kotelchuck_index_att
