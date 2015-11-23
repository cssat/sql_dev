CREATE PROCEDURE [rodis_wh].[etl_procedure_m2m_fat]
AS
IF OBJECT_ID('rodis_wh.staging_procedure_m2m_fat') IS NOT NULL
	DROP TABLE rodis_wh.staging_procedure_m2m_fat

CREATE TABLE rodis_wh.staging_procedure_m2m_fat(
	id_procedure_m2m INT NULL
	,cd_procedure_m2m VARCHAR(50) NULL
	,id_procedure INT NULL
	,cd_procedure VARCHAR(50) NULL
	,id_procedure_order INT NULL
	,cd_procedure_order VARCHAR(50) NULL
	,id_hospital_admission INT NULL
	,cd_hospital_admission VARCHAR(50) NULL
)

INSERT rodis_wh.staging_procedure_m2m_fat (
	cd_procedure_m2m
	,cd_procedure
	,cd_procedure_order
	,cd_hospital_admission
	)
SELECT CONVERT(VARCHAR(50), bc_uni) + '-' + CONVERT(VARCHAR(10), r_admnum) + '-' + CONVERT(VARCHAR(50), cd_procedure) + '-' + REPLACE(procedure_order, 'r_proc', '') [cd_procedure_m2m]
	,CONVERT(VARCHAR(50), cd_procedure) [cd_procedure]
	,REPLACE(procedure_order, 'r_proc', '') [cd_procedure_order]
	,CONVERT(VARCHAR(50), bc_uni) + '-' + CONVERT(VARCHAR(10), r_admnum) [cd_hospital_admission]
FROM (
	SELECT bc_uni
		,r_admnum
		,procedure_order
		,cd_procedure
	FROM (
		SELECT bc_uni
			,r_admnum
			,r_proc1
			,r_proc2
			,r_proc3
			,r_proc4
			,r_proc5
			,r_proc6
			,r_proc7
			,r_proc8
			,r_proc9
			,r_proc10
			,r_proc11
			,r_proc12
			,r_proc13
			,r_proc14
			,r_proc15
			,r_proc16
			,r_proc17
			,r_proc18
			,r_proc19
			,r_proc20
			,r_proc21
			,r_proc22
			,r_proc23
			,r_proc24
			,r_proc25
		FROM rodis.bab_read
		) i
	UNPIVOT(cd_procedure FOR procedure_order IN (
				r_proc1
				,r_proc2
				,r_proc3
				,r_proc4
				,r_proc5
				,r_proc6
				,r_proc7
				,r_proc8
				,r_proc9
				,r_proc10
				,r_proc11
				,r_proc12
				,r_proc13
				,r_proc14
				,r_proc15
				,r_proc16
				,r_proc17
				,r_proc18
				,r_proc19
				,r_proc20
				,r_proc21
				,r_proc22
				,r_proc23
				,r_proc24
				,r_proc25
				)
		) unpvt
	) i

UNION ALL

SELECT CONVERT(VARCHAR(50), bc_uni) + 'C-' + CONVERT(VARCHAR(50), cd_procedure) + '-' + REPLACE(procedure_order, 'cbproc', '') [cd_procedure_m2m]
	,CONVERT(VARCHAR(50), cd_procedure) [cd_procedure]
	,REPLACE(procedure_order, 'cbproc', '') [cd_procedure_order]
	,CONVERT(VARCHAR(50), bc_uni) + 'C' [cd_hospital_admission]
FROM (
	SELECT bc_uni
		,procedure_order
		,cd_procedure
	FROM (
		SELECT bc_uni
			,cbproc1
			,cbproc2
			,cbproc3
			,cbproc4
			,cbproc5
			,cbproc6
			,cbproc7
			,cbproc8
			,cbproc9
			,cbproc10
			,cbproc11
			,cbproc12
			,cbproc13
			,cbproc14
			,cbproc15
			,cbproc16
			,cbproc17
			,cbproc18
			,cbproc19
			,cbproc20
			,cbproc21
			,cbproc22
			,cbproc23
			,cbproc24
			,cbproc25
		FROM rodis.berd
		) i
	UNPIVOT(cd_procedure FOR procedure_order IN (
				cbproc1
				,cbproc2
				,cbproc3
				,cbproc4
				,cbproc5
				,cbproc6
				,cbproc7
				,cbproc8
				,cbproc9
				,cbproc10
				,cbproc11
				,cbproc12
				,cbproc13
				,cbproc14
				,cbproc15
				,cbproc16
				,cbproc17
				,cbproc18
				,cbproc19
				,cbproc20
				,cbproc21
				,cbproc22
				,cbproc23
				,cbproc24
				,cbproc25
				)
		) unpvt
	) i

UNION ALL

SELECT CONVERT(VARCHAR(50), bc_uni) + 'M-' + CONVERT(VARCHAR(50), cd_procedure) + '-' + REPLACE(procedure_order, 'cmproc', '') [cd_procedure_m2m]
	,CONVERT(VARCHAR(50), cd_procedure) [cd_procedure]
	,REPLACE(procedure_order, 'cmproc', '') [cd_procedure_order]
	,CONVERT(VARCHAR(50), bc_uni) + 'M' [cd_hospital_admission]
FROM (
	SELECT bc_uni
		,procedure_order
		,cd_procedure
	FROM (
		SELECT bc_uni
			,cmproc1
			,cmproc2
			,cmproc3
			,cmproc4
			,cmproc5
			,cmproc6
			,cmproc7
			,cmproc8
			,cmproc9
			,cmproc10
			,cmproc11
			,cmproc12
			,cmproc13
			,cmproc14
			,cmproc15
			,cmproc16
			,cmproc17
			,cmproc18
			,cmproc19
			,cmproc20
			,cmproc21
			,cmproc22
			,cmproc23
			,cmproc24
			,cmproc25
		FROM rodis.berd
		) i
	UNPIVOT(cd_procedure FOR procedure_order IN (
				cmproc1
				,cmproc2
				,cmproc3
				,cmproc4
				,cmproc5
				,cmproc6
				,cmproc7
				,cmproc8
				,cmproc9
				,cmproc10
				,cmproc11
				,cmproc12
				,cmproc13
				,cmproc14
				,cmproc15
				,cmproc16
				,cmproc17
				,cmproc18
				,cmproc19
				,cmproc20
				,cmproc21
				,cmproc22
				,cmproc23
				,cmproc24
				,cmproc25
				)
		) unpvt
	) i
ORDER BY 4
	,3

UPDATE STATISTICS rodis_wh.staging_procedure_m2m_fat

CREATE NONCLUSTERED INDEX idx_staging_procedure_m2m_fat_id_procedure_order_m2m ON rodis_wh.staging_procedure_m2m_fat (
	id_procedure_m2m
	)

CREATE NONCLUSTERED INDEX idx_staging_procedure_m2m_fat_cd_procedure_order_m2m ON rodis_wh.staging_procedure_m2m_fat (
	cd_procedure_m2m
	)

CREATE NONCLUSTERED INDEX idx_staging_procedure_m2m_fat_cd_procedure ON rodis_wh.staging_procedure_m2m_fat (
	cd_procedure
	)

CREATE NONCLUSTERED INDEX idx_staging_procedure_m2m_fat_cd_procedure_order ON rodis_wh.staging_procedure_m2m_fat (
	cd_procedure_order
	)

CREATE NONCLUSTERED INDEX idx_staging_procedure_m2m_fat_cd_hospital_admission ON rodis_wh.staging_procedure_m2m_fat (
	cd_hospital_admission
	)

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'procedure_m2m'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_procedure_m2m) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_procedure_m2m [source_key]
FROM rodis_wh.staging_procedure_m2m_fat a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_procedure_m2m
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_procedure_m2m = k.entity_key
FROM rodis_wh.staging_procedure_m2m_fat a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_procedure_m2m AND k.wh_column_id = @column_id

UPDATE a
SET id_procedure = k.id_procedure
FROM rodis_wh.staging_procedure_m2m_fat a
LEFT JOIN rodis_wh.staging_procedure_att k ON k.cd_procedure = ISNULL(a.cd_procedure, '-1')

UPDATE a
SET id_procedure_order = k.id_procedure_order
FROM rodis_wh.staging_procedure_m2m_fat a
LEFT JOIN rodis_wh.staging_procedure_order_att k ON k.cd_procedure_order = ISNULL(a.cd_procedure_order, '-1')

UPDATE a
SET id_hospital_admission = k.id_hospital_admission
FROM rodis_wh.staging_procedure_m2m_fat a
LEFT JOIN rodis_wh.staging_hospital_admission_att k ON k.cd_hospital_admission = ISNULL(a.cd_hospital_admission, '-1')

MERGE rodis_wh.procedure_m2m_fat [target]
USING rodis_wh.staging_procedure_m2m_fat [source]
	ON target.id_procedure_m2m = source.id_procedure_m2m
WHEN MATCHED
	THEN
		UPDATE
		SET id_procedure = source.id_procedure
		,id_procedure_order = source.id_procedure_order
		,id_hospital_admission = source.id_hospital_admission
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			id_procedure_m2m
			,cd_procedure_m2m
			,id_procedure
			,id_procedure_order
			,id_hospital_admission
			)
		VALUES (
			source.id_procedure_m2m
			,source.cd_procedure_m2m
			,source.id_procedure
			,source.id_procedure_order
			,source.id_hospital_admission
			)
WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE;

UPDATE STATISTICS rodis_wh.procedure_m2m_fat
