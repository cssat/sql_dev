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
