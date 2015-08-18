CREATE PROCEDURE [rodis_wh].[etl_diagnosis_att]
AS
IF OBJECT_ID('rodis_wh.staging_diagnosis_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_diagnosis_att

CREATE TABLE rodis_wh.staging_diagnosis_att(
	id_diagnosis INT NULL
	,cd_diagnosis VARCHAR(50) NULL
	,tx_diagnosis VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_diagnosis_att_id_diagnosis ON rodis_wh.staging_diagnosis_att (
	id_diagnosis
	)

CREATE NONCLUSTERED INDEX idx_staging_diagnosis_att_cd_diagnosis ON rodis_wh.staging_diagnosis_att (
	cd_diagnosis
	)
INSERT rodis_wh.staging_diagnosis_att (
	cd_diagnosis
	,tx_diagnosis
	)
SELECT DISTINCT cd_diagnosis
	,cd_diagnosis + ' - Undefined' [tx_diagnosis]
FROM (
	SELECT diagnosis_order
		,cd_diagnosis
	FROM (
		SELECT r_diag1
			,r_diag2
			,r_diag3
			,r_diag4
			,r_diag5
			,r_diag6
			,r_diag7
			,r_diag8
			,r_diag9
			,r_diag10
			,r_diag11
			,r_diag12
			,r_diag13
			,r_diag14
			,r_diag15
			,r_diag16
			,r_diag17
			,r_diag18
			,r_diag19
			,r_diag20
			,r_diag21
			,r_diag22
			,r_diag23
			,r_diag24
			,r_diag25
		FROM rodis.bab_read
		) i
	UNPIVOT(cd_diagnosis FOR diagnosis_order IN (
				r_diag1
				,r_diag2
				,r_diag3
				,r_diag4
				,r_diag5
				,r_diag6
				,r_diag7
				,r_diag8
				,r_diag9
				,r_diag10
				,r_diag11
				,r_diag12
				,r_diag13
				,r_diag14
				,r_diag15
				,r_diag16
				,r_diag17
				,r_diag18
				,r_diag19
				,r_diag20
				,r_diag21
				,r_diag22
				,r_diag23
				,r_diag24
				,r_diag25
				)
		) unpvt
	) i

UNION

SELECT DISTINCT cd_diagnosis
	,cd_diagnosis + ' - Undefined' [tx_diagnosis]
FROM (
	SELECT diagnosis_order
		,cd_diagnosis
	FROM (
		SELECT cbdiag1
			,cbdiag2
			,cbdiag3
			,cbdiag4
			,cbdiag5
			,cbdiag6
			,cbdiag7
			,cbdiag8
			,cbdiag9
			,cbdiag10
			,cbdiag11
			,cbdiag12
			,cbdiag13
			,cbdiag14
			,cbdiag15
			,cbdiag16
			,cbdiag17
			,cbdiag18
			,cbdiag19
			,cbdiag20
			,cbdiag21
			,cbdiag22
			,cbdiag23
			,cbdiag24
			,cbdiag25
		FROM rodis.berd
		) i
	UNPIVOT(cd_diagnosis FOR diagnosis_order IN (
				cbdiag1
				,cbdiag2
				,cbdiag3
				,cbdiag4
				,cbdiag5
				,cbdiag6
				,cbdiag7
				,cbdiag8
				,cbdiag9
				,cbdiag10
				,cbdiag11
				,cbdiag12
				,cbdiag13
				,cbdiag14
				,cbdiag15
				,cbdiag16
				,cbdiag17
				,cbdiag18
				,cbdiag19
				,cbdiag20
				,cbdiag21
				,cbdiag22
				,cbdiag23
				,cbdiag24
				,cbdiag25
				)
		) unpvt
	) i

UNION

SELECT DISTINCT cd_diagnosis
	,cd_diagnosis + ' - Undefined' [tx_diagnosis]
FROM (
	SELECT diagnosis_order
		,cd_diagnosis
	FROM (
		SELECT cmdiag1
			,cmdiag2
			,cmdiag3
			,cmdiag4
			,cmdiag5
			,cmdiag6
			,cmdiag7
			,cmdiag8
			,cmdiag9
			,cmdiag10
			,cmdiag11
			,cmdiag12
			,cmdiag13
			,cmdiag14
			,cmdiag15
			,cmdiag16
			,cmdiag17
			,cmdiag18
			,cmdiag19
			,cmdiag20
			,cmdiag21
			,cmdiag22
			,cmdiag23
			,cmdiag24
			,cmdiag25
		FROM rodis.berd
		) i
	UNPIVOT(cd_diagnosis FOR diagnosis_order IN (
				cmdiag1
				,cmdiag2
				,cmdiag3
				,cmdiag4
				,cmdiag5
				,cmdiag6
				,cmdiag7
				,cmdiag8
				,cmdiag9
				,cmdiag10
				,cmdiag11
				,cmdiag12
				,cmdiag13
				,cmdiag14
				,cmdiag15
				,cmdiag16
				,cmdiag17
				,cmdiag18
				,cmdiag19
				,cmdiag20
				,cmdiag21
				,cmdiag22
				,cmdiag23
				,cmdiag24
				,cmdiag25
				)
		) unpvt
	) i

UNION

SELECT CONVERT(VARCHAR(50), '-1') [cd_diagnosis]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_diagnosis]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_diagnosis_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'diagnosis'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_diagnosis) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_diagnosis [source_key]
FROM rodis_wh.staging_diagnosis_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_diagnosis
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_diagnosis = k.entity_key
FROM rodis_wh.staging_diagnosis_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_diagnosis AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_diagnosis_att

MERGE rodis_wh.diagnosis_att [target]
USING rodis_wh.staging_diagnosis_att [source]
	ON target.id_diagnosis = source.id_diagnosis
WHEN MATCHED
	THEN
		UPDATE
		SET tx_diagnosis = source.tx_diagnosis

WHEN NOT MATCHED
	THEN
		INSERT (
			id_diagnosis
			,cd_diagnosis
			,tx_diagnosis
			)
		VALUES (
			source.id_diagnosis
			,source.cd_diagnosis
			,source.tx_diagnosis
			);

UPDATE STATISTICS rodis_wh.diagnosis_att

UPDATE r
SET id_diagnosis = - 1
FROM rodis_wh.diagnosis_m2m_fat r
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_diagnosis_att p
		WHERE p.id_diagnosis = r.id_diagnosis
		)

DELETE FROM a
FROM rodis_wh.diagnosis_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_diagnosis_att s
		WHERE s.id_diagnosis = a.id_diagnosis
		)

UPDATE STATISTICS rodis_wh.diagnosis_att
