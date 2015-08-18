CREATE PROCEDURE [rodis_wh].[etl_hospital_admission_fat]
AS
IF OBJECT_ID('rodis_wh.staging_hospital_admission_fat') IS NOT NULL
	DROP TABLE rodis_wh.staging_hospital_admission_fat

CREATE TABLE rodis_wh.staging_hospital_admission_fat(
	id_hospital_admission_fact INT NULL
	,cd_hospital_admission_fact VARCHAR(50) NULL
	,id_prsn_child INT NULL
	,id_calendar_dim_admit INT NULL
	,id_calendar_dim_discharge INT NULL
	,am_hospital_charges FLOAT NULL
	,qt_length_of_stay_days INT NULL
	,qt_of_admissions INT NULL
	,id_hospital_admission INT NULL
	,cd_hospital_admission VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_fat_id_hospital_admission_fact ON rodis_wh.staging_hospital_admission_fat (
	id_hospital_admission_fact
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_fat_cd_hospital_admission_fact ON rodis_wh.staging_hospital_admission_fat (
	cd_hospital_admission_fact
	)

CREATE NONCLUSTERED INDEX idx_staging_hospital_admission_fat_cd_hospital_admission ON rodis_wh.staging_hospital_admission_fat (
	cd_hospital_admission
	)

INSERT rodis_wh.staging_hospital_admission_fat (
	cd_hospital_admission_fact
	,id_prsn_child
	,id_calendar_dim_admit
	,id_calendar_dim_discharge
	,am_hospital_charges
	,qt_length_of_stay_days
	,qt_of_admissions
	,cd_hospital_admission
	)
SELECT CONVERT(VARCHAR(50), b.bc_uni) + '-' + CONVERT(VARCHAR(10), B.r_admnum) [cd_hospital_admission_fact]
	,b.PAT_ID [id_prsn_child]
	,CONVERT(VARCHAR(20), DATEFROMPARTS(b.r_admyr, b.r_admmo, b.r_admdy), 112) [id_calendar_dim_admit]
	,CONVERT(VARCHAR(20), DATEFROMPARTS(b.r_disyr, b.r_dismo, b.r_disdy), 112) [id_calendar_dim_discharge]
	,b.r_charge [am_hospital_charges]
	,b.r_stay [qt_length_of_stay_days]
	,b.r_admtot [qt_of_admissions]
	,CONVERT(VARCHAR(50), b.bc_uni) + '-' + CONVERT(VARCHAR(10), B.r_admnum) [cd_hospital_admission]
FROM rodis.bab_read b
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_hospital_admission_fat

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'hospital_admission'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_hospital_admission_fact) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_hospital_admission_fact [source_key]
FROM rodis_wh.staging_hospital_admission_fat a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_hospital_admission_fact
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_hospital_admission_fact = k.entity_key
FROM rodis_wh.staging_hospital_admission_fat a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_hospital_admission_fact AND k.wh_column_id = @column_id

UPDATE a
SET id_hospital_admission = k.id_hospital_admission
FROM rodis_wh.staging_hospital_admission_fat a
LEFT JOIN rodis_wh.staging_hospital_admission_att k ON k.cd_hospital_admission = ISNULL(a.cd_hospital_admission, '-1')

MERGE rodis_wh.hospital_admission_fat [target]
USING rodis_wh.staging_hospital_admission_fat [source]
	ON target.id_hospital_admission_fact = source.id_hospital_admission_fact
WHEN MATCHED
	THEN
		UPDATE
		SET id_prsn_child = source.id_prsn_child
		,id_calendar_dim_admit = source.id_calendar_dim_admit
		,id_calendar_dim_discharge = source.id_calendar_dim_discharge
		,am_hospital_charges = source.am_hospital_charges
		,qt_length_of_stay_days = source.qt_length_of_stay_days
		,qt_of_admissions = source.qt_of_admissions
		,id_hospital_admission = source.id_hospital_admission
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_hospital_admission_fact
			,cd_hospital_admission_fact
			,id_prsn_child
			,id_calendar_dim_admit
			,id_calendar_dim_discharge
			,am_hospital_charges
			,qt_length_of_stay_days
			,qt_of_admissions
			,id_hospital_admission
			)
		VALUES (
			source.id_hospital_admission_fact
			,source.cd_hospital_admission_fact
			,source.id_prsn_child
			,source.id_calendar_dim_admit
			,source.id_calendar_dim_discharge
			,source.am_hospital_charges
			,source.qt_length_of_stay_days
			,source.qt_of_admissions
			,source.id_hospital_admission
			)
WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE;

UPDATE STATISTICS rodis_wh.hospital_admission_fat
