CREATE TABLE [ref].[lookup_ethnicity_census]
(
    [cd_race_census] INT NOT NULL 
        CONSTRAINT [pk_lookup_ethnicity_census] PRIMARY KEY, 
    [tx_race_census] VARCHAR(100) NOT NULL
)
