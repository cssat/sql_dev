CREATE TABLE [prtl].[ooh_pit_measures]
(
    [start_date] DATE NOT NULL, 
    [date_type] INT NOT NULL, 
    [qry_type] INT NOT NULL, 
    [plcm_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_pit_measures_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_pit_measures_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ooh_pit_meausres_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL
        CONSTRAINT [fk_ooh_pit_measures_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [wb_param_key] INT NULL 
        CONSTRAINT [fk_ooh_pit_measures_wb_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_wellbeing]([wb_param_key]), 
    [family_setting_cnt] INT NULL, 
    [family_setting_dcfs_cnt] INT NULL, 
    [family_setting_private_agency_cnt] INT NULL, 
    [relative_care] INT NULL, 
    [group_inst_care_cnt] INT NULL, 
    [all_sib_together] INT NULL, 
    [some_sib_together] INT NULL, 
    [no_sib_together] INT NULL, 
    [cnt_child_unique] INT NULL, 
    [cnt_child] INT NULL, 
    [fl_ooh_wb_family_settings] INT NOT NULL, 
    [fl_ooh_wb_siblings] INT NOT NULL, 
    [fl_ooh_pit] INT NOT NULL 
)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_pit_measures] 
    ON [prtl].[ooh_pit_measures] ([plcm_param_key], [ia_param_key], [demog_param_key], [geog_param_key], [wb_param_key])
    INCLUDE ([fl_ooh_wb_family_settings], [fl_ooh_wb_siblings], [fl_ooh_pit])
GO

CREATE NONCLUSTERED INDEX [idx_ooh_pit_measures_fl_ooh_wb_family_settings]
    ON [prtl].[ooh_pit_measures] ([fl_ooh_wb_family_settings])
GO

CREATE NONCLUSTERED INDEX [idx_ooh_pit_measures_fl_ooh_wb_siblings]
    ON [prtl].[ooh_pit_measures] ([fl_ooh_wb_siblings])
GO

CREATE NONCLUSTERED INDEX [idx_ooh_pit_measures_fl_ooh_pit]
    ON [prtl].[ooh_pit_measures] ([fl_ooh_pit])
GO
