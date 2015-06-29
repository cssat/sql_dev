CREATE PROCEDURE [setup].[populate_param_match_geog]
AS
INSERT prtl.param_match_geog (
	geog_param_key
	,cd_county
	,cd_region_three
	,cd_region_six
	)
SELECT g.geog_param_key
	,c.county_match_code
	,rt.region_three_match_code
	,rs.region_six_match_code
FROM prtl.param_sets_geog g
INNER JOIN ref.match_cd_county c ON c.cd_county = g.cd_county
INNER JOIN ref.match_cd_region_three rt ON rt.cd_region_three = g.cd_region_three
INNER JOIN ref.match_cd_region_six rs ON rs.cd_region_six = g.cd_region_six
