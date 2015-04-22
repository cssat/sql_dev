CREATE TABLE [dbo].[ref_lookup_hispanic_latino_census] (
    [census_hispanic_latino_origin_cd] INT           NOT NULL,
    [census_hispanic_latino_origin]    VARCHAR (200) NULL,
    [cd_race_census]                   INT           NULL,
    CONSTRAINT [PK_ref_lookup_hispanic_latino_census] PRIMARY KEY CLUSTERED ([census_hispanic_latino_origin_cd] ASC)
);

