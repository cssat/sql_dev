CREATE PROCEDURE [rodis_wh].[etl_csection_att]
AS
IF OBJECT_ID('rodis_wh.staging_csection_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_csection_att

CREATE TABLE rodis_wh.staging_csection_att(
	id_csection INT NULL
	,cd_csection VARCHAR(50) NULL
	,tx_csection VARCHAR(50) NULL
)

INSERT rodis_wh.staging_csection_att (
	cd_csection
	,tx_csection
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_csection]
	,CONVERT(VARCHAR(50), Value) [tx_csection]
FROM rodis.ref_csection

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.csection) [cd_csection]
	,ISNULL(CONVERT(VARCHAR(50), r.Value), CONVERT(VARCHAR(50), b.csection) + ' - Undefined') [tx_csection]
FROM rodis.berd b
LEFT JOIN rodis.ref_csection r ON r.Code = b.csection

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_csection]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_csection]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_csection_att

CREATE NONCLUSTERED INDEX idx_staging_csection_att_id_csection ON rodis_wh.staging_csection_att (
	id_csection
	)

CREATE NONCLUSTERED INDEX idx_staging_csection_att_cd_csection ON rodis_wh.staging_csection_att (
	cd_csection
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'csection'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_csection) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_csection [source_key]
FROM rodis_wh.staging_csection_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_csection
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_csection = k.entity_key
FROM rodis_wh.staging_csection_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_csection AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_csection_att

MERGE rodis_wh.csection_att [target]
USING rodis_wh.staging_csection_att [source]
	ON target.id_csection = source.id_csection
WHEN MATCHED
	THEN
		UPDATE
		SET tx_csection = source.tx_csection
WHEN NOT MATCHED
	THEN
		INSERT (
			id_csection
			,cd_csection
			,tx_csection
			)
		VALUES (
			source.id_csection
			,source.cd_csection
			,source.tx_csection
			);

UPDATE STATISTICS rodis_wh.csection_att

UPDATE r
SET id_csection = k.entity_key
FROM rodis_wh.maternal_procedure_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_csection_att p
		WHERE p.id_csection = r.id_csection
		)

DELETE FROM a
FROM rodis_wh.csection_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_csection_att s
		WHERE s.id_csection = a.id_csection
		)

UPDATE STATISTICS rodis_wh.csection_att
