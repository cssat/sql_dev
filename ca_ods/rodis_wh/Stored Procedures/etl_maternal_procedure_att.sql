CREATE PROCEDURE [rodis_wh].[etl_maternal_procedure_att]
AS
IF OBJECT_ID('rodis_wh.staging_maternal_procedure_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_maternal_procedure_att

CREATE TABLE rodis_wh.staging_maternal_procedure_att(
	id_maternal_procedure INT NULL
	,cd_maternal_procedure VARCHAR(50) NULL
	,fl_hysterectomy TINYINT NULL
	,fl_induced TINYINT NULL
	,fl_any_obstetric_procedure TINYINT NULL
	,fl_forcep_use TINYINT NULL
	,fl_steroids_given TINYINT NULL
	,fl_labor_stimulation TINYINT NULL
	,fl_tocolysis_meds TINYINT NULL
	,fl_transfusion TINYINT NULL
	,fl_vacuum_failed VARCHAR(1) NULL
	,fl_vacuum_used TINYINT NULL
	,id_csection INT NULL
	,cd_csection VARCHAR(50) NULL
)

INSERT rodis_wh.staging_maternal_procedure_att (
	cd_maternal_procedure
	,fl_hysterectomy
	,fl_induced
	,fl_any_obstetric_procedure
	,fl_forcep_use
	,fl_steroids_given
	,fl_labor_stimulation
	,fl_tocolysis_meds
	,fl_transfusion
	,fl_vacuum_failed
	,fl_vacuum_used
	,cd_csection
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_maternal_procedure]
	,hyster [fl_hysterectomy]
	,indlab [fl_induced]
	,ob [fl_any_obstetric_procedure]
	,otforcep [fl_forcep_use]
	,steroids [fl_steroids_given]
	,stimlab [fl_labor_stimulation]
	,toco [fl_tocolysis_meds]
	,transfus [fl_transfusion]
	,vacfail [fl_vacuum_failed]
	,vacuum [fl_vacuum_used]
	,CONVERT(VARCHAR(50), csection) [cd_csection]
FROM rodis.berd

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_maternal_procedure]
	,CONVERT(TINYINT, NULL) [fl_hysterectomy]
	,CONVERT(TINYINT, NULL) [fl_induced]
	,CONVERT(TINYINT, NULL) [fl_any_obstetric_procedure]
	,CONVERT(TINYINT, NULL) [fl_forcep_use]
	,CONVERT(TINYINT, NULL) [fl_steroids_given]
	,CONVERT(TINYINT, NULL) [fl_labor_stimulation]
	,CONVERT(TINYINT, NULL) [fl_tocolysis_meds]
	,CONVERT(TINYINT, NULL) [fl_transfusion]
	,CONVERT(VARCHAR(1), NULL) [fl_vacuum_failed]
	,CONVERT(TINYINT, NULL) [fl_vacuum_used]
	,CONVERT(VARCHAR(50), -1) [cd_csection]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_maternal_procedure_att

CREATE NONCLUSTERED INDEX idx_staging_maternal_procedure_att_id_maternal_procedure ON rodis_wh.staging_maternal_procedure_att (
	id_maternal_procedure
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_procedure_att_cd_maternal_procedure ON rodis_wh.staging_maternal_procedure_att (
	cd_maternal_procedure
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_procedure_att_cd_csection ON rodis_wh.staging_maternal_procedure_att (
	cd_csection
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'maternal_procedure'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_maternal_procedure) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_maternal_procedure [source_key]
FROM rodis_wh.staging_maternal_procedure_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_maternal_procedure
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_maternal_procedure = k.entity_key
FROM rodis_wh.staging_maternal_procedure_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_maternal_procedure AND k.wh_column_id = @column_id

UPDATE a
SET id_csection = k.id_csection
FROM rodis_wh.staging_maternal_procedure_att a
INNER JOIN rodis_wh.staging_csection_att k ON k.cd_csection = a.cd_csection

UPDATE STATISTICS rodis_wh.staging_maternal_procedure_att

MERGE rodis_wh.maternal_procedure_att [target]
USING rodis_wh.staging_maternal_procedure_att [source]
	ON target.id_maternal_procedure = source.id_maternal_procedure
WHEN MATCHED
	THEN
		UPDATE
		SET fl_hysterectomy = source.fl_hysterectomy
			,fl_induced = source.fl_induced
			,fl_any_obstetric_procedure = source.fl_any_obstetric_procedure
			,fl_forcep_use = source.fl_forcep_use
			,fl_steroids_given = source.fl_steroids_given
			,fl_labor_stimulation = source.fl_labor_stimulation
			,fl_tocolysis_meds = source.fl_tocolysis_meds
			,fl_transfusion = source.fl_transfusion
			,fl_vacuum_failed = source.fl_vacuum_failed
			,fl_vacuum_used = source.fl_vacuum_used
			,id_csection = source.cd_csection
WHEN NOT MATCHED
	THEN
		INSERT (
			id_maternal_procedure
			,cd_maternal_procedure
			,fl_hysterectomy
			,fl_induced
			,fl_any_obstetric_procedure
			,fl_forcep_use
			,fl_steroids_given
			,fl_labor_stimulation
			,fl_tocolysis_meds
			,fl_transfusion
			,fl_vacuum_failed
			,fl_vacuum_used
			,id_csection
			)
		VALUES (
			source.id_maternal_procedure
			,source.cd_maternal_procedure
			,source.fl_hysterectomy
			,source.fl_induced
			,source.fl_any_obstetric_procedure
			,source.fl_forcep_use
			,source.fl_steroids_given
			,source.fl_labor_stimulation
			,source.fl_tocolysis_meds
			,source.fl_transfusion
			,source.fl_vacuum_failed
			,source.fl_vacuum_used
			,source.id_csection
			);

UPDATE STATISTICS rodis_wh.maternal_procedure_att

UPDATE r
SET id_maternal_procedure = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_procedure_att p
		WHERE p.id_maternal_procedure = r.id_maternal_procedure
		)

DELETE FROM a
FROM rodis_wh.maternal_procedure_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_procedure_att s
		WHERE s.id_maternal_procedure = a.id_maternal_procedure
		)

UPDATE STATISTICS rodis_wh.maternal_procedure_att
