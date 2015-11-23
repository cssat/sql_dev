CREATE PROCEDURE [rodis_wh].[etl_city_att]
AS
IF OBJECT_ID('rodis_wh.staging_city_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_city_att

CREATE TABLE rodis_wh.staging_city_att(
	id_city INT NULL
	,cd_city VARCHAR(50) NULL
	,tx_city VARCHAR(100) NULL
	,id_county INT NULL
	,cd_county VARCHAR(50) NULL
)

;WITH dup_city AS (
	SELECT momres [city]
	FROM rodis.berd
	WHERE momres IS NOT NULL
	GROUP BY momres
	HAVING COUNT(DISTINCT mcnty) != 1

	UNION

	SELECT d_injcity [city]
	FROM rodis.bab_died
	WHERE d_injcity IS NOT NULL
	GROUP BY d_injcity
	HAVING COUNT(DISTINCT d_injcnty) != 1
	)

INSERT rodis_wh.staging_city_att (
	cd_city
	,tx_city
	,cd_county
	)
SELECT DISTINCT CASE
		WHEN d.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.bres) + '-' + CONVERT(VARCHAR(50), b.bcnty)
		ELSE CONVERT(VARCHAR(50), b.bres)
		END [cd_city]
	,CASE
		WHEN d.city IS NOT NULL
			THEN ISNULL(r.Value, CONVERT(VARCHAR(100), b.bres) + ' - Undefined') + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(100), b.bcnty) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(100), b.bres) + ' - Undefined')
		END [tx_city]
	,CONVERT(VARCHAR(50), b.bcnty) [cd_county]
FROM rodis.berd b
LEFT JOIN rodis.ref_res r ON r.Code = b.bres
LEFT JOIN rodis.ref_cnty c ON c.Code = b.bcnty
LEFT JOIN dup_city d ON d.city = b.bres
WHERE b.bres IS NOT NULL

UNION

SELECT DISTINCT CASE
		WHEN d.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.momres) + '-' + CONVERT(VARCHAR(50), b.mcnty)
		ELSE CONVERT(VARCHAR(50), b.momres)
		END [cd_city]
	,CASE
		WHEN d.city IS NOT NULL
			THEN ISNULL(r.Value, CONVERT(VARCHAR(100), b.momres) + ' - Undefined') + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(100), b.mcnty) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(100), b.momres) + ' - Undefined')
		END [tx_city]
	,CONVERT(VARCHAR(50), b.mcnty) [cd_county]
FROM rodis.berd b
LEFT JOIN rodis.ref_res r ON r.Code = b.momres
LEFT JOIN rodis.ref_cnty c ON c.Code = b.mcnty
LEFT JOIN dup_city d ON d.city = b.momres
WHERE b.momres IS NOT NULL

UNION

SELECT DISTINCT '-1--1-' + CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.mombirst) + '-' + CONVERT(VARCHAR(50), b.mcountry)
		ELSE CONVERT(VARCHAR(50), b.mombirst)
		END [cd_city]
	,'Undefined - Undefined - ' + CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(100), b.mcountry) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(100), b.mombirst) + ' - Undefined')
		END [tx_city]
	,'-1-' + CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.mombirst) + '-' + CONVERT(VARCHAR(50), b.mcountry)
		ELSE CONVERT(VARCHAR(50), b.mombirst)
		END [cd_county]
FROM rodis.berd b
LEFT JOIN rodis.ref_birst r ON r.Code = b.mombirst
LEFT JOIN rodis.ref_country c ON c.Code = b.mcountry
WHERE b.mombirst IS NOT NULL

UNION

SELECT DISTINCT '-1--1-' + CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.dadbirst) + '-' + CONVERT(VARCHAR(50), b.dcountry)
		ELSE CONVERT(VARCHAR(50), b.dadbirst)
		END [cd_city]
	,'Undefined - Undefined - ' + CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(100), b.dcountry) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(100), b.dadbirst) + ' - Undefined')
		END [tx_city]
	,'-1-' + CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.dadbirst) + '-' + CONVERT(VARCHAR(50), b.dcountry)
		ELSE CONVERT(VARCHAR(50), b.dadbirst)
		END [cd_county]
FROM rodis.berd b
LEFT JOIN rodis.ref_birst r ON r.Code = b.dadbirst
LEFT JOIN rodis.ref_country c ON c.Code = b.dcountry
WHERE b.dadbirst IS NOT NULL

UNION

SELECT DISTINCT CASE
		WHEN d.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_dcity) + '-' + CONVERT(VARCHAR(50), b.d_dcnty)
		ELSE CONVERT(VARCHAR(50), b.d_dcity)
		END [cd_city]
	,CASE
		WHEN d.city IS NOT NULL
			THEN ISNULL(r.Value, CONVERT(VARCHAR(100), b.d_dcity) + ' - Undefined') + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(100), b.d_dcnty) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(100), b.d_dcity) + ' - Undefined')
		END [tx_city]
	,CONVERT(VARCHAR(50), b.d_dcnty) [cd_county]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_res r ON r.Code = b.d_dcity
LEFT JOIN rodis.ref_cnty c ON c.Code = b.d_dcnty
LEFT JOIN dup_city d ON d.city = b.d_dcity
WHERE b.d_dcity IS NOT NULL

UNION

SELECT DISTINCT CASE
		WHEN d.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_injcity) + '-' + CONVERT(VARCHAR(50), b.d_injcnty)
		ELSE CONVERT(VARCHAR(50), b.d_injcity)
		END [cd_city]
	,CASE
		WHEN d.city IS NOT NULL
			THEN ISNULL(r.Value, CONVERT(VARCHAR(100), b.d_injcity) + ' - Undefined') + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(100), b.d_injcnty) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(100), b.d_injcity) + ' - Undefined')
		END [tx_city]
	,CONVERT(VARCHAR(50), b.d_injcnty) [cd_county]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_res r ON r.Code = b.d_injcity
LEFT JOIN rodis.ref_cnty c ON c.Code = b.d_injcnty
LEFT JOIN dup_city d ON d.city = b.d_injcity
WHERE b.d_injcity IS NOT NULL

UNION

SELECT DISTINCT CASE
		WHEN d.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_rcity) + '-' + CONVERT(VARCHAR(50), b.d_rcnty)
		ELSE CONVERT(VARCHAR(50), b.d_rcity)
		END [cd_city]
	,CASE
		WHEN d.city IS NOT NULL
			THEN ISNULL(r.Value, CONVERT(VARCHAR(100), b.d_rcity) + ' - Undefined') + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(100), b.d_rcnty) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(100), b.d_rcity) + ' - Undefined')
		END [tx_city]
	,CONVERT(VARCHAR(50), b.d_rcnty) [cd_county]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_res r ON r.Code = b.d_rcity
LEFT JOIN rodis.ref_cnty c ON c.Code = b.d_rcnty
LEFT JOIN dup_city d ON d.city = b.d_rcity
WHERE b.d_rcity IS NOT NULL

UNION

SELECT CONVERT(VARCHAR(50), -1) [cd_city]
	,CONVERT(VARCHAR(100), 'Unspecified') [tx_city]
	,CONVERT(VARCHAR(50), -1) [cd_county]
ORDER BY 1
	,3

UPDATE STATISTICS rodis_wh.staging_city_att

CREATE NONCLUSTERED INDEX idx_staging_city_att_id_city ON rodis_wh.staging_city_att (
	id_city
	)

CREATE NONCLUSTERED INDEX idx_staging_city_att_cd_city ON rodis_wh.staging_city_att (
	cd_city
	)

CREATE NONCLUSTERED INDEX idx_staging_city_att_cd_county ON rodis_wh.staging_city_att (
	cd_county
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'city'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_city) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_city [source_key]
FROM rodis_wh.staging_city_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_city
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_city = k.entity_key
FROM rodis_wh.staging_city_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_city AND k.wh_column_id = @column_id

UPDATE a
SET id_county = k.id_county
FROM rodis_wh.staging_city_att a
INNER JOIN rodis_wh.staging_county_att k ON k.cd_county = a.cd_county

UPDATE STATISTICS rodis_wh.staging_city_att

MERGE rodis_wh.city_att [target]
USING rodis_wh.staging_city_att [source]
	ON target.id_city = source.id_city
WHEN MATCHED
	THEN
		UPDATE
		SET tx_city = source.tx_city
			,id_county = source.id_county
WHEN NOT MATCHED
	THEN
		INSERT (
			id_city
			,cd_city
			,tx_city
			,id_county
			)
		VALUES (
			source.id_city
			,source.cd_city
			,source.tx_city
			,source.id_county
			);

UPDATE STATISTICS rodis_wh.city_att

UPDATE r
SET id_city_current = k.entity_key
FROM rodis_wh.birth_familial_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_city_att p
		WHERE p.id_city = r.id_city_current
		)

UPDATE r
SET id_city_birth = k.entity_key
FROM rodis_wh.birth_familial_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_city_att p
		WHERE p.id_city = r.id_city_birth
		)

UPDATE r
SET id_city_of_death = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_city_att p
		WHERE p.id_city = r.id_city_of_death
		)

UPDATE r
SET id_city_of_injury = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_city_att p
		WHERE p.id_city = r.id_city_of_injury
		)

UPDATE r
SET id_city_of_residence_at_death = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_city_att p
		WHERE p.id_city = r.id_city_of_residence_at_death
		)

DELETE FROM a
FROM rodis_wh.city_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_city_att s
		WHERE s.id_city = a.id_city
		)

UPDATE STATISTICS rodis_wh.city_att
