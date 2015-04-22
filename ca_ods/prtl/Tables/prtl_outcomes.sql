CREATE TABLE [prtl].[prtl_outcomes] (
    [cohort_entry_date]                DATETIME NOT NULL,
    [date_type]                        INT      NOT NULL,
    [qry_type]                         INT      NOT NULL,
    [cd_discharge_type]                INT      NOT NULL,
    [age_grouping_cd]                  INT      NULL,
    [pk_gndr]                          INT      NULL,
    [cd_race_census]                   INT      NOT NULL,
    [census_Hispanic_Latino_Origin_cd] INT      NULL,
    [init_cd_plcm_setng]               INT      NULL,
    [long_cd_plcm_setng]               INT      NULL,
    [Removal_County_Cd]                INT      NULL,
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
    [discharge_count]                  INT      NOT NULL,
    [cohort_count]                     INT      NOT NULL,
    CONSTRAINT [PK_prtl_outcomes] PRIMARY KEY CLUSTERED ([cohort_entry_date] ASC, [qry_type] ASC, [cd_discharge_type] ASC, [int_match_param_key] ASC, [bin_dep_cd] ASC, [max_bin_los_cd] ASC, [bin_placement_cd] ASC, [cd_reporter_type] ASC, [bin_ihs_svc_cd] ASC, [filter_access_type] ASC, [filter_allegation] ASC, [filter_finding] ASC, [filter_service_category] ASC, [filter_service_budget] ASC, [mnth] ASC),
    CONSTRAINT [prtl_outcomes_bin_dep_cd_FK] FOREIGN KEY ([bin_dep_cd]) REFERENCES [dbo].[ref_filter_dependency] ([bin_dep_cd]),
    CONSTRAINT [prtl_outcomes_bin_ihs_svc_cd_FK] FOREIGN KEY ([bin_ihs_svc_cd]) REFERENCES [dbo].[ref_filter_ihs_services] ([bin_ihs_svc_cd]),
    CONSTRAINT [prtl_outcomes_bin_placement_cd_FK] FOREIGN KEY ([bin_placement_cd]) REFERENCES [dbo].[ref_filter_nbr_placement] ([bin_placement_cd]),
    CONSTRAINT [prtl_outcomes_cd_race_FK] FOREIGN KEY ([cd_race_census]) REFERENCES [dbo].[ref_lookup_ethnicity_census] ([cd_race_census]),
    CONSTRAINT [prtl_outcomes_cd_reporter_type_FK] FOREIGN KEY ([cd_reporter_type]) REFERENCES [dbo].[ref_filter_reporter_type] ([cd_reporter_type]),
    CONSTRAINT [prtl_outcomes_county_cd_FK] FOREIGN KEY ([Removal_County_Cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd]),
    CONSTRAINT [prtl_outcomes_filter_service_category_FK] FOREIGN KEY ([filter_service_category]) REFERENCES [dbo].[ref_service_category_flag_xwalk] ([int_filter_service_category]),
    CONSTRAINT [prtl_outcomes_init_cd_plcm_setng_FK] FOREIGN KEY ([init_cd_plcm_setng]) REFERENCES [dbo].[ref_lookup_plcmnt] ([cd_plcm_setng]),
    CONSTRAINT [prtl_outcomes_long_cd_plcm_setng_FK] FOREIGN KEY ([long_cd_plcm_setng]) REFERENCES [dbo].[ref_lookup_plcmnt] ([cd_plcm_setng]),
    CONSTRAINT [prtl_outcomes_max_bin_los_cd_FK] FOREIGN KEY ([max_bin_los_cd]) REFERENCES [dbo].[ref_filter_los] ([bin_los_cd]),
    CONSTRAINT [prtl_outcomes_origin_cd_FK] FOREIGN KEY ([census_Hispanic_Latino_Origin_cd]) REFERENCES [dbo].[ref_lookup_hispanic_latino_census] ([census_hispanic_latino_origin_cd]),
    CONSTRAINT [prtl_outcomes_pk_gndr_FK] FOREIGN KEY ([pk_gndr]) REFERENCES [dbo].[ref_lookup_gender] ([pk_gndr])
);


GO
CREATE NONCLUSTERED INDEX [idx_prtl_outcomes]
    ON [prtl].[prtl_outcomes]([int_match_param_key] ASC);

