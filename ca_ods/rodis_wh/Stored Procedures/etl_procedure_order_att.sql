CREATE PROCEDURE [rodis_wh].[etl_procedure_order_att]
AS
IF OBJECT_ID('rodis_wh.staging_procedure_order_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_procedure_order_att

CREATE TABLE rodis_wh.staging_procedure_order_att(
	id_procedure_order INT NULL
	,cd_procedure_order VARCHAR(50) NULL
	,procedure_order VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_procedure_order_att_id_procedure_order ON rodis_wh.staging_procedure_order_att (
	id_procedure_order
	)

CREATE NONCLUSTERED INDEX idx_staging_procedure_order_att_cd_procedure_order ON rodis_wh.staging_procedure_order_att (
	cd_procedure_order
	)

DECLARE @order TINYINT = 1
DECLARE @orders TABLE(order_num TINYINT)

WHILE @order < 26
BEGIN
	INSERT @orders (order_num)
	VALUES (@order)

	SET @order = @order + 1
END

INSERT rodis_wh.staging_procedure_order_att (
	cd_procedure_order
	,procedure_order
	)
SELECT CONVERT(VARCHAR(50), order_num) [cd_procedure_order]
	,order_num [procedure_order]
FROM @orders

UNION ALL

SELECT '-1' [cd_procedure_order]
	,99 [procedure_order]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_procedure_order_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'procedure_order'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_procedure_order) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_procedure_order [source_key]
FROM rodis_wh.staging_procedure_order_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_procedure_order
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_procedure_order = k.entity_key
FROM rodis_wh.staging_procedure_order_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_procedure_order AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_procedure_order_att

MERGE rodis_wh.procedure_order_att [target]
USING rodis_wh.staging_procedure_order_att [source]
	ON target.id_procedure_order = source.id_procedure_order
WHEN MATCHED
	THEN
		UPDATE
		SET procedure_order = source.procedure_order

WHEN NOT MATCHED
	THEN
		INSERT (
			id_procedure_order
			,cd_procedure_order
			,procedure_order
			)
		VALUES (
			source.id_procedure_order
			,source.cd_procedure_order
			,source.procedure_order
			);

UPDATE STATISTICS rodis_wh.procedure_order_att

UPDATE r
SET id_procedure_order = - 1
FROM rodis_wh.procedure_m2m_fat r
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_procedure_order_att p
		WHERE p.id_procedure_order = r.id_procedure_order
		)

DELETE FROM a
FROM rodis_wh.procedure_order_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_procedure_order_att s
		WHERE s.id_procedure_order = a.id_procedure_order
		)

UPDATE STATISTICS rodis_wh.procedure_order_att
