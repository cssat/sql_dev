CREATE TABLE [prtl].[param_sets_ia]
(
	[ia_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_sets_ia] PRIMARY KEY, 
    [cd_reporter_type] INT NOT NULL 
        CONSTRAINT [fk_param_sets_ia_cd_reporter_type] FOREIGN KEY REFERENCES [ref].[filter_reporter_type]([cd_reporter_type]), 
    [cd_access_type] INT NOT NULL 
        CONSTRAINT [fk_param_sets_ia_cd_access_type] FOREIGN KEY REFERENCES [ref].[filter_access_type]([cd_access_type]), 
    [cd_allegation] INT NOT NULL 
        CONSTRAINT [fk_param_sets_ia_cd_allegation] FOREIGN KEY REFERENCES [ref].[filter_allegation]([cd_allegation]), 
    [cd_finding] INT NOT NULL 
        CONSTRAINT [fk_param_sets_ia_cd_finding] FOREIGN KEY REFERENCES [ref].[filter_finding]([cd_finding]), 
    CONSTRAINT [idx_param_sets_ia] UNIQUE NONCLUSTERED (
        [cd_reporter_type], 
        [cd_access_type], 
        [cd_allegation], 
        [cd_finding] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
)
