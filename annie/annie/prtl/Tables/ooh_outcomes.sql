CREATE TABLE [prtl].[ooh_outcomes] (
    [cohort_entry_date] DATE NOT NULL, 
    [qry_type] TINYINT NOT NULL, 
    [date_type] TINYINT NOT NULL, 
	[age_grouping_cd] TINYINT NULL, 
	[pk_gndr] TINYINT NULL, 
	[cd_race_census] TINYINT NOT NULL, 
	[census_Hispanic_Latino_Origin_cd] TINYINT NULL, 
	[init_cd_plcm_setng] TINYINT NULL, 
	[long_cd_plcm_setng] TINYINT NULL, 
	[Removal_County_Cd] SMALLINT NULL, 
	[bin_dep_cd] TINYINT NOT NULL, 
	[max_bin_los_cd] TINYINT NOT NULL, 
	[bin_placement_cd] TINYINT NOT NULL, 
	[bin_ihs_svc_cd] TINYINT NOT NULL, 
	[cd_reporter_type] SMALLINT NOT NULL, 
	[filter_access_type] INT NOT NULL, 
	[filter_allegation] INT NOT NULL, 
	[filter_finding] INT NOT NULL, 
	[cd_discharge_type] TINYINT NOT NULL, 
    [mnth] TINYINT NOT NULL, 
    [discharge_count] INT NOT NULL, 
    [cohort_count] INT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_outcomes] ON [prtl].[ooh_outcomes] (
	[age_grouping_cd]
	,[pk_gndr]
	,[cd_race_census]
	,[init_cd_plcm_setng]
	,[long_cd_plcm_setng]
	,[Removal_County_Cd]
	,[bin_dep_cd]
	,[max_bin_los_cd]
	,[bin_placement_cd]
	,[bin_ihs_svc_cd]
	,[cd_reporter_type]
	,[filter_access_type]
	,[filter_allegation]
	,[filter_finding]
	,[cohort_entry_date]
	) INCLUDE (
	[qry_type]
	,[mnth]
	,[cd_discharge_type]
	,[discharge_count]
	,[cohort_count]
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_outcomes_Removal_County_Cd] ON [prtl].[ooh_outcomes] (
	[Removal_County_Cd]
	) INCLUDE (
	[cohort_entry_date]
	,[qry_type]
	,[date_type]
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
