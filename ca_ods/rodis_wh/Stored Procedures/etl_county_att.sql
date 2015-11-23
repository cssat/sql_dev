CREATE PROCEDURE [rodis_wh].[etl_county_att]
AS
IF OBJECT_ID('rodis_wh.staging_county_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_county_att

CREATE TABLE rodis_wh.staging_county_att(
	id_county INT NULL
	,cd_county VARCHAR(50) NULL
	,tx_county VARCHAR(50) NULL
	,id_state INT NULL
	,cd_state VARCHAR(50) NULL
)

INSERT rodis_wh.staging_county_att (
	cd_county
	,tx_county
	,cd_state
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_county]
	,CONVERT(VARCHAR(50), Value) [tx_county]
	,CASE 
		WHEN Code >= 1 AND Code <= 39 -- WA Counties
			THEN '48' -- Washington
		WHEN Code >= 80 AND Code <= 85 -- Other U.S.
			THEN '99-0' -- Unknown - USA
		WHEN Code IN (97, 98) -- Foreign
			THEN '89-999' -- Other Foreign - 999 - Undefined
		ELSE '99--1' -- Unknown - Undefined
		END [cd_state]
FROM rodis.ref_cnty

UNION

SELECT DISTINCT CASE
		WHEN b.bcnty = 99 -- Unknown
			THEN CONVERT(VARCHAR(50), b.bcnty) + '-' + CONVERT(VARCHAR(50), b.cbirst)
		ELSE CONVERT(VARCHAR(50), b.bcnty)
		END [cd_county]
	,CASE
		WHEN b.bcnty = 99 -- Unknown
			THEN r.Value + ' - ' + ISNULL(s.Value, CONVERT(VARCHAR(50), b.cbirst) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(50), b.bcnty) + ' - Undefined')
		END [tx_county]
	,CONVERT(VARCHAR(50), b.cbirst) [cd_state]
FROM rodis.berd b
LEFT JOIN rodis.ref_cnty r ON r.Code = b.bcnty
LEFT JOIN rodis.ref_birst s ON s.Code = b.cbirst
WHERE b.cbirst IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.mcnty) [cd_county]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.mcnty) + ' - Undefined') [tx_county]
	,CASE
		WHEN b.mcnty >= 1 AND b.mcnty <= 39 -- WA Counties
			THEN '48' -- Washington
		ELSE '99--1' -- Unknown - Unspecified
		END [cd_state]
FROM rodis.berd b
LEFT JOIN rodis.ref_cnty r ON r.Code = b.mcnty
WHERE b.mcnty IS NOT NULL

UNION

SELECT DISTINCT '-1-' + CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.mombirst) + '-' + CONVERT(VARCHAR(50), b.mcountry)
		ELSE CONVERT(VARCHAR(50), b.mombirst)
		END [cd_county]
	,'Undefined - ' + CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(50), b.mcountry) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(50), b.mombirst) + ' - Undefined')
		END [tx_county]
	,CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.mombirst) + '-' + CONVERT(VARCHAR(50), b.mcountry)
		ELSE CONVERT(VARCHAR(50), b.mombirst)
		END [cd_state]
FROM rodis.berd b
LEFT JOIN rodis.ref_birst r ON r.Code = b.mombirst
LEFT JOIN rodis.ref_country c ON c.Code = b.mcountry
WHERE b.mombirst IS NOT NULL

UNION

SELECT DISTINCT '-1-' + CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.dadbirst) + '-' + CONVERT(VARCHAR(50), b.dcountry)
		ELSE CONVERT(VARCHAR(50), b.dadbirst)
		END [cd_county]
	,'Undefined - ' + CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(50), b.dcountry) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(50), b.dadbirst) + ' - Undefined')
		END [tx_county]
	,CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.dadbirst) + '-' + CONVERT(VARCHAR(50), b.dcountry)
		ELSE CONVERT(VARCHAR(50), b.dadbirst)
		END [cd_state]
FROM rodis.berd b
LEFT JOIN rodis.ref_birst r ON r.Code = b.dadbirst
LEFT JOIN rodis.ref_country c ON c.Code = b.dcountry
WHERE b.dadbirst IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.d_dcnty) [cd_county]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.d_dcnty) + ' - Undefined') [tx_county]
	,CASE
		WHEN b.d_dcnty >= 1 AND b.d_dcnty <= 39 -- WA Counties
			THEN '48' -- Washington
		ELSE '99--1' -- Unknown - Unspecified
		END [cd_state]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_cnty r ON r.Code = b.d_dcnty
WHERE b.d_dcnty IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.d_injcnty) [cd_county]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.d_injcnty) + ' - Undefined') [tx_county]
	,CASE 
		WHEN b.d_injcity >= 1 AND Code <= 39 -- WA Counties
			THEN '48' -- Washington
		ELSE '99--1' -- Unknown - Unspecified
		END [cd_state]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_cnty r ON r.Code = b.d_injcnty
WHERE b.d_injcnty IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.d_rcnty) [cd_county]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.d_rcnty) + ' - Undefined') [tx_county]
	,CASE
		WHEN b.d_rcnty >= 1 AND b.d_rcnty <= 39 -- WA Counties
			THEN '48' -- Washington
		ELSE '99--1' -- Unknown - Unspecified
		END [cd_state]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_cnty r ON r.Code = b.d_rcnty
WHERE b.d_rcnty IS NOT NULL

UNION

SELECT '-1' [cd_county]
	,'Unspecified' [tx_county]
	,'-1' [cd_state]
ORDER BY 1
	,3

UPDATE STATISTICS rodis_wh.staging_county_att

CREATE NONCLUSTERED INDEX idx_staging_county_att_id_county ON rodis_wh.staging_county_att (
	id_county
	)

CREATE NONCLUSTERED INDEX idx_staging_county_att_cd_county ON rodis_wh.staging_county_att (
	cd_county
	)

CREATE NONCLUSTERED INDEX idx_staging_county_att_cd_state ON rodis_wh.staging_county_att (
	cd_state
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'county'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_county) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_county [source_key]
FROM rodis_wh.staging_county_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_county
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_county = k.entity_key
FROM rodis_wh.staging_county_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_county AND k.wh_column_id = @column_id

UPDATE a
SET id_state = k.id_state
FROM rodis_wh.staging_county_att a
INNER JOIN rodis_wh.staging_state_att k ON k.cd_state = a.cd_state

UPDATE STATISTICS rodis_wh.staging_county_att

MERGE rodis_wh.county_att [target]
USING rodis_wh.staging_county_att [source]
	ON target.id_county = source.id_county
WHEN MATCHED
	THEN
		UPDATE
		SET tx_county = source.tx_county
			,id_state = source.id_state
WHEN NOT MATCHED
	THEN
		INSERT (
			id_county
			,cd_county
			,tx_county
			,id_state
			)
		VALUES (
			source.id_county
			,source.cd_county
			,source.tx_county
			,source.id_state
			);

UPDATE STATISTICS rodis_wh.county_att

UPDATE r
SET id_county = k.entity_key
FROM rodis_wh.city_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_county_att p
		WHERE p.id_county = r.id_county
		)

DELETE FROM a
FROM rodis_wh.county_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_county_att s
		WHERE s.id_county = a.id_county
		)

UPDATE STATISTICS rodis_wh.county_att
