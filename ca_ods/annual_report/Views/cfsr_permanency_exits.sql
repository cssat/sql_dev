CREATE VIEW annual_report.cfsr_permanency_exits
AS
SELECT [dat_year]
	,[region]
	,[sex]
	,[race]
	,[age_cat]
	,[cd_discharge]
	,[time_period]
	,[percent]
FROM (
	SELECT [dat_year]
		,[region]
		,[sex]
		,[race]
		,[age_cat]
		,[cd_discharge]
		,[perm_months_12_23] AS [1]
		,[perm_months_24] AS [2]
		,[permanency_12_months] AS [0]
	FROM [annual_report].[cfsr_permanency]
	) AS dat
UNPIVOT([percent] FOR [time_period] IN (
			[0]
			,[1]
			,[2]
			)) AS unpvt
