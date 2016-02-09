CREATE VIEW [annual_report].[disreasn_view]
AS
SELECT [cd_disreasn]
	,[cd_disreasn] AS [match_code]
FROM [annual_report].[ref_afcars_disreasn]
WHERE [cd_disreasn] != 0

UNION ALL

SELECT 0 AS [cd_disreasn]
	,[cd_disreasn] AS [match_code]
FROM [annual_report].[ref_afcars_disreasn]
WHERE [cd_disreasn] != 0

UNION ALL

SELECT 0 AS [cd_disreasn]
	,7777 AS [match_code]
