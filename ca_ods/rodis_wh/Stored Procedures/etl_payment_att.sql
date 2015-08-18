CREATE PROCEDURE [rodis_wh].[etl_payment_att]
AS
IF OBJECT_ID('rodis_wh.staging_payment_att') IS NOT NULL
	DROP TABLE rodis_wh.staging_payment_att

CREATE TABLE rodis_wh.staging_payment_att(
	id_payment INT NULL
	,cd_payment VARCHAR(50) NULL
	,tx_payment VARCHAR(50) NULL
)

CREATE NONCLUSTERED INDEX idx_staging_payment_att_id_payment ON rodis_wh.staging_payment_att (
	id_payment
	)

CREATE NONCLUSTERED INDEX idx_staging_payment_att_cd_payment ON rodis_wh.staging_payment_att (
	cd_payment
	)

INSERT rodis_wh.staging_payment_att (
	cd_payment
	,tx_payment
	)
SELECT DISTINCT CONVERT(VARCHAR(50), b.r_payid1) [cd_payment]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.r_payid1) + ' - Undefined') [tx_payment]
FROM rodis.bab_read b
LEFT JOIN rodis.ref_payid1 r ON r.Code = b.r_payid1
WHERE b.r_payid1 IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.r_payid2) [cd_payment]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.r_payid2) + ' - Undefined') [tx_payment]
FROM rodis.bab_read b
LEFT JOIN rodis.ref_payid1 r ON r.Code = b.r_payid2
WHERE b.r_payid2 IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cbpayid1) [cd_payment]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.cbpayid1) + ' - Undefined') [tx_payment]
FROM rodis.berd b
LEFT JOIN rodis.ref_payid1 r ON r.Code = b.cbpayid1
WHERE b.cbpayid1 IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cbpayid2) [cd_payment]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.cbpayid2) + ' - Undefined') [tx_payment]
FROM rodis.berd b
LEFT JOIN rodis.ref_payid1 r ON r.Code = b.cbpayid2
WHERE b.cbpayid2 IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cmpayid1) [cd_payment]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.cmpayid1) + ' - Undefined') [tx_payment]
FROM rodis.berd b
LEFT JOIN rodis.ref_payid1 r ON r.Code = b.cmpayid1
WHERE b.cmpayid1 IS NOT NULL

UNION

SELECT DISTINCT CONVERT(VARCHAR(50), b.cmpayid2) [cd_payment]
	,ISNULL(r.Value, CONVERT(VARCHAR(50), b.cmpayid2) + ' - Undefined') [tx_payment]
FROM rodis.berd b
LEFT JOIN rodis.ref_payid1 r ON r.Code = b.cmpayid2
WHERE b.cmpayid2 IS NOT NULL

UNION

SELECT CONVERT(VARCHAR(50), Code) [cd_payment]
	,Value [tx_payment]
FROM rodis.ref_payid1

UNION

SELECT '-1' [cd_payment]
	,'Unspecified' [tx_payment]
ORDER BY 1
	,2

UPDATE STATISTICS rodis_wh.staging_payment_att

DECLARE @table_id INT = (
		SELECT wh_table_id
		FROM rodis_wh.wh_table
		WHERE wh_table_name = 'payment'
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
SELECT ROW_NUMBER() OVER(ORDER BY cd_payment) + @max_wh_key [entity_key]
	,@column_id [wh_column_id]
	,cd_payment [source_key]
FROM rodis_wh.staging_payment_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.wh_entity_key
		WHERE wh_column_id = @column_id AND source_key = a.cd_payment
		)

UPDATE STATISTICS rodis_wh.wh_entity_key

UPDATE a
SET id_payment = k.entity_key
FROM rodis_wh.staging_payment_att a
INNER JOIN rodis_wh.wh_entity_key k ON k.source_key = a.cd_payment AND k.wh_column_id = @column_id

MERGE rodis_wh.payment_att [target]
USING rodis_wh.staging_payment_att [source]
	ON target.id_payment = source.id_payment
WHEN MATCHED
	THEN
		UPDATE
		SET tx_payment = source.tx_payment
WHEN NOT MATCHED
	THEN
		INSERT (
			id_payment
			,cd_payment
			,tx_payment
			)
		VALUES (
			source.id_payment
			,source.cd_payment
			,source.tx_payment
			);

UPDATE STATISTICS rodis_wh.payment_att

UPDATE r
SET id_payment_primary = - 1
FROM rodis_wh.hospital_admission_att r
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_payment_att p
		WHERE p.id_payment = r.id_payment_primary
		)

UPDATE r
SET id_payment_secondary = - 1
FROM rodis_wh.hospital_admission_att r
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_payment_att p
		WHERE p.id_payment = r.id_payment_secondary
		)

DELETE FROM a
FROM rodis_wh.payment_att a
WHERE NOT EXISTS (
		SELECT *
		FROM rodis_wh.staging_payment_att s
		WHERE s.id_payment = a.id_payment
		)

UPDATE STATISTICS rodis_wh.payment_att
