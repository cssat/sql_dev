CREATE TABLE [prtl].[cache_qry_param_poc1ab_exits] (
    [int_param_key]       BIGINT       NOT NULL,
    [bin_dep_cd]          INT          NULL,
    [bin_los_cd]          INT          NOT NULL,
    [bin_placement_cd]    INT          NOT NULL,
    [bin_ihs_svc_cd]      INT          NOT NULL,
    [cd_reporter_type]    INT          NOT NULL,
    [cd_access_type]      INT          NOT NULL,
    [cd_allegation]       INT          NOT NULL,
    [cd_finding]          INT          NOT NULL,
    [cd_subctgry_poc_frc] INT          NOT NULL,
    [cd_budget_poc_frc]   INT          NOT NULL,
    [age_grouping_cd]     INT          NOT NULL,
    [cd_race]             INT          NOT NULL,
    [pk_gndr]             INT          NOT NULL,
    [init_cd_plcm_setng]  INT          NOT NULL,
    [long_cd_plcm_setng]  INT          NOT NULL,
    [county_cd]           INT          NOT NULL,
    [qry_id]              INT          NOT NULL,
    [int_hash_key]        NUMERIC (22) NOT NULL
);

