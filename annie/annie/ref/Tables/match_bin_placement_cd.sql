CREATE TABLE [ref].[match_bin_placement_cd] (
	[bin_placement_cd] TINYINT NOT NULL
	,[bin_placement_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_placement_cd_code] ON [ref].[match_bin_placement_cd] (
	[bin_placement_cd]
	) INCLUDE (
	[bin_placement_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_placement_cd_match] ON [ref].[match_bin_placement_cd] (
	[bin_placement_match_code]
	) INCLUDE (
	[bin_placement_cd]
	)
GO
