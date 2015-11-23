CREATE VIEW [ref].[match_cd_placement_setting]
AS
SELECT cd_placement_setting
	,cd_placement_setting [placement_setting_match_code]
FROM ref.lookup_placement_setting
WHERE cd_placement_setting != 0

UNION ALL

SELECT 0 [cd_placement_setting]
	,cd_placement_setting [placement_setting_match_code]
FROM ref.lookup_placement_setting
WHERE cd_placement_setting != 0
 