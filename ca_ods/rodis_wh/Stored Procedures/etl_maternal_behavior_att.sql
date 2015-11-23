CREATE PROCEDURE [rodis_wh].[etl_maternal_behavior_att]
AS
IF OBJECT_ID('rodis_wh.staging_maternal_behavior_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_maternal_behavior_att

CREATE TABLE rodis_wh.staging_maternal_behavior_att(
	id_maternal_behavior INT NULL
	,cd_maternal_behavior VARCHAR(50) NULL
	,fl_married TINYINT NULL
	,fl_breast_feeding VARCHAR(1) NULL
	,qt_cigs_tri1 TINYINT NULL
	,qt_cigs_tri2 TINYINT NULL
	,qt_cigs_tri3 TINYINT NULL
	,qt_cigs_prior TINYINT NULL
	,qt_alcoholic_drinks TINYINT NULL
	,fl_drank_during_pregnancy TINYINT NULL
	,qt_cigs TINYINT NULL
	,qt_prenatal_visits TINYINT NULL
	,fl_smoked_during_pregnancy TINYINT NULL
	,fl_birth_injury TINYINT NULL
	,fl_chlamydia SMALLINT NULL
	,id_kotelchuck_index INT NULL
	,cd_kotelchuck_index VARCHAR(50)
)

INSERT rodis_wh.staging_maternal_behavior_att (
	cd_maternal_behavior
	,fl_married
	,fl_breast_feeding
	,qt_cigs_tri1
	,qt_cigs_tri2
	,qt_cigs_tri3
	,qt_cigs_prior
	,qt_alcoholic_drinks
	,fl_drank_during_pregnancy
	,qt_cigs
	,qt_prenatal_visits
	,fl_smoked_during_pregnancy
	,fl_birth_injury
	,fl_chlamydia
	,cd_kotelchuck_index
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_maternal_behavior]
	,maristat [fl_married]
	,breastfd [fl_breast_feeding]
	,cigs_1st [qt_cigs_tri1]
	,cigs_2nd [qt_cigs_tri2]
	,cigs_3rd [qt_cigs_tri3]
	,cigs_bef [qt_cigs_prior]
	,drinks [qt_alcoholic_drinks]
	,mdrink [fl_drank_during_pregnancy]
	,ncigs [qt_cigs]
	,prenatvs [qt_prenatal_visits]
	,smoked [fl_smoked_during_pregnancy]
	,binjur [fl_birth_injury]
	,chlamyd [fl_chlamydia]
	,CONVERT(VARCHAR(50), moindex4) [cd_kotelchuck_index]
FROM rodis.berd

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_maternal_behavior]
	,CONVERT(TINYINT, NULL) [fl_married]
	,CONVERT(VARCHAR(1), NULL) [fl_breast_feeding]
	,CONVERT(TINYINT, NULL) [qt_cigs_tri1]
	,CONVERT(TINYINT, NULL) [qt_cigs_tri2]
	,CONVERT(TINYINT, NULL) [qt_cigs_tri3]
	,CONVERT(TINYINT, NULL) [qt_cigs_prior]
	,CONVERT(TINYINT, NULL) [qt_alcoholic_drinks]
	,CONVERT(TINYINT, NULL) [fl_drank_during_pregnancy]
	,CONVERT(TINYINT, NULL) [qt_cigs]
	,CONVERT(TINYINT, NULL) [qt_prenatal_visits]
	,CONVERT(TINYINT, NULL) [fl_smoked_during_pregnancy]
	,CONVERT(TINYINT, NULL) [fl_birth_injury]
	,CONVERT(SMALLINT, NULL) [fl_chlamydia]
	,CONVERT(VARCHAR(50), -1) [cd_kotelchuck_index]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_maternal_behavior_att

CREATE NONCLUSTERED INDEX idx_staging_maternal_behavior_att_id_maternal_behavior ON rodis_wh.staging_maternal_behavior_att (
	id_maternal_behavior
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_behavior_att_cd_maternal_behavior ON rodis_wh.staging_maternal_behavior_att (
	cd_maternal_behavior
	)

CREATE NONCLUSTERED INDEX idx_staging_maternal_behavior_att_cd_kotelchuck_index ON rodis_wh.staging_maternal_behavior_att (
	cd_kotelchuck_index
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'maternal_behavior'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_maternal_behavior) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_maternal_behavior [source_key]
FROM rodis_wh.staging_maternal_behavior_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_maternal_behavior
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_maternal_behavior = k.entity_key
FROM rodis_wh.staging_maternal_behavior_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_maternal_behavior AND k.wh_column_id = @column_id

UPDATE a
SET id_kotelchuck_index = k.id_kotelchuck_index
FROM rodis_wh.staging_maternal_behavior_att a
INNER JOIN rodis_wh.staging_kotelchuck_index_att k ON k.cd_kotelchuck_index = ISNULL(a.cd_kotelchuck_index, '-1')

UPDATE STATISTICS rodis_wh.staging_maternal_behavior_att

MERGE rodis_wh.maternal_behavior_att [target]
USING rodis_wh.staging_maternal_behavior_att [source]
	ON target.id_maternal_behavior = source.id_maternal_behavior
WHEN MATCHED
	THEN
		UPDATE
		SET fl_married = source.fl_married
			,fl_breast_feeding = source.fl_breast_feeding
			,qt_cigs_tri1 = source.qt_cigs_tri1
			,qt_cigs_tri2 = source.qt_cigs_tri2
			,qt_cigs_tri3 = source.qt_cigs_tri3
			,qt_cigs_prior = source.qt_cigs_prior
			,qt_alcoholic_drinks = source.qt_alcoholic_drinks
			,fl_drank_during_pregnancy = source.fl_drank_during_pregnancy
			,qt_cigs = source.qt_cigs
			,qt_prenatal_visits = source.qt_prenatal_visits
			,fl_smoked_during_pregnancy = source.fl_smoked_during_pregnancy
			,fl_birth_injury = source.fl_birth_injury
			,fl_chlamydia = source.fl_chlamydia
			,id_kotelchuck_index = source.id_kotelchuck_index
WHEN NOT MATCHED
	THEN
		INSERT (
			id_maternal_behavior
			,cd_maternal_behavior
			,fl_married
			,fl_breast_feeding
			,qt_cigs_tri1
			,qt_cigs_tri2
			,qt_cigs_tri3
			,qt_cigs_prior
			,qt_alcoholic_drinks
			,fl_drank_during_pregnancy
			,qt_cigs
			,qt_prenatal_visits
			,fl_smoked_during_pregnancy
			,fl_birth_injury
			,fl_chlamydia
			,id_kotelchuck_index
			)
		VALUES (
			source.id_maternal_behavior
			,source.cd_maternal_behavior
			,source.fl_married
			,source.fl_breast_feeding
			,source.qt_cigs_tri1
			,source.qt_cigs_tri2
			,source.qt_cigs_tri3
			,source.qt_cigs_prior
			,source.qt_alcoholic_drinks
			,source.fl_drank_during_pregnancy
			,source.qt_cigs
			,source.qt_prenatal_visits
			,source.fl_smoked_during_pregnancy
			,source.fl_birth_injury
			,source.fl_chlamydia
			,source.id_kotelchuck_index
			);

UPDATE STATISTICS rodis_wh.maternal_behavior_att

UPDATE r
SET id_maternal_behavior = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_behavior_att p
		WHERE p.id_maternal_behavior = r.id_maternal_behavior
		)

DELETE FROM a
FROM rodis_wh.maternal_behavior_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_maternal_behavior_att s
		WHERE s.id_maternal_behavior = a.id_maternal_behavior
		)

UPDATE STATISTICS rodis_wh.maternal_behavior_att
