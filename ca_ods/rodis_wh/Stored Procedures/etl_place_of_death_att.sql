CREATE PROCEDURE [rodis_wh].[etl_place_of_death_att]
AS
IF OBJECT_ID('rodis_wh.staging_place_of_death_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_place_of_death_att

CREATE TABLE rodis_wh.staging_place_of_death_att(
	id_place_of_death INT NULL
	,cd_place_of_death VARCHAR(50) NULL
	,tx_place_of_death VARCHAR(50) NULL
	,id_place_of_death_type INT NULL
	,cd_place_of_death_type VARCHAR(50) NULL
)

;WITH dups AS (
	SELECT d_dispo
	FROM rodis.bab_died
	WHERE d_dispo IS NOT NULL
	GROUP BY d_dispo
	HAVING COUNT(DISTINCT d_dthplace) != 1
)

INSERT rodis_wh.staging_place_of_death_att (
	cd_place_of_death
	,tx_place_of_death
	,cd_place_of_death_type
	)
SELECT DISTINCT CASE
		WHEN d.d_dispo IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_dispo) + '-' + ISNULL(CONVERT(VARCHAR(50), b.d_dthplace), CONVERT(VARCHAR(50), -1))
		ELSE CONVERT(VARCHAR(50), b.d_dispo)
		END [cd_place_of_death]
	,CASE
		WHEN d.d_dispo IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_dispo) + ' - Undefined - ' + CONVERT(VARCHAR(50), b.d_dthplace) + ' - Undefined'
		ELSE CONVERT(VARCHAR(50), b.d_dispo) + ' - Undefined'
		END [tx_place_of_death]
	,ISNULL(CONVERT(VARCHAR(50), b.d_dthplace), CONVERT(VARCHAR(50), -1)) [cd_place_of_death_type]
FROM rodis.bab_died b
LEFT JOIN dups d ON d.d_dispo = b.d_dispo
WHERE b.d_dispo IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_place_of_death]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_place_of_death]
	,CONVERT(VARCHAR(50), -1) [cd_place_of_death_type]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_place_of_death_att

CREATE NONCLUSTERED INDEX idx_staging_place_of_death_att_id_place_of_death ON rodis_wh.staging_place_of_death_att (
	id_place_of_death
	)

CREATE NONCLUSTERED INDEX idx_staging_place_of_death_att_cd_place_of_death ON rodis_wh.staging_place_of_death_att (
	cd_place_of_death
	)

CREATE NONCLUSTERED INDEX idx_staging_place_of_death_att_cd_place_of_death_type ON rodis_wh.staging_place_of_death_att (
	cd_place_of_death_type
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'place_of_death'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_place_of_death) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_place_of_death [source_key]
FROM rodis_wh.staging_place_of_death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_place_of_death
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_place_of_death = k.entity_key
FROM rodis_wh.staging_place_of_death_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_place_of_death AND k.wh_column_id = @column_id

UPDATE a
SET id_place_of_death_type = k.id_place_of_death_type
FROM rodis_wh.staging_place_of_death_att a
INNER JOIN rodis_wh.staging_place_of_death_type_att k ON k.cd_place_of_death_type = a.cd_place_of_death_type

UPDATE STATISTICS rodis_wh.staging_place_of_death_att

MERGE rodis_wh.place_of_death_att [target]
USING rodis_wh.staging_place_of_death_att [source]
	ON target.id_place_of_death = source.id_place_of_death
WHEN MATCHED
	THEN
		UPDATE
		SET tx_place_of_death = source.tx_place_of_death
			,id_place_of_death_type = source.id_place_of_death_type

WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_place_of_death
			,cd_place_of_death
			,tx_place_of_death
			,id_place_of_death_type
			)
		VALUES (
			source.id_place_of_death
			,source.cd_place_of_death
			,source.tx_place_of_death
			,source.id_place_of_death_type
			);

UPDATE r
SET id_place_of_death = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_place_of_death_att p
		WHERE p.id_place_of_death = r.id_place_of_death
		)

DELETE FROM a
FROM rodis_wh.place_of_death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_place_of_death_att s
		WHERE s.id_place_of_death = a.id_place_of_death
		)

UPDATE STATISTICS rodis_wh.place_of_death_att
