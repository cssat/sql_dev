CREATE PROCEDURE [rodis_wh].[etl_fetal_or_infant_death_att]
AS
IF OBJECT_ID('rodis_wh.staging_fetal_or_infant_death_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_fetal_or_infant_death_att

CREATE TABLE rodis_wh.staging_fetal_or_infant_death_att(
	id_fetal_or_infant_death INT NULL
	,cd_fetal_or_infant_death VARCHAR(50) NULL
	,tx_fetal_or_infant_death VARCHAR(50) NULL
)

INSERT rodis_wh.staging_fetal_or_infant_death_att (
	cd_fetal_or_infant_death
	,tx_fetal_or_infant_death
	)
SELECT DISTINCT CONVERT(VARCHAR(50), fdid) [cd_fetal_or_infant_death]
	,CONVERT(VARCHAR(50), fdid) + ' - Undefined' [tx_fetal_or_infant_death]
FROM rodis.berd
WHERE fdid IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_fetal_or_infant_death]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_fetal_or_infant_death]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_fetal_or_infant_death_att

CREATE NONCLUSTERED INDEX idx_staging_fetal_or_infant_death_att_id_fetal_or_infant_death ON rodis_wh.staging_fetal_or_infant_death_att (
	id_fetal_or_infant_death
	)

CREATE NONCLUSTERED INDEX idx_staging_fetal_or_infant_death_att_cd_fetal_or_infant_death ON rodis_wh.staging_fetal_or_infant_death_att (
	cd_fetal_or_infant_death
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'fetal_or_infant_death'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_fetal_or_infant_death) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_fetal_or_infant_death [source_key]
FROM rodis_wh.staging_fetal_or_infant_death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_fetal_or_infant_death
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_fetal_or_infant_death = k.entity_key
FROM rodis_wh.staging_fetal_or_infant_death_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_fetal_or_infant_death AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_fetal_or_infant_death_att

MERGE rodis_wh.fetal_or_infant_death_att [target]
USING rodis_wh.staging_fetal_or_infant_death_att [source]
	ON target.id_fetal_or_infant_death = source.id_fetal_or_infant_death
WHEN MATCHED
	THEN
		UPDATE
		SET tx_fetal_or_infant_death = source.tx_fetal_or_infant_death

WHEN NOT MATCHED
	THEN
		INSERT (
			id_fetal_or_infant_death
			,cd_fetal_or_infant_death
			,tx_fetal_or_infant_death
			)
		VALUES (
			source.id_fetal_or_infant_death
			,source.cd_fetal_or_infant_death
			,source.tx_fetal_or_infant_death
			);

UPDATE STATISTICS rodis_wh.fetal_or_infant_death_att

UPDATE r
SET id_fetal_or_infant_death = k.entity_key
FROM rodis_wh.maternal_history_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_fetal_or_infant_death_att p
		WHERE p.id_fetal_or_infant_death = r.id_fetal_or_infant_death
		)

DELETE FROM a
FROM rodis_wh.fetal_or_infant_death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_fetal_or_infant_death_att s
		WHERE s.id_fetal_or_infant_death = a.id_fetal_or_infant_death
		)

UPDATE STATISTICS rodis_wh.fetal_or_infant_death_att
