SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [maps].[ooh_population_counties]

AS

SELECT TOP 100 PERCENT *
FROM (				 
	SELECT
	 measurement_year [date]
	, age_grouping_cd [age_group]
	, county_cd [geog]
	, sum(pop_cnt) [datacol]
	FROM public_data.census_population
	GROUP BY measurement_year, age_grouping_cd, cd_race, county_cd

	UNION ALL
	-- all age groups
	SELECT
	  measurement_year [date]
	, 0 [age_group]
	, county_cd [geog]
	, sum(pop_cnt) [datacol]
	FROM public_data.census_population
	GROUP BY measurement_year, cd_race, county_cd) X
ORDER BY date desc, geog, age_group;






GO


