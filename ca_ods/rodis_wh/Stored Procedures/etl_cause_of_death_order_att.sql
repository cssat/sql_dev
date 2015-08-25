CREATE PROCEDURE [rodis_wh].[etl_cause_of_death_order_att]
AS
IF OBJECT_ID('rodis_wh.staging_cause_of_death_order_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_cause_of_death_order_att

CREATE TABLE rodis_wh.staging_cause_of_death_order_att(
	id_cause_of_death_order INT NULL
	,cd_cause_of_death_order VARCHAR(50) NULL
	,cause_of_death_order TINYINT NULL
)

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_order_att_id_cause_of_death_order ON rodis_wh.staging_cause_of_death_order_att (
	id_cause_of_death_order
	)

CREATE NONCLUSTERED INDEX idx_staging_cause_of_death_order_att_cd_cause_of_death_order ON rodis_wh.staging_cause_of_death_order_att (
	cd_cause_of_death_order
	)

DECLARE @order TINYINT = 0
DECLARE @orders TABLE(order_num TINYINT)

WHILE @order < 11
BEGIN
	INSERT @orders (order_num)
	VALUES (@order)

	SET @order = @order + 1
END

INSERT rodis_wh.staging_cause_of_death_order_att (
	cd_cause_of_death_order
	,cause_of_death_order
	)
SELECT CONVERT(VARCHAR(50), order_num) [cd_cause_of_death_order]
	,order_num [cause_of_death_order]
FROM @orders

UNION ALL

SELECT '-1' [cd_cause_of_death_order]
	,99 [cause_of_death_order]
ORDER BY 1

UPDATE STATISTICS rodis_wh.staging_cause_of_death_order_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'cause_of_death_order'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_cause_of_death_order) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_cause_of_death_order [source_key]
FROM rodis_wh.staging_cause_of_death_order_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_cause_of_death_order
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_cause_of_death_order = k.entity_key
FROM rodis_wh.staging_cause_of_death_order_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_cause_of_death_order AND k.wh_column_id = @column_id

UPDATE STATISTICS rodis_wh.staging_cause_of_death_order_att

MERGE rodis_wh.cause_of_death_order_att [target]
USING rodis_wh.staging_cause_of_death_order_att [source]
	ON target.id_cause_of_death_order = source.id_cause_of_death_order
WHEN MATCHED
	THEN
		UPDATE
		SET cause_of_death_order = source.cause_of_death_order

WHEN NOT MATCHED
	THEN
		INSERT (
			id_cause_of_death_order
			,cd_cause_of_death_order
			,cause_of_death_order
			)
		VALUES (
			source.id_cause_of_death_order
			,source.cd_cause_of_death_order
			,source.cause_of_death_order
			);

UPDATE STATISTICS rodis_wh.cause_of_death_order_att

UPDATE r
SET id_cause_of_death_order = - 1
FROM rodis_wh.cause_of_death_m2m_fat r
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_cause_of_death_order_att p
		WHERE p.id_cause_of_death_order = r.id_cause_of_death_order
		)

DELETE FROM a
FROM rodis_wh.cause_of_death_order_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_cause_of_death_order_att s
		WHERE s.id_cause_of_death_order = a.id_cause_of_death_order
		)

UPDATE STATISTICS rodis_wh.cause_of_death_order_att
