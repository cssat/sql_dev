SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [maps].[ooh_population_counties]

AS

SELECT
	measurement_year [date]
	,age_grouping_cd [age_group]
	,cd_race [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population
GROUP BY measurement_year, age_grouping_cd, cd_race, county_cd

UNION ALL
-- all age groups
SELECT
	measurement_year [date]
	,0 [age_group]
	,cd_race [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population
GROUP BY measurement_year, cd_race, county_cd

UNION ALL
-- all races
SELECT
	measurement_year [date]
	,age_grouping_cd [age_group]
	,0 [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population
WHERE cd_race < 9
GROUP BY measurement_year, age_grouping_cd, county_cd

UNION ALL
-- all ages and races
SELECT
	measurement_year [date]
	,0 [age_group]
	,0 [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population
WHERE cd_race < 9
GROUP BY measurement_year, county_cd







GO


