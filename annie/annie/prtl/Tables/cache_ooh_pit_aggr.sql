CREATE TABLE [prtl].[cache_ooh_pit_aggr]
(
	[qry_type] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_cache_ooh_pit_aggr] PRIMARY KEY, 
    [date_type] INT NOT NULL, 
    [start_date] DATETIME NOT NULL, 
    [plcm_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_pit_aggr_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_pit_aggr_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_pit_aggr_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_pit_aggr_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [cnt_start_date] INT NOT NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [start_year] INT NULL, 
	[fl_include_perCapita] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [idx_cache_ooh_pit_aggr] UNIQUE NONCLUSTERED (
        [qry_type], 
        [date_type], 
        [start_date], 
        [plcm_param_key], 
        [ia_param_key], 
        [demog_param_key], 
        [geog_param_key]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
