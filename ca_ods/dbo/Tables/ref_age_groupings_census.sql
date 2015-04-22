CREATE TABLE [dbo].[ref_age_groupings_census] (
    [age_grouping_cd]  INT       NOT NULL,
    [age_begin]        INT       NOT NULL,
    [age_lessthan_end] INT       NOT NULL,
    [age_grouping]     CHAR (50) NULL,
    CONSTRAINT [PK_ref_Age_Groupings_census] PRIMARY KEY CLUSTERED ([age_grouping_cd] ASC)
);

