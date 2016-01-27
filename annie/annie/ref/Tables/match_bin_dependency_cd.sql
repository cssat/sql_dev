CREATE TABLE [ref].[match_bin_dependency_cd] (
	[bin_dependency_cd] TINYINT NOT NULL
	,[bin_dependency_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_dependency_cd_code] ON [ref].[match_bin_dependency_cd] (
	[bin_dependency_cd]
	) INCLUDE (
	[bin_dependency_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_dependency_cd_match] ON [ref].[match_bin_dependency_cd] (
	[bin_dependency_match_code]
	) INCLUDE (
	[bin_dependency_cd]
	)
GO
