CREATE TABLE [prtl].[cache_ooh_flow_exits_aggr]
(
	[qry_type] INT NOT NULL , 
    [date_type] INT NOT NULL, 
    [start_date] DATETIME NOT NULL, 
    [plcm_param_key] INT NOT NULL, 
    [ia_param_key] INT NOT NULL, 
    [demog_param_key] INT NOT NULL, 
    [geog_param_key] INT NOT NULL, 
    [cnt_exits] INT NOT NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [start_year] INT NULL, 
    PRIMARY KEY ([qry_type], [date_type], [start_date], [plcm_param_key], [ia_param_key], [demog_param_key], [geog_param_key])
)
