CREATE TABLE [rodis_wh].[staging_maternal_condition_att] (
    [id_maternal_condition]          INT          NULL,
    [cd_maternal_condition]          VARCHAR (50) NULL,
    [fl_amniorrhexis]                TINYINT      NULL,
    [fl_any_maternal_infection]      SMALLINT     NULL,
    [fl_chronic_hypertension]        TINYINT      NULL,
    [fl_diabetes_mellitus]           TINYINT      NULL,
    [fl_failure_to_progress]         TINYINT      NULL,
    [fl_fetal_distress]              TINYINT      NULL,
    [fl_gestational_hypertension]    TINYINT      NULL,
    [fl_hepatitis_b_mom]             SMALLINT     NULL,
    [fl_hepatitis_c]                 SMALLINT     NULL,
    [fl_herpes]                      SMALLINT     NULL,
    [fl_gonorrhea]                   SMALLINT     NULL,
    [fl_labor_complications]         TINYINT      NULL,
    [fl_other_maternal_infections]   SMALLINT     NULL,
    [fl_precipitating_labor_lt_3hrs] TINYINT      NULL,
    [fl_pregnancy_complications]     TINYINT      NULL,
    [fl_seizures]                    TINYINT      NULL,
    [fl_spontaneous_delivery]        TINYINT      NULL,
    [fl_syphillis]                   SMALLINT     NULL,
    [id_dysfunctional_uterine_bleed] INT          NULL,
    [cd_dysfunctional_uterine_bleed] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_condition_att_cd_dysfunctional_uterine_bleed]
    ON [rodis_wh].[staging_maternal_condition_att]([cd_dysfunctional_uterine_bleed] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_condition_att_cd_maternal_condition]
    ON [rodis_wh].[staging_maternal_condition_att]([cd_maternal_condition] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_condition_att_id_maternal_condition]
    ON [rodis_wh].[staging_maternal_condition_att]([id_maternal_condition] ASC);

