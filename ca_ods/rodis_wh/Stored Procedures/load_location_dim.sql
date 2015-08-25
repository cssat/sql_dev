CREATE PROCEDURE [rodis_wh].[load_location_dim]
AS
TRUNCATE TABLE rodis_wh.location_dim

INSERT rodis_wh.location_dim (
	id_city
	,cd_city
	,tx_city
	,id_county
	,cd_county
	,tx_county
	,id_state
	,cd_state
	,tx_state
	,id_country
	,cd_country
	,tx_country
	)
SELECT ct.id_city
	,ct.cd_city
	,ct.tx_city
	,ct.id_county
	,cn.cd_county
	,cn.tx_county
	,cn.id_state
	,s.cd_state
	,s.tx_state
	,s.id_country
	,cy.cd_country
	,cy.tx_country
FROM rodis_wh.city_att ct
LEFT JOIN rodis_wh.county_att cn ON cn.id_county = ct.id_county
LEFT JOIN rodis_wh.state_att s ON s.id_state = cn.id_state
LEFT JOIN rodis_wh.country_att cy ON cy.id_country = s.id_country

UPDATE STATISTICS rodis_wh.location_dim
