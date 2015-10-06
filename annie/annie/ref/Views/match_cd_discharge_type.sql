CREATE VIEW [ref].[match_cd_discharge_type]
AS
SELECT cd_discharge_type
	,cd_discharge_type [discharge_type_match_code]
FROM ref.filter_discharge_type
WHERE cd_discharge_type != 0

UNION ALL

SELECT 0 [cd_discharge_type]
	,cd_discharge_type [discharge_type_match_code]
FROM ref.filter_discharge_type
WHERE cd_discharge_type != 0
