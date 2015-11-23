CREATE TABLE [prtl].[ooh_wb_siblings_cache] (
	[qry_type] TINYINT NOT NULL, 
    [date_type] TINYINT NOT NULL, 
    [cohort_entry_date] DATE NOT NULL, 
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
	[kincare] TINYINT NOT NULL, 
	[bin_sibling_group_size] TINYINT NOT NULL, 
    [all_together] DECIMAL(9, 2) NULL, 
    [some_together] DECIMAL(9, 2) NULL, 
    [none_together] DECIMAL(9, 2) NULL, 
	[cnt_cohort] INT NULL 
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_wb_siblings_cache] ON [prtl].[ooh_wb_siblings_cache] (
	[cohort_entry_date]
	,[age_grouping_cd]
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
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[kincare]
	,[bin_sibling_group_size]
	,[all_together]
	,[some_together]
	,[none_together]
	,[cnt_cohort]
	)
GO
