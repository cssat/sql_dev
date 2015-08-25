CREATE PROCEDURE [rodis_wh].[etl_cause_of_death_att]
AS
IF OBJECT_ID('rodis_wh.staging_cause_of_death_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_cause_of_death_att

CREATE TABLE rodis_wh.staging_cause_of_death_att(
	id_cause_of_death INT NULL
	,cd_cause_of_death VARCHAR(50) NULL
	,tx_cause_of_death VARCHAR(50) NULL
)

INSERT rodis_wh.staging_cause_of_death_att (
	cd_cause_of_death
	,tx_cause_of_death
	)
SELECT DISTINCT cd_cause_of_death [cd_cause_of_death]
	,cd_cause_of_death + ' - Undefined' [tx_cause_of_death]
FROM (
	SELECT cause_of_death_order
		,cd_cause_of_death
	FROM (
		SELECT CONVERT(VARCHAR(5), d_ccod) [d_ccod0]
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
		) c
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
	) c

UNION ALL

SELECT CONVERT(VARCHAR(50), '-1') [cd_cause_of_death]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_cause_of_death]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_cause_of_death_att

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_att_id_cause_of_death ON rodis_wh.staging_cause_of_death_att (
	id_cause_of_death
	)

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_att_cd_cause_of_death ON rodis_wh.staging_cause_of_death_att (
	cd_cause_of_death
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'cause_of_death'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_cause_of_death) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_cause_of_death [source_key]
FROM rodis_wh.staging_cause_of_death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_cause_of_death
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_cause_of_death = k.entity_key
FROM rodis_wh.staging_cause_of_death_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_cause_of_death AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_cause_of_death_att

MERGE rodis_wh.cause_of_death_att [target]
USING rodis_wh.staging_cause_of_death_att [source]
	ON target.id_cause_of_death = source.id_cause_of_death
WHEN MATCHED
	THEN
		UPDATE
		SET tx_cause_of_death = source.tx_cause_of_death

WHEN NOT MATCHED
	THEN
		INSERT (
			id_cause_of_death
			,cd_cause_of_death
			,tx_cause_of_death
			)
		VALUES (
			source.id_cause_of_death
			,source.cd_cause_of_death
			,source.tx_cause_of_death
			);

UPDATE STATISTICS rodis_wh.cause_of_death_att

UPDATE r
SET id_cause_of_death = k.entity_key
FROM rodis_wh.cause_of_death_m2m_fat r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_cause_of_death_att p
		WHERE p.id_cause_of_death = r.id_cause_of_death
		)

DELETE FROM a
FROM rodis_wh.cause_of_death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_cause_of_death_att s
		WHERE s.id_cause_of_death = a.id_cause_of_death
		)

UPDATE STATISTICS rodis_wh.cause_of_death_att
