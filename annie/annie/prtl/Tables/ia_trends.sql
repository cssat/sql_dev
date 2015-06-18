CREATE TABLE [prtl].[ia_trends]
(
    [qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [start_date] DATE NOT NULL, 
    [start_year] INT NOT NULL, 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_ia_trends_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ia_trends_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ia_trends_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [cnt_start_date] INT NULL, 
    [cnt_opened] INT NULL, 
    [cnt_closed] INT NULL 
)
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends] 
    ON [prtl].[ia_trends] ([ia_param_key], [demog_param_key], [geog_param_key])
GO
