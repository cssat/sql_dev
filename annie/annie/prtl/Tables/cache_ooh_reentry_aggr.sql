CREATE TABLE [prtl].[cache_ooh_reentry_aggr]
(
	[qry_type] INT NOT NULL IDENTITY(1,1)
        CONSTRAINT [pk_cache_ooh_reentry_aggr] PRIMARY KEY, 
    [date_type] INT NOT NULL, 
    [cohort_entry_date] DATETIME NOT NULL, 
    [reentry_within_month] INT NOT NULL, 
    [plcm_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_reentry_aggr_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_reentry_aggr_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_reentry_aggr_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_reentry_aggr_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [reentry_rate] DECIMAL(18, 2) NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [start_year] INT NULL, 
    CONSTRAINT [idx_cache_ooh_reentry_aggr] UNIQUE NONCLUSTERED ( 
        [qry_type], 
        [date_type], 
        [cohort_entry_date], 
        [reentry_within_month], 
        [plcm_param_key], 
        [ia_param_key], 
        [demog_param_key], 
        [geog_param_key]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
)
