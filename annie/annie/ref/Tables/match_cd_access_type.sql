CREATE TABLE [ref].[match_cd_access_type] (
	[cd_access_type] TINYINT NOT NULL
	,[filter_access_type] INT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_access_type_code] ON [ref].[match_cd_access_type] (
	[cd_access_type]
	) INCLUDE (
	[filter_access_type]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_access_type_match] ON [ref].[match_cd_access_type] (
	[filter_access_type]
	) INCLUDE (
	[cd_access_type]
	)
GO
