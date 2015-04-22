CREATE TABLE [dbo].[ref_xwalk_race_origin] (
    [cd_race_census]                   INT NOT NULL,
    [census_hispanic_latino_origin_cd] INT NOT NULL,
    CONSTRAINT [PK_ref_xwalk_race_origin] PRIMARY KEY CLUSTERED ([cd_race_census] ASC, [census_hispanic_latino_origin_cd] ASC)
);

