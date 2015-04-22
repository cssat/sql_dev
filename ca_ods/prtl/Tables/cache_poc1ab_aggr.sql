CREATE TABLE [prtl].[cache_poc1ab_aggr] (
    [qry_type]             INT          NOT NULL,
    [date_type]            INT          NOT NULL,
    [start_date]           DATETIME     NOT NULL,
    [int_param_key]        BIGINT       NOT NULL,
    [bin_dep_cd]           INT          NOT NULL,
    [bin_los_cd]           INT          NOT NULL,
    [bin_placement_cd]     INT          NOT NULL,
    [bin_ihs_svc_cd]       INT          NOT NULL,
    [cd_reporter_type]     INT          NOT NULL,
    [cd_access_type]       INT          NOT NULL,
    [cd_allegation]        INT          NOT NULL,
    [cd_finding]           INT          NOT NULL,
    [cd_subctgry_poc_frc]  INT          NOT NULL,
    [cd_budget_poc_frc]    INT          NOT NULL,
    [custody_id]           INT          CONSTRAINT [DF_cache_poc1ab_aggr_custody_id] DEFAULT ((0)) NOT NULL,
    [age_grouping_cd]      INT          NOT NULL,
    [cd_race]              INT          NOT NULL,
    [pk_gndr]              INT          NOT NULL,
    [init_cd_plcm_setng]   INT          NOT NULL,
    [long_cd_plcm_setng]   INT          NOT NULL,
    [county_cd]            INT          NOT NULL,
    [cnt_start_date]       INT          NOT NULL,
    [min_start_date]       DATETIME     NOT NULL,
    [max_start_date]       DATETIME     NOT NULL,
    [x1]                   FLOAT (53)   NOT NULL,
    [x2]                   FLOAT (53)   NOT NULL,
    [insert_date]          DATETIME     NOT NULL,
    [int_hash_key]         DECIMAL (22) NOT NULL,
    [qry_id]               INT          NOT NULL,
    [start_year]           INT          NULL,
    [fl_include_perCapita] INT          NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_qry_id_start_year]
    ON [prtl].[cache_poc1ab_aggr]([qry_id] ASC, [start_year] ASC, [county_cd] ASC, [cd_race] ASC, [age_grouping_cd] ASC, [pk_gndr] ASC, [cnt_start_date] ASC);

