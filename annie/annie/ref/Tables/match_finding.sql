CREATE TABLE [ref].[match_finding]
(
    [cd_finding] INT NOT NULL 
        CONSTRAINT [fk_match_finding_cd_finding] FOREIGN KEY REFERENCES [ref].[filter_finding]([cd_finding]), 
    [filter_finding] INT NOT NULL, 
    [fl_any_finding_legal] INT NULL, 
    [fl_founded_neglect] INT NULL, 
    [fl_founded_sexual_abuse] INT NULL, 
    [fl_founded_phys_abuse] INT NULL, 
    CONSTRAINT [idx_match_finding] UNIQUE NONCLUSTERED (
        [cd_finding], 
        [filter_finding]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
