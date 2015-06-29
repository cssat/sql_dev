CREATE VIEW [ref].[match_cd_access_type]
AS
SELECT cd_access_type
	,filter_access_type
FROM ref.filter_access_type
WHERE cd_access_type != 0

UNION ALL

SELECT 0
	,filter_access_type
FROM ref.filter_access_type
