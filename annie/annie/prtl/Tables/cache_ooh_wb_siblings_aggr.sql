CREATE TABLE [prtl].[cache_ooh_wb_siblings_aggr]
(
    [cache_id] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_cache_ooh_wb_siblings_aggr] PRIMARY KEY, 
	[qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [cohort_entry_date] DATETIME NOT NULL, 
    [plcm_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_wb_siblings_aggr_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_wb_siblings_aggr_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_wb_siblings_aggr_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_wb_siblings_aggr_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [all_together] DECIMAL(9, 2) NULL, 
    [some_together] DECIMAL(9, 2) NULL, 
    [none_together] DECIMAL(9, 2) NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [cohort_begin_year] INT NULL, 
    CONSTRAINT [idx_cache_ooh_wb_siblings_aggr] UNIQUE NONCLUSTERED ( 
        [qry_type], 
        [date_type], 
        [cohort_entry_date], 
        [plcm_param_key], 
        [ia_param_key], 
        [demog_param_key], 
        [geog_param_key] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
