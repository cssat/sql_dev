CREATE TABLE [prtl].[prtl_pbcp5] (
    [cohort_exit_year]                 DATETIME NOT NULL,
    [date_type]                        INT      NOT NULL,
    [qry_type]                         INT      NOT NULL,
    [cd_discharge_type]                INT      NOT NULL,
    [age_grouping_cd]                  INT      NULL,
    [pk_gndr]                          INT      NULL,
    [cd_race_census]                   INT      NULL,
    [census_hispanic_latino_origin_cd] INT      NULL,
    [init_cd_plcm_setng]               INT      NULL,
    [long_cd_plcm_setng]               INT      NULL,
    [exit_county_cd]                   INT      NULL,
    [int_match_param_key]              INT      NOT NULL,
    [bin_dep_cd]                       INT      NOT NULL,
    [max_bin_los_cd]                   INT      NOT NULL,
    [bin_placement_cd]                 INT      NOT NULL,
    [cd_reporter_type]                 INT      NOT NULL,
    [bin_ihs_svc_cd]                   INT      NOT NULL,
    [filter_access_type]               INT      NOT NULL,
    [filter_allegation]                INT      NOT NULL,
    [filter_finding]                   INT      NOT NULL,
    [filter_service_category]          INT      NOT NULL,
    [filter_service_budget]            INT      NOT NULL,
    [mnth]                             INT      NOT NULL,
    [discharge_count]                  INT      NULL,
    [cohort_count]                     INT      NOT NULL,
    CONSTRAINT [PK_prtl_pbcp5] PRIMARY KEY CLUSTERED ([cohort_exit_year] ASC, [qry_type] ASC, [cd_discharge_type] ASC, [int_match_param_key] ASC, [bin_dep_cd] ASC, [max_bin_los_cd] ASC, [bin_placement_cd] ASC, [cd_reporter_type] ASC, [bin_ihs_svc_cd] ASC, [filter_access_type] ASC, [filter_allegation] ASC, [filter_finding] ASC, [filter_service_category] ASC, [filter_service_budget] ASC, [mnth] ASC),
    CONSTRAINT [prtl_pbcp5_bin_dep_cd_FK] FOREIGN KEY ([bin_dep_cd]) REFERENCES [dbo].[ref_filter_dependency] ([bin_dep_cd]),
    CONSTRAINT [prtl_pbcp5_bin_ihs_svc_cd_FK] FOREIGN KEY ([bin_ihs_svc_cd]) REFERENCES [dbo].[ref_filter_ihs_services] ([bin_ihs_svc_cd]),
    CONSTRAINT [prtl_pbcp5_bin_placement_cd_FK] FOREIGN KEY ([bin_placement_cd]) REFERENCES [dbo].[ref_filter_nbr_placement] ([bin_placement_cd]),
    CONSTRAINT [prtl_pbcp5_cd_race_FK] FOREIGN KEY ([cd_race_census]) REFERENCES [dbo].[ref_lookup_ethnicity_census] ([cd_race_census]),
    CONSTRAINT [prtl_pbcp5_cd_reporter_type_FK] FOREIGN KEY ([cd_reporter_type]) REFERENCES [dbo].[ref_filter_reporter_type] ([cd_reporter_type]),
    CONSTRAINT [prtl_pbcp5_county_cd_FK] FOREIGN KEY ([exit_county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd]),
    CONSTRAINT [prtl_pbcp5_filter_service_category_FK] FOREIGN KEY ([filter_service_category]) REFERENCES [dbo].[ref_service_category_flag_xwalk] ([int_filter_service_category]),
    CONSTRAINT [prtl_pbcp5_init_cd_plcm_setng_FK] FOREIGN KEY ([init_cd_plcm_setng]) REFERENCES [dbo].[ref_lookup_plcmnt] ([cd_plcm_setng]),
    CONSTRAINT [prtl_pbcp5_long_cd_plcm_setng_FK] FOREIGN KEY ([long_cd_plcm_setng]) REFERENCES [dbo].[ref_lookup_plcmnt] ([cd_plcm_setng]),
    CONSTRAINT [prtl_pbcp5_max_bin_los_cd_FK] FOREIGN KEY ([max_bin_los_cd]) REFERENCES [dbo].[ref_filter_los] ([bin_los_cd]),
    CONSTRAINT [prtl_pbcp5_origin_cd_FK] FOREIGN KEY ([census_hispanic_latino_origin_cd]) REFERENCES [dbo].[ref_lookup_hispanic_latino_census] ([census_hispanic_latino_origin_cd]),
    CONSTRAINT [prtl_pbcp5_pk_gndr_FK] FOREIGN KEY ([pk_gndr]) REFERENCES [dbo].[ref_lookup_gender] ([pk_gndr])
);


GO
CREATE NONCLUSTERED INDEX [idx_qryt]
    ON [prtl].[prtl_pbcp5]([qry_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_year_params]
    ON [prtl].[prtl_pbcp5]([cohort_exit_year] ASC, [date_type] ASC, [qry_type] ASC, [int_match_param_key] ASC)
    INCLUDE([cd_discharge_type], [bin_dep_cd], [filter_finding], [filter_service_category], [filter_service_budget], [mnth], [discharge_count], [max_bin_los_cd], [bin_placement_cd], [cd_reporter_type], [bin_ihs_svc_cd], [filter_access_type], [filter_allegation]);


GO
CREATE NONCLUSTERED INDEX [idx_fl_include_in_cohort_count]
    ON [prtl].[prtl_pbcp5]([cohort_count] ASC)
    INCLUDE([cohort_exit_year], [date_type], [qry_type], [int_match_param_key], [bin_dep_cd], [filter_finding], [filter_service_category], [filter_service_budget], [discharge_count], [max_bin_los_cd], [bin_placement_cd], [cd_reporter_type], [bin_ihs_svc_cd], [filter_access_type], [filter_allegation]);

