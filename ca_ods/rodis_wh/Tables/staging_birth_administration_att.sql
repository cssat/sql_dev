CREATE TABLE [rodis_wh].[staging_birth_administration_att] (
    [id_birth_administration]        INT          NULL,
    [cd_birth_administration]        VARCHAR (50) NULL,
    [fl_icu_maternal_admit]          TINYINT      NULL,
    [fl_infant_transfer]             TINYINT      NULL,
    [fl_nicu_child_admit]            TINYINT      NULL,
    [fl_or_maternal_admit]           TINYINT      NULL,
    [fl_malformation]                TINYINT      NULL,
    [dt_prenatal_care_start]         SMALLINT     NULL,
    [fl_urban_tract]                 TINYINT      NULL,
    [fl_prenatal_wic_benefits]       TINYINT      NULL,
    [dt_hour_birth_child]            TINYINT      NULL,
    [qt_latitude]                    FLOAT (53)   NULL,
    [qt_longitude]                   FLOAT (53)   NULL,
    [id_certifier_type]              INT          NULL,
    [cd_certifier_type]              VARCHAR (50) NULL,
    [id_maternal_transfer_type]      INT          NULL,
    [cd_maternal_transfer_type]      VARCHAR (50) NULL,
    [id_child_sex]                   INT          NULL,
    [cd_child_sex]                   VARCHAR (50) NULL,
    [id_facility_type]               INT          NULL,
    [cd_facility_type]               VARCHAR (50) NULL,
    [id_birth_familial_child]        INT          NULL,
    [cd_birth_familial_child]        VARCHAR (50) NULL,
    [id_birth_familial_maternal]     INT          NULL,
    [cd_birth_familial_maternal]     VARCHAR (50) NULL,
    [id_birth_familial_paternal]     INT          NULL,
    [cd_birth_familial_paternal]     VARCHAR (50) NULL,
    [id_hospital_admission_child]    INT          NULL,
    [cd_hospital_admission_child]    VARCHAR (50) NULL,
    [id_hospital_admission_maternal] INT          NULL,
    [cd_hospital_admission_maternal] VARCHAR (50) NULL,
    [id_birth_child_condition]       INT          NULL,
    [cd_birth_child_condition]       VARCHAR (50) NULL,
    [id_birth_child_procedure]       INT          NULL,
    [cd_birth_child_procedure]       VARCHAR (50) NULL,
    [id_maternal_behavior]           INT          NULL,
    [cd_maternal_behavior]           VARCHAR (50) NULL,
    [id_maternal_condition]          INT          NULL,
    [cd_maternal_condition]          VARCHAR (50) NULL,
    [id_maternal_history]            INT          NULL,
    [cd_maternal_history]            VARCHAR (50) NULL,
    [id_maternal_procedure]          INT          NULL,
    [cd_maternal_procedure]          VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_maternal_procedure]
    ON [rodis_wh].[staging_birth_administration_att]([cd_maternal_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_maternal_history]
    ON [rodis_wh].[staging_birth_administration_att]([cd_maternal_history] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_maternal_condition]
    ON [rodis_wh].[staging_birth_administration_att]([cd_maternal_condition] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_maternal_behavior]
    ON [rodis_wh].[staging_birth_administration_att]([cd_maternal_behavior] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_birth_child_procedure]
    ON [rodis_wh].[staging_birth_administration_att]([cd_birth_child_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_birth_child_condition]
    ON [rodis_wh].[staging_birth_administration_att]([cd_birth_child_condition] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_hospital_admission_maternal]
    ON [rodis_wh].[staging_birth_administration_att]([cd_hospital_admission_maternal] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_hospital_admission_child]
    ON [rodis_wh].[staging_birth_administration_att]([cd_hospital_admission_child] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_birth_familial_paternal]
    ON [rodis_wh].[staging_birth_administration_att]([cd_birth_familial_paternal] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_birth_familial_maternal]
    ON [rodis_wh].[staging_birth_administration_att]([cd_birth_familial_maternal] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_birth_familial_child]
    ON [rodis_wh].[staging_birth_administration_att]([cd_birth_familial_child] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_facility_type]
    ON [rodis_wh].[staging_birth_administration_att]([cd_facility_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_child_sex]
    ON [rodis_wh].[staging_birth_administration_att]([cd_child_sex] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_maternal_transfer_type]
    ON [rodis_wh].[staging_birth_administration_att]([cd_maternal_transfer_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_certifier_type]
    ON [rodis_wh].[staging_birth_administration_att]([cd_certifier_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_cd_birth_administration]
    ON [rodis_wh].[staging_birth_administration_att]([cd_birth_administration] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_administration_att_id_birth_administration]
    ON [rodis_wh].[staging_birth_administration_att]([id_birth_administration] ASC);

