CREATE PROCEDURE [rodis_wh].[load_cause_of_death_order_dim]
AS
TRUNCATE TABLE rodis_wh.cause_of_death_order_dim

INSERT rodis_wh.cause_of_death_order_dim (
	id_cause_of_death_order
	,cd_cause_of_death_order
	,cause_of_death_order
	)
SELECT id_cause_of_death_order
	,cd_cause_of_death_order
	,cause_of_death_order
FROM rodis_wh.cause_of_death_order_att d

UPDATE STATISTICS rodis_wh.cause_of_death_order_dim
