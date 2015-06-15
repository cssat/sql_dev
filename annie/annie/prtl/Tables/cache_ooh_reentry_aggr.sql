CREATE TABLE [prtl].[cache_ooh_reentry_aggr]
(
	[qry_type] INT NOT NULL , 
    [date_type] INT NOT NULL, 
    [cohort_entry_date] DATETIME NOT NULL, 
    [reentry_within_month] INT NOT NULL, 
    [plcm_param_key] INT NOT NULL, 
    [ia_param_key] INT NOT NULL, 
    [demog_param_key] INT NOT NULL, 
    [geog_param_key] INT NOT NULL, 
    [reentry_rate] DECIMAL(18, 2) NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [start_year] INT NULL, 
    PRIMARY KEY ([qry_type], [date_type], [cohort_entry_date], [reentry_within_month], [plcm_param_key], [ia_param_key], [demog_param_key], [geog_param_key]) 
)
