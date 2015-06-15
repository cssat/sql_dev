CREATE TABLE [prtl].[cache_ia_trends_aggr]
(
	[qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [start_date] DATETIME NOT NULL, 
    [ia_param_key] INT NOT NULL, 
    [demog_param_key] INT NOT NULL, 
	[geog_param_key] INT NOT NULL,
    [cnt_opened] INT NOT NULL, 
    [cnt_closed] INT NOT NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [start_year] INT NULL, 
	[fl_include_perCapita] SMALLINT NOT NULL DEFAULT 1,
    PRIMARY KEY ([qry_type], [date_type], [start_date], [ia_param_key], [demog_param_key], [geog_param_key])
)
