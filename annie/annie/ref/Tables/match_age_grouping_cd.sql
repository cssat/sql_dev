CREATE TABLE [ref].[match_age_grouping_cd] (
	[age_grouping_cd] TINYINT NOT NULL
	,[age_grouping_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_age_grouping_cd_code] ON [ref].[match_age_grouping_cd] (
	[age_grouping_cd]
	) INCLUDE (
	[age_grouping_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_age_grouping_cd_match] ON [ref].[match_age_grouping_cd] (
	[age_grouping_match_code]
	) INCLUDE (
	[age_grouping_cd]
	)
GO
