CREATE TABLE [ref].[match_cd_county] (
	[cd_county] SMALLINT NOT NULL
	,[county_match_code] SMALLINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_county_code] ON [ref].[match_cd_county] (
	[cd_county]
	) INCLUDE (
	[county_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_county_match] ON [ref].[match_cd_county] (
	[county_match_code]
	) INCLUDE (
	[cd_county]
	)
GO
