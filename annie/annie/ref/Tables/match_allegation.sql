CREATE TABLE [ref].[match_allegation]
(
    [cd_allegation] INT NOT NULL 
        CONSTRAINT  [fk_match_allegation_cd_allegation] REFERENCES [ref].[filter_allegation]([cd_allegation]), 
    [filter_allegation] INT NOT NULL, 
    [fl_any_legal] INT NULL, 
    [fl_neglect] INT NULL, 
    [fl_sexual_abuse] INT NULL, 
    [fl_phys_abuse] INT NULL, 
    CONSTRAINT [idx_match_allegation] UNIQUE NONCLUSTERED (
        [cd_allegation], 
        [filter_allegation]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
