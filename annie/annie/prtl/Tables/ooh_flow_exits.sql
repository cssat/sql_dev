CREATE TABLE [prtl].[ooh_flow_exits] (
    [qry_type] TINYINT NOT NULL, 
    [date_type] TINYINT NOT NULL, 
    [start_date] DATE NOT NULL, 
    [age_grouping_cd] TINYINT NULL, 
    [pk_gndr] TINYINT NOT NULL, 
    [cd_race] TINYINT NULL, 
	[census_hispanic_latino_origin_cd] TINYINT NOT NULL, 
    [init_cd_plcm_setng] TINYINT NULL, 
	[long_cd_plcm_setng] TINYINT NULL, 
	[county_cd] SMALLINT NULL, 
	[bin_dep_cd] TINYINT NOT NULL, 
	[max_bin_los_cd] TINYINT NOT NULL, 
	[bin_placement_cd] TINYINT NOT NULL, 
	[bin_ihs_svc_cd] TINYINT NOT NULL, 
	[cd_reporter_type] SMALLINT NOT NULL, 
	[filter_access_type] INT NOT NULL, 
	[filter_allegation] INT NOT NULL, 
	[filter_finding] INT NOT NULL,
	[cd_discharge_type] TINYINT NOT NULL, 
    [cnt_exits] INT NOT NULL 
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_flow_exits] ON [prtl].[ooh_flow_exits] (
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
	,[cnt_exits]
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_flow_exits_county_cd] ON [prtl].[ooh_flow_exits] (
	[county_cd]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[start_date]
	,[age_grouping_cd]
	,[pk_gndr]
	,[cd_race]
	,[init_cd_plcm_setng]
	,[long_cd_plcm_setng]
	,[bin_dep_cd]
	,[max_bin_los_cd]
	,[bin_placement_cd]
	,[bin_ihs_svc_cd]
	,[cd_reporter_type]
	,[filter_access_type]
	,[filter_allegation]
	,[filter_finding]
	,[cd_discharge_type]
	,[cnt_exits]
	)
GO
