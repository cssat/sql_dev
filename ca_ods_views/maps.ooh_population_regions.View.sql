SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [maps].[ooh_population_regions]

AS

SELECT TOP 100 PERCENT *
FROM (				 
	SELECT
	  cp.measurement_year [date]
	, cp.age_grouping_cd [age_group]
	, cr.region_6_cd [geog]
	, sum(cp.pop_cnt) [datacol]
	FROM public_data.census_population cp
		LEFT JOIN dbo.ref_lookup_county_region cr
			ON cp.county_cd = cr.county_cd
	GROUP BY cp.measurement_year, cp.age_grouping_cd, cr.region_6_cd

	UNION ALL
	-- all ages
	SELECT
	  cp.measurement_year [date]
	, 0 [age_group]
	, cr.region_6_cd [geog]
	, sum(cp.pop_cnt) [datacol]
	FROM public_data.census_population cp
		LEFT JOIN dbo.ref_lookup_county_region cr
			ON cp.county_cd = cr.county_cd
	GROUP BY cp.measurement_year, cr.region_6_cd
) X
ORDER BY date desc, geog, age_group;






GO


