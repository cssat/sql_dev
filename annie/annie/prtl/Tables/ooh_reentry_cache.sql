CREATE TABLE [prtl].[ooh_reentry_cache] (
	[qry_type] TINYINT NOT NULL, 
    [date_type] TINYINT NOT NULL, 
    [cohort_exit_year] DATE NOT NULL, 
    [age_grouping_cd] TINYINT NOT NULL, 
    [pk_gender] TINYINT NOT NULL, 
    [cd_race_census] TINYINT NOT NULL, 
    [initial_cd_placement_setting] TINYINT NOT NULL, 
	[longest_cd_placement_setting] TINYINT NOT NULL, 
	[cd_county] TINYINT NOT NULL, 
	[bin_dependency_cd] TINYINT NOT NULL, 
	[bin_los_cd] TINYINT NOT NULL, 
	[bin_placement_cd] TINYINT NOT NULL, 
	[bin_ihs_service_cd] TINYINT NOT NULL, 
	[cd_reporter_type] TINYINT NOT NULL, 
	[cd_access_type] TINYINT NOT NULL, 
	[cd_allegation] TINYINT NOT NULL, 
	[cd_finding] TINYINT NOT NULL, 
	[cd_discharge_type] TINYINT NOT NULL, 
    [reentry_within_month] TINYINT NOT NULL, 
	[reentry_count] INT NOT NULL, 
	[total_count] INT NOT NULL, 
    [reentry_rate] DECIMAL(9, 2) NULL 
	)
GO
CREATE NONCLUSTERED INDEX [idx_ooh_reentry_cache] ON [prtl].[ooh_reentry_cache] (
	[age_grouping_cd]
	,[pk_gender]
	,[cd_race_census]
	,[initial_cd_placement_setting]
	,[longest_cd_placement_setting]
	,[cd_county]
	,[bin_dependency_cd]
	,[bin_los_cd]
	,[bin_placement_cd]
	,[bin_ihs_service_cd]
	,[cd_reporter_type]
	,[cd_access_type]
	,[cd_allegation]
	,[cd_finding]
	,[cohort_exit_year]
	) INCLUDE (
	[qry_type]
	,[cd_discharge_type]
	,[reentry_within_month]
	,[reentry_rate]
	)
GO
