CREATE PROCEDURE [rodis_wh].[etl_birth_familial_att]
AS
IF OBJECT_ID('rodis_wh.staging_birth_familial_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_birth_familial_att

CREATE TABLE rodis_wh.staging_birth_familial_att(
	id_birth_familial INT NULL
	,cd_birth_familial VARCHAR(50) NULL
	,cd_birth_zip INT NULL
	,id_race_census INT NULL
	,cd_race_census VARCHAR(50) NULL
	,id_ethnicity_census INT NULL
	,cd_ethnicity_census VARCHAR(50) NULL
	,id_tribe INT NULL
	,cd_tribe VARCHAR(50) NULL
	,id_occupation INT NULL
	,cd_occupation VARCHAR(50) NULL
	,id_city_current INT NULL
	,cd_city_current VARCHAR(50) NULL
	,id_city_birth INT NULL
	,cd_city_birth VARCHAR(50) NULL
	,id_education INT NULL
	,cd_education VARCHAR(50) NULL
)

INSERT rodis_wh.staging_birth_familial_att (
	cd_birth_familial
	,cd_birth_zip
	,cd_race_census
	,cd_ethnicity_census
	,cd_tribe
	,cd_occupation
	,cd_city_current
	,cd_city_birth
	,cd_education
	)
SELECT CONVERT(VARCHAR(50), b.bc_uni) + 'C' [cd_birth_familial]
	,b.geozip [cd_birth_zip]
	,CONVERT(VARCHAR(50), b.kidrace) [cd_race_census]
	,CONVERT(VARCHAR(50), ISNULL(b.kidhisp, b.chisp)) [cd_ethnicity_census]
	,CONVERT(VARCHAR(50), b.trib_res) [cd_tribe]
	,CONVERT(VARCHAR(50), -1) [cd_occupation]
	,CONVERT(VARCHAR(50), -1) [cd_city_current]
	,CONVERT(VARCHAR(50), b.bres) [cd_city_birth]
	,CONVERT(VARCHAR(50), -1) [cd_education]
FROM rodis.berd b

UNION

SELECT CONVERT(VARCHAR(50), b.bc_uni) + 'M' [cd_birth_familial]
	,b.geozip [cd_birth_zip]
	,CONVERT(VARCHAR(50), b.momrace) [cd_race_census]
	,CONVERT(VARCHAR(50), b.momhisp) [cd_ethnicity_census]
	,CONVERT(VARCHAR(50), b.trib_res) [cd_tribe]
	,CONVERT(VARCHAR(50), b.momocc) [cd_occupation]
	,CONVERT(VARCHAR(50), b.momres) [cd_city_current]
	,'-1--1-' + CASE
		WHEN b.mombirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.mombirst) + '-' + CONVERT(VARCHAR(50), b.mcountry)
		ELSE CONVERT(VARCHAR(50), b.mombirst)
		END [cd_city_birth]
	,CONVERT(VARCHAR(50), ISNULL(b.momedu, b.momle8ed)) [cd_education]
FROM rodis.berd b

UNION

SELECT CONVERT(VARCHAR(50), b.bc_uni) + 'P' [cd_birth_familial]
	,b.geozip [cd_birth_zip]
	,CONVERT(VARCHAR(50), b.dadrace) [cd_race_census]
	,CONVERT(VARCHAR(50), b.dadhisp) [cd_ethnicity_census]
	,CONVERT(VARCHAR(50), b.trib_res) [cd_tribe]
	,CONVERT(VARCHAR(50), b.dadocc) [cd_occupation]
	,CONVERT(VARCHAR(50), -1) [cd_city_current]
	,'-1--1-' + CASE
		WHEN b.dadbirst IN (89, 99) -- Other Foreign, Unknown
			THEN CONVERT(VARCHAR(50), b.dadbirst) + '-' + CONVERT(VARCHAR(50), b.dcountry)
		ELSE CONVERT(VARCHAR(50), b.dadbirst)
		END [cd_city_birth]
	,CONVERT(VARCHAR(50), ISNULL(b.dadedu, b.dadle8ed)) [cd_education]
FROM rodis.berd b

UNION

SELECT '-1' [cd_birth_familial]
	,CONVERT(INT, NULL) [cd_birth_zip]
	,CONVERT(VARCHAR(50), -1) [cd_race_census]
	,CONVERT(VARCHAR(50), -1) [cd_ethnicity_census]
	,CONVERT(VARCHAR(50), -1) [cd_tribe]
	,CONVERT(VARCHAR(50), -1) [cd_occupation]
	,CONVERT(VARCHAR(50), -1) [cd_city_current]
	,CONVERT(VARCHAR(50), -1) [cd_city_birth]
	,CONVERT(VARCHAR(50), -1) [cd_education]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_birth_familial_att

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_id_birth_familial ON rodis_wh.staging_birth_familial_att (
	id_birth_familial
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_birth_familial ON rodis_wh.staging_birth_familial_att (
	cd_birth_familial
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_race_census ON rodis_wh.staging_birth_familial_att (
	cd_race_census
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_ethnicity_census ON rodis_wh.staging_birth_familial_att (
	cd_ethnicity_census
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_tribe ON rodis_wh.staging_birth_familial_att (
	cd_tribe
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_occupation ON rodis_wh.staging_birth_familial_att (
	cd_occupation
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_city_current ON rodis_wh.staging_birth_familial_att (
	cd_city_current
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_city_birth ON rodis_wh.staging_birth_familial_att (
	cd_city_birth
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_familial_att_cd_education ON rodis_wh.staging_birth_familial_att (
	cd_education
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'birth_familial'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_birth_familial) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_birth_familial [source_key]
FROM rodis_wh.staging_birth_familial_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_birth_familial
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_birth_familial = k.entity_key
FROM rodis_wh.staging_birth_familial_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_birth_familial AND k.wh_column_id = @column_id

UPDATE a
SET id_race_census = k.id_race_census
FROM rodis_wh.staging_birth_familial_att a
LEFT JOIN rodis_wh.staging_race_census_att k ON k.cd_race_census = ISNULL(a.cd_race_census, '-1')

UPDATE a
SET id_ethnicity_census = k.id_ethnicity_census
FROM rodis_wh.staging_birth_familial_att a
LEFT JOIN rodis_wh.staging_ethnicity_census_att k ON k.cd_ethnicity_census = ISNULL(a.cd_ethnicity_census, '-1')

UPDATE a
SET id_tribe = k.id_tribe
FROM rodis_wh.staging_birth_familial_att a
LEFT JOIN rodis_wh.staging_tribe_att k ON k.cd_tribe = ISNULL(a.cd_tribe, '-1')

UPDATE a
SET id_occupation = k.id_occupation
FROM rodis_wh.staging_birth_familial_att a
LEFT JOIN rodis_wh.staging_occupation_att k ON k.cd_occupation = ISNULL(a.cd_occupation, '-1')

UPDATE a
SET id_city_current = k.id_city
FROM rodis_wh.staging_birth_familial_att a
LEFT JOIN rodis_wh.staging_city_att k ON k.cd_city = ISNULL(a.cd_city_current, '-1')

UPDATE a
SET id_city_birth = k.id_city
FROM rodis_wh.staging_birth_familial_att a
LEFT JOIN rodis_wh.staging_city_att k ON k.cd_city = ISNULL(a.cd_city_birth, '-1')

UPDATE a
SET id_education = k.id_education
FROM rodis_wh.staging_birth_familial_att a
LEFT JOIN rodis_wh.staging_education_att k ON k.cd_education = ISNULL(a.cd_education, '-1')

UPDATE STATISTICS rodis_wh.staging_birth_familial_att

MERGE rodis_wh.birth_familial_att [target]
USING rodis_wh.staging_birth_familial_att [source]
	ON target.id_birth_familial = source.id_birth_familial
WHEN MATCHED
	THEN
		UPDATE
		SET cd_birth_zip = source.cd_birth_zip
			,id_race_census = source.id_race_census
			,id_ethnicity_census = source.id_ethnicity_census
			,id_tribe = source.id_tribe
			,id_occupation = source.id_occupation
			,id_city_current = source.id_city_current
			,id_city_birth = source.id_city_birth
			,id_education = source.id_education
WHEN NOT MATCHED
	THEN
		INSERT (
			id_birth_familial
			,cd_birth_familial
			,cd_birth_zip
			,id_race_census
			,id_ethnicity_census
			,id_tribe
			,id_occupation
			,id_city_current
			,id_city_birth
			,id_education
			)
		VALUES (
			source.id_birth_familial
			,source.cd_birth_familial
			,source.cd_birth_zip
			,source.id_race_census
			,source.id_ethnicity_census
			,source.id_tribe
			,source.id_occupation
			,source.id_city_current
			,source.id_city_birth
			,source.id_education
			);

UPDATE STATISTICS rodis_wh.birth_familial_att

UPDATE r
SET id_birth_familial_child = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_familial_att p
		WHERE p.id_birth_familial = r.id_birth_familial_child
		)

UPDATE r
SET id_birth_familial_maternal = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_familial_att p
		WHERE p.id_birth_familial = r.id_birth_familial_maternal
		)

UPDATE r
SET id_birth_familial_paternal = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_familial_att p
		WHERE p.id_birth_familial = r.id_birth_familial_paternal
		)

DELETE FROM a
FROM rodis_wh.birth_familial_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_familial_att s
		WHERE s.id_birth_familial = a.id_birth_familial
		)

UPDATE STATISTICS rodis_wh.birth_familial_att
