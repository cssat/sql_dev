CREATE PROCEDURE [rodis_wh].[load_birth_familial_dim]
AS
TRUNCATE TABLE rodis_wh.birth_familial_dim

INSERT rodis_wh.birth_familial_dim (
	id_birth_familial
	,cd_birth_familial
	,cd_birth_zip
	,id_race_census
	,cd_race_census
	,tx_race_census
	,id_ethnicity_census
	,cd_ethnicity_census
	,tx_ethnicity_census
	,id_tribe
	,cd_tribe
	,tx_tribe
	,id_occupation
	,cd_occupation
	,tx_occupation
	,id_city_current
	,id_city_birth
	,id_education
	)
SELECT bf.id_birth_familial
	,bf.cd_birth_familial
	,bf.cd_birth_zip
	,bf.id_race_census
	,rc.cd_race_census
	,rc.tx_race_census
	,bf.id_ethnicity_census
	,ec.cd_ethnicity_census
	,ec.tx_ethnicity_census
	,bf.id_tribe
	,t.cd_tribe
	,t.tx_tribe
	,bf.id_occupation
	,o.cd_occupation
	,o.tx_occupation
	,bf.id_city_current
	,bf.id_city_birth
	,bf.id_education
FROM rodis_wh.birth_familial_att bf
LEFT JOIN rodis_wh.race_census_att rc ON rc.id_race_census = bf.id_race_census
LEFT JOIN rodis_wh.ethnicity_census_att ec ON ec.id_ethnicity_census = bf.id_ethnicity_census
LEFT JOIN rodis_wh.tribe_att t ON t.id_tribe = bf.id_tribe
LEFT JOIN rodis_wh.occupation_att o ON o.id_occupation = bf.id_occupation

UPDATE STATISTICS rodis_wh.birth_familial_dim
