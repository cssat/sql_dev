CREATE PROCEDURE [rodis_wh].[etl_diagnosis_m2m_fat]
AS
IF OBJECT_ID('rodis_wh.staging_diagnosis_m2m_fat') IS NOT NULL
	DROP TABLE rodis_wh.staging_diagnosis_m2m_fat

CREATE TABLE rodis_wh.staging_diagnosis_m2m_fat(
	id_diagnosis_m2m INT NULL
	,cd_diagnosis_m2m VARCHAR(50) NULL
	,id_diagnosis INT NULL
	,cd_diagnosis VARCHAR(50) NULL
	,id_diagnosis_order INT NULL
	,cd_diagnosis_order VARCHAR(50) NULL
	,id_hospital_admission INT NULL
	,cd_hospital_admission VARCHAR(50) NULL
)

INSERT rodis_wh.staging_diagnosis_m2m_fat (
	cd_diagnosis_m2m
	,cd_diagnosis
	,cd_diagnosis_order
	,cd_hospital_admission
	)
SELECT CONVERT(VARCHAR(50), bc_uni) + '-' + CONVERT(VARCHAR(10), r_admnum) + '-' + cd_diagnosis + '-' + REPLACE(diagnosis_order, 'r_diag', '') [cd_diagnosis_m2m]
	,cd_diagnosis
	,REPLACE(diagnosis_order, 'r_diag', '') [cd_diagnosis_order]
	,CONVERT(VARCHAR(50), bc_uni) + '-' + CONVERT(VARCHAR(10), r_admnum) [cd_hospital_admission]
FROM (
	SELECT bc_uni
		,r_admnum
		,diagnosis_order
		,cd_diagnosis
	FROM (
		SELECT bc_uni
			,r_admnum
			,r_diag1
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

UNION ALL

SELECT CONVERT(VARCHAR(50), bc_uni) + 'C-' + cd_diagnosis + '-' + REPLACE(diagnosis_order, 'cbdiag', '') [cd_diagnosis_m2m]
	,cd_diagnosis
	,REPLACE(diagnosis_order, 'cbdiag', '') [cd_diagnosis_order]
	,CONVERT(VARCHAR(50), bc_uni) + 'C' [cd_hospital_admission]
FROM (
	SELECT bc_uni
		,diagnosis_order
		,cd_diagnosis
	FROM (
		SELECT bc_uni
			,cbdiag1
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

UNION ALL

SELECT CONVERT(VARCHAR(50), bc_uni) + 'M-' + cd_diagnosis + '-' + REPLACE(diagnosis_order, 'cmdiag', '') [cd_diagnosis_m2m]
	,cd_diagnosis
	,REPLACE(diagnosis_order, 'cmdiag', '') [cd_diagnosis_order]
	,CONVERT(VARCHAR(50), bc_uni) + 'M' [cd_hospital_admission]
FROM (
	SELECT bc_uni
		,diagnosis_order
		,cd_diagnosis
	FROM (
		SELECT bc_uni
			,cmdiag1
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
ORDER BY 4
	,3

UPDATE STATISTICS rodis_wh.staging_diagnosis_m2m_fat

CREATE NONCLUSTERED INDEX idx_staging_diagnosis_m2m_fat_id_diagnosis_order_m2m ON rodis_wh.staging_diagnosis_m2m_fat (
	id_diagnosis_m2m
	)

CREATE NONCLUSTERED INDEX idx_staging_diagnosis_m2m_fat_cd_diagnosis_order_m2m ON rodis_wh.staging_diagnosis_m2m_fat (
	cd_diagnosis_m2m
	)

CREATE NONCLUSTERED INDEX idx_staging_diagnosis_m2m_fat_cd_diagnosis ON rodis_wh.staging_diagnosis_m2m_fat (
	cd_diagnosis
	)

CREATE NONCLUSTERED INDEX idx_staging_diagnosis_m2m_fat_cd_diagnosis_order ON rodis_wh.staging_diagnosis_m2m_fat (
	cd_diagnosis_order
	)

CREATE NONCLUSTERED INDEX idx_staging_diagnosis_m2m_fat_cd_hospital_admission ON rodis_wh.staging_diagnosis_m2m_fat (
	cd_hospital_admission
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'diagnosis_m2m'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_diagnosis_m2m) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_diagnosis_m2m [source_key]
FROM rodis_wh.staging_diagnosis_m2m_fat a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_diagnosis_m2m
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_diagnosis_m2m = k.entity_key
FROM rodis_wh.staging_diagnosis_m2m_fat a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_diagnosis_m2m AND k.wh_column_id = @column_id

UPDATE a
SET id_diagnosis = k.id_diagnosis
FROM rodis_wh.staging_diagnosis_m2m_fat a
LEFT JOIN rodis_wh.staging_diagnosis_att k ON k.cd_diagnosis = ISNULL(a.cd_diagnosis, '-1')

UPDATE a
SET id_diagnosis_order = k.id_diagnosis_order
FROM rodis_wh.staging_diagnosis_m2m_fat a
LEFT JOIN rodis_wh.staging_diagnosis_order_att k ON k.cd_diagnosis_order = ISNULL(a.cd_diagnosis_order, '-1')

UPDATE a
SET id_hospital_admission = k.id_hospital_admission
FROM rodis_wh.staging_diagnosis_m2m_fat a
LEFT JOIN rodis_wh.staging_hospital_admission_att k ON k.cd_hospital_admission = ISNULL(a.cd_hospital_admission, '-1')

MERGE rodis_wh.diagnosis_m2m_fat [target]
USING rodis_wh.staging_diagnosis_m2m_fat [source]
	ON target.id_diagnosis_m2m = source.id_diagnosis_m2m
WHEN MATCHED
	THEN
		UPDATE
		SET id_diagnosis = source.id_diagnosis
		,id_diagnosis_order = source.id_diagnosis_order
		,id_hospital_admission = source.id_hospital_admission
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_diagnosis_m2m
			,cd_diagnosis_m2m
			,id_diagnosis
			,id_diagnosis_order
			,id_hospital_admission
			)
		VALUES (
			source.id_diagnosis_m2m
			,source.cd_diagnosis_m2m
			,source.id_diagnosis
			,source.id_diagnosis_order
			,source.id_hospital_admission
			)
WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE;

UPDATE STATISTICS rodis_wh.diagnosis_m2m_fat
