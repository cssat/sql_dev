CREATE TABLE [prtl].[ooh_wb_family_settings_params] (
    [qry_id]                       INT           IDENTITY (1, 1) NOT NULL,
    [age_grouping_cd]              VARCHAR (20)  NOT NULL,
    [cd_race_census]               VARCHAR (30)  NOT NULL,
    [pk_gender]                    VARCHAR (10)  NOT NULL,
    [initial_cd_placement_setting] VARCHAR (50)  NOT NULL,
    [longest_cd_placement_setting] VARCHAR (50)  NOT NULL,
    [cd_county]                    VARCHAR (200) NOT NULL,
    [bin_los_cd]                   VARCHAR (30)  NOT NULL,
    [bin_placement_cd]             VARCHAR (30)  NOT NULL,
    [bin_ihs_service_cd]           VARCHAR (30)  NOT NULL,
    [cd_reporter_type]             VARCHAR (100) NOT NULL,
    [cd_access_type]               VARCHAR (30)  NOT NULL,
    [cd_allegation]                VARCHAR (30)  NOT NULL,
    [cd_finding]                   VARCHAR (30)  NOT NULL,
    [bin_dependency_cd]            VARCHAR (20)  NOT NULL,
    [min_start_date]               DATETIME      NOT NULL,
    [max_start_date]               DATETIME      NOT NULL,
    [cnt_qry]                      INT           NOT NULL,
    [last_run_date]                DATETIME      NOT NULL,
    CONSTRAINT [pk_cache_ooh_wb_family_settings_params] PRIMARY KEY CLUSTERED ([qry_id] ASC),
    CONSTRAINT [idx_cache_ooh_wb_family_settings_params] UNIQUE NONCLUSTERED ([age_grouping_cd] ASC, [cd_race_census] ASC, [pk_gender] ASC, [initial_cd_placement_setting] ASC, [longest_cd_placement_setting] ASC, [cd_county] ASC, [bin_los_cd] ASC, [bin_placement_cd] ASC, [bin_ihs_service_cd] ASC, [cd_reporter_type] ASC, [cd_access_type] ASC, [cd_allegation] ASC, [cd_finding] ASC, [bin_dependency_cd] ASC)
);


