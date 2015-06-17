CREATE TABLE [prtl].[cache_ooh_reentry_params]
(
    [qry_id] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_cache_ooh_reentry_params] PRIMARY KEY, 
    [age_grouping_cd] VARCHAR(20) NOT NULL, 
    [cd_race_census] VARCHAR(30) NOT NULL, 
    [pk_gender] VARCHAR(10) NOT NULL, 
    [init_cd_plcm_setng] VARCHAR(50) NOT NULL, 
    [long_cd_plcm_setng] VARCHAR(50) NOT NULL, 
    [cd_county] VARCHAR(200) NOT NULL, 
    [bin_los_cd] VARCHAR(30) NOT NULL, 
    [bin_placement_cd] VARCHAR(30) NOT NULL, 
    [bin_ihs_svc_cd] VARCHAR(30) NOT NULL, 
    [cd_reporter_type] VARCHAR(100) NOT NULL, 
    [filter_access_type] VARCHAR(30) NOT NULL, 
    [filter_allegation] VARCHAR(30) NOT NULL, 
    [filter_finding] VARCHAR(30) NOT NULL, 
    [bin_dependency_cd] VARCHAR(20) NOT NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [cnt_qry] INT NOT NULL, 
    [last_run_date] DATETIME NOT NULL, 
    CONSTRAINT [idx_cache_ooh_reentry_params] UNIQUE NONCLUSTERED ( 
        [age_grouping_cd], 
        [cd_race_census], 
        [pk_gender], 
        [init_cd_plcm_setng], 
        [long_cd_plcm_setng], 
        [cd_county], 
        [bin_los_cd], 
        [bin_placement_cd], 
        [bin_ihs_svc_cd], 
        [cd_reporter_type], 
        [filter_access_type], 
        [filter_allegation], 
        [filter_finding], 
        [bin_dependency_cd]
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
