CREATE TABLE [prtl].[ooh_flow_entries] (
    [qry_type] INT NOT NULL, 
    [date_type] INT NOT NULL, 
    [start_date] DATE NOT NULL, 
	[bin_dep_cd] INT NOT NULL, 
	[age_grouping_cd] INT NULL, 
	[pk_gndr] INT NOT NULL, 
	[cd_race] INT NULL, 
	[census_hispanic_latino_origin_cd] INT NOT NULL, 
	[init_cd_plcm_setng] INT NULL, 
	[long_cd_plcm_setng] INT NULL, 
	[county_cd] INT NULL, 
	[max_bin_los_cd] INT NOT NULL, 
	[bin_placement_cd] INT NOT NULL,
	[bin_ihs_svc_cd] INT NOT NULL, 
	[cd_reporter_type] INT NOT NULL, 
	[filter_access_type] INT NOT NULL, 
	[filter_allegation] INT NOT NULL, 
	[filter_finding] INT NOT NULL, 
    [cnt_entries] INT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_flow_entries] ON [prtl].[ooh_flow_entries] (
	[age_grouping_cd]
	,[pk_gndr]
	,[cd_race]
	,[init_cd_plcm_setng]
	,[long_cd_plcm_setng]
	,[county_cd]
	,[max_bin_los_cd]
	,[bin_placement_cd]
	,[bin_ihs_svc_cd]
	,[cd_reporter_type]
	,[filter_access_type]
	,[filter_allegation]
	,[filter_finding]
	,[start_date]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[cnt_entries]
	)
GO
