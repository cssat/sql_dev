CREATE PROCEDURE [rodis_wh].[etl_state_att]
AS
IF OBJECT_ID('rodis_wh.staging_state_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_state_att

CREATE TABLE rodis_wh.staging_state_att(
	id_state INT NULL
	,cd_state VARCHAR(50) NULL
	,tx_state VARCHAR(50) NULL
	,id_country INT NULL
	,cd_country VARCHAR(50) NULL
)

INSERT rodis_wh.staging_state_att (
	cd_state
	,tx_state
	,cd_country
	)
SELECT CONVERT(VARCHAR(50), Code) [cd_state]
	,CONVERT(VARCHAR(50), Value) [tx_state]
	,CASE 
		WHEN Code >= 1 AND Code <= 51 -- US States
			THEN '0' -- USA
		WHEN Code IN (71, 72, 73) -- US Territories
			THEN '0' -- USA
		WHEN Code = 81 -- Canada
			THEN '401' -- Canada
		WHEN Code = 82 -- Cuba
			THEN '402' -- Cuba
		WHEN Code = 83 -- Mexico
			THEN '403' -- Mexico
		ELSE '-1'
		END [cd_country]
FROM rodis.ref_birst
WHERE Code NOT IN (89, 99) -- Other Foreign, Unknown -- defined in data files

UNION

SELECT DISTINCT CASE
		WHEN b.cbirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.cbirst) + '-' + CONVERT(VARCHAR(50), b.bcountry)
		ELSE CONVERT(VARCHAR(50), b.cbirst)
		END [cd_state]
	,CASE
		WHEN b.cbirst IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(50), b.bcountry) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(50), b.cbirst) + ' - Undefined')
		END [tx_state]
	,CONVERT(VARCHAR(50), b.bcountry) [cd_country]
FROM rodis.berd b
LEFT JOIN rodis.ref_birst r ON r.Code = b.cbirst
LEFT JOIN rodis.ref_country c ON c.Code = b.bcountry
WHERE b.cbirst IS NOT NULL

UNION

SELECT DISTINCT CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.mombirst) + '-' + CONVERT(VARCHAR(50), b.mcountry)
		ELSE CONVERT(VARCHAR(50), b.mombirst)
		END [cd_state]
	,CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(50), b.mcountry) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(50), b.mombirst) + ' - Undefined')
		END [tx_state]
	,CONVERT(VARCHAR(50), b.mcountry) [cd_country]
FROM rodis.berd b
LEFT JOIN rodis.ref_birst r ON r.Code = b.mombirst
LEFT JOIN rodis.ref_country c ON c.Code = b.mcountry
WHERE b.mombirst IS NOT NULL

UNION

SELECT DISTINCT CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.dadbirst) + '-' + CONVERT(VARCHAR(50), b.dcountry)
		ELSE CONVERT(VARCHAR(50), b.dadbirst)
		END [cd_state]
	,CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - ' + ISNULL(c.Value, CONVERT(VARCHAR(50), b.dcountry) + ' - Undefined')
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(50), b.dadbirst) + ' - Undefined')
		END [tx_state]
	,CONVERT(VARCHAR(50), b.dcountry) [cd_country]
FROM rodis.berd b
LEFT JOIN rodis.ref_birst r ON r.Code = b.dadbirst
LEFT JOIN rodis.ref_country c ON c.Code = b.dcountry
WHERE b.dadbirst IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.d_dstate) [cd_state]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.d_dstate) + ' - Undefined') [tx_state]
	,CASE 
		WHEN b.d_dstate >= 1 AND Code <= 51 -- US States
			THEN '0' -- USA
		WHEN b.d_dstate IN (71, 72, 73) -- US Territories
			THEN '0' -- USA
		WHEN b.d_dstate = 81 -- Canada
			THEN '401' -- Canada
		WHEN b.d_dstate = 82 -- Cuba
			THEN '402' -- Cuba
		WHEN b.d_dstate = 83 -- Mexico
			THEN '403' -- Mexico
		ELSE '-1'
		END [cd_country]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_birst r ON r.Code = b.d_dstate
WHERE b.d_dstate IS NOT NULL

UNION

SELECT DISTINCT CASE
		WHEN b.d_rstate IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.d_rstate) + '--1'
		ELSE CONVERT(VARCHAR(50), b.d_rstate)
		END [cd_state]
	,CASE
		WHEN b.d_rstate IN (89, 99) -- Other Foreign, Unknown
			THEN r.Value + ' - Unspecified'
		ELSE ISNULL(r.Value, CONVERT(VARCHAR(50), b.d_rstate) + ' - Undefined')
		END [tx_state]
	,CASE 
		WHEN b.d_rstate >= 1 AND Code <= 51 -- US States
			THEN '0' -- USA
		WHEN b.d_rstate IN (71, 72, 73) -- US Territories
			THEN '0' -- USA
		WHEN b.d_rstate = 81 -- Canada
			THEN '401' -- Canada
		WHEN b.d_rstate = 82 -- Cuba
			THEN '402' -- Cuba
		WHEN b.d_rstate = 83 -- Mexico
			THEN '403' -- Mexico
		ELSE '-1'
		END [cd_country]
FROM rodis.bab_died b
LEFT JOIN rodis.ref_birst r ON r.Code = b.d_rstate
WHERE b.d_rstate IS NOT NULL

UNION

SELECT '-1' [cd_state]
	,'Unspecified' [tx_state]
	,'-1' [cd_country]
ORDER BY 1
	,3

UPDATE STATISTICS rodis_wh.staging_state_att

CREATE NONCLUSTERED INDEX idx_staging_state_att_id_state ON rodis_wh.staging_state_att (
	id_state
	)

CREATE NONCLUSTERED INDEX idx_staging_state_att_cd_state ON rodis_wh.staging_state_att (
	cd_state
	)

CREATE NONCLUSTERED INDEX idx_staging_state_att_cd_country ON rodis_wh.staging_state_att (
	cd_country
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'state'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_state) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_state [source_key]
FROM rodis_wh.staging_state_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_state
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_state = k.entity_key
FROM rodis_wh.staging_state_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_state AND k.wh_column_id = @column_id

UPDATE a
SET id_country = k.id_country
FROM rodis_wh.staging_state_att a
INNER JOIN rodis_wh.staging_country_att k ON k.cd_country = a.cd_country

UPDATE STATISTICS rodis_wh.staging_state_att

MERGE rodis_wh.state_att [target]
USING rodis_wh.staging_state_att [source]
	ON target.id_state = source.id_state
WHEN MATCHED
	THEN
		UPDATE
		SET tx_state = source.tx_state
WHEN NOT MATCHED
	THEN
		INSERT (
			id_state
			,cd_state
			,tx_state
            ,id_country
			)
		VALUES (
			source.id_state
			,source.cd_state
			,source.tx_state
            ,source.id_country
			);

UPDATE STATISTICS rodis_wh.state_att

UPDATE r
SET id_state = k.entity_key
FROM rodis_wh.county_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_state_att p
		WHERE p.id_state = r.id_state
		)

DELETE FROM a
FROM rodis_wh.state_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_state_att s
		WHERE s.id_state = a.id_state
		)

UPDATE STATISTICS rodis_wh.state_att
