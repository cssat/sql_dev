--INSERT prtl.param_match_geog(geog_param_key, cd_county, cd_region_three, cd_region_six)
--SELECT 
--	g.geog_param_key
--	,c.county_match_code
--	,rt.region_three_match_code
--FROM prtl.param_sets_geog g
--inner join ref.match_cd_county c on c.cd_county = g.cd_county
--inner join ref.match_cd_region_three rt on rt.cd_region_three = g.cd_region_three
CREATE VIEW [ref].[match_cd_region_six]
AS
SELECT cd_region_six
	,cd_region_six [region_six_match_code]
FROM ref.lookup_region_six
WHERE cd_region_six != 0

UNION ALL

SELECT 0
	,cd_region_six
FROM ref.lookup_region_six
WHERE cd_region_six != 0
