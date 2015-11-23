CREATE PROCEDURE [ref].[import_match_census_population]
AS
TRUNCATE TABLE ref.match_census_population

INSERT ref.match_census_population (
	measurement_year
	,age_grouping_cd
	,pk_gender
	,cd_race_census
	,cd_county
	,population_count
	,perCapita_threshold
	)
SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,cd_race
	,county_cd
	,pop_cnt
	,pop_cnt * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,cd_race
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,pk_gndr
	,cd_race
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,cd_race
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,age_grouping_cd
	,cd_race
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd
	,pk_gndr
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,age_grouping_cd
	,pk_gndr
	,cd_race

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,cd_race
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,cd_race
	,county_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,pk_gndr
	,county_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,pk_gndr
	,cd_race

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,age_grouping_cd
	,cd_race

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd
	,pk_gndr

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,county_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,cd_race

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,pk_gndr

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
GO
