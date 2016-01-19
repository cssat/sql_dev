CREATE TABLE [prtl].[ooh_flow_entries] (
    [qry_type] TINYINT NOT NULL, 
    [date_type] TINYINT NOT NULL, 
    [start_date] DATE NOT NULL, 
	[bin_dep_cd] TINYINT NOT NULL, 
	[age_grouping_cd] TINYINT NULL, 
	[pk_gndr] TINYINT NOT NULL, 
	[cd_race] TINYINT NULL, 
	[census_hispanic_latino_origin_cd] TINYINT NOT NULL, 
	[init_cd_plcm_setng] TINYINT NULL, 
	[long_cd_plcm_setng] TINYINT NULL, 
	[county_cd] SMALLINT NULL, 
	[max_bin_los_cd] TINYINT NOT NULL, 
	[bin_placement_cd] TINYINT NOT NULL,
	[bin_ihs_svc_cd] TINYINT NOT NULL, 
	[cd_reporter_type] SMALLINT NOT NULL, 
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

CREATE NONCLUSTERED INDEX [idx_ooh_flow_entries_county_cd] ON [prtl].[ooh_flow_entries] (
	[county_cd]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[start_date]
	,[bin_dep_cd]
	,[age_grouping_cd]
	,[pk_gndr]
	,[cd_race]
	,[init_cd_plcm_setng]
	,[long_cd_plcm_setng]
	,[max_bin_los_cd]
	,[bin_placement_cd]
	,[bin_ihs_svc_cd]
	,[cd_reporter_type]
	,[filter_access_type]
	,[filter_allegation]
	,[filter_finding]
	,[cnt_entries]
	)
GO
