CREATE TABLE [ref].[lookup_age_grouping]
(
    [age_grouping_cd] INT NOT NULL 
        CONSTRAINT [pk_lookup_age_grouping] PRIMARY KEY, 
    [age_grouping] VARCHAR(100) NOT NULL
)
