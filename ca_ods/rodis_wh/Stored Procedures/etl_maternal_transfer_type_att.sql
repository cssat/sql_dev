CREATE PROCEDURE [rodis_wh].[etl_maternal_transfer_type_att]
AS
IF OBJECT_ID('rodis_wh.staging_maternal_transfer_type_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_maternal_transfer_type_att

CREATE TABLE rodis_wh.staging_maternal_transfer_type_att(
	id_maternal_transfer_type INT NULL
	,cd_maternal_transfer_type VARCHAR(50) NULL
	,tx_maternal_transfer_type VARCHAR(50) NULL
)

INSERT rodis_wh.staging_maternal_transfer_type_att (
	cd_maternal_transfer_type
	,tx_maternal_transfer_type
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_maternal_transfer_type]
	,CONVERT(VARCHAR(50), Value) [tx_maternal_transfer_type]
FROM rodis.ref_momtrans

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.momtrans) [cd_maternal_transfer_type]
	,ISNULL(CONVERT(VARCHAR(50), r.Value), CONVERT(VARCHAR(50), b.momtrans) + ' - Undefined') [tx_maternal_transfer_type]
FROM rodis.berd b
LEFT JOIN rodis.ref_momtrans r ON r.Code = b.momtrans
WHERE b.momtrans IS NOT NULL

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_maternal_transfer_type]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_maternal_transfer_type]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_maternal_transfer_type_att

CREATE NONCLUSTERED INDEX idx_staging_maternal_transfer_type_att_id_maternal_transfer_type ON rodis_wh.staging_maternal_transfer_type_att (
	id_maternal_transfer_type
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_transfer_type_att_cd_maternal_transfer_type ON rodis_wh.staging_maternal_transfer_type_att (
	cd_maternal_transfer_type
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'maternal_transfer_type'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_maternal_transfer_type) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_maternal_transfer_type [source_key]
FROM rodis_wh.staging_maternal_transfer_type_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_maternal_transfer_type
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_maternal_transfer_type = k.entity_key
FROM rodis_wh.staging_maternal_transfer_type_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_maternal_transfer_type AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_maternal_transfer_type_att

MERGE rodis_wh.maternal_transfer_type_att [target]
USING rodis_wh.staging_maternal_transfer_type_att [source]
	ON target.id_maternal_transfer_type = source.id_maternal_transfer_type
WHEN MATCHED
	THEN
		UPDATE
		SET tx_maternal_transfer_type = source.tx_maternal_transfer_type
WHEN NOT MATCHED
	THEN
		INSERT (
			id_maternal_transfer_type
			,cd_maternal_transfer_type
			,tx_maternal_transfer_type
			)
		VALUES (
			source.id_maternal_transfer_type
			,source.cd_maternal_transfer_type
			,source.tx_maternal_transfer_type
			);

UPDATE STATISTICS rodis_wh.maternal_transfer_type_att

UPDATE r
SET id_maternal_transfer_type = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_transfer_type_att p
		WHERE p.id_maternal_transfer_type = r.id_maternal_transfer_type
		)

DELETE FROM a
FROM rodis_wh.maternal_transfer_type_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_transfer_type_att s
		WHERE s.id_maternal_transfer_type = a.id_maternal_transfer_type
		)

UPDATE STATISTICS rodis_wh.maternal_transfer_type_att
