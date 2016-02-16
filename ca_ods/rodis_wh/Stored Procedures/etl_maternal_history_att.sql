CREATE PROCEDURE [rodis_wh].[etl_maternal_history_att]
AS
IF OBJECT_ID('rodis_wh.staging_maternal_history_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_maternal_history_att

CREATE TABLE rodis_wh.staging_maternal_history_att(
	id_maternal_history INT NULL
	,cd_maternal_history VARCHAR(50) NULL
	,qt_prior_fetal_geq_20wks TINYINT NULL
	,qt_prior_fetal_lt_20wks TINYINT NULL
	,qt_months_at_residence SMALLINT NULL
	,qt_years_at_residence TINYINT NULL
	,qt_induced_termination_of_pregnancy TINYINT NULL
	,qt_born_child_now_dead TINYINT NULL
	,qt_born_child_now_living TINYINT NULL
	,dt_last_pregnancy_year SMALLINT NULL
	,dt_last_birth_year SMALLINT NULL
	,qt_parity TINYINT NULL
	,fl_previous_csection TINYINT NULL
	,fl_previous_preterm_infant TINYINT NULL
	,qt_prior_csections TINYINT NULL
	,dt_last_pregnancy_month TINYINT NULL
	,dt_last_birth_month TINYINT NULL
	,id_fetal_or_infant_death INT NULL
	,cd_fetal_or_infant_death VARCHAR(50) NULL
)

INSERT rodis_wh.staging_maternal_history_att (
	cd_maternal_history
	,qt_prior_fetal_geq_20wks
	,qt_prior_fetal_lt_20wks
	,qt_months_at_residence
	,qt_years_at_residence
	,qt_induced_termination_of_pregnancy
	,qt_born_child_now_dead
	,qt_born_child_now_living
	,dt_last_pregnancy_year
	,dt_last_birth_year
	,qt_parity
	,fl_previous_csection
	,fl_previous_preterm_infant
	,qt_prior_csections
	,dt_last_pregnancy_month
	,dt_last_birth_month
	,cd_fetal_or_infant_death
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_maternal_history]
	,fdge20 [qt_prior_fetal_geq_20wks]
	,fdlt20 [qt_prior_fetal_lt_20wks]
	,howlgm [qt_months_at_residence]
	,howlgy [qt_years_at_residence]
	,indterm [qt_induced_termination_of_pregnancy]
	,lbnd [qt_born_child_now_dead]
	,lbnl [qt_born_child_now_living]
	,lstfetyr [dt_last_pregnancy_year]
	,lstlivyr [dt_last_birth_year]
	,PARITY [qt_parity]
	,precsec [fl_previous_csection]
	,preterm [fl_previous_preterm_infant]
	,prev_cno [qt_prior_csections]
	,lstfetmo [dt_last_pregnancy_month]
	,lstlivmo [dt_last_birth_month]
	,CONVERT(VARCHAR(50), fdid) [cd_fetal_or_infant_death]
FROM rodis.berd

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_maternal_history]
	,CONVERT(TINYINT, NULL) [qt_prior_fetal_geq_20wks]
	,CONVERT(TINYINT, NULL) [qt_prior_fetal_lt_20wks]
	,CONVERT(SMALLINT, NULL) [qt_months_at_residence]
	,CONVERT(TINYINT, NULL) [qt_years_at_residence]
	,CONVERT(TINYINT, NULL) [qt_induced_termination_of_pregnancy]
	,CONVERT(TINYINT, NULL) [qt_born_child_now_dead]
	,CONVERT(TINYINT, NULL) [qt_born_child_now_living]
	,CONVERT(SMALLINT, NULL) [dt_last_pregnancy_year]
	,CONVERT(SMALLINT, NULL) [dt_last_birth_year]
	,CONVERT(TINYINT, NULL) [qt_parity]
	,CONVERT(TINYINT, NULL) [fl_previous_csection]
	,CONVERT(TINYINT, NULL) [fl_previous_preterm_infant]
	,CONVERT(TINYINT, NULL) [qt_prior_csections]
	,CONVERT(TINYINT, NULL) [dt_last_pregnancy_month]
	,CONVERT(TINYINT, NULL) [dt_last_birth_month]
	,CONVERT(VARCHAR(50), -1) [cd_fetal_or_infant_death]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_maternal_history_att

CREATE NONCLUSTERED INDEX idx_staging_maternal_history_att_id_maternal_history ON rodis_wh.staging_maternal_history_att (
	id_maternal_history
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_history_att_cd_maternal_history ON rodis_wh.staging_maternal_history_att (
	cd_maternal_history
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_history_att_cd_fetal_or_infant_death ON rodis_wh.staging_maternal_history_att (
	cd_fetal_or_infant_death
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'maternal_history'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_maternal_history) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_maternal_history [source_key]
FROM rodis_wh.staging_maternal_history_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_maternal_history
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_maternal_history = k.entity_key
FROM rodis_wh.staging_maternal_history_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_maternal_history AND k.wh_column_id = @column_id

UPDATE a
SET id_fetal_or_infant_death = k.id_fetal_or_infant_death
FROM rodis_wh.staging_maternal_history_att a
INNER JOIN rodis_wh.staging_fetal_or_infant_death_att k ON k.cd_fetal_or_infant_death = ISNULL(a.cd_fetal_or_infant_death, '-1')

UPDATE STATISTICS rodis_wh.staging_maternal_history_att

MERGE rodis_wh.maternal_history_att [target]
USING rodis_wh.staging_maternal_history_att [source]
	ON target.id_maternal_history = source.id_maternal_history
WHEN MATCHED
	THEN
		UPDATE
		SET qt_prior_fetal_geq_20wks = source.qt_prior_fetal_geq_20wks
			,qt_prior_fetal_lt_20wks = source.qt_prior_fetal_lt_20wks
			,qt_months_at_residence = source.qt_months_at_residence
			,qt_years_at_residence = source.qt_years_at_residence
			,qt_induced_termination_of_pregnancy = source.qt_induced_termination_of_pregnancy
			,qt_born_child_now_dead = source.qt_born_child_now_dead
			,qt_born_child_now_living = source.qt_born_child_now_living
			,dt_last_pregnancy_year = source.dt_last_pregnancy_year
			,dt_last_birth_year = source.dt_last_birth_year
			,qt_parity = source.qt_parity
			,fl_previous_csection = source.fl_previous_csection
			,fl_previous_preterm_infant = source.fl_previous_preterm_infant
			,qt_prior_csections = source.qt_prior_csections
			,dt_last_pregnancy_month = source.dt_last_pregnancy_month
			,dt_last_birth_month = source.dt_last_birth_month
			,id_fetal_or_infant_death = source.id_fetal_or_infant_death
WHEN NOT MATCHED
	THEN
		INSERT (
			id_maternal_history
			,cd_maternal_history
			,qt_prior_fetal_geq_20wks
			,qt_prior_fetal_lt_20wks
			,qt_months_at_residence
			,qt_years_at_residence
			,qt_induced_termination_of_pregnancy
			,qt_born_child_now_dead
			,qt_born_child_now_living
			,dt_last_pregnancy_year
			,dt_last_birth_year
			,qt_parity
			,fl_previous_csection
			,fl_previous_preterm_infant
			,qt_prior_csections
			,dt_last_pregnancy_month
			,dt_last_birth_month
			,id_fetal_or_infant_death
			)
		VALUES (
			source.id_maternal_history
			,source.cd_maternal_history
			,source.qt_prior_fetal_geq_20wks
			,source.qt_prior_fetal_lt_20wks
			,source.qt_months_at_residence
			,source.qt_years_at_residence
			,source.qt_induced_termination_of_pregnancy
			,source.qt_born_child_now_dead
			,source.qt_born_child_now_living
			,source.dt_last_pregnancy_year
			,source.dt_last_birth_year
			,source.qt_parity
			,source.fl_previous_csection
			,source.fl_previous_preterm_infant
			,source.qt_prior_csections
			,source.dt_last_pregnancy_month
			,source.dt_last_birth_month
			,source.id_fetal_or_infant_death
			);

UPDATE STATISTICS rodis_wh.maternal_history_att

UPDATE r
SET id_maternal_history = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_history_att p
		WHERE p.id_maternal_history = r.id_maternal_history
		)

DELETE FROM a
FROM rodis_wh.maternal_history_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_history_att s
		WHERE s.id_maternal_history = a.id_maternal_history
		)

UPDATE STATISTICS rodis_wh.maternal_history_att
