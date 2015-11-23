CREATE PROCEDURE [rodis_wh].[etl_dysfunctional_uterine_bleed_att]
AS
IF OBJECT_ID('rodis_wh.staging_dysfunctional_uterine_bleed_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_dysfunctional_uterine_bleed_att

CREATE TABLE rodis_wh.staging_dysfunctional_uterine_bleed_att(
	id_dysfunctional_uterine_bleed INT NULL
	,cd_dysfunctional_uterine_bleed VARCHAR(50) NULL
	,tx_dysfunctional_uterine_bleed VARCHAR(50) NULL
)

INSERT rodis_wh.staging_dysfunctional_uterine_bleed_att (
	cd_dysfunctional_uterine_bleed
	,tx_dysfunctional_uterine_bleed
	)
SELECT DISTINCT CONVERT(VARCHAR(50), trimest) [cd_dysfunctional_uterine_bleed]
	,CONVERT(VARCHAR(50), trimest) + ' - Undefined' [tx_dysfunctional_uterine_bleed]
FROM rodis.berd
WHERE trimest IS NOT NULL

UNION

SELECT CONVERT(VARCHAR(50), -1) [cd_dysfunctional_uterine_bleed]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_dysfunctional_uterine_bleed]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_dysfunctional_uterine_bleed_att

CREATE NONCLUSTERED INDEX idx_staging_dysfunctional_uterine_bleed_att_id_dysfunctional_uterine_bleed ON rodis_wh.staging_dysfunctional_uterine_bleed_att (
	id_dysfunctional_uterine_bleed
	)

CREATE NONCLUSTERED INDEX idx_staging_dysfunctional_uterine_bleed_att_cd_dysfunctional_uterine_bleed ON rodis_wh.staging_dysfunctional_uterine_bleed_att (
	cd_dysfunctional_uterine_bleed
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'dysfunctional_uterine_bleed'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_dysfunctional_uterine_bleed) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_dysfunctional_uterine_bleed [source_key]
FROM rodis_wh.staging_dysfunctional_uterine_bleed_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_dysfunctional_uterine_bleed
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_dysfunctional_uterine_bleed = k.entity_key
FROM rodis_wh.staging_dysfunctional_uterine_bleed_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_dysfunctional_uterine_bleed AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_dysfunctional_uterine_bleed_att

MERGE rodis_wh.dysfunctional_uterine_bleed_att [target]
USING rodis_wh.staging_dysfunctional_uterine_bleed_att [source]
	ON target.id_dysfunctional_uterine_bleed = source.id_dysfunctional_uterine_bleed
WHEN MATCHED
	THEN
		UPDATE
		SET tx_dysfunctional_uterine_bleed = source.tx_dysfunctional_uterine_bleed
WHEN NOT MATCHED
	THEN
		INSERT (
			id_dysfunctional_uterine_bleed
			,cd_dysfunctional_uterine_bleed
			,tx_dysfunctional_uterine_bleed
			)
		VALUES (
			source.id_dysfunctional_uterine_bleed
			,source.cd_dysfunctional_uterine_bleed
			,source.tx_dysfunctional_uterine_bleed
			);

UPDATE STATISTICS rodis_wh.dysfunctional_uterine_bleed_att

UPDATE r
SET id_dysfunctional_uterine_bleed = k.entity_key
FROM rodis_wh.maternal_condition_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_dysfunctional_uterine_bleed_att p
		WHERE p.id_dysfunctional_uterine_bleed = r.id_dysfunctional_uterine_bleed
		)

DELETE FROM a
FROM rodis_wh.dysfunctional_uterine_bleed_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_dysfunctional_uterine_bleed_att s
		WHERE s.id_dysfunctional_uterine_bleed = a.id_dysfunctional_uterine_bleed
		)

UPDATE STATISTICS rodis_wh.dysfunctional_uterine_bleed_att
