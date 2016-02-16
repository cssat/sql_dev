CREATE TABLE [rodis_wh].[staging_death_att] (
    [id_death]                      INT          NULL,
    [cd_death]                      VARCHAR (50) NULL,
    [fl_autopsy]                    TINYINT      NULL,
    [fl_citizen]                    TINYINT      NULL,
    [fl_city_limits_death]          VARCHAR (1)  NULL,
    [fl_coroner_referred]           TINYINT      NULL,
    [fl_smoked]                     TINYINT      NULL,
    [dt_death_dtg]                  DATETIME     NULL,
    [dt_injury_dtg]                 DATETIME     NULL,
    [id_armed_forces]               INT          NULL,
    [cd_armed_forces]               VARCHAR (50) NULL,
    [id_attendent_type]             INT          NULL,
    [cd_attendent_type]             VARCHAR (50) NULL,
    [id_place_of_death]             INT          NULL,
    [cd_place_of_death]             VARCHAR (50) NULL,
    [id_marital_status]             INT          NULL,
    [cd_marital_status]             VARCHAR (50) NULL,
    [id_ucode]                      INT          NULL,
    [cd_ucode]                      VARCHAR (50) NULL,
    [id_city_of_death]              INT          NULL,
    [cd_city_of_death]              VARCHAR (50) NULL,
    [id_city_of_injury]             INT          NULL,
    [cd_city_of_injury]             VARCHAR (50) NULL,
    [id_city_of_residence_at_death] INT          NULL,
    [cd_city_of_residence_at_death] VARCHAR (50) NULL,
    [id_education]                  INT          NULL,
    [cd_education]                  VARCHAR (50) NULL,
    [id_birth_administration]       INT          NULL,
    [cd_birth_administration]       VARCHAR (50) NULL,
    [id_hospital_admission_last]    INT          NULL,
    [cd_hospital_admission_last]    VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_hospital_admission_last]
    ON [rodis_wh].[staging_death_att]([cd_hospital_admission_last] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_birth_administration]
    ON [rodis_wh].[staging_death_att]([cd_birth_administration] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_education]
    ON [rodis_wh].[staging_death_att]([cd_education] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_city_of_residence_at_death]
    ON [rodis_wh].[staging_death_att]([cd_city_of_residence_at_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_city_of_injury]
    ON [rodis_wh].[staging_death_att]([cd_city_of_injury] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_city_of_death]
    ON [rodis_wh].[staging_death_att]([cd_city_of_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_ucode]
    ON [rodis_wh].[staging_death_att]([cd_ucode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_marital_status]
    ON [rodis_wh].[staging_death_att]([cd_marital_status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_place_of_death]
    ON [rodis_wh].[staging_death_att]([cd_place_of_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_attendent_type]
    ON [rodis_wh].[staging_death_att]([cd_attendent_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_armed_forces]
    ON [rodis_wh].[staging_death_att]([cd_armed_forces] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_cd_death]
    ON [rodis_wh].[staging_death_att]([cd_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_att_id_death]
    ON [rodis_wh].[staging_death_att]([id_death] ASC);

