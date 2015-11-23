CREATE PROCEDURE [rodis_wh].[etl_country_att]
AS
IF OBJECT_ID('rodis_wh.staging_country_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_country_att

CREATE TABLE rodis_wh.staging_country_att(
	id_country INT NULL
	,cd_country VARCHAR(50) NULL
	,tx_country VARCHAR(50) NULL
)

INSERT rodis_wh.staging_country_att (
	cd_country
	,tx_country
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_country]
	,CONVERT(VARCHAR(50), Value) [tx_country]
FROM rodis.ref_country

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.bcountry) [cd_country]
	,ISNULL(CONVERT(VARCHAR(50), r.Value), CONVERT(VARCHAR(50), b.bcountry) + ' - Undefined') [tx_country]
FROM rodis.berd b
LEFT JOIN rodis.ref_country r ON r.Code = b.bcountry
WHERE b.bcountry IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.dcountry) [cd_country]
	,ISNULL(CONVERT(VARCHAR(50), r.Value), CONVERT(VARCHAR(50), b.dcountry) + ' - Undefined') [tx_country]
FROM rodis.berd b
LEFT JOIN rodis.ref_country r ON r.Code = b.dcountry
WHERE b.dcountry IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.mcountry) [cd_country]
	,ISNULL(CONVERT(VARCHAR(50), r.Value), CONVERT(VARCHAR(50), b.mcountry) + ' - Undefined') [tx_country]
FROM rodis.berd b
LEFT JOIN rodis.ref_country r ON r.Code = b.mcountry
WHERE b.mcountry IS NOT NULL

UNION

SELECT '-1' [cd_country]
	,'Unspecified' [tx_country]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_country_att

CREATE NONCLUSTERED INDEX idx_staging_country_att_id_country ON rodis_wh.staging_country_att (
	id_country
	)

CREATE NONCLUSTERED INDEX idx_staging_country_att_cd_country ON rodis_wh.staging_country_att (
	cd_country
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'country'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_country) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_country [source_key]
FROM rodis_wh.staging_country_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_country
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_country = k.entity_key
FROM rodis_wh.staging_country_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_country AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_country_att

MERGE rodis_wh.country_att [target]
USING rodis_wh.staging_country_att [source]
	ON target.id_country = source.id_country
WHEN MATCHED
	THEN
		UPDATE
		SET tx_country = source.tx_country

WHEN NOT MATCHED
	THEN
		INSERT (
			id_country
			,cd_country
			,tx_country
			)
		VALUES (
			source.id_country
			,source.cd_country
			,source.tx_country
			);

UPDATE STATISTICS rodis_wh.country_att

UPDATE r
SET id_country = k.entity_key
FROM rodis_wh.state_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_country_att p
		WHERE p.id_country = r.id_country
		)

DELETE FROM a
FROM rodis_wh.country_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_country_att s
		WHERE s.id_country = a.id_country
		)

UPDATE STATISTICS rodis_wh.country_att
