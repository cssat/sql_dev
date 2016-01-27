CREATE TABLE [rodis].[xwalk_icd_9_to_10] (
	[icd9cm] VARCHAR(50)
	,[icd10cm] VARCHAR(50)
	,[flags] VARCHAR(50)
	,[approximate] VARCHAR(50)
	,[no_map] VARCHAR(50)
	,[combination] VARCHAR(50)
	,[scenario] VARCHAR(50)
	,[choice_list] VARCHAR(50)
	)
GO

CREATE NONCLUSTERED INDEX [idx_xwalk_icd_9_to_10_icd9cm] ON [rodis].[xwalk_icd_9_to_10] (
	[icd9cm]
	) INCLUDE (
	[icd10cm]
	)
GO

CREATE NONCLUSTERED INDEX [idx_xwalk_icd_9_to_10_icd10cm] ON [rodis].[xwalk_icd_9_to_10] (
	[icd10cm]
	) INCLUDE (
	[icd9cm]
	)
GO
