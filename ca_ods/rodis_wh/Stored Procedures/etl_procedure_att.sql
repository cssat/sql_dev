CREATE PROCEDURE [rodis_wh].[etl_procedure_att]
AS
IF OBJECT_ID('rodis_wh.staging_procedure_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_procedure_att

CREATE TABLE rodis_wh.staging_procedure_att(
	id_procedure INT NULL
	,cd_procedure VARCHAR(50) NULL
	,tx_procedure VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_procedure_att_id_procedure ON rodis_wh.staging_procedure_att (
	id_procedure
	)

CREATE NONCLUSTERED INDEX idx_staging_procedure_att_cd_procedure ON rodis_wh.staging_procedure_att (
	cd_procedure
	)
INSERT rodis_wh.staging_procedure_att (
	cd_procedure
	,tx_procedure
	)
SELECT DISTINCT CONVERT(VARCHAR(50), cd_procedure) [cd_procedure]
	,CONVERT(VARCHAR(50), cd_procedure) + ' - Undefined' [tx_procedure]
FROM (
	SELECT procedure_order
		,cd_procedure
	FROM (
		SELECT r_proc1
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

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), cd_procedure) [cd_procedure]
	,CONVERT(VARCHAR(50), cd_procedure) + ' - Undefined' [tx_procedure]
FROM (
	SELECT procedure_order
		,cd_procedure
	FROM (
		SELECT cbproc1
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

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), cd_procedure) [cd_procedure]
	,CONVERT(VARCHAR(50), cd_procedure) + ' - Undefined' [tx_procedure]
FROM (
	SELECT procedure_order
		,cd_procedure
	FROM (
		SELECT cmproc1
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

UNION

SELECT CONVERT(VARCHAR(50), '-1') [cd_procedure]
	,CONVERT(VARCHAR(50), 'Unspecified') [tx_procedure]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_procedure_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'procedure'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_procedure) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_procedure [source_key]
FROM rodis_wh.staging_procedure_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_procedure
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_procedure = k.entity_key
FROM rodis_wh.staging_procedure_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_procedure AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_procedure_att

MERGE rodis_wh.procedure_att [target]
USING rodis_wh.staging_procedure_att [source]
	ON target.id_procedure = source.id_procedure
WHEN MATCHED
	THEN
		UPDATE
		SET tx_procedure = source.tx_procedure

WHEN NOT MATCHED
	THEN
		INSERT (
			id_procedure
			,cd_procedure
			,tx_procedure
			)
		VALUES (
			source.id_procedure
			,source.cd_procedure
			,source.tx_procedure
			);

UPDATE STATISTICS rodis_wh.procedure_att

UPDATE r
SET id_procedure = - 1
FROM rodis_wh.procedure_m2m_fat r
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_procedure_att p
		WHERE p.id_procedure = r.id_procedure
		)

DELETE FROM a
FROM rodis_wh.procedure_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_procedure_att s
		WHERE s.id_procedure = a.id_procedure
		)

UPDATE STATISTICS rodis_wh.procedure_att