CREATE PROCEDURE [rodis_wh].[etl_birth_administration_att]
AS
IF OBJECT_ID('rodis_wh.staging_birth_administration_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_birth_administration_att

CREATE TABLE rodis_wh.staging_birth_administration_att(
	id_birth_administration INT NULL
	,cd_birth_administration VARCHAR(50) NULL
	,fl_icu_maternal_admit TINYINT NULL
	,fl_infant_transfer TINYINT NULL
	,fl_nicu_child_admit TINYINT NULL
	,fl_or_maternal_admit TINYINT NULL
	,fl_malformation TINYINT NULL
	,dt_prenatal_care_start SMALLINT NULL
	,fl_urban_tract TINYINT NULL
	,fl_prenatal_wic_benefits TINYINT NULL
	,dt_hour_birth_child TINYINT NULL
	,qt_latitude FLOAT NULL
	,qt_longitude FLOAT NULL
	,id_certifier_type INT NULL
	,cd_certifier_type VARCHAR(50) NULL
	,id_maternal_transfer_type INT NULL
	,cd_maternal_transfer_type VARCHAR(50) NULL
	,id_child_sex INT NULL
	,cd_child_sex VARCHAR(50) NULL
	,id_facility_type INT NULL
	,cd_facility_type VARCHAR(50) NULL
	,id_birth_familial_child INT NULL
	,cd_birth_familial_child VARCHAR(50) NULL
	,id_birth_familial_maternal INT NULL
	,cd_birth_familial_maternal VARCHAR(50) NULL
	,id_birth_familial_paternal INT NULL
	,cd_birth_familial_paternal VARCHAR(50) NULL
	,id_hospital_admission_child INT NULL
	,cd_hospital_admission_child VARCHAR(50) NULL
	,id_hospital_admission_maternal INT NULL
	,cd_hospital_admission_maternal VARCHAR(50) NULL
	,id_birth_child_condition INT NULL
	,cd_birth_child_condition VARCHAR(50) NULL
	,id_birth_child_procedure INT NULL
	,cd_birth_child_procedure VARCHAR(50) NULL
	,id_maternal_behavior INT NULL
	,cd_maternal_behavior VARCHAR(50) NULL
	,id_maternal_condition INT NULL
	,cd_maternal_condition VARCHAR(50) NULL
	,id_maternal_history INT NULL
	,cd_maternal_history VARCHAR(50) NULL
	,id_maternal_procedure INT NULL
	,cd_maternal_procedure VARCHAR(50) NULL
)

INSERT rodis_wh.staging_birth_administration_att (
	cd_birth_administration
	,fl_icu_maternal_admit
	,fl_infant_transfer
	,fl_nicu_child_admit
	,fl_or_maternal_admit
	,fl_malformation
	,dt_prenatal_care_start
	,fl_urban_tract
	,fl_prenatal_wic_benefits
	,dt_hour_birth_child
	,qt_latitude
	,qt_longitude
	,cd_certifier_type
	,cd_maternal_transfer_type
	,cd_child_sex
	,cd_facility_type
	,cd_birth_familial_child
	,cd_birth_familial_maternal
	,cd_birth_familial_paternal
	,cd_hospital_admission_child
	,cd_hospital_admission_maternal
	,cd_birth_child_condition
	,cd_birth_child_procedure
	,cd_maternal_behavior
	,cd_maternal_condition
	,cd_maternal_history
	,cd_maternal_procedure
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_birth_administration]
	,icu [fl_icu_maternal_admit]
	,inftrans [fl_infant_transfer]
	,nicu [fl_nicu_child_admit]
	,oproom [fl_or_maternal_admit]
	,anymalf [fl_malformation]
	,prenatmo [dt_prenatal_care_start]
	,urbrur [fl_urban_tract]
	,wic [fl_prenatal_wic_benefits]
	,birhour [dt_hour_birth_child]
	,lat [qt_latitude]
	,long [qt_longitude]
	,CONVERT(VARCHAR(50), cert) [cd_certifier_type]
	,CONVERT(VARCHAR(50), momtrans) [cd_maternal_transfer_type]
	,CONVERT(VARCHAR(50), sex) [cd_child_sex]
	,CONVERT(VARCHAR(50), birplace) [cd_facility_type]
	,CONVERT(VARCHAR(50), bc_uni) + 'C' [cd_birth_familial_child]
	,CONVERT(VARCHAR(50), bc_uni) + 'M' [cd_birth_familial_maternal]
	,CONVERT(VARCHAR(50), bc_uni) + 'P' [cd_birth_familial_paternal]
	,CONVERT(VARCHAR(50), bc_uni) + 'C' [cd_hospital_admission_child]
	,CONVERT(VARCHAR(50), bc_uni) + 'M' [cd_hospital_admission_maternal]
	,CONVERT(VARCHAR(50), bc_uni) [cd_birth_child_condition]
	,CONVERT(VARCHAR(50), bc_uni) [cd_birth_child_procedure]
	,CONVERT(VARCHAR(50), bc_uni) [cd_maternal_behavior]
	,CONVERT(VARCHAR(50), bc_uni) [cd_maternal_condition]
	,CONVERT(VARCHAR(50), bc_uni) [cd_maternal_history]
	,CONVERT(VARCHAR(50), bc_uni) [cd_maternal_procedure]
FROM rodis.berd

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_birth_administration]
	,CONVERT(TINYINT, NULL) [fl_icu_maternal_admit]
	,CONVERT(TINYINT, NULL) [fl_infant_transfer]
	,CONVERT(TINYINT, NULL) [fl_nicu_child_admit]
	,CONVERT(TINYINT, NULL) [fl_or_maternal_admit]
	,CONVERT(TINYINT, NULL) [fl_malformation]
	,CONVERT(SMALLINT, NULL) [dt_prenatal_care_start]
	,CONVERT(TINYINT, NULL) [fl_urban_tract]
	,CONVERT(TINYINT, NULL) [fl_prenatal_wic_benefits]
	,CONVERT(TINYINT, NULL) [dt_hour_birth_child]
	,CONVERT(FLOAT, NULL) [qt_latitude]
	,CONVERT(FLOAT, NULL) [qt_longitude]
	,CONVERT(VARCHAR(50), -1) [cd_certifier_type]
	,CONVERT(VARCHAR(50), -1) [cd_maternal_transfer_type]
	,CONVERT(VARCHAR(50), -1) [cd_child_sex]
	,CONVERT(VARCHAR(50), -1) [cd_facility_type]
	,CONVERT(VARCHAR(50), -1) [cd_birth_familial_child]
	,CONVERT(VARCHAR(50), -1) [cd_birth_familial_maternal]
	,CONVERT(VARCHAR(50), -1) [cd_birth_familial_paternal]
	,CONVERT(VARCHAR(50), -1) [cd_hospital_admission_child]
	,CONVERT(VARCHAR(50), -1) [cd_hospital_admission_maternal]
	,CONVERT(VARCHAR(50), -1) [cd_birth_child_condition]
	,CONVERT(VARCHAR(50), -1) [cd_birth_child_procedure]
	,CONVERT(VARCHAR(50), -1) [cd_maternal_behavior]
	,CONVERT(VARCHAR(50), -1) [cd_maternal_condition]
	,CONVERT(VARCHAR(50), -1) [cd_maternal_history]
	,CONVERT(VARCHAR(50), -1) [cd_maternal_procedure]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_birth_administration_att

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_id_birth_administration ON rodis_wh.staging_birth_administration_att (
	id_birth_administration
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_birth_administration ON rodis_wh.staging_birth_administration_att (
	cd_birth_administration
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_certifier_type ON rodis_wh.staging_birth_administration_att (
	cd_certifier_type
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_maternal_transfer_type ON rodis_wh.staging_birth_administration_att (
	cd_maternal_transfer_type
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_child_sex ON rodis_wh.staging_birth_administration_att (
	cd_child_sex
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_facility_type ON rodis_wh.staging_birth_administration_att (
	cd_facility_type
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_birth_familial_child ON rodis_wh.staging_birth_administration_att (
	cd_birth_familial_child
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_birth_familial_maternal ON rodis_wh.staging_birth_administration_att (
	cd_birth_familial_maternal
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_birth_familial_paternal ON rodis_wh.staging_birth_administration_att (
	cd_birth_familial_paternal
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_hospital_admission_child ON rodis_wh.staging_birth_administration_att (
	cd_hospital_admission_child
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_hospital_admission_maternal ON rodis_wh.staging_birth_administration_att (
	cd_hospital_admission_maternal
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_birth_child_condition ON rodis_wh.staging_birth_administration_att (
	cd_birth_child_condition
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_birth_child_procedure ON rodis_wh.staging_birth_administration_att (
	cd_birth_child_procedure
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_maternal_behavior ON rodis_wh.staging_birth_administration_att (
	cd_maternal_behavior
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_maternal_condition ON rodis_wh.staging_birth_administration_att (
	cd_maternal_condition
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_maternal_history ON rodis_wh.staging_birth_administration_att (
	cd_maternal_history
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_administration_att_cd_maternal_procedure ON rodis_wh.staging_birth_administration_att (
	cd_maternal_procedure
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'birth_administration'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_birth_administration) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_birth_administration [source_key]
FROM rodis_wh.staging_birth_administration_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_birth_administration
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_birth_administration = k.entity_key
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_birth_administration AND k.wh_column_id = @column_id

UPDATE a
SET id_certifier_type = k.id_certifier_type
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_certifier_type_att k ON k.cd_certifier_type = ISNULL(a.cd_certifier_type, '-1')

UPDATE a
SET id_maternal_transfer_type = k.id_maternal_transfer_type
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_maternal_transfer_type_att k ON k.cd_maternal_transfer_type = ISNULL(a.cd_maternal_transfer_type, '-1')

UPDATE a
SET id_child_sex = k.id_child_sex
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_child_sex_att k ON k.cd_child_sex = ISNULL(a.cd_child_sex, '-1')

UPDATE a
SET id_facility_type = k.id_facility_type
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_facility_type_att k ON k.cd_facility_type = ISNULL(a.cd_facility_type, '-1')

UPDATE a
SET id_birth_familial_child = k.id_birth_familial
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_birth_familial_att k ON k.cd_birth_familial = ISNULL(a.cd_birth_familial_child, '-1')

UPDATE a
SET id_birth_familial_maternal = k.id_birth_familial
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_birth_familial_att k ON k.cd_birth_familial = ISNULL(a.cd_birth_familial_maternal, '-1')

UPDATE a
SET id_birth_familial_paternal = k.id_birth_familial
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_birth_familial_att k ON k.cd_birth_familial = ISNULL(a.cd_birth_familial_paternal, '-1')

UPDATE a
SET id_hospital_admission_child = k.id_hospital_admission
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_hospital_admission_att k ON k.cd_hospital_admission = ISNULL(a.cd_hospital_admission_child, '-1')

UPDATE a
SET id_hospital_admission_maternal = k.id_hospital_admission
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_hospital_admission_att k ON k.cd_hospital_admission = ISNULL(a.cd_hospital_admission_maternal, '-1')

UPDATE a
SET id_birth_child_condition = k.id_birth_child_condition
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_birth_child_condition_att k ON k.cd_birth_child_condition = ISNULL(a.cd_birth_child_condition, '-1')

UPDATE a
SET id_birth_child_procedure = k.id_birth_child_procedure
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_birth_child_procedure_att k ON k.cd_birth_child_procedure = ISNULL(a.cd_birth_child_procedure, '-1')

UPDATE a
SET id_maternal_behavior = k.id_maternal_behavior
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_maternal_behavior_att k ON k.cd_maternal_behavior = ISNULL(a.cd_maternal_behavior, '-1')

UPDATE a
SET id_maternal_condition = k.id_maternal_condition
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_maternal_condition_att k ON k.cd_maternal_condition = ISNULL(a.cd_maternal_condition, '-1')

UPDATE a
SET id_maternal_history = k.id_maternal_history
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_maternal_history_att k ON k.cd_maternal_history = ISNULL(a.cd_maternal_history, '-1')

UPDATE a
SET id_maternal_procedure = k.id_maternal_procedure
FROM rodis_wh.staging_birth_administration_att a
INNER JOIN rodis_wh.staging_maternal_procedure_att k ON k.cd_maternal_procedure = ISNULL(a.cd_maternal_procedure, '-1')

UPDATE STATISTICS rodis_wh.staging_birth_administration_att

MERGE rodis_wh.birth_administration_att [target]
USING rodis_wh.staging_birth_administration_att [source]
	ON target.id_birth_administration = source.id_birth_administration
WHEN MATCHED
	THEN
		UPDATE
		SET fl_icu_maternal_admit = source.fl_icu_maternal_admit
			,fl_infant_transfer = source.fl_infant_transfer
			,fl_nicu_child_admit = source.fl_nicu_child_admit
			,fl_or_maternal_admit = source.fl_or_maternal_admit
			,fl_malformation = source.fl_malformation
			,dt_prenatal_care_start = source.dt_prenatal_care_start
			,fl_urban_tract = source.fl_urban_tract
			,fl_prenatal_wic_benefits = source.fl_prenatal_wic_benefits
			,dt_hour_birth_child = source.dt_hour_birth_child
			,qt_latitude = source.qt_latitude
			,qt_longitude = source.qt_longitude
			,id_certifier_type = source.id_certifier_type
			,id_maternal_transfer_type = source.id_maternal_transfer_type
			,id_child_sex = source.id_child_sex
			,id_facility_type = source.id_facility_type
			,id_birth_familial_child = source.id_birth_familial_child
			,id_birth_familial_maternal = source.id_birth_familial_maternal
			,id_birth_familial_paternal = source.id_birth_familial_paternal
			,id_hospital_admission_child = source.id_hospital_admission_child
			,id_hospital_admission_maternal = source.id_hospital_admission_maternal
			,id_birth_child_condition = source.id_birth_child_condition
			,id_birth_child_procedure = source.id_birth_child_procedure
			,id_maternal_behavior = source.id_maternal_behavior
			,id_maternal_condition = source.id_maternal_condition
			,id_maternal_history = source.id_maternal_history
			,id_maternal_procedure = source.id_maternal_procedure

WHEN NOT MATCHED
	THEN
		INSERT (
			id_birth_administration
			,cd_birth_administration
			,fl_icu_maternal_admit
			,fl_infant_transfer
			,fl_nicu_child_admit
			,fl_or_maternal_admit
			,fl_malformation
			,dt_prenatal_care_start
			,fl_urban_tract
			,fl_prenatal_wic_benefits
			,dt_hour_birth_child
			,qt_latitude
			,qt_longitude
			,id_certifier_type
			,id_maternal_transfer_type
			,id_child_sex
			,id_facility_type
			,id_birth_familial_child
			,id_birth_familial_maternal
			,id_birth_familial_paternal
			,id_hospital_admission_child
			,id_hospital_admission_maternal
			,id_birth_child_condition
			,id_birth_child_procedure
			,id_maternal_behavior
			,id_maternal_condition
			,id_maternal_history
			,id_maternal_procedure
			)
		VALUES (
			source.id_birth_administration
			,source.cd_birth_administration
			,source.fl_icu_maternal_admit
			,source.fl_infant_transfer
			,source.fl_nicu_child_admit
			,source.fl_or_maternal_admit
			,source.fl_malformation
			,source.dt_prenatal_care_start
			,source.fl_urban_tract
			,source.fl_prenatal_wic_benefits
			,source.dt_hour_birth_child
			,source.qt_latitude
			,source.qt_longitude
			,source.id_certifier_type
			,source.id_maternal_transfer_type
			,source.id_child_sex
			,source.id_facility_type
			,source.id_birth_familial_child
			,source.id_birth_familial_maternal
			,source.id_birth_familial_paternal
			,source.id_hospital_admission_child
			,source.id_hospital_admission_maternal
			,source.id_birth_child_condition
			,source.id_birth_child_procedure
			,source.id_maternal_behavior
			,source.id_maternal_condition
			,source.id_maternal_history
			,source.id_maternal_procedure
			);

UPDATE STATISTICS rodis_wh.birth_administration_att

UPDATE r
SET id_birth_administration = k.entity_key
FROM rodis_wh.birth_fat r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_administration_att p
		WHERE p.id_birth_administration = r.id_birth_administration
		)

UPDATE r
SET id_birth_administration = k.entity_key
FROM rodis_wh.death_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_administration_att p
		WHERE p.id_birth_administration = r.id_birth_administration
		)

DELETE FROM a
FROM rodis_wh.birth_administration_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_administration_att s
		WHERE s.id_birth_administration = a.id_birth_administration
		)

UPDATE STATISTICS rodis_wh.birth_administration_att
