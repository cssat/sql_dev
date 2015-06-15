CREATE TABLE [prtl].[cache_ooh_outcomes_aggr]
(
	[qry_type] INT NOT NULL , 
    [date_type] INT NOT NULL, 
    [cohort_entry_date] DATETIME NOT NULL, 
    [month] INT NOT NULL, 
    [plcm_param_key] INT NOT NULL, 
    [ia_param_key] INT NOT NULL, 
    [demog_param_key] INT NOT NULL, 
    [geog_param_key] INT NOT NULL, 
    [rate] DECIMAL(9, 2) NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [start_year] INT NULL, 
    PRIMARY KEY ([qry_type], [date_type], [cohort_entry_date], [month], [plcm_param_key], [ia_param_key], [demog_param_key], [geog_param_key])
)
