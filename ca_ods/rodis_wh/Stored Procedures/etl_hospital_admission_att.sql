CREATE PROCEDURE [rodis_wh].[etl_hospital_admission_att]
AS
IF OBJECT_ID('rodis_wh.staging_hospital_admission_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_hospital_admission_att

CREATE TABLE rodis_wh.staging_hospital_admission_att(
	id_hospital_admission INT NULL
	,cd_hospital_admission VARCHAR(50) NULL
	,cd_child_admit_zip INT NULL
	,qt_length_of_stay_days SMALLINT NULL
	,rank_of_admission TINYINT NULL
	,id_admission_source INT NULL
	,cd_admission_source VARCHAR(50) NULL
	,id_admission_reason INT NULL
	,cd_admission_reason VARCHAR(50) NULL
	,id_facility INT NULL
	,cd_facility VARCHAR(50) NULL
	,id_discharge_status INT NULL
	,cd_discharge_status VARCHAR(50) NULL
	,id_ecode INT NULL
	,cd_ecode VARCHAR(50) NULL
	,id_payment_primary INT NULL
	,cd_payment_primary VARCHAR(50) NULL
	,id_payment_secondary INT NULL
	,cd_payment_secondary VARCHAR(50) NULL
)

INSERT rodis_wh.staging_hospital_admission_att (
	cd_hospital_admission
	,cd_child_admit_zip
	,qt_length_of_stay_days
	,rank_of_admission
	,cd_admission_source
	,cd_admission_reason
	,cd_facility
	,cd_discharge_status
	,cd_ecode
	,cd_payment_primary
	,cd_payment_secondary
	)
SELECT CONVERT(VARCHAR(50), i.bc_uni) + '-' + CONVERT(VARCHAR(10), i.r_admnum) [cd_hospital_admission]
	,i.r_zip [cd_child_admit_zip]
	,i.r_stay [qt_length_of_stay_days]
	,i.r_admnum [rank_of_admission]
	,CONVERT(VARCHAR(50), i.r_admsor) + CASE 
		WHEN i.r_admty IS NULL
			THEN NULL
		WHEN i.r_admty = 4
			THEN 'B'
		WHEN i.r_admty != 4
			THEN 'I'
		ELSE NULL
		END [cd_admission_source]
	,CONVERT(VARCHAR(50), i.r_admty) [cd_admission_reason]
	,CONVERT(VARCHAR(50), i.r_hosp) + IIF(b.birfacil IS NULL, 'I', '') [cd_facility]
	,CONVERT(VARCHAR(50), i.r_status) [cd_discharge_status]
	,CONVERT(VARCHAR(50), i.r_ecode1) [cd_ecode]
	,CONVERT(VARCHAR(50), i.r_payid1) [cd_payment_primary]
	,CONVERT(VARCHAR(50), i.r_payid2) [cd_payment_secondary]
FROM rodis.bab_read i
LEFT JOIN rodis.ref_prebirth_admin r1 ON r1.Code = i.r_admsor AND i.r_admty != 4
LEFT JOIN rodis.ref_postbirth_admin r2 ON r2.Code = i.r_admsor AND i.r_admty = 4
LEFT JOIN (
	SELECT DISTINCT CONVERT(VARCHAR(50), birfacil) [birfacil]
	FROM rodis.berd
	WHERE birfacil IS NOT NULL
	) b ON b.birfacil = i.r_hosp

UNION ALL

SELECT CONVERT(VARCHAR(50), b.bc_uni) + 'C' [cd_hospital_admission]
	,CONVERT(INT, NULL) [cd_child_admit_zip]
	,b.cbstay [qt_length_of_stay_days]
	,CONVERT(TINYINT, 0) [rank_of_admission]
	,CONVERT(VARCHAR(50), b.cbadmsor) + CASE 
		WHEN b.cbadmty IS NULL
			THEN NULL
		WHEN b.cbadmty = 4
			THEN 'B'
		WHEN b.cbadmty != 4
			THEN 'I'
		ELSE NULL
		END [cd_admission_source]
	,CONVERT(VARCHAR(50), b.cbadmty) [cd_admission_reason]
	,CONVERT(VARCHAR(50), b.birfacil) + IIF(i.r_hosp IS NULL, 'B', '') [cd_facility]
	,CONVERT(VARCHAR(50), b.cbstatus) [cd_discharge_status]
	,CONVERT(VARCHAR(50), b.cbecode1) [cd_ecode]
	,CONVERT(VARCHAR(50), b.cbpayid1) [cd_payment_primary]
	,CONVERT(VARCHAR(50), b.cbpayid2) [cd_payment_secondary]
FROM rodis.berd b
LEFT JOIN rodis.ref_prebirth_admin r1 ON r1.Code = b.cbadmsor AND b.cbadmty != 4
LEFT JOIN rodis.ref_postbirth_admin r2 ON r2.Code = b.cbadmsor AND b.cbadmty = 4
LEFT JOIN (
	SELECT DISTINCT r_hosp
	FROM rodis.bab_read
	WHERE r_hosp IS NOT NULL
	) i ON i.r_hosp = CONVERT(VARCHAR(50), b.birfacil)

UNION ALL

SELECT CONVERT(VARCHAR(50), b.bc_uni) + 'M' [cd_hospital_admission]
	,CONVERT(INT, NULL) [cd_child_admit_zip]
	,b.cmstay [qt_length_of_stay_days]
	,CONVERT(TINYINT, 0) [rank_of_admission]
	,CONVERT(VARCHAR(50), b.cmadmsor) + CASE 
		WHEN b.cmadmty IS NULL
			THEN NULL
		WHEN b.cmadmty = 4
			THEN 'B'
		WHEN b.cmadmty != 4
			THEN 'I'
		ELSE NULL
		END [cd_admission_source]
	,CONVERT(VARCHAR(50), b.cmadmty) [cd_admission_reason]
	,CONVERT(VARCHAR(50), b.birfacil) + IIF(i.r_hosp IS NULL, 'B', '') [cd_facility]
	,CONVERT(VARCHAR(50), b.cmstatus) [cd_discharge_status]
	,CONVERT(VARCHAR(50), b.cmecode1) [cd_ecode]
	,CONVERT(VARCHAR(50), b.cmpayid1) [cd_payment_primary]
	,CONVERT(VARCHAR(50), b.cmpayid2) [cd_payment_secondary]
FROM rodis.berd b
LEFT JOIN rodis.ref_prebirth_admin r1 ON r1.Code = b.cmadmsor AND b.cmadmty != 4
LEFT JOIN rodis.ref_postbirth_admin r2 ON r2.Code = b.cmadmsor AND b.cmadmty = 4
LEFT JOIN (
	SELECT DISTINCT r_hosp
	FROM rodis.bab_read
	WHERE r_hosp IS NOT NULL
	) i ON i.r_hosp = CONVERT(VARCHAR(50), b.birfacil)

UNION ALL

SELECT CONVERT(VARCHAR(50), '-1') [cd_hospital_admission]
	,CONVERT(INT, NULL) [cd_child_admit_zip]
	,CONVERT(SMALLINT, NULL) [qt_length_of_stay_days]
	,CONVERT(TINYINT, NULL) [rank_of_admission]
	,CONVERT(VARCHAR(50), '-1') [cd_admission_source]
	,CONVERT(VARCHAR(50), '-1') [cd_admission_reason]
	,CONVERT(VARCHAR(50), '-1') [cd_facility]
	,CONVERT(VARCHAR(50), '-1') [cd_discharge_status]
	,CONVERT(VARCHAR(50), '-1') [cd_ecode]
	,CONVERT(VARCHAR(50), '-1') [cd_payment_primary]
	,CONVERT(VARCHAR(50), '-1') [cd_payment_secondary]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_hospital_admission_att

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_id_hospital_admission ON rodis_wh.staging_hospital_admission_att (
	id_hospital_admission
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_hospital_admission ON rodis_wh.staging_hospital_admission_att (
	cd_hospital_admission
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_admission_source ON rodis_wh.staging_hospital_admission_att (
	cd_admission_source
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_admission_reason ON rodis_wh.staging_hospital_admission_att (
	cd_admission_reason
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_facility ON rodis_wh.staging_hospital_admission_att (
	cd_facility
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_discharge_status ON rodis_wh.staging_hospital_admission_att (
	cd_discharge_status
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_ecode ON rodis_wh.staging_hospital_admission_att (
	cd_ecode
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_payment_primary ON rodis_wh.staging_hospital_admission_att (
	cd_payment_primary
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_att_cd_payment_secondary ON rodis_wh.staging_hospital_admission_att (
	cd_payment_secondary
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'hospital_admission'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_hospital_admission) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_hospital_admission [source_key]
FROM rodis_wh.staging_hospital_admission_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_hospital_admission
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_hospital_admission = k.entity_key
FROM rodis_wh.staging_hospital_admission_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_hospital_admission AND k.wh_column_id = @column_id

UPDATE a
SET id_admission_reason = k.id_admission_reason
FROM rodis_wh.staging_hospital_admission_att a
LEFT JOIN rodis_wh.staging_admission_reason_att k ON k.cd_admission_reason = ISNULL(a.cd_admission_reason, '-1')

UPDATE a
SET id_admission_source = k.id_admission_source
FROM rodis_wh.staging_hospital_admission_att a
LEFT JOIN rodis_wh.staging_admission_source_att k ON k.cd_admission_source = ISNULL(a.cd_admission_source, '-1')

UPDATE a
SET id_facility = k.id_facility
FROM rodis_wh.staging_hospital_admission_att a
LEFT JOIN rodis_wh.staging_facility_att k ON k.cd_facility = ISNULL(a.cd_facility, '-1')

UPDATE a
SET id_discharge_status = k.id_discharge_status
FROM rodis_wh.staging_hospital_admission_att a
LEFT JOIN rodis_wh.staging_discharge_status_att k ON k.cd_discharge_status = ISNULL(a.cd_discharge_status, '-1')

UPDATE a
SET id_ecode = k.id_ecode
FROM rodis_wh.staging_hospital_admission_att a
LEFT JOIN rodis_wh.staging_ecode_att k ON k.cd_ecode = ISNULL(a.cd_ecode, '-1')

UPDATE a
SET id_payment_primary = k.id_payment
FROM rodis_wh.staging_hospital_admission_att a
LEFT JOIN rodis_wh.staging_payment_att k ON k.cd_payment = ISNULL(a.cd_payment_primary, '-1')

UPDATE a
SET id_payment_secondary = k.id_payment
FROM rodis_wh.staging_hospital_admission_att a
LEFT JOIN rodis_wh.staging_payment_att k ON k.cd_payment = ISNULL(a.cd_payment_secondary, '-1')

UPDATE STATISTICS rodis_wh.staging_hospital_admission_att

MERGE rodis_wh.hospital_admission_att [target]
USING rodis_wh.staging_hospital_admission_att [source]
	ON target.id_hospital_admission = source.id_hospital_admission
WHEN MATCHED
	THEN
		UPDATE
		SET cd_child_admit_zip = source.cd_child_admit_zip
		,qt_length_of_stay_days = source.qt_length_of_stay_days
		,rank_of_admission = source.rank_of_admission
		,id_admission_source = source.id_admission_source
		,id_admission_reason = source.id_admission_reason
		,id_facility = source.id_facility
		,id_discharge_status = source.id_discharge_status
		,id_ecode = source.id_ecode
		,id_payment_primary = source.id_payment_primary
		,id_payment_secondary = source.id_payment_secondary

WHEN NOT MATCHED
	THEN
		INSERT (
			id_hospital_admission
			,cd_hospital_admission
			,cd_child_admit_zip
			,qt_length_of_stay_days
			,rank_of_admission
			,id_admission_source
			,id_admission_reason
			,id_facility
			,id_discharge_status
			,id_ecode
			,id_payment_primary
			,id_payment_secondary
			)
		VALUES (
			source.id_hospital_admission
			,source.cd_hospital_admission
			,source.cd_child_admit_zip
			,source.qt_length_of_stay_days
			,source.rank_of_admission
			,source.id_admission_source
			,source.id_admission_reason
			,source.id_facility
			,source.id_discharge_status
			,source.id_ecode
			,source.id_payment_primary
			,source.id_payment_secondary
			);

UPDATE STATISTICS rodis_wh.hospital_admission_att

UPDATE r
SET id_hospital_admission_child = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_hospital_admission_att p
		WHERE p.id_hospital_admission = r.id_hospital_admission_child
		)

UPDATE r
SET id_hospital_admission_maternal = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_hospital_admission_att p
		WHERE p.id_hospital_admission = r.id_hospital_admission_maternal
		)

UPDATE r
SET id_hospital_admission = k.entity_key
FROM rodis_wh.hospital_admission_fat r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_hospital_admission_att p
		WHERE p.id_hospital_admission = r.id_hospital_admission
		)

UPDATE r
SET id_hospital_admission = k.entity_key
FROM rodis_wh.diagnosis_m2m_fat r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_hospital_admission_att p
		WHERE p.id_hospital_admission = r.id_hospital_admission
		)

UPDATE r
SET id_hospital_admission = k.entity_key
FROM rodis_wh.procedure_m2m_fat r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_hospital_admission_att p
		WHERE p.id_hospital_admission = r.id_hospital_admission
		)

DELETE FROM a
FROM rodis_wh.hospital_admission_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_hospital_admission_att s
		WHERE s.id_hospital_admission = a.id_hospital_admission
		)

UPDATE STATISTICS rodis_wh.hospital_admission_att
