CREATE PROCEDURE [ref].[import_match_census_population_household]
AS
TRUNCATE TABLE ref.match_census_population_household

INSERT ref.match_census_population_household (
	measurement_year
	,age_sib_group_cd
	,cd_race_census
	,cd_county
	,population_count
	)
SELECT measurement_year
	,cd_sib_age_grp
	,cd_race
	,county_cd
	,pop_cnt
FROM ca_ods.public_data.census_population_household

UNION ALL

SELECT measurement_year
	,0 [cd_sib_age_grp]
	,cd_race
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
FROM ca_ods.public_data.census_population_household
GROUP BY measurement_year
	,cd_race
	,county_cd

UNION ALL

SELECT measurement_year
	,cd_sib_age_grp
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
FROM ca_ods.public_data.census_population_household
WHERE cd_race <= 8
GROUP BY measurement_year
	,cd_sib_age_grp
	,county_cd

UNION ALL

SELECT measurement_year
	,cd_sib_age_grp
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
FROM ca_ods.public_data.census_population_household
GROUP BY measurement_year
	,cd_sib_age_grp
	,cd_race

UNION ALL

SELECT measurement_year
	,0 [cd_sib_age_grp]
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
FROM ca_ods.public_data.census_population_household
WHERE cd_race <= 8
GROUP BY measurement_year
	,county_cd

UNION ALL

SELECT measurement_year
	,0 [cd_sib_age_grp]
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
FROM ca_ods.public_data.census_population_household
GROUP BY measurement_year
	,cd_race

UNION ALL

SELECT measurement_year
	,cd_sib_age_grp
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
FROM ca_ods.public_data.census_population_household
WHERE cd_race <= 8
GROUP BY measurement_year
	,cd_sib_age_grp

UNION ALL

SELECT measurement_year
	,0 [cd_sib_age_grp]
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
FROM ca_ods.public_data.census_population_household
WHERE cd_race <= 8
GROUP BY measurement_year
GO
