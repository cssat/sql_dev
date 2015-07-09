CREATE TABLE [ref].[match_census_population_household]
(
    [measurement_year] INT NOT NULL,
    [age_sib_group_cd] INT NOT NULL, 
    [cd_race_census] INT NOT NULL, 
    [cd_county] INT NOT NULL, 
    [population_count] INT NOT NULL
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_match_census_population_household] ON [ref].[match_census_population_household] (
    [measurement_year], 
    [age_sib_group_cd], 
    [cd_race_census], 
    [cd_county]
)
INCLUDE ([population_count])
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
