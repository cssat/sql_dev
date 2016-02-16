CREATE PROCEDURE [rodis_wh].[etl_marital_status_att]
AS
IF OBJECT_ID('rodis_wh.staging_marital_status_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_marital_status_att

CREATE TABLE rodis_wh.staging_marital_status_att(
	id_marital_status INT NULL
	,cd_marital_status VARCHAR(50) NULL
	,tx_marital_status VARCHAR(50) NULL
)

INSERT rodis_wh.staging_marital_status_att (
	cd_marital_status
	,tx_marital_status
	)
SELECT DISTINCT CONVERT(VARCHAR(50), d_maristat) [cd_marital_status]
	,CONVERT(VARCHAR(50), d_maristat) + ' - Undefined' [tx_marital_status]
FROM rodis.bab_died
WHERE d_maristat IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_marital_status]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_marital_status]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_marital_status_att

CREATE NONCLUSTERED INDEX idx_staging_marital_status_att_id_marital_status ON rodis_wh.staging_marital_status_att (
	id_marital_status
	)

CREATE NONCLUSTERED INDEX idx_staging_marital_status_att_cd_marital_status ON rodis_wh.staging_marital_status_att (
	cd_marital_status
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'marital_status'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_marital_status) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_marital_status [source_key]
FROM rodis_wh.staging_marital_status_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_marital_status
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_marital_status = k.entity_key
FROM rodis_wh.staging_marital_status_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_marital_status AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_marital_status_att

MERGE rodis_wh.marital_status_att [target]
USING rodis_wh.staging_marital_status_att [source]
	ON target.id_marital_status = source.id_marital_status
WHEN MATCHED
	THEN
		UPDATE
		SET tx_marital_status = source.tx_marital_status

WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_marital_status
			,cd_marital_status
			,tx_marital_status
			)
		VALUES (
			source.id_marital_status
			,source.cd_marital_status
			,source.tx_marital_status
			);

UPDATE r
SET id_marital_status = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_marital_status_att p
		WHERE p.id_marital_status = r.id_marital_status
		)

DELETE FROM a
FROM rodis_wh.marital_status_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_marital_status_att s
		WHERE s.id_marital_status = a.id_marital_status
		)

UPDATE STATISTICS rodis_wh.marital_status_att
