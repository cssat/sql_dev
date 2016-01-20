CREATE TABLE [rodis].[ICD9_injury_codes] (
	[ICD_9_code] VARCHAR(50)
	,[EPH_intentional] SMALLINT
	,[EPH_unintentional] SMALLINT
	,[EPH_undetermined] SMALLINT
	,[EPH_all_injury] SMALLINT
	)
GO

CREATE NONCLUSTERED INDEX [idx_ICD9_injury_codes] ON [rodis].[ICD9_injury_codes] (
	[ICD_9_code]
	) INCLUDE (
	[EPH_intentional]
	,[EPH_unintentional]
	,[EPH_undetermined]
	,[EPH_all_injury]
	)
GO
