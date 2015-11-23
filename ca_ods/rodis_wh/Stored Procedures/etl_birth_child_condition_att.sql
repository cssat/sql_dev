CREATE PROCEDURE [rodis_wh].[etl_birth_child_condition_att]
AS
IF OBJECT_ID('rodis_wh.staging_birth_child_condition_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_birth_child_condition_att

CREATE TABLE rodis_wh.staging_birth_child_condition_att(
	id_birth_child_condition INT NULL
	,cd_birth_child_condition VARCHAR(50) NULL
	,ms_apgar5 TINYINT NULL
	,ms_apgar10 TINYINT NULL
	,fl_anencephaly TINYINT NULL
	,fl_breech TINYINT NULL
	,fl_chromosome_anomaly TINYINT NULL
	,fl_diaphragmic_hernia TINYINT NULL
	,fl_downs_syndrome TINYINT NULL
	,fl_heart_malformations TINYINT NULL
	,fl_orofacial_cleft TINYINT NULL
	,fl_spinabifida TINYINT NULL
	,fl_small_for_gestational_age TINYINT NULL
	,fl_omphalocele TINYINT NULL
	,fl_meconium_mod_to_heavy TINYINT NULL
)
INSERT rodis_wh.staging_birth_child_condition_att (
	cd_birth_child_condition
	,ms_apgar5
	,ms_apgar10
	,fl_anencephaly
	,fl_breech
	,fl_chromosome_anomaly
	,fl_diaphragmic_hernia
	,fl_downs_syndrome
	,fl_heart_malformations
	,fl_orofacial_cleft
	,fl_spinabifida
	,fl_small_for_gestational_age
	,fl_omphalocele
	,fl_meconium_mod_to_heavy
	)
SELECT CONVERT(VARCHAR(50), bc_uni) [cd_birth_child_condition]
	,apgar5 [ms_apgar5]
	,apgar10 [ms_apgar10]
	,anen [fl_anencephaly]
	,breech [fl_breech]
	,chromo [fl_chromosome_anomaly]
	,diahern [fl_diaphragmic_hernia]
	,downs [fl_downs_syndrome]
	,heart [fl_heart_malformations]
	,clftlp [fl_orofacial_cleft]
	,spinb [fl_spinabifida]
	,sga [fl_small_for_gestational_age]
	,omph [fl_omphalocele]
	,mecon [fl_meconium_mod_to_heavy]
FROM rodis.berd

UNION ALL

SELECT CONVERT(VARCHAR(50), -1) [cd_birth_child_condition]
	,CONVERT(TINYINT, NULL) [ms_apgar5]
	,CONVERT(TINYINT, NULL) [ms_apgar10]
	,CONVERT(TINYINT, NULL) [fl_anencephaly]
	,CONVERT(TINYINT, NULL) [fl_breech]
	,CONVERT(TINYINT, NULL) [fl_chromosome_anomaly]
	,CONVERT(TINYINT, NULL) [fl_diaphragmic_hernia]
	,CONVERT(TINYINT, NULL) [fl_downs_syndrome]
	,CONVERT(TINYINT, NULL) [fl_heart_malformations]
	,CONVERT(TINYINT, NULL) [fl_orofacial_cleft]
	,CONVERT(TINYINT, NULL) [fl_spinabifida]
	,CONVERT(TINYINT, NULL) [fl_small_for_gestational_age]
	,CONVERT(TINYINT, NULL) [fl_omphalocele]
	,CONVERT(TINYINT, NULL) [fl_meconium_mod_to_heavy]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_birth_child_condition_att

CREATE NONCLUSTERED INDEX idx_staging_birth_child_condition_att_id_birth_child_condition ON rodis_wh.staging_birth_child_condition_att (
	id_birth_child_condition
	)

CREATE NONCLUSTERED INDEX idx_staging_birth_child_condition_att_cd_birth_child_condition ON rodis_wh.staging_birth_child_condition_att (
	cd_birth_child_condition
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'birth_child_condition'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_birth_child_condition) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_birth_child_condition [source_key]
FROM rodis_wh.staging_birth_child_condition_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_birth_child_condition
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_birth_child_condition = k.entity_key
FROM rodis_wh.staging_birth_child_condition_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_birth_child_condition AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_birth_child_condition_att

MERGE rodis_wh.birth_child_condition_att [target]
USING rodis_wh.staging_birth_child_condition_att [source]
	ON target.id_birth_child_condition = source.id_birth_child_condition
WHEN MATCHED
	THEN
		UPDATE
		SET cd_birth_child_condition = source.cd_birth_child_condition
			,ms_apgar5 = source.ms_apgar5
			,ms_apgar10 = source.ms_apgar10
			,fl_anencephaly = source.fl_anencephaly
			,fl_breech = source.fl_breech
			,fl_chromosome_anomaly = source.fl_chromosome_anomaly
			,fl_diaphragmic_hernia = source.fl_diaphragmic_hernia
			,fl_downs_syndrome = source.fl_downs_syndrome
			,fl_heart_malformations = source.fl_heart_malformations
			,fl_orofacial_cleft = source.fl_orofacial_cleft
			,fl_spinabifida = source.fl_spinabifida
			,fl_small_for_gestational_age = source.fl_small_for_gestational_age
			,fl_omphalocele = source.fl_omphalocele
			,fl_meconium_mod_to_heavy = source.fl_meconium_mod_to_heavy
WHEN NOT MATCHED
	THEN
		INSERT (
			id_birth_child_condition
			,cd_birth_child_condition
			,ms_apgar5
			,ms_apgar10
			,fl_anencephaly
			,fl_breech
			,fl_chromosome_anomaly
			,fl_diaphragmic_hernia
			,fl_downs_syndrome
			,fl_heart_malformations
			,fl_orofacial_cleft
			,fl_spinabifida
			,fl_small_for_gestational_age
			,fl_omphalocele
			,fl_meconium_mod_to_heavy
			)
		VALUES (
			source.id_birth_child_condition
			,source.cd_birth_child_condition
			,source.ms_apgar5
			,source.ms_apgar10
			,source.fl_anencephaly
			,source.fl_breech
			,source.fl_chromosome_anomaly
			,source.fl_diaphragmic_hernia
			,source.fl_downs_syndrome
			,source.fl_heart_malformations
			,source.fl_orofacial_cleft
			,source.fl_spinabifida
			,source.fl_small_for_gestational_age
			,source.fl_omphalocele
			,source.fl_meconium_mod_to_heavy
			);

UPDATE STATISTICS rodis_wh.birth_child_condition_att

UPDATE r
SET id_birth_child_condition = k.entity_key
FROM rodis_wh.birth_administration_att r
INNER JOIN rodis_wh.wh_entity_key k ON k.wh_column_id = @column_id AND k.source_key = '-1'
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_child_condition_att p
		WHERE p.id_birth_child_condition = r.id_birth_child_condition
		)

DELETE FROM a
FROM rodis_wh.birth_child_condition_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_birth_child_condition_att s
		WHERE s.id_birth_child_condition = a.id_birth_child_condition
		)

UPDATE STATISTICS rodis_wh.birth_child_condition_att
