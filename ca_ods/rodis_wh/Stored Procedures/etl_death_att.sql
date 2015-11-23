CREATE PROCEDURE [rodis_wh].[etl_death_att]
AS
IF OBJECT_ID('rodis_wh.staging_death_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_death_att

CREATE TABLE rodis_wh.staging_death_att(
	id_death INT NULL
	,cd_death VARCHAR(50) NULL
	,fl_autopsy TINYINT NULL
	,fl_citizen TINYINT NULL
	,fl_city_limits_death VARCHAR(1) NULL
	,fl_coroner_referred TINYINT NULL
	,fl_smoked TINYINT NULL
	,dt_death_dtg DATETIME NULL
	,dt_injury_dtg DATETIME NULL
	,id_armed_forces INT NULL
	,cd_armed_forces VARCHAR(50) NULL
	,id_attendent_type INT NULL
	,cd_attendent_type VARCHAR(50) NULL
	,id_place_of_death INT NULL
	,cd_place_of_death VARCHAR(50) NULL
	,id_marital_status INT NULL
	,cd_marital_status VARCHAR(50) NULL
	,id_ucode INT NULL
	,cd_ucode VARCHAR(50) NULL
	,id_city_of_death INT NULL
	,cd_city_of_death VARCHAR(50) NULL
	,id_city_of_injury INT NULL
	,cd_city_of_injury VARCHAR(50) NULL
	,id_city_of_residence_at_death INT NULL
	,cd_city_of_residence_at_death VARCHAR(50) NULL
	,id_education INT NULL
	,cd_education VARCHAR(50) NULL
	,id_birth_administration INT NULL
	,cd_birth_administration VARCHAR(50) NULL
	,id_hospital_admission_last INT NULL
	,cd_hospital_admission_last VARCHAR(50) NULL
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

INSERT rodis_wh.staging_death_att (
	cd_death
	,fl_autopsy
	,fl_citizen
	,fl_city_limits_death
	,fl_coroner_referred
	,fl_smoked
	,dt_death_dtg
	,dt_injury_dtg
	,cd_armed_forces
	,cd_attendent_type
	,cd_place_of_death
	,cd_marital_status
	,cd_ucode
	,cd_city_of_death
	,cd_city_of_injury
	,cd_city_of_residence_at_death
	,cd_education
	,cd_birth_administration
	,cd_hospital_admission_last
	)
SELECT CONVERT(VARCHAR(50), b.bc_uni) [cd_death]
	,b.d_autopsy [fl_autopsy]
	,b.d_citizen [fl_citizen]
	,b.d_climit [fl_city_limits_death]
	,b.d_coroner [fl_coroner_referred]
	,b.d_smoked [fl_smoked]
	,DATETIMEFROMPARTS(b.deathyr, b.d_deathmo, b.d_deathdy, CASE
		WHEN b.d_dthhr = 99 AND b.d_dthampm = 'A'
			THEN 0
		WHEN b.d_dthhr = 99 AND b.d_dthampm = 'P'
			THEN 12
		WHEN b.d_dthhr IN (24, 99)
			THEN 0
		ELSE b.d_dthhr
		END, IIF(b.d_dthmin = 99, 0, b.d_dthmin), 0, 0) [dt_death_dtg]
	,CASE
		WHEN b.d_injyr IS NOT NULL
			THEN DATETIMEFROMPARTS(b.d_injyr, CASE
					WHEN b.d_injmo > 12
						THEN 1
					ELSE b.d_injmo
					END, CASE
					WHEN b.d_injdy > 31
						THEN 1
					ELSE b.d_injdy
					END, CASE
					WHEN b.d_injhr > 23
						THEN 0
					ELSE ISNULL(b.d_injhr, 0)
					END, CASE
					WHEN b.d_injmin > 59
						THEN 0 
					ELSE ISNULL(b.d_injmin, 0)
					END, 0, 0)
		ELSE CONVERT(DATETIME, NULL)
		END [dt_injury_dtg]
	,CONVERT(VARCHAR(50), b.d_armed) [cd_armed_forces]
	,CONVERT(VARCHAR(50), b.d_attend) [cd_attendent_type]
	,CASE
		WHEN d.d_dispo IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_dispo) + '-' + ISNULL(CONVERT(VARCHAR(50), b.d_dthplace), CONVERT(VARCHAR(50), -1))
		ELSE CONVERT(VARCHAR(50), b.d_dispo)
		END [cd_place_of_death]
	,CONVERT(VARCHAR(50), b.d_maristat) [cd_marital_status]
	,CONVERT(VARCHAR(50), b.d_ucod) [cd_ucode]
	,CASE
		WHEN dc.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_dcity) + '-' + CONVERT(VARCHAR(50), b.d_dcnty)
		ELSE CONVERT(VARCHAR(50), b.d_dcity)
		END [cd_city_of_death]
	,CASE
		WHEN ic.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_injcity) + '-' + CONVERT(VARCHAR(50), b.d_injcnty)
		ELSE CONVERT(VARCHAR(50), b.d_injcity)
		END [cd_city_of_injury]
	,CASE
		WHEN rc.city IS NOT NULL
			THEN CONVERT(VARCHAR(50), b.d_rcity) + '-' + CONVERT(VARCHAR(50), b.d_rcnty)
		ELSE CONVERT(VARCHAR(50), b.d_rcity)
		END [cd_city_of_residence_at_death]
	,CONVERT(VARCHAR(50), b.d_educate) [cd_education]
	,CONVERT(VARCHAR(50), b.bc_uni) [cd_birth_administration]
	,CONVERT(VARCHAR(50), b.bc_uni) + ISNULL('-' + CONVERT(VARCHAR(50), i.r_admnum), 'C') [cd_hospital_admission_last]
FROM rodis.bab_died b
LEFT JOIN (
		SELECT d_dispo
		FROM rodis.bab_died
		WHERE d_dispo IS NOT NULL
		GROUP BY d_dispo
		HAVING COUNT(DISTINCT d_dthplace) != 1
		) d ON d.d_dispo = b.d_dispo
LEFT JOIN dup_city dc ON dc.city = b.d_dcity
LEFT JOIN dup_city ic ON ic.city = b.d_injcity
LEFT JOIN dup_city rc ON rc.city = b.d_rcity
LEFT JOIN (
		SELECT bc_uni
			,MAX(r_admnum) [r_admnum]
		FROM rodis.bab_read
		GROUP BY bc_uni
		) i ON i.bc_uni = b.bc_uni

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_death]
	,CONVERT(TINYINT, NULL) [fl_autopsy]
	,CONVERT(TINYINT, NULL) [fl_citizen]
	,CONVERT(VARCHAR(1), NULL) [fl_city_limits_death]
	,CONVERT(TINYINT, NULL) [fl_coroner_referred]
	,CONVERT(TINYINT, NULL) [fl_smoked]
	,CONVERT(DATETIME, NULL) [dt_death_dtg]
	,CONVERT(DATETIME, NULL) [dt_injury_dtg]
	,CONVERT(VARCHAR(50), -1) [cd_armed_forces]
	,CONVERT(VARCHAR(50), -1) [cd_attendent_type]
	,CONVERT(VARCHAR(50), -1) [cd_place_of_death]
	,CONVERT(VARCHAR(50), -1) [cd_marital_status]
	,CONVERT(VARCHAR(50), -1) [cd_ucode]
	,CONVERT(VARCHAR(50), -1) [cd_city_of_death]
	,CONVERT(VARCHAR(50), -1) [cd_city_of_injury]
	,CONVERT(VARCHAR(50), -1) [cd_city_of_residence_at_death]
	,CONVERT(VARCHAR(50), -1) [cd_education]
	,CONVERT(VARCHAR(50), -1) [cd_birth_administration]
	,CONVERT(VARCHAR(50), -1) [cd_hospital_admission_last]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_death_att

CREATE NONCLUSTERED INDEX idx_staging_death_att_id_death ON rodis_wh.staging_death_att (
	id_death
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_death ON rodis_wh.staging_death_att (
	cd_death
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_armed_forces ON rodis_wh.staging_death_att (
	cd_armed_forces
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_attendent_type ON rodis_wh.staging_death_att (
	cd_attendent_type
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_place_of_death ON rodis_wh.staging_death_att (
	cd_place_of_death
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_marital_status ON rodis_wh.staging_death_att (
	cd_marital_status
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_ucode ON rodis_wh.staging_death_att (
	cd_ucode
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_city_of_death ON rodis_wh.staging_death_att (
	cd_city_of_death
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_city_of_injury ON rodis_wh.staging_death_att (
	cd_city_of_injury
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_city_of_residence_at_death ON rodis_wh.staging_death_att (
	cd_city_of_residence_at_death
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_education ON rodis_wh.staging_death_att (
	cd_education
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_birth_administration ON rodis_wh.staging_death_att (
	cd_birth_administration
	)

CREATE NONCLUSTERED INDEX idx_staging_death_att_cd_hospital_admission_last ON rodis_wh.staging_death_att (
	cd_hospital_admission_last
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'death'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_death) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_death [source_key]
FROM rodis_wh.staging_death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_death
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_death = k.entity_key
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_death AND k.wh_column_id = @column_id

UPDATE a
SET id_armed_forces = k.id_armed_forces
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_armed_forces_att k ON k.cd_armed_forces = ISNULL(a.cd_armed_forces, '-1')

UPDATE a
SET id_attendent_type = k.id_attendent_type
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_attendent_type_att k ON k.cd_attendent_type = ISNULL(a.cd_attendent_type, '-1')

UPDATE a
SET id_place_of_death = k.id_place_of_death
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_place_of_death_att k ON k.cd_place_of_death = ISNULL(a.cd_place_of_death, '-1')

UPDATE a
SET id_marital_status = k.id_marital_status
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_marital_status_att k ON k.cd_marital_status = ISNULL(a.cd_marital_status, '-1')

UPDATE a
SET id_ucode = k.id_ucode
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_ucode_att k ON k.cd_ucode = ISNULL(a.cd_ucode, '-1')

UPDATE a
SET id_city_of_death = k.id_city
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_city_att k ON k.cd_city = ISNULL(a.cd_city_of_death, '-1')

UPDATE a
SET id_city_of_injury = k.id_city
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_city_att k ON k.cd_city = ISNULL(a.cd_city_of_injury, '-1')

UPDATE a
SET id_city_of_residence_at_death = k.id_city
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_city_att k ON k.cd_city = ISNULL(a.cd_city_of_residence_at_death, '-1')

UPDATE a
SET id_education = k.id_education
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_education_att k ON k.cd_education = ISNULL(a.cd_education, '-1')

UPDATE a
SET id_birth_administration = k.id_birth_administration
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_birth_administration_att k ON k.cd_birth_administration = ISNULL(a.cd_birth_administration, '-1')

DECLARE @birth_table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'birth_administration'
			AND wh_table_type_id = 1 -- att
		)
DECLARE @birth_column_id INT = (
		SELECT wh_column_id
		FROM rodis_wh.wh_column
		WHERE wh_table_id = @birth_table_id AND wh_column_type_id = 2 -- source
		)

UPDATE a
SET id_birth_administration = k.entity_key
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @birth_column_id AND k.source_key = '-1'
WHERE a.id_birth_administration IS NULL

UPDATE a
SET id_hospital_admission_last = k.id_hospital_admission
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.staging_hospital_admission_att k ON k.cd_hospital_admission = ISNULL(a.cd_hospital_admission_last, '-1')

DECLARE @hosp_table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'hospital_admission'
			AND wh_table_type_id = 1 -- att
		)
DECLARE @hosp_column_id INT = (
		SELECT wh_column_id
		FROM rodis_wh.wh_column
		WHERE wh_table_id = @hosp_table_id AND wh_column_type_id = 2 -- source
		)

UPDATE a
SET id_hospital_admission_last = k.entity_key
FROM rodis_wh.staging_death_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @hosp_column_id AND k.source_key = '-1'
WHERE a.id_hospital_admission_last IS NULL

UPDATE STATISTICS rodis_wh.staging_death_att

MERGE rodis_wh.death_att [target]
USING rodis_wh.staging_death_att [source]
	ON target.id_death = source.id_death
WHEN MATCHED
	THEN
		UPDATE
		SET fl_autopsy = source.fl_autopsy
			,fl_citizen = source.fl_citizen
			,fl_city_limits_death = source.fl_city_limits_death
			,fl_coroner_referred = source.fl_coroner_referred
			,fl_smoked = source.fl_smoked
			,dt_death_dtg = source.dt_death_dtg
			,dt_injury_dtg = source.dt_injury_dtg
			,id_armed_forces = source.id_armed_forces
			,id_attendent_type = source.id_attendent_type
			,id_place_of_death = source.id_place_of_death
			,id_marital_status = source.id_marital_status
			,id_ucode = source.id_ucode
			,id_city_of_death = source.id_city_of_death
			,id_city_of_injury = source.id_city_of_injury
			,id_city_of_residence_at_death = source.id_city_of_residence_at_death
			,id_education = source.id_education
			,id_birth_administration = source.id_birth_administration
			,id_hospital_admission_last = source.id_hospital_admission_last
WHEN NOT MATCHED
	THEN
		INSERT (
			id_death
			,cd_death
			,fl_autopsy
			,fl_citizen
			,fl_city_limits_death
			,fl_coroner_referred
			,fl_smoked
			,dt_death_dtg
			,dt_injury_dtg
			,id_armed_forces
			,id_attendent_type
			,id_place_of_death
			,id_marital_status
			,id_ucode
			,id_city_of_death
			,id_city_of_injury
			,id_city_of_residence_at_death
			,id_education
			,id_birth_administration
			,id_hospital_admission_last
			)
		VALUES (
			source.id_death
			,source.cd_death
			,source.fl_autopsy
			,source.fl_citizen
			,source.fl_city_limits_death
			,source.fl_coroner_referred
			,source.fl_smoked
			,source.dt_death_dtg
			,source.dt_injury_dtg
			,source.id_armed_forces
			,source.id_attendent_type
			,source.id_place_of_death
			,source.id_marital_status
			,source.id_ucode
			,source.id_city_of_death
			,source.id_city_of_injury
			,source.id_city_of_residence_at_death
			,source.id_education
			,source.id_birth_administration
			,source.id_hospital_admission_last
			);

UPDATE r
SET id_death = k.entity_key
FROM rodis_wh.death_fat r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_death_att p
		WHERE p.id_death = r.id_death
		)

UPDATE r
SET id_death = k.entity_key
FROM rodis_wh.cause_of_death_m2m_fat r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_death_att p
		WHERE p.id_death = r.id_death
		)

DELETE FROM a
FROM rodis_wh.death_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_death_att s
		WHERE s.id_death = a.id_death
		)

UPDATE STATISTICS rodis_wh.death_att
