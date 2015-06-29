CREATE VIEW [ref].[match_cd_county] AS 
SELECT cd_county
	,cd_county [county_match_code]
FROM ref.lookup_county
WHERE cd_county != 0

UNION ALL

SELECT 0
	,cd_county
FROM ref.lookup_county
WHERE cd_county != 0
