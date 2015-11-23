CREATE TABLE [prtl].[ooh_reentry] (
    [qry_type] TINYINT NOT NULL, 
    [date_type] TINYINT NOT NULL, 
    [cohort_exit_year] DATE NOT NULL, 
    [age_grouping_cd] TINYINT NULL, 
    [pk_gndr] TINYINT NULL, 
    [cd_race_census] TINYINT NULL, 
	[census_hispanic_latino_origin_cd] TINYINT NULL, 
	[init_cd_plcm_setng] TINYINT NULL, 
	[long_cd_plcm_setng] TINYINT NULL, 
	[exit_county_cd] SMALLINT NULL, 
	[bin_dep_cd] TINYINT NOT NULL, 
	[max_bin_los_cd] TINYINT NOT NULL, 
	[bin_placement_cd] TINYINT NOT NULL, 
	[bin_ihs_svc_cd] TINYINT NOT NULL, 
	[cd_reporter_type] SMALLINT NOT NULL, 
	[filter_access_type] INT NOT NULL, 
	[filter_allegation] SMALLINT NOT NULL, 
	[filter_finding] SMALLINT NOT NULL, 
    [cd_discharge_type] TINYINT NOT NULL, 
    [mnth] TINYINT NOT NULL, 
    [discharge_count] TINYINT NULL, 
    [cohort_count] TINYINT NOT NULL 
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_reentry] ON [prtl].[ooh_reentry] (
	[exit_county_cd]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[cohort_exit_year]
	,[age_grouping_cd]
	,[pk_gndr]
	,[cd_race_census]
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
	,[mnth]
	,[discharge_count]
	,[cohort_count]
	)
GO
