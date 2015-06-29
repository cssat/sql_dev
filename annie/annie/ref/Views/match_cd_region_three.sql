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
