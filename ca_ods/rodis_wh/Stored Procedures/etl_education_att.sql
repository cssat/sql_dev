CREATE PROCEDURE [rodis_wh].[etl_education_att]
AS
IF OBJECT_ID('rodis_wh.staging_education_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_education_att

CREATE TABLE rodis_wh.staging_education_att(
	id_education INT NULL
	,cd_education VARCHAR(50) NULL
	,tx_education VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_education_att_id_education ON rodis_wh.staging_education_att (
	id_education
	)

CREATE NONCLUSTERED INDEX idx_staging_education_att_cd_education ON rodis_wh.staging_education_att (
	cd_education
	)

INSERT rodis_wh.staging_education_att (
	cd_education
	,tx_education
	)
SELECT DISTINCT CONVERT(VARCHAR(50), momedu) [cd_education]
	,CONVERT(VARCHAR(50), momedu) + ' - Undefined' [tx_education]
FROM rodis.berd
WHERE momedu IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), momle8ed) [cd_education]
	,CONVERT(VARCHAR(50), momle8ed) + ' - Undefined' [tx_education]
FROM rodis.berd
WHERE momle8ed IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), dadedu) [cd_education]
	,CONVERT(VARCHAR(50), dadedu) + ' - Undefined' [tx_education]
FROM rodis.berd
WHERE dadedu IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), dadle8ed) [cd_education]
	,CONVERT(VARCHAR(50), dadle8ed) + ' - Undefined' [tx_education]
FROM rodis.berd
WHERE dadle8ed IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), d_educate) [cd_education]
	,CONVERT(VARCHAR(50), d_educate) + ' - Undefined' [tx_education]
FROM rodis.bab_died
WHERE d_educate IS NOT NULL

UNION

SELECT '-1' [cd_education]
	,'Unspecified' [tx_education]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_education_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'education'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_education) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_education [source_key]
FROM rodis_wh.staging_education_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_education
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_education = k.entity_key
FROM rodis_wh.staging_education_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_education AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_education_att

MERGE rodis_wh.education_att [target]
USING rodis_wh.staging_education_att [source]
	ON target.id_education = source.id_education
WHEN MATCHED
	THEN
		UPDATE
		SET tx_education = source.tx_education

WHEN NOT MATCHED
	THEN
		INSERT (
			id_education
			,cd_education
			,tx_education
			)
		VALUES (
			source.id_education
			,source.cd_education
			,source.tx_education
			);

UPDATE STATISTICS rodis_wh.education_att

UPDATE r
SET id_education = k.entity_key
FROM rodis_wh.birth_familial_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_education_att p
		WHERE p.id_education = r.id_education
		)

UPDATE r
SET id_education = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_education_att p
		WHERE p.id_education = r.id_education
		)

DELETE FROM a
FROM rodis_wh.education_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_education_att s
		WHERE s.id_education = a.id_education
		)

UPDATE STATISTICS rodis_wh.education_att
