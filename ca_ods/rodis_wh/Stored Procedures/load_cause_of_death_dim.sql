CREATE PROCEDURE [rodis_wh].[load_cause_of_death_dim]
AS
TRUNCATE TABLE rodis_wh.cause_of_death_dim

INSERT rodis_wh.cause_of_death_dim (
	id_cause_of_death
	,cd_cause_of_death
	,tx_cause_of_death
	)
SELECT id_cause_of_death
	,cd_cause_of_death
	,tx_cause_of_death
FROM rodis_wh.cause_of_death_att d

UPDATE STATISTICS rodis_wh.cause_of_death_dim
