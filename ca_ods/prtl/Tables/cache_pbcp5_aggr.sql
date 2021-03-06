﻿CREATE TABLE [prtl].[cache_pbcp5_aggr] (
    [qry_type]             INT             NOT NULL,
    [date_type]            INT             NOT NULL,
    [cohort_exit_year]     DATETIME        NOT NULL,
    [cd_discharge_type]    INT             NOT NULL,
    [int_param_key]        BIGINT          NOT NULL,
    [bin_dep_cd]           INT             NOT NULL,
    [bin_los_cd]           INT             NOT NULL,
    [bin_placement_cd]     INT             NOT NULL,
    [bin_ihs_svc_cd]       INT             NOT NULL,
    [cd_reporter_type]     INT             NOT NULL,
    [cd_access_type]       INT             NOT NULL,
    [cd_allegation]        INT             NOT NULL,
    [cd_finding]           INT             NOT NULL,
    [reentry_within_month] INT             NOT NULL,
    [reentry_rate]         NUMERIC (18, 4) NULL,
    [age_grouping_cd]      INT             NOT NULL,
    [cd_race]              INT             NOT NULL,
    [pk_gndr]              INT             NOT NULL,
    [init_cd_plcm_setng]   INT             NOT NULL,
    [long_cd_plcm_setng]   INT             NOT NULL,
    [county_cd]            INT             NOT NULL,
    [min_start_date]       DATETIME        NOT NULL,
    [max_start_date]       DATETIME        NOT NULL,
    [x1]                   FLOAT (53)      NOT NULL,
    [x2]                   FLOAT (53)      NOT NULL,
    [insert_date]          DATETIME        NOT NULL,
    [int_all_param_key]    DECIMAL (22)    NOT NULL,
    [qry_id]               INT             NOT NULL,
    [exit_year]            INT             NULL,
    [reentry_count]        INT             NULL,
    [total_count]          INT             NULL
);

