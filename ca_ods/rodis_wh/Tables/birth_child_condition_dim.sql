CREATE TABLE [rodis_wh].[birth_child_condition_dim] (
    [id_birth_child_condition]     INT          NOT NULL,
    [cd_birth_child_condition]     VARCHAR (50) NOT NULL,
    [ms_apgar5]                    TINYINT      NULL,
    [ms_apgar10]                   TINYINT      NULL,
    [fl_anencephaly]               TINYINT      NULL,
    [fl_breech]                    TINYINT      NULL,
    [fl_chromosome_anomaly]        TINYINT      NULL,
    [fl_diaphragmic_hernia]        TINYINT      NULL,
    [fl_downs_syndrome]            TINYINT      NULL,
    [fl_heart_malformations]       TINYINT      NULL,
    [fl_orofacial_cleft]           TINYINT      NULL,
    [fl_spinabifida]               TINYINT      NULL,
    [fl_small_for_gestational_age] TINYINT      NULL,
    [fl_omphalocele]               TINYINT      NULL,
    [fl_meconium_mod_to_heavy]     TINYINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_birth_child_condition_dim]
    ON [rodis_wh].[birth_child_condition_dim]([id_birth_child_condition] ASC);

