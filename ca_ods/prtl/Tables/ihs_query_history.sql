CREATE TABLE [prtl].[ihs_query_history] (
	[measure_id] INT NOT NULL, 
    [cd_sib_age_grp] VARCHAR (100) NOT NULL, 
    [cd_race_census] VARCHAR (30) NOT NULL, 
    [cd_county] VARCHAR (250) NOT NULL, 
    [cd_reporter_type] VARCHAR (100) NOT NULL, 
    [bin_ihs_svc_cd] VARCHAR (30) NOT NULL, 
    [filter_access_type] VARCHAR (30) NOT NULL, 
    [filter_allegation] VARCHAR (30) NOT NULL, 
    [filter_finding] VARCHAR (30) NOT NULL, 
    [cnt_qry] INT NOT NULL, 
    [last_run_date] DATETIME NOT NULL, 
	[snapshot_date] DATETIME NOT NULL 
	)
