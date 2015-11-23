CREATE TABLE [prtl].[ooh_pit_measures] (
    [qry_type] TINYINT NOT NULL, 
    [date_type] TINYINT NOT NULL, 
    [start_date] DATE NOT NULL, 
	[age_grouping_cd_mix] TINYINT NOT NULL, 
	[age_grouping_cd_census] TINYINT NOT NULL, 
	[pk_gndr] TINYINT NOT NULL, 
	[cd_race] TINYINT NOT NULL, 
	[census_hispanic_latino_origin_cd] TINYINT NOT NULL, 
	[init_cd_plcm_setng] TINYINT NOT NULL, 
	[long_cd_plcm_setng] TINYINT NOT NULL,
	[county_cd] SMALLINT NOT NULL, 
	[bin_dep_cd] TINYINT NOT NULL, 
	[max_bin_los_cd] TINYINT NOT NULL, 
	[bin_placement_cd] TINYINT NOT NULL, 
	[bin_ihs_svc_cd] TINYINT NOT NULL, 
	[cd_reporter_type] SMALLINT NOT NULL, 
	[filter_access_type] INT NOT NULL, 
	[filter_allegation] INT NOT NULL, 
	[filter_finding] INT NOT NULL, 
	[kincare] TINYINT NULL, 
	[bin_sibling_group_size] TINYINT NULL, 
	[cnt_child] TINYINT NULL, 
    [fl_ooh_pit] BIT NOT NULL, 
    [cnt_child_unique] TINYINT NULL, 
    [fl_ooh_wb_family_settings] BIT NOT NULL, 
    [family_setting_dcfs_cnt] TINYINT NULL, 
    [family_setting_private_agency_cnt] TINYINT NULL, 
    [relative_care] TINYINT NULL, 
    [group_inst_care_cnt] TINYINT NULL, 
    [fl_ooh_wb_siblings] BIT NOT NULL, 
    [all_sib_together] TINYINT NULL, 
    [some_sib_together] TINYINT NULL, 
    [no_sib_together] TINYINT NULL 
)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_pit_measures_pit] ON [prtl].[ooh_pit_measures] (
	[fl_ooh_pit]
	,[age_grouping_cd_census]
	,[pk_gndr]
	,[cd_race]
	,[init_cd_plcm_setng]
	,[long_cd_plcm_setng]
	,[county_cd]
	,[bin_dep_cd]
	,[max_bin_los_cd]
	,[bin_placement_cd]
	,[bin_ihs_svc_cd]
	,[cd_reporter_type]
	,[filter_access_type]
	,[filter_allegation]
	,[filter_finding]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[start_date]
	,[cnt_child_unique]
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_pit_measures_wb_family_settings] ON [prtl].[ooh_pit_measures] (
	[county_cd]
	,[fl_ooh_wb_family_settings]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[start_date]
	,[age_grouping_cd_mix]
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
	,[cnt_child]
	,[family_setting_dcfs_cnt]
	,[family_setting_private_agency_cnt]
	,[relative_care]
	,[group_inst_care_cnt]
	)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_pit_measures_wb_siblings] ON [prtl].[ooh_pit_measures] (
	[county_cd]
	,[fl_ooh_wb_siblings]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[start_date]
	,[age_grouping_cd_mix]
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
	,[kincare]
	,[bin_sibling_group_size]
	,[cnt_child]
	,[all_sib_together]
	,[some_sib_together]
	,[no_sib_together]
	)
GO
