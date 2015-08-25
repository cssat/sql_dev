CREATE PROCEDURE [rodis_wh].[etl_admission_source_att]
AS
IF OBJECT_ID('rodis_wh.staging_admission_source_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_admission_source_att

CREATE TABLE rodis_wh.staging_admission_source_att(
	id_admission_source INT NULL
	,cd_admission_source VARCHAR(50) NULL
	,tx_admission_source VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_admission_source_att_id_admission_source ON rodis_wh.staging_admission_source_att (
	id_admission_source
	)

CREATE NONCLUSTERED INDEX idx_staging_admission_source_att_cd_admission_source ON rodis_wh.staging_admission_source_att (
	cd_admission_source
	)

INSERT rodis_wh.staging_admission_source_att (
	cd_admission_source
	,tx_admission_source
	)
SELECT DISTINCT CONVERT(VARCHAR(50), b.r_admsor) + IIF(b.r_admty = 4, 'B', 'I') [cd_admission_source]
	,COALESCE(r1.Value, r2.Value, CONVERT(VARCHAR(50), b.r_admsor) + IIF(b.r_admty = 4, 'B', 'I') + ' - Undefined') [tx_admission_source]
FROM rodis.bab_read b
LEFT JOIN rodis.ref_prebirth_admin r1 ON r1.Code = b.r_admsor AND b.r_admty != 4
LEFT JOIN rodis.ref_postbirth_admin r2 ON r2.Code = b.r_admsor AND b.r_admty = 4
WHERE b.r_admsor IS NOT NULL
	AND b.r_admty IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cbadmsor) + IIF(b.cbadmty = 4, 'B', 'I') [cd_admission_source]
	,COALESCE(r1.Value, r2.Value, CONVERT(VARCHAR(50), b.cbadmsor) + IIF(b.cbadmty = 4, 'B', 'I') + ' - Undefined') [tx_admission_source]
FROM rodis.berd b
LEFT JOIN rodis.ref_prebirth_admin r1 ON r1.Code = b.cbadmsor AND b.cbadmty != 4
LEFT JOIN rodis.ref_postbirth_admin r2 ON r2.Code = b.cbadmsor AND b.cbadmty = 4
WHERE b.cbadmsor IS NOT NULL
	AND b.cbadmty IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cmadmsor) + IIF(b.cmadmty = 4, 'B', 'I') [cd_admission_source]
	,COALESCE(r1.Value, r2.Value, CONVERT(VARCHAR(50), b.cmadmsor) + IIF(b.cmadmty = 4, 'B', 'I') + ' - Undefined') [tx_admission_source]
FROM rodis.berd b
LEFT JOIN rodis.ref_prebirth_admin r1 ON r1.Code = b.cmadmsor AND b.cmadmty != 4
LEFT JOIN rodis.ref_postbirth_admin r2 ON r2.Code = b.cmadmsor AND b.cmadmty = 4
WHERE b.cmadmsor IS NOT NULL
	AND b.cmadmty IS NOT NULL

UNION

SELECT CONVERT(VARCHAR(50), Code) + 'I' [cd_admission_source]
	,Value [tx_admission_source]
FROM rodis.ref_prebirth_admin

UNION

SELECT CONVERT(VARCHAR(50), Code) + 'B' [cd_admission_source]
	,Value [tx_admission_source]
FROM rodis.ref_postbirth_admin

UNION

SELECT '-1' [cd_admission_source]
	,'Unspecified' [tx_admission_source]
ORDER BY 1
	,2

UPDATE STATISTICS rodis_wh.staging_admission_source_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'admission_source'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_admission_source) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_admission_source [source_key]
FROM rodis_wh.staging_admission_source_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_admission_source
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_admission_source = k.entity_key
FROM rodis_wh.staging_admission_source_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_admission_source AND k.wh_column_id = @column_id

MERGE rodis_wh.admission_source_att [target]
USING rodis_wh.staging_admission_source_att [source]
	ON target.id_admission_source = source.id_admission_source
WHEN MATCHED
	THEN
		UPDATE
		SET tx_admission_source = source.tx_admission_source
WHEN NOT MATCHED
	THEN
		INSERT (
			id_admission_source
			,cd_admission_source
			,tx_admission_source
			)
		VALUES (
			source.id_admission_source
			,source.cd_admission_source
			,source.tx_admission_source
			);

UPDATE STATISTICS rodis_wh.admission_source_att

UPDATE r
SET id_admission_source = k.entity_key
FROM rodis_wh.hospital_admission_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_admission_source_att p
		WHERE p.id_admission_source = r.id_admission_source
		)

DELETE FROM a
FROM rodis_wh.admission_source_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_admission_source_att s
		WHERE s.id_admission_source = a.id_admission_source
		)

UPDATE STATISTICS rodis_wh.admission_source_att
