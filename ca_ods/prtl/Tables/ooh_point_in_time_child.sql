CREATE TABLE [prtl].[ooh_point_in_time_child] (
    [id_prsn_child]                    INT        NOT NULL,
    [point_in_time_date]               DATETIME   NOT NULL,
    [id_removal_episode_fact]          INT        NOT NULL,
    [id_placement_fact]                INT        NULL,
    [removal_dt]                       DATETIME   NULL,
    [discharge_dt]                     DATETIME   NULL,
    [begin_date]                       DATETIME   NOT NULL,
    [end_date]                         DATETIME   NULL,
    [date_type]                        INT        NOT NULL,
    [qry_type]                         INT        NOT NULL,
    [row_num]                          BIGINT     NULL,
    [birth_dt]                         DATE       NULL,
    [bin_dep_cd]                       INT        NOT NULL,
    [bin_placement_cd]                 INT        NOT NULL,
    [max_bin_los_cd]                   INT        NOT NULL,
    [bin_ihs_svc_cd]                   INT        NOT NULL,
    [cd_reporter_type]                 INT        NOT NULL,
    [filter_access_type]               INT        NOT NULL,
    [filter_allegation]                INT        NOT NULL,
    [filter_finding]                   INT        NOT NULL,
    [pk_gndr]                          INT        NOT NULL,
    [cd_race_census]                   INT        NOT NULL,
    [census_Hispanic_Latino_Origin_cd] INT        NOT NULL,
    [init_cd_plcm_setng]               INT        NOT NULL,
    [long_cd_plcm_setng]               INT        NOT NULL,
    [pit_county_cd]                    INT        NOT NULL,
    [age_grouping_cd_census]           INT        NOT NULL,
    [age_grouping_cd_mix]              INT        NOT NULL,
    [dur_days]                         INT        NULL,
    [int_match_param_key_census]       INT        NOT NULL,
    [int_match_param_key_mix]          INT        NOT NULL,
    [int_filter_service_category]      INT        NOT NULL,
    [filter_service_budget]            INT        NOT NULL,
    [plctypc]                          INT        NULL,
    [plctypc_desc]                     CHAR (200) NULL,
    [qualevt_w3w4]                     INT        NULL,
    [kinmark]                          INT        NULL,
    [tempevt]                          INT        NULL,
    [cd_plcm_setng]                    INT        NULL,
    [curr_prtl_cd_plcm_setng]          INT        NULL,
    [fl_out_trial_return_home]         INT        NOT NULL,
    CONSTRAINT [PK_ooh_point_in_time_child] PRIMARY KEY CLUSTERED ([id_prsn_child] ASC, [point_in_time_date] ASC, [date_type] ASC, [qry_type] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_pbcw4_1]
    ON [prtl].[ooh_point_in_time_child]([id_placement_fact] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_id_removal_episode_fact]
    ON [prtl].[ooh_point_in_time_child]([id_removal_episode_fact] ASC)
    INCLUDE([id_prsn_child], [point_in_time_date], [id_placement_fact], [date_type], [qry_type], [cd_reporter_type], [filter_access_type], [census_Hispanic_Latino_Origin_cd], [init_cd_plcm_setng], [bin_dep_cd], [bin_placement_cd], [max_bin_los_cd], [bin_ihs_svc_cd], [int_match_param_key_census], [int_match_param_key_mix], [filter_allegation], [filter_finding], [pk_gndr], [cd_race_census], [qualevt_w3w4], [kinmark], [long_cd_plcm_setng], [pit_county_cd], [age_grouping_cd_census], [age_grouping_cd_mix], [tempevt], [fl_out_trial_return_home], [int_filter_service_category], [filter_service_budget], [plctypc], [plctypc_desc]);


GO
CREATE NONCLUSTERED INDEX [idx_ooh_point_in_time_child_BX8W3]
    ON [prtl].[ooh_point_in_time_child]([point_in_time_date] ASC, [date_type] ASC, [qry_type] ASC, [pit_county_cd] ASC)
    INCLUDE([id_prsn_child], [cd_race_census]);

