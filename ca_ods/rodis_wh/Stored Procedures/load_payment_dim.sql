CREATE PROCEDURE [rodis_wh].[load_payment_dim]
AS
TRUNCATE TABLE rodis_wh.payment_dim

INSERT rodis_wh.payment_dim (
	id_payment
	,cd_payment
	,tx_payment
	)
SELECT id_payment
	,cd_payment
	,tx_payment
FROM rodis_wh.payment_att

UPDATE STATISTICS rodis_wh.payment_dim
