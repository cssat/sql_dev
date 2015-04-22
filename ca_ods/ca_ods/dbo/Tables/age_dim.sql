CREATE TABLE [dbo].[age_dim] (
    [age_mo]                INT           NOT NULL,
    [age_yr]                INT           NULL,
    [census_child_group_cd] INT           NULL,
    [census_child_group_tx] VARCHAR (200) NULL,
    [census_20_group_cd]    INT           NULL,
    [census_20_group_tx]    VARCHAR (200) NULL,
    [census_all_group_cd]   INT           NULL,
    [census_all_group_tx]   VARCHAR (200) NULL,
    [custom_group_cd]       INT           NULL,
    [custom_group_tx]       INT           NULL,
    [developmental_age_cd]  INT           NULL,
    [developmental_age_tx]  VARCHAR (200) NULL,
    [school_age_cd]         INT           NULL,
    [school_age_tx]         VARCHAR (200) NULL,
    [cdc_age_cd]            INT           NULL,
    [cdc_age_tx]            VARCHAR (200) NULL,
    [cdc_census_mix_age_cd] INT           NULL,
    [cdc_census_mix_age_tx] VARCHAR (200) NULL
);

