CREATE TABLE [public_data].[census_population_household] (
    [source_census]    INT NULL,
    [county_cd]        INT NULL,
    [cd_race]          INT NULL,
    [cd_sib_age_grp]   INT NULL,
    [measurement_year] INT NULL,
    [pop_cnt]          INT NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_county_measurement_year]
    ON [public_data].[census_population_household]([measurement_year] ASC, [county_cd] ASC)
    INCLUDE([pop_cnt]);

