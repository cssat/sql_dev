CREATE PROCEDURE [rodis_wh].[etl_ethnicity_census_att]
AS
IF OBJECT_ID('rodis_wh.staging_ethnicity_census_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_ethnicity_census_att

CREATE TABLE rodis_wh.staging_ethnicity_census_att(
	id_ethnicity_census INT NULL
	,cd_ethnicity_census VARCHAR(50) NULL
	,tx_ethnicity_census VARCHAR(50) NULL
)

INSERT rodis_wh.staging_ethnicity_census_att (
	cd_ethnicity_census
	,tx_ethnicity_census
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_ethnicity_census]
	,CONVERT(VARCHAR(50), Value) [tx_ethnicity_census]
FROM rodis.ref_hisp

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), ISNULL(b.kidhisp, b.chisp)) [cd_ethnicity_census]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), ISNULL(b.kidhisp, b.chisp)) + ' - Undefined') [tx_ethnicity_census]
FROM rodis.berd b
LEFT JOIN rodis.ref_hisp r ON r.Code = ISNULL(b.kidhisp, b.chisp)
WHERE ISNULL(b.kidhisp, b.chisp) IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.momhisp) [cd_ethnicity_census]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.momhisp) + ' - Undefined') [tx_ethnicity_census]
FROM rodis.berd b
LEFT JOIN rodis.ref_hisp r ON r.Code = b.momhisp
WHERE b.momhisp IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.dadhisp) [cd_ethnicity_census]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.dadhisp) + ' - Undefined') [tx_ethnicity_census]
FROM rodis.berd b
LEFT JOIN rodis.ref_hisp r ON r.Code = b.dadhisp
WHERE b.dadhisp IS NOT NULL

UNION

SELECT '-1' [cd_ethnicity_census]
	,'Unspecified' [tx_ethnicity_census]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_ethnicity_census_att

CREATE NONCLUSTERED INDEX idx_staging_ethnicity_census_att_id_ethnicity_census ON rodis_wh.staging_ethnicity_census_att (
	id_ethnicity_census
	)

CREATE NONCLUSTERED INDEX idx_staging_ethnicity_census_att_cd_ethnicity_census ON rodis_wh.staging_ethnicity_census_att (
	cd_ethnicity_census
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'ethnicity_census'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_ethnicity_census) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_ethnicity_census [source_key]
FROM rodis_wh.staging_ethnicity_census_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_ethnicity_census
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_ethnicity_census = k.entity_key
FROM rodis_wh.staging_ethnicity_census_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_ethnicity_census AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_ethnicity_census_att

MERGE rodis_wh.ethnicity_census_att [target]
USING rodis_wh.staging_ethnicity_census_att [source]
	ON target.id_ethnicity_census = source.id_ethnicity_census
WHEN MATCHED
	THEN
		UPDATE
		SET tx_ethnicity_census = source.tx_ethnicity_census
WHEN NOT MATCHED
	THEN
		INSERT (
			id_ethnicity_census
			,cd_ethnicity_census
			,tx_ethnicity_census
			)
		VALUES (
			source.id_ethnicity_census
			,source.cd_ethnicity_census
			,source.tx_ethnicity_census
			);

UPDATE STATISTICS rodis_wh.ethnicity_census_att

UPDATE r
SET id_ethnicity_census = k.entity_key
FROM rodis_wh.birth_familial_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_ethnicity_census_att p
		WHERE p.id_ethnicity_census = r.id_ethnicity_census
		)

DELETE FROM a
FROM rodis_wh.ethnicity_census_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_ethnicity_census_att s
		WHERE s.id_ethnicity_census = a.id_ethnicity_census
		)

UPDATE STATISTICS rodis_wh.ethnicity_census_att
