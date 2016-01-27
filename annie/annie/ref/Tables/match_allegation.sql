CREATE TABLE [ref].[match_allegation] (
    [cd_allegation] INT NOT NULL 
        CONSTRAINT  [fk_match_allegation_cd_allegation] REFERENCES [ref].[filter_allegation]([cd_allegation]), 
    [filter_allegation] INT NOT NULL, 
    [fl_any_legal] INT NULL, 
    [fl_neglect] INT NULL, 
    [fl_sexual_abuse] INT NULL, 
    [fl_phys_abuse] INT NULL 
)
GO 

CREATE NONCLUSTERED INDEX [idx_match_allegation_code] ON [ref].[match_allegation] (
	[cd_allegation]
	) INCLUDE (
	[filter_allegation]
    )
GO

CREATE NONCLUSTERED INDEX [idx_match_allegation_match] ON [ref].[match_allegation] (
	[filter_allegation]
	) INCLUDE (
	[cd_allegation]
    )
GO
