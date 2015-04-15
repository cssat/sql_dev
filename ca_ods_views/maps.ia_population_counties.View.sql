SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [maps].[ia_population_counties]

AS

SELECT
	measurement_year [date]
	,cd_sib_age_grp
	,cd_race [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population_household
GROUP BY measurement_year, cd_sib_age_grp, cd_race, county_cd

UNION ALL
-- all ages
SELECT
	measurement_year [date]
	,0 [cd_sib_age_grp]
	,cd_race [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population_household
GROUP BY measurement_year, cd_race, county_cd

UNION ALL
-- all races
SELECT
	measurement_year [date]
	,cd_sib_age_grp
	,0 [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population_household
WHERE cd_race < 9
GROUP BY measurement_year, cd_sib_age_grp, county_cd

UNION ALL
-- all ages and races
SELECT
	measurement_year [date]
	,0 [cd_sib_age_grp]
	,0 [ethnicity_cd]
	,county_cd [geog]
	,sum(pop_cnt) [datacol]
FROM public_data.census_population_household
WHERE cd_race < 9
GROUP BY measurement_year, county_cd









GO


