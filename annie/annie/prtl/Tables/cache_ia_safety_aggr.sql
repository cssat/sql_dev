CREATE TABLE [prtl].[cache_ia_safety_aggr]
(
	[cache_id] INT NOT NULL IDENTITY(1,1) 
	    CONSTRAINT [pk_cache_ia_safety_aggr] PRIMARY KEY, 
	[qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [start_date] DATETIME NOT NULL, 
    [ia_param_key] INT NOT NULL 
	    CONSTRAINT [fk_cache_ia_safety_aggr_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
	    CONSTRAINT [fk_cache_ia_safety_aggr_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
	[geog_param_key] INT NOT NULL 
	    CONSTRAINT [fk_cache_ia_safety_aggr_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]),
    [month] INT NOT NULL, 
    [among_first_cmpt_rereferred] DECIMAL(9, 2) NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [insert_date] DATETIME NOT NULL, 
    [qry_id] INT NOT NULL, 
    [start_year] INT NULL, 
    CONSTRAINT [idx_cache_ia_safety_aggr] UNIQUE NONCLUSTERED (
	    [qry_type], 
		[date_type], 
		[start_date], 
		[ia_param_key], 
		[demog_param_key], 
		[geog_param_key], 
		[month]
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
