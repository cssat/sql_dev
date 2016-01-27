CREATE TABLE [ref].[match_cd_reporter_type] (
	[cd_reporter_type] TINYINT NOT NULL
	,[reporter_type_match_code] SMALLINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_reporter_type_code] ON [ref].[match_cd_reporter_type] (
	[cd_reporter_type]
	) INCLUDE (
	[reporter_type_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_reporter_type_match] ON [ref].[match_cd_reporter_type] (
	[reporter_type_match_code]
	) INCLUDE (
	[cd_reporter_type]
	)
GO
