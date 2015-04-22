CREATE TABLE [prtl].[cache_pbcs2_aggr] (
    [qry_type]                    INT            NOT NULL,
    [date_type]                   INT            NOT NULL,
    [start_date]                  DATETIME       NOT NULL,
    [int_param_key]               BIGINT         NOT NULL,
    [cd_reporter_type]            INT            NOT NULL,
    [cd_access_type]              INT            NOT NULL,
    [cd_allegation]               INT            NOT NULL,
    [cd_finding]                  INT            NOT NULL,
    [cd_sib_age_grp]              INT            NOT NULL,
    [cd_race]                     INT            NOT NULL,
    [cd_county]                   INT            NOT NULL,
    [month]                       INT            NOT NULL,
    [among_first_cmpt_rereferred] DECIMAL (9, 2) NOT NULL,
    [min_start_date]              DATETIME       NOT NULL,
    [max_start_date]              DATETIME       NOT NULL,
    [x1]                          FLOAT (53)     NOT NULL,
    [x2]                          FLOAT (53)     NOT NULL,
    [insert_date]                 DATETIME       NOT NULL,
    [int_hash_key]                DECIMAL (21)   NULL,
    [qry_id]                      INT            NOT NULL,
    [start_year]                  INT            NULL
);

