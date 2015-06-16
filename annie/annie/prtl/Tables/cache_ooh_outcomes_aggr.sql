CREATE TABLE [prtl].[cache_ooh_outcomes_aggr]
(
	[cache_id] INT IDENTITY(1,1) NOT NULL 
        CONSTRAINT [pk_cache_ooh_outcomes_aggr] PRIMARY KEY,
	[qry_type] INT NOT NULL , 
    [date_type] INT NOT NULL, 
    [cohort_entry_date] DATETIME NOT NULL, 
    [month] INT NOT NULL, 
    [plcm_param_key] INT NOT NULL 
	    CONSTRAINT [fk_cache_ooh_outcomes_aggr_plcm_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_placement]([plcm_param_key]), 
    [ia_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_outcomes_aggr_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_outcomes_aggr_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_cache_ooh_outcomes_aggr_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [rate] DECIMAL(9, 2) NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [start_year] INT NULL, 
    CONSTRAINT [idx_cache_ooh_outcomes_aggr] UNIQUE NONCLUSTERED 
    (
        [qry_type] ASC, 
    	[date_type] ASC, 
    	[cohort_entry_date] ASC, 
    	[month] ASC, 
    	[plcm_param_key] ASC, 
    	[ia_param_key] ASC, 
    	[demog_param_key] ASC, 
    	[geog_param_key] ASC 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
