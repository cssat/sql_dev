CREATE TABLE [prtl].[cache_pbcs2_params] (
    [qry_ID]             BIGINT        NOT NULL,
    [age_grouping_cd]    VARCHAR (20)  NOT NULL,
    [cd_race_census]     VARCHAR (30)  NOT NULL,
    [cd_county]          VARCHAR (250) NOT NULL,
    [cd_reporter_type]   VARCHAR (100) NOT NULL,
    [filter_access_type] VARCHAR (30)  NOT NULL,
    [filter_allegation]  VARCHAR (30)  NOT NULL,
    [filter_finding]     VARCHAR (30)  NOT NULL,
    [min_start_date]     DATETIME      NOT NULL,
    [max_start_date]     DATETIME      NOT NULL,
    [cnt_qry]            INT           NOT NULL,
    [last_run_date]      DATETIME      NOT NULL
);

