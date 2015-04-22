CREATE TABLE [prtl].[cache_qry_param_pbcs3] (
    [int_param_key]       BIGINT       NOT NULL,
    [bin_ihs_svc_cd]      INT          NOT NULL,
    [cd_reporter_type]    INT          NOT NULL,
    [cd_access_type]      INT          NOT NULL,
    [cd_allegation]       INT          NOT NULL,
    [cd_finding]          INT          NOT NULL,
    [cd_subctgry_poc_frc] INT          NOT NULL,
    [cd_budget_poc_frc]   INT          NOT NULL,
    [age_grouping_cd]     INT          NOT NULL,
    [cd_race]             INT          NOT NULL,
    [cd_county]           INT          NOT NULL,
    [qry_id]              INT          NOT NULL,
    [int_hash_key]        NUMERIC (22) NOT NULL
);

