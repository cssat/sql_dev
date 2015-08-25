CREATE PROCEDURE [rodis_wh].[etl_race_census_att]
AS
IF OBJECT_ID('rodis_wh.staging_race_census_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_race_census_att

CREATE TABLE rodis_wh.staging_race_census_att(
	id_race_census INT NULL
	,cd_race_census VARCHAR(50) NULL
	,tx_race_census VARCHAR(50) NULL
)

INSERT rodis_wh.staging_race_census_att (
	cd_race_census
	,tx_race_census
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_race_census]
	,CONVERT(VARCHAR(50), Value) [tx_race_census]
FROM rodis.ref_parent_race

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.kidrace) [cd_race_census]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.kidrace) + ' - Undefined') [tx_race_census]
FROM rodis.berd b
LEFT JOIN rodis.ref_parent_race r ON r.Code = b.kidrace
WHERE b.kidrace IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.momrace) [cd_race_census]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.momrace) + ' - Undefined') [tx_race_census]
FROM rodis.berd b
LEFT JOIN rodis.ref_parent_race r ON r.Code = b.momrace
WHERE b.momrace IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.dadrace) [cd_race_census]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.dadrace) + ' - Undefined') [tx_race_census]
FROM rodis.berd b
LEFT JOIN rodis.ref_parent_race r ON r.Code = b.dadrace
WHERE b.dadrace IS NOT NULL

UNION

SELECT '-1' [cd_race_census]
	,'Unspecified' [tx_race_census]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_race_census_att

CREATE NONCLUSTERED INDEX idx_staging_race_census_att_id_race_census ON rodis_wh.staging_race_census_att (
	id_race_census
	)

CREATE NONCLUSTERED INDEX idx_staging_race_census_att_cd_race_census ON rodis_wh.staging_race_census_att (
	cd_race_census
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'race_census'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_race_census) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_race_census [source_key]
FROM rodis_wh.staging_race_census_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_race_census
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_race_census = k.entity_key
FROM rodis_wh.staging_race_census_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_race_census AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_race_census_att

MERGE rodis_wh.race_census_att [target]
USING rodis_wh.staging_race_census_att [source]
	ON target.id_race_census = source.id_race_census
WHEN MATCHED
	THEN
		UPDATE
		SET tx_race_census = source.tx_race_census
WHEN NOT MATCHED
	THEN
		INSERT (
			id_race_census
			,cd_race_census
			,tx_race_census
			)
		VALUES (
			source.id_race_census
			,source.cd_race_census
			,source.tx_race_census
			);

UPDATE STATISTICS rodis_wh.race_census_att

UPDATE r
SET id_race_census = k.entity_key
FROM rodis_wh.birth_familial_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_race_census_att p
		WHERE p.id_race_census = r.id_race_census
		)

DELETE FROM a
FROM rodis_wh.race_census_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_race_census_att s
		WHERE s.id_race_census = a.id_race_census
		)

UPDATE STATISTICS rodis_wh.race_census_att
