CREATE TABLE [prtl].[ooh_flow_entries]
(
    [qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [start_date] DATE NOT NULL, 
    [plcm_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_flow_entries_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_flow_entries_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_flow_entries_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_flow_entries_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [cnt_entries] INT NULL, 
    [start_year] INT NULL 
)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_flow_entries] 
    ON [prtl].[ooh_flow_entries] ([plcm_param_key], [ia_param_key], [demog_param_key], [geog_param_key])
GO
