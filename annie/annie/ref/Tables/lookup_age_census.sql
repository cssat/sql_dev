CREATE TABLE [ref].[lookup_age_census]
(
    [age_census_cd] INT NOT NULL 
        CONSTRAINT [pk_lookup_age_census] PRIMARY KEY, 
    [age_census] VARCHAR(50) NOT NULL
)
