CREATE TABLE [rodis_wh].[staging_maternal_behavior_att] (
    [id_maternal_behavior]       INT          NULL,
    [cd_maternal_behavior]       VARCHAR (50) NULL,
    [fl_married]                 TINYINT      NULL,
    [fl_breast_feeding]          VARCHAR (1)  NULL,
    [qt_cigs_tri1]               TINYINT      NULL,
    [qt_cigs_tri2]               TINYINT      NULL,
    [qt_cigs_tri3]               TINYINT      NULL,
    [qt_cigs_prior]              TINYINT      NULL,
    [qt_alcoholic_drinks]        TINYINT      NULL,
    [fl_drank_during_pregnancy]  TINYINT      NULL,
    [qt_cigs]                    TINYINT      NULL,
    [qt_prenatal_visits]         TINYINT      NULL,
    [fl_smoked_during_pregnancy] TINYINT      NULL,
    [fl_birth_injury]            TINYINT      NULL,
    [fl_chlamydia]               SMALLINT     NULL,
    [id_kotelchuck_index]        INT          NULL,
    [cd_kotelchuck_index]        VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_behavior_att_cd_kotelchuck_index]
    ON [rodis_wh].[staging_maternal_behavior_att]([cd_kotelchuck_index] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_behavior_att_cd_maternal_behavior]
    ON [rodis_wh].[staging_maternal_behavior_att]([cd_maternal_behavior] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_behavior_att_id_maternal_behavior]
    ON [rodis_wh].[staging_maternal_behavior_att]([id_maternal_behavior] ASC);

