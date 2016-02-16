CREATE TABLE [rodis_wh].[staging_birth_fat] (
    [id_birth_fact]                    INT          NULL,
    [cd_birth_fact]                    VARCHAR (50) NULL,
    [id_prsn_child]                    INT          NULL,
    [id_prsn_mother]                   INT          NULL,
    [id_calendar_dim_birth_child]      INT          NULL,
    [qt_child_weight]                  INT          NULL,
    [ms_maternal_bmi]                  FLOAT (53)   NULL,
    [qt_child_head_circum]             INT          NULL,
    [qt_paternal_age]                  INT          NULL,
    [qt_child_age_est_gest]            INT          NULL,
    [qt_child_age_gest]                INT          NULL,
    [qt_maternal_age]                  INT          NULL,
    [qt_maternal_height]               INT          NULL,
    [qt_preconception_maternal_weight] INT          NULL,
    [qt_maternal_weight]               INT          NULL,
    [ms_maternal_weight_gain]          INT          NULL,
    [am_median_income_tract]           INT          NULL,
    [id_birth_administration]          INT          NULL,
    [cd_birth_administration]          VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_fact_cd_certifier_type]
    ON [rodis_wh].[staging_birth_fat]([cd_birth_administration] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_fact_cd_birth_fact]
    ON [rodis_wh].[staging_birth_fat]([cd_birth_fact] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_fat_id_birth_fact]
    ON [rodis_wh].[staging_birth_fat]([id_birth_fact] ASC);

