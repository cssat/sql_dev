CREATE TABLE [prtl].[ia_safety_params]
(
    [qry_id] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_ia_safety_params] PRIMARY KEY, 
    [age_sib_group_cd] VARCHAR(20) NOT NULL, 
    [cd_race_census] VARCHAR(30) NOT NULL, 
    [cd_county] VARCHAR(200) NOT NULL, 
    [cd_reporter_type] VARCHAR(100) NOT NULL, 
    [cd_access_type] VARCHAR(30) NOT NULL, 
    [cd_allegation] VARCHAR(30) NOT NULL, 
    [cd_finding] VARCHAR(30) NOT NULL, 
    [min_start_date] DATETIME NOT NULL, 
    [max_start_date] DATETIME NOT NULL, 
    [cnt_qry] INT NOT NULL, 
    [last_run_date] DATETIME NOT NULL, 
    CONSTRAINT [idx_ia_safety_params] UNIQUE NONCLUSTERED (
        [age_sib_group_cd], 
        [cd_race_census], 
        [cd_county], 
        [cd_reporter_type], 
        [cd_access_type], 
        [cd_allegation], 
        [cd_finding] 
    )
)
