CREATE TABLE [prtl].[cache_poc3ab_aggr] (
    [qry_type]             INT          NOT NULL,
    [date_type]            INT          NOT NULL,
    [start_date]           DATETIME     NOT NULL,
    [int_param_key]        BIGINT       NOT NULL,
    [bin_ihs_svc_cd]       INT          NOT NULL,
    [cd_reporter_type]     INT          NOT NULL,
    [cd_access_type]       INT          NOT NULL,
    [cd_allegation]        INT          NOT NULL,
    [cd_finding]           INT          NOT NULL,
    [cd_service_type]      INT          NOT NULL,
    [cd_budget_type]       INT          NOT NULL,
    [cd_sib_age_grp]       INT          NOT NULL,
    [cd_race_census]       INT          NOT NULL,
    [cd_county]            INT          NOT NULL,
    [cnt_start_date]       INT          NOT NULL,
    [cnt_opened]           INT          NOT NULL,
    [cnt_closed]           INT          NOT NULL,
    [min_start_date]       DATETIME     NOT NULL,
    [max_start_date]       DATETIME     NOT NULL,
    [x1]                   FLOAT (53)   NOT NULL,
    [x2]                   FLOAT (53)   NOT NULL,
    [insert_date]          DATETIME     NOT NULL,
    [qry_id]               INT          NOT NULL,
    [start_year]           INT          NULL,
    [int_hash_key]         DECIMAL (22) NOT NULL,
    [fl_include_perCapita] SMALLINT     CONSTRAINT [DF__cache_poc__fl_in__10A21EA2] DEFAULT ('1') NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_qry_id]
    ON [prtl].[cache_poc3ab_aggr]([qry_id] ASC);

