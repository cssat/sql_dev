CREATE TABLE [prtl].[cache_ooh_wb_family_settings_aggr]
(
    [cache_id] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_cache_ooh_wb_family_settings_aggr] PRIMARY KEY, 
	[qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [cohort_entry_date] DATETIME NOT NULL, 
    [plcm_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_wb_family_settings_aggr_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_wb_family_settings_aggr_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL
        CONSTRAINT [fk_cache_ooh_wb_family_settings_aggr_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL
        CONSTRAINT [fk_cache_ooh_wb_family_settings_aggr_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [wb_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_wb_family_settings_aggr_wb_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_wellbeing]([wb_param_key]), 
    [family_setting_dcfs_percentage] DECIMAL(9, 2) NULL, 
    [family_setting_private_agency_percentage] DECIMAL(9, 2) NULL, 
	[relative_percentage] DECIMAL(9, 2) NULL, 
	[group_inst_care_percentage] DECIMAL(9, 2) NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [cohort_begin_year] INT NULL, 
    CONSTRAINT [idx_cache_ooh_wb_family_settings_aggr] UNIQUE NONCLUSTERED ( 
        [qry_type], 
        [date_type], 
        [cohort_entry_date], 
        [plcm_param_key], 
        [ia_param_key], 
        [demog_param_key], 
        [geog_param_key], 
        [wb_param_key] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
