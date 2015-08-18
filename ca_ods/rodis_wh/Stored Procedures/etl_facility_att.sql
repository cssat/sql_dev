CREATE PROCEDURE [rodis_wh].[etl_facility_att]
AS
IF OBJECT_ID('rodis_wh.staging_facility_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_facility_att

CREATE TABLE rodis_wh.staging_facility_att(
	id_facility INT NULL
	,cd_facility VARCHAR(50) NULL
	,tx_facility VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_facility_att_id_facility ON rodis_wh.staging_facility_att (
	id_facility
	)

CREATE NONCLUSTERED INDEX idx_staging_facility_att_cd_facility ON rodis_wh.staging_facility_att (
	cd_facility
	)

INSERT rodis_wh.staging_facility_att (
	cd_facility
	,tx_facility
	)
SELECT DISTINCT CONVERT(VARCHAR(50), b.birfacil) + IIF(i.r_hosp IS NULL, 'B', '') [cd_facility]
	,CONVERT(VARCHAR(50), b.birfacil) + IIF(i.r_hosp IS NULL, 'B', '') + ' - Undefined' [tx_facility]
FROM rodis.berd b
LEFT JOIN (
	SELECT DISTINCT r_hosp
	FROM rodis.bab_read
	WHERE r_hosp IS NOT NULL
	) i ON i.r_hosp = CONVERT(VARCHAR(50), b.birfacil)
WHERE b.birfacil IS NOT NULL

UNION

SELECT DISTINCT i.r_hosp + IIF(b.birfacil IS NULL, 'I', '') [cd_facility]
	,i.r_hosp + IIF(b.birfacil IS NULL, 'I', '') + ' - Undefined' [tx_facility]
FROM rodis.bab_read i
LEFT JOIN (
	SELECT DISTINCT CONVERT(VARCHAR(50), birfacil) [birfacil]
	FROM rodis.berd
	WHERE birfacil IS NOT NULL
	) b ON b.birfacil = i.r_hosp
WHERE r_hosp IS NOT NULL

UNION

SELECT '-1' [cd_facility]
	,'Unspecified' [tx_facility]
ORDER BY 1
	,2

UPDATE STATISTICS rodis_wh.staging_facility_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'facility'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_facility) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_facility [source_key]
FROM rodis_wh.staging_facility_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_facility
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_facility = k.entity_key
FROM rodis_wh.staging_facility_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_facility

MERGE rodis_wh.facility_att [target]
USING rodis_wh.staging_facility_att [source]
	ON target.id_facility = source.id_facility
WHEN MATCHED
	THEN
		UPDATE
		SET tx_facility = source.tx_facility
WHEN NOT MATCHED
	THEN
		INSERT (
			id_facility
			,cd_facility
			,tx_facility
			)
		VALUES (
			source.id_facility
			,source.cd_facility
			,source.tx_facility
			);

UPDATE STATISTICS rodis_wh.facility_att

UPDATE r
SET id_facility = - 1
FROM rodis_wh.hospital_admission_att r
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_facility_att p
		WHERE p.id_facility = r.id_facility
		)

DELETE FROM a
FROM rodis_wh.facility_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_facility_att s
		WHERE s.id_facility = a.id_facility
		)

UPDATE STATISTICS rodis_wh.facility_att
