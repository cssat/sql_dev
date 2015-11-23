CREATE PROCEDURE [rodis_wh].[etl_ecode_att]
AS
IF OBJECT_ID('rodis_wh.staging_ecode_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_ecode_att

CREATE TABLE rodis_wh.staging_ecode_att(
	id_ecode INT NULL
	,cd_ecode VARCHAR(50) NULL
	,tx_ecode VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_ecode_att_id_ecode ON rodis_wh.staging_ecode_att (
	id_ecode
	)

CREATE NONCLUSTERED INDEX idx_staging_ecode_att_cd_ecode ON rodis_wh.staging_ecode_att (
	cd_ecode
	)

INSERT rodis_wh.staging_ecode_att (
	cd_ecode
	,tx_ecode
	)
SELECT DISTINCT CONVERT(VARCHAR(50), b.r_ecode1) [cd_ecode]
	,CONVERT(VARCHAR(50), b.r_ecode1) + ' - Undefined' [tx_ecode]
FROM rodis.bab_read b
WHERE b.r_ecode1 IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cbecode1) [cd_ecode]
	,CONVERT(VARCHAR(50), b.cbecode1) + ' - Undefined' [tx_ecode]
FROM rodis.berd b
WHERE b.cbecode1 IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cmecode1) [cd_ecode]
	,CONVERT(VARCHAR(50), b.cmecode1) + ' - Undefined' [tx_ecode]
FROM rodis.berd b
WHERE b.cmecode1 IS NOT NULL

UNION

SELECT '-1' [cd_ecode]
	,'Unspecified' [tx_ecode]
ORDER BY 1
	,2

UPDATE STATISTICS rodis_wh.staging_ecode_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'ecode'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_ecode) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_ecode [source_key]
FROM rodis_wh.staging_ecode_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_ecode
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_ecode = k.entity_key
FROM rodis_wh.staging_ecode_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_ecode AND k.wh_column_id = @column_id

MERGE rodis_wh.ecode_att [target]
USING rodis_wh.staging_ecode_att [source]
	ON target.id_ecode = source.id_ecode
WHEN MATCHED
	THEN
		UPDATE
		SET tx_ecode = source.tx_ecode
WHEN NOT MATCHED
	THEN
		INSERT (
			id_ecode
			,cd_ecode
			,tx_ecode
			)
		VALUES (
			source.id_ecode
			,source.cd_ecode
			,source.tx_ecode
			);

UPDATE STATISTICS rodis_wh.ecode_att

UPDATE r
SET id_ecode = k.entity_key
FROM rodis_wh.hospital_admission_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_ecode_att p
		WHERE p.id_ecode = r.id_ecode
		)

DELETE FROM a
FROM rodis_wh.ecode_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_ecode_att s
		WHERE s.id_ecode = a.id_ecode
		)

UPDATE STATISTICS rodis_wh.ecode_att
