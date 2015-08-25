CREATE PROCEDURE [rodis_wh].[etl_birth_fat]
AS
IF OBJECT_ID('rodis_wh.staging_birth_fat') IS NOT NULL
	DROP TABLE rodis_wh.staging_birth_fat

CREATE TABLE rodis_wh.staging_birth_fat(
	id_birth_fact INT NULL
	,cd_birth_fact VARCHAR(50) NULL
	,id_prsn_child INT NULL
	,id_prsn_mother INT NULL
	,id_calendar_dim_birth_child INT NULL
	,qt_child_weight INT NULL
	,ms_maternal_bmi FLOAT NULL
	,qt_child_head_circum INT NULL
	,qt_paternal_age INT NULL
	,qt_child_age_est_gest INT NULL
	,qt_child_age_gest INT NULL
	,qt_maternal_age INT NULL
	,qt_maternal_height INT NULL
	,qt_preconception_maternal_weight INT NULL
	,qt_maternal_weight INT NULL
	,ms_maternal_weight_gain INT NULL
	,am_median_income_tract INT NULL
	,id_birth_administration INT NULL
	,cd_birth_administration VARCHAR(50) NULL
)

INSERT rodis_wh.staging_birth_fat (
	cd_birth_fact
	,id_prsn_child
	,id_prsn_mother
	,id_calendar_dim_birth_child
	,qt_child_weight
	,ms_maternal_bmi
	,qt_child_head_circum
	,qt_paternal_age
	,qt_child_age_est_gest
	,qt_child_age_gest
	,qt_maternal_age
	,qt_maternal_height
	,qt_preconception_maternal_weight
	,qt_maternal_weight
	,ms_maternal_weight_gain
	,am_median_income_tract
	,cd_birth_administration
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_birth_fact]
	,PAT_ID [id_prsn_child]
	,CONVERT(INT, NULL) [id_prsn_mother]
	,CONVERT(INT, CONVERT(VARCHAR(20), DATEFROMPARTS(birthyr, birthmo, birthdy), 112)) [id_calendar_dim_birth_child]
	,birgrams [qt_child_weight]
	,bmi [ms_maternal_bmi]
	,circumf [qt_child_head_circum]
	,dadage [qt_paternal_age]
	,gestest [qt_child_age_est_gest]
	,gestlen [qt_child_age_gest]
	,momage [qt_maternal_age]
	,momhgt [qt_maternal_height]
	,prewght [qt_preconception_maternal_weight]
	,wghtdelv [qt_maternal_weight]
	,wtgain [ms_maternal_weight_gain]
	,income [am_median_income_tract]
	,CONVERT(VARCHAR(50), bc_uni) [cd_birth_administration]
FROM rodis.berd
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_birth_fat

CREATE NONCLUSTERED INDEX idx_staging_birth_fat_id_birth_fact ON rodis_wh.staging_birth_fat (
	id_birth_fact
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_fact_cd_birth_fact ON rodis_wh.staging_birth_fat (
	cd_birth_fact
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_fact_cd_certifier_type ON rodis_wh.staging_birth_fat (
	cd_birth_administration
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'birth'
			AND wh_table_type_id = 2 -- fat
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_birth_fact) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_birth_fact [source_key]
FROM rodis_wh.staging_birth_fat a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_birth_fact
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_birth_fact = k.entity_key
FROM rodis_wh.staging_birth_fat a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_birth_fact AND k.wh_column_id = @column_id

UPDATE a
SET id_birth_administration = k.id_birth_administration
FROM rodis_wh.staging_birth_fat a
INNER JOIN rodis_wh.staging_birth_administration_att k ON k.cd_birth_administration = ISNULL(a.cd_birth_administration, '-1')

UPDATE STATISTICS rodis_wh.staging_birth_fat

MERGE rodis_wh.birth_fat [target]
USING rodis_wh.staging_birth_fat [source]
	ON target.id_birth_fact = source.id_birth_fact
WHEN MATCHED
	THEN
		UPDATE
		SET id_prsn_child = source.id_prsn_child
			,id_prsn_mother = source.id_prsn_mother
			,id_calendar_dim_birth_child = source.id_calendar_dim_birth_child
			,qt_child_weight = source.qt_child_weight
			,ms_maternal_bmi = source.ms_maternal_bmi
			,qt_child_head_circum = source.qt_child_head_circum
			,qt_paternal_age = source.qt_paternal_age
			,qt_child_age_est_gest = source.qt_child_age_est_gest
			,qt_child_age_gest = source.qt_child_age_gest
			,qt_maternal_age = source.qt_maternal_age
			,qt_maternal_height = source.qt_maternal_height
			,qt_preconception_maternal_weight = source.qt_preconception_maternal_weight
			,qt_maternal_weight = source.qt_maternal_weight
			,ms_maternal_weight_gain = source.ms_maternal_weight_gain
			,am_median_income_tract = source.am_median_income_tract
			,id_birth_administration = source.id_birth_administration

WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_birth_fact
			,cd_birth_fact
			,id_prsn_child
			,id_prsn_mother
			,id_calendar_dim_birth_child
			,qt_child_weight
			,ms_maternal_bmi
			,qt_child_head_circum
			,qt_paternal_age
			,qt_child_age_est_gest
			,qt_child_age_gest
			,qt_maternal_age
			,qt_maternal_height
			,qt_preconception_maternal_weight
			,qt_maternal_weight
			,ms_maternal_weight_gain
			,am_median_income_tract
			,id_birth_administration
			)
		VALUES (
			source.id_birth_fact
			,source.cd_birth_fact
			,source.id_prsn_child
			,source.id_prsn_mother
			,source.id_calendar_dim_birth_child
			,source.qt_child_weight
			,source.ms_maternal_bmi
			,source.qt_child_head_circum
			,source.qt_paternal_age
			,source.qt_child_age_est_gest
			,source.qt_child_age_gest
			,source.qt_maternal_age
			,source.qt_maternal_height
			,source.qt_preconception_maternal_weight
			,source.qt_maternal_weight
			,source.ms_maternal_weight_gain
			,source.am_median_income_tract
			,source.id_birth_administration
			)
	WHEN NOT MATCHED BY SOURCE
		THEN
			DELETE;

UPDATE STATISTICS rodis_wh.birth_fat
