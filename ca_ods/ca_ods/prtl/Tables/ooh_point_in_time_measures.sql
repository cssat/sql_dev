CREATE TABLE [prtl].[ooh_point_in_time_measures] (
    [start_date]                        DATETIME NOT NULL,
    [date_type]                         INT      NOT NULL,
    [qry_type]                          INT      NOT NULL,
    [age_grouping_cd_mix]               INT      NOT NULL,
    [age_grouping_cd_census]            INT      NOT NULL,
    [pk_gndr]                           INT      NOT NULL,
    [cd_race]                           INT      NOT NULL,
    [census_hispanic_latino_origin_cd]  INT      NOT NULL,
    [init_cd_plcm_setng]                INT      NOT NULL,
    [long_cd_plcm_setng]                INT      NOT NULL,
    [county_cd]                         INT      NOT NULL,
    [int_match_param_key_mix]           INT      NOT NULL,
    [int_match_param_key_census]        INT      NOT NULL,
    [bin_dep_cd]                        INT      NOT NULL,
    [max_bin_los_cd]                    INT      NOT NULL,
    [bin_placement_cd]                  INT      NOT NULL,
    [cd_reporter_type]                  INT      NOT NULL,
    [bin_ihs_svc_cd]                    INT      NOT NULL,
    [filter_access_type]                INT      NOT NULL,
    [filter_allegation]                 INT      NOT NULL,
    [filter_finding]                    INT      NOT NULL,
    [filter_service_category]           INT      NOT NULL,
    [filter_service_budget]             INT      NOT NULL,
    [kincare]                           INT      NULL,
    [bin_sibling_group_size]            INT      NULL,
    [family_setting_cnt]                INT      NULL,
    [family_setting_DCFS_cnt]           INT      NULL,
    [family_setting_private_agency_cnt] INT      NULL,
    [relative_care]                     INT      NULL,
    [group_inst_care_cnt]               INT      NULL,
    [all_sib_together]                  INT      NULL,
    [some_sib_together]                 INT      NULL,
    [no_sib_together]                   INT      NULL,
    [cnt_child_unique]                  INT      NULL,
    [cnt_child]                         INT      NULL,
    [fl_w3]                             INT      NOT NULL,
    [fl_w4]                             INT      NOT NULL,
    [fl_poc1ab]                         INT      NOT NULL,
    CONSTRAINT [ooh_point_in_time_measures_age_grouping_cd_census_FK] FOREIGN KEY ([age_grouping_cd_census]) REFERENCES [dbo].[ref_age_groupings_census] ([age_grouping_cd]),
    CONSTRAINT [ooh_point_in_time_measures_bin_dep_cd_FK] FOREIGN KEY ([bin_dep_cd]) REFERENCES [dbo].[ref_filter_dependency] ([bin_dep_cd]),
    CONSTRAINT [ooh_point_in_time_measures_bin_ihs_svc_cd_FK] FOREIGN KEY ([bin_ihs_svc_cd]) REFERENCES [dbo].[ref_filter_ihs_services] ([bin_ihs_svc_cd]),
    CONSTRAINT [ooh_point_in_time_measures_bin_placement_cd_FK] FOREIGN KEY ([bin_placement_cd]) REFERENCES [dbo].[ref_filter_nbr_placement] ([bin_placement_cd]),
    CONSTRAINT [ooh_point_in_time_measures_cd_race_FK] FOREIGN KEY ([cd_race]) REFERENCES [dbo].[ref_lookup_ethnicity_census] ([cd_race_census]),
    CONSTRAINT [ooh_point_in_time_measures_cd_reporter_type_FK] FOREIGN KEY ([cd_reporter_type]) REFERENCES [dbo].[ref_filter_reporter_type] ([cd_reporter_type]),
    CONSTRAINT [ooh_point_in_time_measures_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd]),
    CONSTRAINT [ooh_point_in_time_measures_init_cd_plcm_setng_FK] FOREIGN KEY ([init_cd_plcm_setng]) REFERENCES [dbo].[ref_lookup_plcmnt] ([cd_plcm_setng]),
    CONSTRAINT [ooh_point_in_time_measures_long_cd_plcm_setng_FK] FOREIGN KEY ([long_cd_plcm_setng]) REFERENCES [dbo].[ref_lookup_plcmnt] ([cd_plcm_setng]),
    CONSTRAINT [ooh_point_in_time_measures_max_bin_los_cd_FK] FOREIGN KEY ([max_bin_los_cd]) REFERENCES [dbo].[ref_filter_los] ([bin_los_cd]),
    CONSTRAINT [ooh_point_in_time_measures_origin_cd_FK] FOREIGN KEY ([census_hispanic_latino_origin_cd]) REFERENCES [dbo].[ref_lookup_hispanic_latino_census] ([census_hispanic_latino_origin_cd]),
    CONSTRAINT [ooh_point_in_time_measures_pk_gndr_FK] FOREIGN KEY ([pk_gndr]) REFERENCES [dbo].[ref_lookup_gender] ([pk_gndr])
);


GO
CREATE NONCLUSTERED INDEX [idx_fl_w3]
    ON [prtl].[ooh_point_in_time_measures]([fl_w3] ASC)
    INCLUDE([start_date], [date_type], [qry_type], [age_grouping_cd_mix], [age_grouping_cd_census], [cnt_child], [family_setting_cnt], [family_setting_DCFS_cnt], [family_setting_private_agency_cnt], [relative_care], [group_inst_care_cnt], [cnt_child_unique], [bin_ihs_svc_cd], [filter_access_type], [filter_allegation], [filter_finding], [filter_service_category], [filter_service_budget], [int_match_param_key_mix], [int_match_param_key_census], [bin_dep_cd], [max_bin_los_cd], [bin_placement_cd], [cd_reporter_type], [pk_gndr], [cd_race], [census_hispanic_latino_origin_cd], [init_cd_plcm_setng], [long_cd_plcm_setng], [county_cd]);


GO
CREATE NONCLUSTERED INDEX [idx_fl_w4]
    ON [prtl].[ooh_point_in_time_measures]([fl_w4] ASC)
    INCLUDE([start_date], [date_type], [qry_type], [age_grouping_cd_mix], [age_grouping_cd_census], [cnt_child], [all_sib_together], [some_sib_together], [no_sib_together], [kincare], [bin_sibling_group_size], [cnt_child_unique], [bin_ihs_svc_cd], [filter_access_type], [filter_allegation], [filter_finding], [filter_service_category], [filter_service_budget], [int_match_param_key_mix], [int_match_param_key_census], [bin_dep_cd], [max_bin_los_cd], [bin_placement_cd], [cd_reporter_type], [pk_gndr], [cd_race], [census_hispanic_latino_origin_cd], [init_cd_plcm_setng], [long_cd_plcm_setng], [county_cd]);


GO
CREATE NONCLUSTERED INDEX [idx_fl_poc1ab]
    ON [prtl].[ooh_point_in_time_measures]([fl_poc1ab] ASC)
    INCLUDE([start_date], [date_type], [qry_type], [age_grouping_cd_mix], [age_grouping_cd_census], [cnt_child_unique], [cnt_child], [bin_ihs_svc_cd], [filter_access_type], [filter_allegation], [filter_finding], [filter_service_category], [filter_service_budget], [int_match_param_key_mix], [int_match_param_key_census], [bin_dep_cd], [max_bin_los_cd], [bin_placement_cd], [cd_reporter_type], [pk_gndr], [cd_race], [census_hispanic_latino_origin_cd], [init_cd_plcm_setng], [long_cd_plcm_setng], [county_cd]);

