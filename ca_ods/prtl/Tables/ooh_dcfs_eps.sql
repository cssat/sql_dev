CREATE TABLE [prtl].[ooh_dcfs_eps] (
    [cohort_entry_year]                            DATETIME      NOT NULL,
    [cohort_entry_month]                           DATETIME      NOT NULL,
    [cohort_exit_year]                             DATETIME      NULL,
    [cohort_exit_month]                            DATETIME      NULL,
    [id_prsn_child]                                INT           NOT NULL,
    [birth_dt]                                     DATE          NULL,
    [id_removal_episode_fact]                      INT           NOT NULL,
    [discharge_type]                               VARCHAR (200) NULL,
    [cd_discharge_type]                            INT           NULL,
    [first_removal_dt]                             DATETIME      NULL,
    [fl_first_removal]                             INT           NOT NULL,
    [removal_dt]                                   DATETIME      NOT NULL,
    [orig_removal_dt]                              DATETIME      NOT NULL,
    [federal_discharge_date]                       DATETIME      NULL,
    [orig_federal_discharge_date]                  DATETIME      NULL,
    [last_placement_discharge_date]                DATETIME      NULL,
    [entry_cdc_census_mix_age_cd]                  INT           NULL,
    [entry_census_child_group_cd]                  INT           NULL,
    [entry_developmental_age_cd]                   INT           NULL,
    [exit_cdc_census_mix_age_cd]                   INT           NULL,
    [exit_census_child_group_cd]                   INT           NULL,
    [exit_developmental_age_cd]                    INT           NULL,
    [fl_exit_over_17]                              SMALLINT      NOT NULL,
    [pk_gndr]                                      INT           NULL,
    [cd_race_census]                               INT           NULL,
    [census_Hispanic_Latino_Origin_cd]             INT           NULL,
    [init_cd_plcm_setng]                           INT           NULL,
    [long_cd_plcm_setng]                           INT           NULL,
    [Removal_County_Cd]                            INT           NULL,
    [exit_county_cd]                               INT           NULL,
    [entry_int_match_param_key_cdc_census_mix]     DECIMAL (9)   NULL,
    [entry_int_match_param_key_census_child_group] DECIMAL (9)   NULL,
    [entry_int_match_param_key_developmental]      DECIMAL (9)   NULL,
    [exit_int_match_param_key_cdc_census_mix]      DECIMAL (9)   NULL,
    [exit_int_match_param_key_census_child_group]  DECIMAL (9)   NULL,
    [exit_int_match_param_key_developmental]       DECIMAL (9)   NULL,
    [bin_dep_cd]                                   INT           NULL,
    [max_bin_los_cd]                               INT           NULL,
    [bin_placement_cd]                             INT           NULL,
    [cd_reporter_type]                             INT           NULL,
    [fl_cps_invs]                                  INT           NULL,
    [fl_cfws]                                      INT           NULL,
    [fl_risk_only]                                 INT           NULL,
    [fl_alternate_intervention]                    INT           NULL,
    [fl_frs]                                       INT           NULL,
    [fl_dlr]                                       INT           NULL,
    [fl_far]                                       INT           NULL,
    [fl_phys_abuse]                                INT           NOT NULL,
    [fl_sexual_abuse]                              INT           NOT NULL,
    [fl_neglect]                                   INT           NOT NULL,
    [fl_any_legal]                                 INT           NOT NULL,
    [fl_founded_phys_abuse]                        INT           NOT NULL,
    [fl_founded_sexual_abuse]                      INT           NOT NULL,
    [fl_founded_neglect]                           INT           NOT NULL,
    [fl_found_any_legal]                           INT           NOT NULL,
    [bin_ihs_svc_cd]                               INT           NULL,
    [int_filter_service_category]                  INT           NULL,
    [filter_service_budget]                        INT           NULL,
    [prsn_cnt]                                     INT           NOT NULL,
    [exit_within_month_mult3]                      INT           NULL,
    [nxt_reentry_within_min_month_mult3]           INT           NULL,
    [fl_nondcfs_eps]                               INT           NOT NULL,
    [fl_nondcfs_within_eps]                        INT           NOT NULL,
    [fl_nondcfs_overlap_eps]                       INT           NOT NULL,
    [dependency_dt]                                DATETIME      NULL,
    [fl_dep_exist]                                 INT           NULL,
    [fl_reentry]                                   INT           NOT NULL,
    [next_reentry_date]                            DATETIME      NULL,
    [child_eps_rank_asc]                           INT           NULL,
    [child_eps_rank_desc]                          INT           NULL,
    [id_case]                                      INT           NULL,
    CONSTRAINT [PK__ooh_dcfs__2697C46CC8BE5425] PRIMARY KEY CLUSTERED ([id_prsn_child] ASC, [removal_dt] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_age_census_child_age_grp_federal_discharge_date_in]
    ON [prtl].[ooh_dcfs_eps]([exit_census_child_group_cd] ASC, [federal_discharge_date] ASC)
    INCLUDE([cohort_entry_year], [cohort_entry_month], [cohort_exit_year], [cohort_exit_month], [discharge_type], [cd_discharge_type], [first_removal_dt], [orig_federal_discharge_date], [last_placement_discharge_date], [entry_cdc_census_mix_age_cd], [id_prsn_child], [birth_dt], [id_removal_episode_fact], [cd_race_census], [census_Hispanic_Latino_Origin_cd], [init_cd_plcm_setng], [fl_first_removal], [removal_dt], [orig_removal_dt], [entry_int_match_param_key_cdc_census_mix], [entry_int_match_param_key_census_child_group], [exit_int_match_param_key_cdc_census_mix], [entry_census_child_group_cd], [exit_cdc_census_mix_age_cd], [pk_gndr], [bin_placement_cd], [cd_reporter_type], [fl_cps_invs], [long_cd_plcm_setng], [Removal_County_Cd], [exit_county_cd], [fl_frs], [fl_phys_abuse], [fl_sexual_abuse], [exit_int_match_param_key_census_child_group], [bin_dep_cd], [max_bin_los_cd], [fl_founded_sexual_abuse], [fl_founded_neglect], [fl_found_any_legal], [fl_cfws], [fl_risk_only], [fl_alternate_intervention], [prsn_cnt], [exit_within_month_mult3], [nxt_reentry_within_min_month_mult3], [fl_neglect], [fl_any_legal], [fl_founded_phys_abuse], [dependency_dt], [fl_dep_exist], [fl_reentry], [bin_ihs_svc_cd], [int_filter_service_category], [filter_service_budget], [next_reentry_date], [child_eps_rank_asc], [child_eps_rank_desc], [fl_nondcfs_eps], [fl_nondcfs_within_eps], [fl_nondcfs_overlap_eps]);


GO
CREATE NONCLUSTERED INDEX [idx_poc1ab_1]
    ON [prtl].[ooh_dcfs_eps]([removal_dt] ASC, [federal_discharge_date] ASC, [id_removal_episode_fact] ASC, [birth_dt] ASC)
    INCLUDE([id_prsn_child]);


GO
CREATE NONCLUSTERED INDEX [idx_federal_discharge_date_ooh_dcfs_eps]
    ON [prtl].[ooh_dcfs_eps]([federal_discharge_date] ASC)
    INCLUDE([id_prsn_child], [birth_dt], [removal_dt], [pk_gndr], [exit_county_cd], [max_bin_los_cd]);

