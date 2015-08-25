CREATE PROCEDURE [rodis_wh].[etl_armed_forces_att]
AS
IF OBJECT_ID('rodis_wh.staging_armed_forces_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_armed_forces_att

CREATE TABLE rodis_wh.staging_armed_forces_att(
	id_armed_forces INT NULL
	,cd_armed_forces VARCHAR(50) NULL
	,tx_armed_forces VARCHAR(50) NULL
)

INSERT rodis_wh.staging_armed_forces_att (
	cd_armed_forces
	,tx_armed_forces
	)
SELECT DISTINCT CONVERT(VARCHAR(50), d_armed) [cd_armed_forces]
	,CONVERT(VARCHAR(50), d_armed) + ' - Undefined' [tx_armed_forces]
FROM rodis.bab_died
WHERE d_armed IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_armed_forces]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_armed_forces]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_armed_forces_att

CREATE NONCLUSTERED INDEX idx_staging_armed_forces_att_id_armed_forces ON rodis_wh.staging_armed_forces_att (
	id_armed_forces
	)

CREATE NONCLUSTERED INDEX idx_staging_armed_forces_att_cd_armed_forces ON rodis_wh.staging_armed_forces_att (
	cd_armed_forces
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'armed_forces'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_armed_forces) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_armed_forces [source_key]
FROM rodis_wh.staging_armed_forces_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_armed_forces
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_armed_forces = k.entity_key
FROM rodis_wh.staging_armed_forces_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_armed_forces AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_armed_forces_att

MERGE rodis_wh.armed_forces_att [target]
USING rodis_wh.staging_armed_forces_att [source]
	ON target.id_armed_forces = source.id_armed_forces
WHEN MATCHED
	THEN
		UPDATE
		SET tx_armed_forces = source.tx_armed_forces

WHEN NOT MATCHED
	THEN
		INSERT (
			id_armed_forces
			,cd_armed_forces
			,tx_armed_forces
			)
		VALUES (
			source.id_armed_forces
			,source.cd_armed_forces
			,source.tx_armed_forces
			);

UPDATE r
SET id_armed_forces = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_armed_forces_att p
		WHERE p.id_armed_forces = r.id_armed_forces
		)

DELETE FROM a
FROM rodis_wh.armed_forces_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_armed_forces_att s
		WHERE s.id_armed_forces = a.id_armed_forces
		)

UPDATE STATISTICS rodis_wh.armed_forces_att
