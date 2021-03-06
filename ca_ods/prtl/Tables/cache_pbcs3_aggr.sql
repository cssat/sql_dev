﻿CREATE TABLE [prtl].[cache_pbcs3_aggr] (
    [qry_type]         INT            NOT NULL,
    [date_type]        INT            NOT NULL,
    [start_date]       DATETIME       NOT NULL,
    [int_param_key]    BIGINT         NOT NULL,
    [bin_ihs_svc_cd]   INT            NOT NULL,
    [cd_reporter_type] INT            NOT NULL,
    [cd_access_type]   INT            NOT NULL,
    [cd_allegation]    INT            NOT NULL,
    [cd_finding]       INT            NOT NULL,
    [cd_service_type]  INT            NOT NULL,
    [cd_budget_type]   INT            NOT NULL,
    [cd_sib_age_grp]   INT            NOT NULL,
    [cd_race_census]   INT            NOT NULL,
    [cd_county]        INT            NOT NULL,
    [month]            INT            NOT NULL,
    [placed]           DECIMAL (9, 2) NULL,
    [not_placed]       DECIMAL (9, 2) NULL,
    [min_start_date]   DATETIME       NOT NULL,
    [max_start_date]   DATETIME       NOT NULL,
    [x1]               FLOAT (53)     NOT NULL,
    [x2]               FLOAT (53)     NOT NULL,
    [insert_date]      DATETIME       NOT NULL,
    [qry_id]           INT            NOT NULL,
    [start_year]       INT            NULL,
    [int_hash_key]     DECIMAL (22)   NULL
);



