CREATE TABLE [prtl].[param_match_ia]
(
    [ia_match_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_match_ia] PRIMARY KEY, 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_param_match_ia_ia_param_key] REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [cd_reporter_type] INT NOT NULL, 
    [filter_access_type] INT NOT NULL, 
    [filter_allegation] INT NOT NULL, 
    [filter_finding] INT NOT NULL
)
GO

CREATE NONCLUSTERED INDEX [idx_param_match_ia]
    ON [prtl].[param_match_ia]([ia_param_key])
    INCLUDE ([cd_reporter_type], [filter_access_type], [filter_allegation], [filter_finding])
GO

CREATE NONCLUSTERED INDEX [idx_param_match_ia_aggr_insert]
    ON [prtl].[param_match_ia]([ia_param_key], [cd_reporter_type], [filter_access_type], [filter_allegation], [filter_finding])
GO
