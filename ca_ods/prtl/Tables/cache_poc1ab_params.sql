CREATE TABLE [prtl].[cache_poc1ab_params] (
    [qry_ID]             BIGINT        NOT NULL,
    [age_grouping_cd]    VARCHAR (20)  NOT NULL,
    [cd_race_census]     VARCHAR (30)  NOT NULL,
    [pk_gndr]            VARCHAR (10)  NOT NULL,
    [init_cd_plcm_setng] VARCHAR (50)  NOT NULL,
    [long_cd_plcm_setng] VARCHAR (50)  NOT NULL,
    [county_cd]          VARCHAR (200) NOT NULL,
    [bin_los_cd]         VARCHAR (30)  NOT NULL,
    [bin_placement_cd]   VARCHAR (30)  NOT NULL,
    [bin_ihs_svc_cd]     VARCHAR (30)  NOT NULL,
    [cd_reporter_type]   VARCHAR (100) NOT NULL,
    [filter_access_type] VARCHAR (30)  NOT NULL,
    [filter_allegation]  VARCHAR (30)  NOT NULL,
    [filter_finding]     VARCHAR (30)  NOT NULL,
    [filter_srvc_type]   VARCHAR (50)  NOT NULL,
    [filter_budget]      VARCHAR (50)  NOT NULL,
    [bin_dep_cd]         VARCHAR (20)  NOT NULL,
    [min_start_date]     DATETIME      NOT NULL,
    [max_start_date]     DATETIME      NOT NULL,
    [cnt_qry]            INT           NOT NULL,
    [last_run_date]      DATETIME      NOT NULL
);

