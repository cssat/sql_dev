CREATE PROCEDURE [rodis_wh].[etl_maternal_condition_att]
AS
IF OBJECT_ID('rodis_wh.staging_maternal_condition_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_maternal_condition_att

CREATE TABLE rodis_wh.staging_maternal_condition_att(
	id_maternal_condition INT NULL
	,cd_maternal_condition VARCHAR(50) NULL
	,fl_amniorrhexis TINYINT NULL
	,fl_any_maternal_infection SMALLINT NULL
	,fl_chronic_hypertension TINYINT NULL
	,fl_diabetes_mellitus TINYINT NULL
	,fl_failure_to_progress TINYINT NULL
	,fl_fetal_distress TINYINT NULL
	,fl_gestational_hypertension TINYINT NULL
	,fl_hepatitis_b_mom SMALLINT NULL
	,fl_hepatitis_c SMALLINT NULL
	,fl_herpes SMALLINT NULL
	,fl_gonorrhea SMALLINT NULL
	,fl_labor_complications TINYINT NULL
	,fl_other_maternal_infections SMALLINT NULL
	,fl_precipitating_labor_lt_3hrs TINYINT NULL
	,fl_pregnancy_complications TINYINT NULL
	,fl_seizures TINYINT NULL
	,fl_spontaneous_delivery TINYINT NULL
	,fl_syphillis SMALLINT NULL
	,id_dysfunctional_uterine_bleed INT NULL
	,cd_dysfunctional_uterine_bleed VARCHAR(50) NULL
)

INSERT rodis_wh.staging_maternal_condition_att (
	cd_maternal_condition
	,fl_amniorrhexis
	,fl_any_maternal_infection
	,fl_chronic_hypertension
	,fl_diabetes_mellitus
	,fl_failure_to_progress
	,fl_fetal_distress
	,fl_gestational_hypertension
	,fl_hepatitis_b_mom
	,fl_hepatitis_c
	,fl_herpes
	,fl_gonorrhea
	,fl_labor_complications
	,fl_other_maternal_infections
	,fl_precipitating_labor_lt_3hrs
	,fl_pregnancy_complications
	,fl_seizures
	,fl_spontaneous_delivery
	,fl_syphillis
	,cd_dysfunctional_uterine_bleed
	)
SELECT DISTINCT CONVERT(VARCHAR(50), bc_uni) [cd_maternal_condition]
	,rupmem [fl_amniorrhexis]
	,minfect [fl_any_maternal_infection]
	,hyper [fl_chronic_hypertension]
	,diabetes [fl_diabetes_mellitus]
	,longlab [fl_failure_to_progress]
	,fdist [fl_fetal_distress]
	,preclamp [fl_gestational_hypertension]
	,hepatitb [fl_hepatitis_b_mom]
	,hepatitc [fl_hepatitis_c]
	,gherpes [fl_herpes]
	,gonorrh [fl_gonorrhea]
	,labcomp [fl_labor_complications]
	,othinfec [fl_other_maternal_infections]
	,precipl [fl_precipitating_labor_lt_3hrs]
	,comp [fl_pregnancy_complications]
	,seizures [fl_seizures]
	,spontdel [fl_spontaneous_delivery]
	,syphil [fl_syphillis]
	,CONVERT(VARCHAR(50), trimest) [cd_dysfunctional_uterine_bleed]
FROM rodis.berd

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_maternal_condition]
	,CONVERT(TINYINT, NULL) [fl_amniorrhexis]
	,CONVERT(SMALLINT, NULL) [fl_any_maternal_infection]
	,CONVERT(TINYINT, NULL) [fl_chronic_hypertension]
	,CONVERT(TINYINT, NULL) [fl_diabetes_mellitus]
	,CONVERT(TINYINT, NULL) [fl_failure_to_progress]
	,CONVERT(TINYINT, NULL) [fl_fetal_distress]
	,CONVERT(TINYINT, NULL) [fl_gestational_hypertension]
	,CONVERT(SMALLINT, NULL) [fl_hepatitis_b_mom]
	,CONVERT(SMALLINT, NULL) [fl_hepatitis_c]
	,CONVERT(SMALLINT, NULL) [fl_herpes]
	,CONVERT(SMALLINT, NULL) [fl_gonorrhea]
	,CONVERT(TINYINT, NULL) [fl_labor_complications]
	,CONVERT(SMALLINT, NULL) [fl_other_maternal_infections]
	,CONVERT(TINYINT, NULL) [fl_precipitating_labor_lt_3hrs]
	,CONVERT(TINYINT, NULL) [fl_pregnancy_complications]
	,CONVERT(TINYINT, NULL) [fl_seizures]
	,CONVERT(TINYINT, NULL) [fl_spontaneous_delivery]
	,CONVERT(SMALLINT, NULL) [fl_syphillis]
	,CONVERT(VARCHAR(50), -1) [cd_dysfunctional_uterine_bleed]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_maternal_condition_att

CREATE NONCLUSTERED INDEX idx_staging_maternal_condition_att_id_maternal_condition ON rodis_wh.staging_maternal_condition_att (
	id_maternal_condition
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_condition_att_cd_maternal_condition ON rodis_wh.staging_maternal_condition_att (
	cd_maternal_condition
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_condition_att_cd_dysfunctional_uterine_bleed ON rodis_wh.staging_maternal_condition_att (
	cd_dysfunctional_uterine_bleed
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'maternal_condition'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_maternal_condition) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_maternal_condition [source_key]
FROM rodis_wh.staging_maternal_condition_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_maternal_condition
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_maternal_condition = k.entity_key
FROM rodis_wh.staging_maternal_condition_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_maternal_condition AND k.wh_column_id = @column_id

UPDATE a
SET id_dysfunctional_uterine_bleed = k.id_dysfunctional_uterine_bleed
FROM rodis_wh.staging_maternal_condition_att a
INNER JOIN rodis_wh.staging_dysfunctional_uterine_bleed_att k ON k.cd_dysfunctional_uterine_bleed = ISNULL(a.cd_dysfunctional_uterine_bleed, '-1')

UPDATE STATISTICS rodis_wh.staging_maternal_condition_att

MERGE rodis_wh.maternal_condition_att [target]
USING rodis_wh.staging_maternal_condition_att [source]
	ON target.id_maternal_condition = source.id_maternal_condition
WHEN MATCHED
	THEN
		UPDATE
		SET fl_amniorrhexis = source.fl_amniorrhexis
			,fl_any_maternal_infection = source.fl_any_maternal_infection
			,fl_chronic_hypertension = source.fl_chronic_hypertension
			,fl_diabetes_mellitus = source.fl_diabetes_mellitus
			,fl_failure_to_progress = source.fl_failure_to_progress
			,fl_fetal_distress = source.fl_fetal_distress
			,fl_gestational_hypertension = source.fl_gestational_hypertension
			,fl_hepatitis_b_mom = source.fl_hepatitis_b_mom
			,fl_hepatitis_c = source.fl_hepatitis_c
			,fl_herpes = source.fl_herpes
			,fl_gonorrhea = source.fl_gonorrhea
			,fl_labor_complications = source.fl_labor_complications
			,fl_other_maternal_infections = source.fl_other_maternal_infections
			,fl_precipitating_labor_lt_3hrs = source.fl_precipitating_labor_lt_3hrs
			,fl_pregnancy_complications = source.fl_pregnancy_complications
			,fl_seizures = source.fl_seizures
			,fl_spontaneous_delivery = source.fl_spontaneous_delivery
			,fl_syphillis = source.fl_syphillis
			,id_dysfunctional_uterine_bleed = source.id_dysfunctional_uterine_bleed

WHEN NOT MATCHED
	THEN
		INSERT (
			id_maternal_condition
			,cd_maternal_condition
			,fl_amniorrhexis
			,fl_any_maternal_infection
			,fl_chronic_hypertension
			,fl_diabetes_mellitus
			,fl_failure_to_progress
			,fl_fetal_distress
			,fl_gestational_hypertension
			,fl_hepatitis_b_mom
			,fl_hepatitis_c
			,fl_herpes
			,fl_gonorrhea
			,fl_labor_complications
			,fl_other_maternal_infections
			,fl_precipitating_labor_lt_3hrs
			,fl_pregnancy_complications
			,fl_seizures
			,fl_spontaneous_delivery
			,fl_syphillis
			,id_dysfunctional_uterine_bleed
			)
		VALUES (
			source.id_maternal_condition
			,source.cd_maternal_condition
			,source.fl_amniorrhexis
			,source.fl_any_maternal_infection
			,source.fl_chronic_hypertension
			,source.fl_diabetes_mellitus
			,source.fl_failure_to_progress
			,source.fl_fetal_distress
			,source.fl_gestational_hypertension
			,source.fl_hepatitis_b_mom
			,source.fl_hepatitis_c
			,source.fl_herpes
			,source.fl_gonorrhea
			,source.fl_labor_complications
			,source.fl_other_maternal_infections
			,source.fl_precipitating_labor_lt_3hrs
			,source.fl_pregnancy_complications
			,source.fl_seizures
			,source.fl_spontaneous_delivery
			,source.fl_syphillis
			,source.id_dysfunctional_uterine_bleed
			);

UPDATE STATISTICS rodis_wh.maternal_condition_att

UPDATE r
SET id_maternal_condition = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_condition_att p
		WHERE p.id_maternal_condition = r.id_maternal_condition
		)

DELETE FROM a
FROM rodis_wh.maternal_condition_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_condition_att s
		WHERE s.id_maternal_condition = a.id_maternal_condition
		)

UPDATE STATISTICS rodis_wh.maternal_condition_att
