CREATE PROCEDURE [rodis_wh].[etl_discharge_status_att]
AS
IF OBJECT_ID('rodis_wh.staging_discharge_status_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_discharge_status_att

CREATE TABLE rodis_wh.staging_discharge_status_att(
	id_discharge_status INT NULL
	,cd_discharge_status VARCHAR(50) NULL
	,tx_discharge_status VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_discharge_status_att_id_discharge_status ON rodis_wh.staging_discharge_status_att (
	id_discharge_status
	)

CREATE NONCLUSTERED INDEX idx_staging_discharge_status_att_cd_discharge_status ON rodis_wh.staging_discharge_status_att (
	cd_discharge_status
	)

INSERT rodis_wh.staging_discharge_status_att (
	cd_discharge_status
	,tx_discharge_status
	)
SELECT DISTINCT CONVERT(VARCHAR(50), b.r_status) [cd_discharge_status]
	,CONVERT(VARCHAR(50), b.r_status) + ' - Undefined' [tx_discharge_status]
FROM rodis.bab_read b
WHERE b.r_status IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cbstatus) [cd_discharge_status]
	,CONVERT(VARCHAR(50), b.cbstatus) + ' - Undefined' [tx_discharge_status]
FROM rodis.berd b
WHERE b.cbstatus IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cmstatus) [cd_discharge_status]
	,CONVERT(VARCHAR(50), b.cmstatus) + ' - Undefined' [tx_discharge_status]
FROM rodis.berd b
WHERE b.cmstatus IS NOT NULL

UNION

SELECT '-1' [cd_discharge_status]
	,'Unspecified' [tx_discharge_status]
ORDER BY 1
	,2

UPDATE STATISTICS rodis_wh.staging_discharge_status_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'discharge_status'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_discharge_status) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_discharge_status [source_key]
FROM rodis_wh.staging_discharge_status_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_discharge_status
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_discharge_status = k.entity_key
FROM rodis_wh.staging_discharge_status_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_discharge_status AND k.wh_column_id = @column_id

MERGE rodis_wh.discharge_status_att [target]
USING rodis_wh.staging_discharge_status_att [source]
	ON target.id_discharge_status = source.id_discharge_status
WHEN MATCHED
	THEN
		UPDATE
		SET tx_discharge_status = source.tx_discharge_status
WHEN NOT MATCHED
	THEN
		INSERT (
			id_discharge_status
			,cd_discharge_status
			,tx_discharge_status
			)
		VALUES (
			source.id_discharge_status
			,source.cd_discharge_status
			,source.tx_discharge_status
			);

UPDATE STATISTICS rodis_wh.discharge_status_att

UPDATE r
SET id_discharge_status = k.entity_key
FROM rodis_wh.hospital_admission_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_discharge_status_att p
		WHERE p.id_discharge_status = r.id_discharge_status
		)

DELETE FROM a
FROM rodis_wh.discharge_status_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_discharge_status_att s
		WHERE s.id_discharge_status = a.id_discharge_status
		)

UPDATE STATISTICS rodis_wh.discharge_status_att
