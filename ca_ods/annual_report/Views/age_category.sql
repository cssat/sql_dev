CREATE VIEW [annual_report].[age_category]
AS
SELECT [cd_age_cat]
	,[cd_age_cat] AS [match_code]
FROM [annual_report].[cfsr_age_category]
WHERE cd_age_cat != 0

UNION ALL

SELECT 0 AS [cd_age_cat]
	,[cd_age_cat] AS [match_code]
FROM [annual_report].[cfsr_age_category]
WHERE cd_age_cat != 0
