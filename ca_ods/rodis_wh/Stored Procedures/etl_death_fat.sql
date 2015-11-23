CREATE PROCEDURE [rodis_wh].[etl_death_fat]
AS
IF OBJECT_ID('rodis_wh.staging_death_fat') IS NOT NULL
	DROP TABLE rodis_wh.staging_death_fat

CREATE TABLE rodis_wh.staging_death_fat(
	id_death_fact INT NULL
	,cd_death_fact VARCHAR(50) NULL
	,id_prsn_child INT NULL
	,id_county_file_number VARCHAR(10) NULL
	,id_calendar_dim_death INT NULL
	,id_calendar_dim_injury INT NULL
	,id_death INT NULL
	,cd_death VARCHAR(50) NULL
)

INSERT rodis_wh.staging_death_fat (
	cd_death_fact
	,id_prsn_child
	,id_county_file_number
	,id_calendar_dim_death
	,id_calendar_dim_injury
	,cd_death
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_death_fact]
	,PAT_ID [id_prsn_child]
	,d_cntyfile [id_county_file_number]
	,CONVERT(INT, CONVERT(VARCHAR(20), DATEFROMPARTS(deathyr, d_deathmo, d_deathdy), 112)) [id_calendar_dim_death]
	,CONVERT(INT, CONVERT(VARCHAR(20), CASE
		WHEN d_injyr IS NOT NULL
			THEN DATEFROMPARTS(d_injyr, CASE
					WHEN d_injmo > 12
						THEN 1
					ELSE d_injmo
					END, CASE
					WHEN d_injdy > 31
						THEN 1
					ELSE d_injdy
					END)
		ELSE CONVERT(DATETIME, NULL)
		END, 112)) [id_calendar_dim_injury]
	,CONVERT(VARCHAR(50), bc_uni) [cd_death]
FROM rodis.bab_died

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_death_fact]
	,CONVERT(INT, NULL) [id_prsn_child]
	,CONVERT(VARCHAR(10), NULL) [id_county_file_number]
	,CONVERT(INT, NULL) [id_calendar_dim_death]
	,CONVERT(INT, NULL) [id_calendar_dim_injury]
	,CONVERT(VARCHAR(50), -1) [cd_death]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_death_fat

CREATE NONCLUSTERED INDEX idx_staging_death_fat_id_death_fact ON rodis_wh.staging_death_fat (
	id_death_fact
	)

CREATE NONCLUSTERED INDEX idx_staging_death_fat_cd_death_fact ON rodis_wh.staging_death_fat (
	cd_death_fact
	)

CREATE NONCLUSTERED INDEX idx_staging_death_fat_cd_death ON rodis_wh.staging_death_fat (
	cd_death
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'death'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_death_fact) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_death_fact [source_key]
FROM rodis_wh.staging_death_fat a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_death_fact
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_death_fact = k.entity_key
FROM rodis_wh.staging_death_fat a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_death_fact AND k.wh_column_id = @column_id

UPDATE a
SET id_death = k.id_death
FROM rodis_wh.staging_death_fat a
INNER JOIN rodis_wh.staging_death_att k ON k.cd_armed_forces = ISNULL(a.id_death, '-1')

UPDATE STATISTICS rodis_wh.staging_death_fat

MERGE rodis_wh.death_fat [target]
USING rodis_wh.staging_death_fat [source]
	ON target.id_death_fact = source.id_death_fact
WHEN MATCHED
	THEN
		UPDATE
		SET id_prsn_child = source.id_prsn_child
			,id_county_file_number = source.id_county_file_number
			,id_calendar_dim_death = source.id_calendar_dim_death
			,id_calendar_dim_injury = source.id_calendar_dim_injury
			,id_death = source.id_death
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_death_fact
			,cd_death_fact
			,id_prsn_child
			,id_county_file_number
			,id_calendar_dim_death
			,id_calendar_dim_injury
			,id_death
			)
		VALUES (
			source.id_death_fact
			,source.cd_death_fact
			,source.id_prsn_child
			,source.id_county_file_number
			,source.id_calendar_dim_death
			,source.id_calendar_dim_injury
			,source.id_death
			)
WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE;

UPDATE STATISTICS rodis_wh.death_fat
