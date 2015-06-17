CREATE TABLE [ref].[lookup_dev_age_grouping]
(
    [dev_age_grouping_cd] INT NOT NULL 
        CONSTRAINT [pk_lookup_dev_age_grouping] PRIMARY KEY, 
    [dev_age_grouping] VARCHAR(100) NOT NULL
)
