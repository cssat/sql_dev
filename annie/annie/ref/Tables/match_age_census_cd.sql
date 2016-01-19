CREATE TABLE [ref].[match_age_census_cd] (
	[age_census_cd] TINYINT NOT NULL
	,[age_census_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_age_census_cd_code] ON [ref].[match_age_census_cd] (
	[age_census_cd]
	) INCLUDE (
	[age_census_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_age_census_cd_match] ON [ref].[match_age_census_cd] (
	[age_census_match_code]
	) INCLUDE (
	[age_census_cd]
	)
GO
