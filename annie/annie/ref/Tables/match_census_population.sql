CREATE TABLE [ref].[match_census_population]
(
    [measurement_year] INT NOT NULL,
    [age_grouping_cd] INT NOT NULL, 
	[pk_gender] INT NOT NULL, 
    [cd_race_census] INT NOT NULL, 
    [cd_county] INT NOT NULL, 
    [population_count] INT NOT NULL, 
    [perCapita_threshold] INT NOT NULL
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_match_census_population] ON [ref].[match_census_population] (
    [measurement_year], 
    [age_grouping_cd],
	[pk_gender], 
    [cd_race_census], 
    [cd_county]
	) INCLUDE (
	[population_count]
	,[perCapita_threshold]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_census_population_population_count] ON [ref].[match_census_population] (
	[population_count]
	) INCLUDE (
	[measurement_year]
	,[age_grouping_cd]
	,[pk_gender]
	,[cd_race_census]
	,[cd_county]
	,[perCapita_threshold]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_census_population2] ON [ref].[match_census_population] (
	[age_grouping_cd]
	,[pk_gender]
	,[cd_race_census]
	,[cd_county]
	) INCLUDE (
	[measurement_year]
	,[population_count]
	,[perCapita_threshold]
	)
GO
