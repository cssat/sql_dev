CREATE TABLE [dbo].[ref_match_allegation] (
    [cd_allegation]     INT NOT NULL,
    [filter_allegation] INT NOT NULL,
    [fl_phys_abuse]     INT NULL,
    [fl_sexual_abuse]   INT NULL,
    [fl_neglect]        INT NULL,
    [fl_any_legal]      INT NULL,
    PRIMARY KEY CLUSTERED ([filter_allegation] ASC, [cd_allegation] ASC)
);

