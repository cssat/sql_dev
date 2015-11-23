CREATE TABLE [prtl].[ooh_outcomes_cache_query] (
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
	[cd_finding] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_outcomes_cache_query] ON [prtl].[ooh_outcomes_cache_query] (
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
	)
GO
