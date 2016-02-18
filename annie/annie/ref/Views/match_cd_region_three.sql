--INSERT prtl.param_match_geog(geog_param_key, cd_county, cd_region_three, cd_region_six)
--SELECT 
--	g.geog_param_key
--	,c.county_match_code
--FROM prtl.param_sets_geog g
--inner join ref.match_cd_county c on c.cd_county = g.cd_county
CREATE VIEW [ref].[match_cd_region_three]
AS
SELECT cd_region_three
	,cd_region_three [region_three_match_code]
FROM ref.lookup_region_three
WHERE cd_region_three != 0

UNION ALL

SELECT 0
	,cd_region_three
FROM ref.lookup_region_three
WHERE cd_region_three != 0
