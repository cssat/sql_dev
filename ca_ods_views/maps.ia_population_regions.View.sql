SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [maps].[ia_population_regions]

AS

SELECT
	cp.measurement_year [date]
	,cp.cd_sib_age_grp
	,cp.cd_race [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population_household cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
GROUP BY cp.measurement_year, cp.cd_sib_age_grp, cp.cd_race, cr.region_6_cd

UNION ALL
-- all ages
SELECT
	cp.measurement_year [date]
	,0 [cd_sib_age_grp]
	,cp.cd_race [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population_household cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
GROUP BY cp.measurement_year, cp.cd_race, cr.region_6_cd

UNION ALL
-- all races
SELECT
	cp.measurement_year [date]
	,cp.cd_sib_age_grp
	,0 [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population_household cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
WHERE cp.cd_race < 9
GROUP BY cp.measurement_year, cp.cd_sib_age_grp, cr.region_6_cd

UNION ALL
-- all ages and races
SELECT
	cp.measurement_year [date]
	,0 [cd_sib_age_grp]
	,0 [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population_household cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
WHERE cp.cd_race < 9
GROUP BY cp.measurement_year, cr.region_6_cd









GO


