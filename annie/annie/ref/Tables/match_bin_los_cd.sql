CREATE TABLE [ref].[match_bin_los_cd] (
	[bin_los_cd] TINYINT NOT NULL
	,[bin_los_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_los_cd_code] ON [ref].[match_bin_los_cd] (
	[bin_los_cd]
	) INCLUDE (
	[bin_los_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_los_cd_match] ON [ref].[match_bin_los_cd] (
	[bin_los_match_code]
	) INCLUDE (
	[bin_los_cd]
	)
GO
