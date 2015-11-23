CREATE PROCEDURE [rodis_wh].[etl_occupation_att]
AS
IF OBJECT_ID('rodis_wh.staging_occupation_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_occupation_att

CREATE TABLE rodis_wh.staging_occupation_att(
	id_occupation INT NULL
	,cd_occupation VARCHAR(50) NULL
	,tx_occupation VARCHAR(50) NULL
)

INSERT rodis_wh.staging_occupation_att (
	cd_occupation
	,tx_occupation
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_occupation]
	,CONVERT(VARCHAR(50), Value) [tx_occupation]
FROM rodis.ref_occ

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.momocc) [cd_occupation]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.momocc) + ' - Undefined') [tx_occupation]
FROM rodis.berd b
LEFT JOIN rodis.ref_occ r ON r.Code = b.momocc
WHERE b.momocc IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.dadocc) [cd_occupation]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.dadocc) + ' - Undefined') [tx_occupation]
FROM rodis.berd b
LEFT JOIN rodis.ref_occ r ON r.Code = b.dadocc
WHERE b.dadocc IS NOT NULL

UNION

SELECT '-1' [cd_occupation]
	,'Unspecified' [tx_occupation]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_occupation_att

CREATE NONCLUSTERED INDEX idx_staging_occupation_att_id_occupation ON rodis_wh.staging_occupation_att (
	id_occupation
	)

CREATE NONCLUSTERED INDEX idx_staging_occupation_att_cd_occupation ON rodis_wh.staging_occupation_att (
	cd_occupation
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'occupation'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_occupation) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_occupation [source_key]
FROM rodis_wh.staging_occupation_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_occupation
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_occupation = k.entity_key
FROM rodis_wh.staging_occupation_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_occupation AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_occupation_att

MERGE rodis_wh.occupation_att [target]
USING rodis_wh.staging_occupation_att [source]
	ON target.id_occupation = source.id_occupation
WHEN MATCHED
	THEN
		UPDATE
		SET tx_occupation = source.tx_occupation
WHEN NOT MATCHED
	THEN
		INSERT (
			id_occupation
			,cd_occupation
			,tx_occupation
			)
		VALUES (
			source.id_occupation
			,source.cd_occupation
			,source.tx_occupation
			);

UPDATE STATISTICS rodis_wh.occupation_att

UPDATE r
SET id_occupation = k.entity_key
FROM rodis_wh.birth_familial_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_occupation_att p
		WHERE p.id_occupation = r.id_occupation
		)

DELETE FROM a
FROM rodis_wh.occupation_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_occupation_att s
		WHERE s.id_occupation = a.id_occupation
		)

UPDATE STATISTICS rodis_wh.occupation_att
