CREATE TABLE [prtl].[cache_ia_trends_params]
(
    [qry_id] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_cache_ia_trends_params] PRIMARY KEY, 
    [age_grouping_cd] VARCHAR(20) NOT NULL, 
    [cd_race_census] VARCHAR(30) NOT NULL, 
    [cd_county] VARCHAR(250) NOT NULL, 
    [cd_reporter_type] VARCHAR(100) NOT NULL, 
    [filter_access_type] VARCHAR(30) NOT NULL, 
    [filter_allegation] VARCHAR(30) NOT NULL, 
    [filter_finding] VARCHAR(30) NOT NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [cnt_qry] INT NOT NULL, 
    [last_run_date] DATETIME NOT NULL, 
    CONSTRAINT [idx_cache_ia_trends_params] UNIQUE NONCLUSTERED (
        [age_grouping_cd], 
        [cd_race_census], 
        [cd_county], 
        [cd_reporter_type], 
        [filter_access_type], 
        [filter_allegation], 
        [filter_finding]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
