CREATE PROCEDURE [rodis_wh].[etl_admission_reason_att]
AS
IF OBJECT_ID('rodis_wh.staging_admission_reason_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_admission_reason_att

CREATE TABLE rodis_wh.staging_admission_reason_att (
	id_admission_reason INT NULL
	,cd_admission_reason VARCHAR(50) NULL
	,tx_admission_reason VARCHAR(50) NULL
	)

CREATE NONCLUSTERED INDEX idx_staging_admission_reason_att_id_admission_reason ON rodis_wh.staging_admission_reason_att (
	id_admission_reason
	)

CREATE NONCLUSTERED INDEX idx_staging_admission_reason_att_cd_admission_reason ON rodis_wh.staging_admission_reason_att (
	cd_admission_reason
	)

INSERT rodis_wh.staging_admission_reason_att (
	cd_admission_reason
	,tx_admission_reason
	)
SELECT DISTINCT CONVERT(VARCHAR(50), b.r_admty) [cd_admission_reason]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.r_admty) + ' - Undefined') [tx_admission_reason]
FROM rodis.bab_read b
LEFT JOIN rodis.ref_admty r ON r.Code = b.r_admty
WHERE b.r_admty IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cbadmty) [cd_admission_reason]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.cbadmty) + ' - Undefined') [tx_admission_reason]
FROM rodis.berd b
LEFT JOIN rodis.ref_admty r ON r.Code = b.cbadmty
WHERE b.cbadmty IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cmadmty) [cd_admission_reason]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.cmadmty) + ' - Undefined') [tx_admission_reason]
FROM rodis.berd b
LEFT JOIN rodis.ref_admty r ON r.Code = b.cmadmty
WHERE b.cmadmty IS NOT NULL

UNION

SELECT CONVERT(VARCHAR(50), Code) [cd_admission_reason]
	,Value
FROM rodis.ref_admty

UNION

SELECT '-1' [cd_admission_reson]
	,'Unspecified' [tx_admission_reason]
ORDER BY 1
	,2

UPDATE STATISTICS rodis_wh.staging_admission_reason_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'admission_reason'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_admission_reason) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_admission_reason [source_key]
FROM rodis_wh.staging_admission_reason_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_admission_reason
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_admission_reason = k.entity_key
FROM rodis_wh.staging_admission_reason_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_admission_reason AND k.wh_column_id = @column_id

MERGE rodis_wh.admission_reason_att [target]
USING rodis_wh.staging_admission_reason_att [source]
	ON target.id_admission_reason = source.id_admission_reason
WHEN MATCHED
	THEN
		UPDATE
		SET tx_admission_reason = source.tx_admission_reason
WHEN NOT MATCHED
	THEN
		INSERT (
			id_admission_reason
			,cd_admission_reason
			,tx_admission_reason
			)
		VALUES (
			source.id_admission_reason
			,source.cd_admission_reason
			,source.tx_admission_reason
			);

UPDATE STATISTICS rodis_wh.admission_reason_att

UPDATE r
SET id_admission_reason = k.entity_key
FROM rodis_wh.hospital_admission_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_admission_reason_att p
		WHERE p.id_admission_reason = r.id_admission_reason
		)

DELETE FROM a
FROM rodis_wh.admission_reason_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_admission_reason_att s
		WHERE s.id_admission_reason = a.id_admission_reason
		)

UPDATE STATISTICS rodis_wh.admission_reason_att
