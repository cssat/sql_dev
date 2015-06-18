CREATE TABLE [prtl].[ooh_outcomes]
(
    [cohort_entry_date] DATE NOT NULL, 
    [date_type] INT NOT NULL, 
    [qry_type] INT NOT NULL, 
    [plcm_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_outcomes_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_outcomes_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL
        CONSTRAINT [fk_ooh_outcomes_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_outcomes_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [month] INT NOT NULL, 
    [discharge_count] INT NOT NULL, 
    [cohort_count] INT NOT NULL
)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_outcomes] 
    ON [prtl].[ooh_outcomes] ([plcm_param_key], [ia_param_key], [demog_param_key], [geog_param_key])
    INCLUDE ([month])
GO
