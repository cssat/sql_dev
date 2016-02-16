CREATE TABLE [rodis_wh].[birth_fat] (
    [id_birth_fact]                    INT          NOT NULL,
    [cd_birth_fact]                    VARCHAR (50) NOT NULL,
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
    [id_birth_administration]          INT          NOT NULL,
    CONSTRAINT [pk_birth_fat] PRIMARY KEY CLUSTERED ([id_birth_fact] ASC),
    CONSTRAINT [fk_birth_fat_id_birth_administration] FOREIGN KEY ([id_birth_administration]) REFERENCES [rodis_wh].[birth_administration_att] ([id_birth_administration])
);


GO
CREATE NONCLUSTERED INDEX [idx_birth_fat_id_birth_administration]
    ON [rodis_wh].[birth_fat]([id_birth_administration] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_birth_fat_cd_birth_fact]
    ON [rodis_wh].[birth_fat]([cd_birth_fact] ASC);

