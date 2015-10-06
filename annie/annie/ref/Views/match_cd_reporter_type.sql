CREATE VIEW [ref].[match_cd_reporter_type]
AS
SELECT cd_reporter_type
	,cd_reporter_type [reporter_type_match_code]
FROM ref.filter_reporter_type
WHERE cd_reporter_type != 0

UNION ALL

SELECT 0 [cd_reporter_type]
	,cd_reporter_type [reporter_type_match_cd]
FROM ref.filter_reporter_type
WHERE cd_reporter_type != 0

UNION ALL

SELECT 0 [cd_reporter_type]
	,-99 [reporter_type_match_cd]
