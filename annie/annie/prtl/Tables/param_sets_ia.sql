CREATE TABLE [prtl].[param_sets_ia]
(
	[ia_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_sets_ia] PRIMARY KEY, 
    [cd_reporter_type] INT NOT NULL, 
    [cd_access_type] INT NOT NULL, 
    [cd_allegation] INT NOT NULL, 
    [cd_finding] INT NOT NULL, 
    CONSTRAINT [idx_param_sets_ia] UNIQUE NONCLUSTERED (
        [cd_reporter_type], 
        [cd_access_type], 
        [cd_allegation], 
        [cd_finding] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
)
