CREATE TABLE [ref].[match_finding] (
    [cd_finding] INT NOT NULL 
        CONSTRAINT [fk_match_finding_cd_finding] FOREIGN KEY REFERENCES [ref].[filter_finding]([cd_finding]), 
    [filter_finding] INT NOT NULL, 
    [fl_any_finding_legal] INT NULL, 
    [fl_founded_neglect] INT NULL, 
    [fl_founded_sexual_abuse] INT NULL, 
    [fl_founded_phys_abuse] INT NULL, 
)
GO

CREATE NONCLUSTERED INDEX [idx_match_finding_code] ON [ref].[match_finding] (
	[cd_finding]
	) INCLUDE (
	[filter_finding]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_finding_match] ON [ref].[match_finding] (
	[filter_finding]
	) INCLUDE (
	[cd_finding]
	)
GO
