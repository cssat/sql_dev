CREATE PROCEDURE [rodis_wh].[etl_cause_of_death_m2m_fat]
AS
IF OBJECT_ID('rodis_wh.staging_cause_of_death_m2m_fat') IS NOT NULL
	DROP TABLE rodis_wh.staging_cause_of_death_m2m_fat

CREATE TABLE rodis_wh.staging_cause_of_death_m2m_fat(
	id_cause_of_death_m2m INT NULL
	,cd_cause_of_death_m2m VARCHAR(50) NULL
	,id_cause_of_death INT NULL
	,cd_cause_of_death VARCHAR(50) NULL
	,id_cause_of_death_order INT NULL
	,cd_cause_of_death_order VARCHAR(50) NULL
	,id_death INT NULL
	,cd_death VARCHAR(50) NULL
)

INSERT rodis_wh.staging_cause_of_death_m2m_fat (
	cd_cause_of_death_m2m
	,cd_cause_of_death
	,cd_cause_of_death_order
	,cd_death
	)
SELECT CONVERT(VARCHAR(50), bc_uni) + '-' + cd_cause_of_death + '-' + REPLACE(cause_of_death_order, 'd_ccod', '') [cd_cause_of_death_m2m]
	,cd_cause_of_death
	,REPLACE(cause_of_death_order, 'd_ccod', '') [cd_cause_of_death_order]
	,CONVERT(VARCHAR(50), bc_uni) [cd_death]
FROM (
	SELECT bc_uni
		,cause_of_death_order
		,cd_cause_of_death
	FROM (
		SELECT bc_uni
			,CONVERT(VARCHAR(5), d_ccod) [d_ccod0]
			,d_ccod1
			,d_ccod2
			,d_ccod3
			,d_ccod4
			,d_ccod5
			,d_ccod6
			,d_ccod7
			,d_ccod8
			,d_ccod9
			,d_ccod10
		FROM rodis.bab_died
		) i
	UNPIVOT(cd_cause_of_death FOR cause_of_death_order IN (
				d_ccod0
				,d_ccod1
				,d_ccod2
				,d_ccod3
				,d_ccod4
				,d_ccod5
				,d_ccod6
				,d_ccod7
				,d_ccod8
				,d_ccod9
				,d_ccod10
				)
		) unpvt
	) i
ORDER BY 4
	,3

UPDATE STATISTICS rodis_wh.staging_cause_of_death_m2m_fat

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_m2m_fat_id_cause_of_death_order_m2m ON rodis_wh.staging_cause_of_death_m2m_fat (
	id_cause_of_death_m2m
	)

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_m2m_fat_cd_cause_of_death_order_m2m ON rodis_wh.staging_cause_of_death_m2m_fat (
	cd_cause_of_death_m2m
	)

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_m2m_fat_cd_cause_of_death ON rodis_wh.staging_cause_of_death_m2m_fat (
	cd_cause_of_death
	)

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_m2m_fat_cd_cause_of_death_order ON rodis_wh.staging_cause_of_death_m2m_fat (
	cd_cause_of_death_order
	)

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_m2m_fat_cd_death ON rodis_wh.staging_cause_of_death_m2m_fat (
	cd_death
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'cause_of_death_m2m'
			AND wh_table_type_id = 2 -- fat
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_cause_of_death_m2m) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_cause_of_death_m2m [source_key]
FROM rodis_wh.staging_cause_of_death_m2m_fat a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_cause_of_death_m2m
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_cause_of_death_m2m = k.entity_key
FROM rodis_wh.staging_cause_of_death_m2m_fat a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_cause_of_death_m2m AND k.wh_column_id = @column_id

UPDATE a
SET id_cause_of_death = k.id_cause_of_death
FROM rodis_wh.staging_cause_of_death_m2m_fat a
LEFT JOIN rodis_wh.staging_cause_of_death_att k ON k.cd_cause_of_death = ISNULL(a.cd_cause_of_death, '-1')

UPDATE a
SET id_cause_of_death_order = k.id_cause_of_death_order
FROM rodis_wh.staging_cause_of_death_m2m_fat a
LEFT JOIN rodis_wh.staging_cause_of_death_order_att k ON k.cd_cause_of_death_order = ISNULL(a.cd_cause_of_death_order, '-1')

UPDATE a
SET id_death = k.id_death
FROM rodis_wh.staging_cause_of_death_m2m_fat a
LEFT JOIN rodis_wh.staging_death_att k ON k.cd_death = ISNULL(a.cd_death, '-1')

MERGE rodis_wh.cause_of_death_m2m_fat [target]
USING rodis_wh.staging_cause_of_death_m2m_fat [source]
	ON target.id_cause_of_death_m2m = source.id_cause_of_death_m2m
WHEN MATCHED
	THEN
		UPDATE
		SET id_cause_of_death = source.id_cause_of_death
		,id_cause_of_death_order = source.id_cause_of_death_order
		,id_death = source.id_death
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_cause_of_death_m2m
			,cd_cause_of_death_m2m
			,id_cause_of_death
			,id_cause_of_death_order
			,id_death
			)
		VALUES (
			source.id_cause_of_death_m2m
			,source.cd_cause_of_death_m2m
			,source.id_cause_of_death
			,source.id_cause_of_death_order
			,source.id_death
			)
WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE;

UPDATE STATISTICS rodis_wh.cause_of_death_m2m_fat
