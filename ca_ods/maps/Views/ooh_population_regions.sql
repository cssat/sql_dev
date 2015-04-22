





CREATE VIEW [maps].[ooh_population_regions]

AS

SELECT
	cp.measurement_year [date]
	,cp.age_grouping_cd [age_group]
	,cp.cd_race [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
GROUP BY cp.measurement_year, cp.age_grouping_cd, cp.cd_race, cr.region_6_cd

UNION ALL
-- all ages
SELECT
	cp.measurement_year [date]
	,0 [age_group]
	,cp.cd_race [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
GROUP BY cp.measurement_year, cp.cd_race, cr.region_6_cd

UNION ALL
-- all races
SELECT
	cp.measurement_year [date]
	,cp.age_grouping_cd [age_group]
	,0 [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
WHERE cp.cd_race < 9
GROUP BY cp.measurement_year, cp.age_grouping_cd, cr.region_6_cd

UNION ALL
-- all ages and races
SELECT
	cp.measurement_year [date]
	,0 [age_group]
	,0 [ethnicity_cd]
	,cr.region_6_cd [geog]
	,sum(cp.pop_cnt) [datacol]
FROM public_data.census_population cp
LEFT JOIN dbo.ref_lookup_county_region cr ON cp.county_cd = cr.county_cd
WHERE cp.cd_race < 9
GROUP BY cp.measurement_year, cr.region_6_cd









