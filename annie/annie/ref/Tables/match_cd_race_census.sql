CREATE TABLE [ref].[match_cd_race_census] (
	[cd_race_census] TINYINT NOT NULL
	,[race_census_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_race_census_code] ON [ref].[match_cd_race_census] (
	[cd_race_census]
	) INCLUDE (
	[race_census_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_race_census_match] ON [ref].[match_cd_race_census] (
	[race_census_match_code]
	) INCLUDE (
	[cd_race_census]
	)
GO
