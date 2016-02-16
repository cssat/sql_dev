CREATE TABLE [rodis_wh].[birth_administration_dim] (
    [id_birth_administration]        INT          NOT NULL,
    [cd_birth_administration]        VARCHAR (50) NOT NULL,
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
    [id_certifier_type]              INT          NOT NULL,
    [cd_certifier_type]              VARCHAR (50) NOT NULL,
    [tx_certifier_type]              VARCHAR (50) NULL,
    [id_maternal_transfer_type]      INT          NOT NULL,
    [cd_maternal_transfer_type]      VARCHAR (50) NOT NULL,
    [tx_maternal_transfer_type]      VARCHAR (50) NULL,
    [id_child_sex]                   INT          NOT NULL,
    [cd_child_sex]                   VARCHAR (50) NOT NULL,
    [tx_child_sex]                   VARCHAR (50) NULL,
    [id_facility_type]               INT          NOT NULL,
    [cd_facility_type]               VARCHAR (50) NOT NULL,
    [tx_facility_type]               VARCHAR (50) NULL,
    [id_birth_familial_child]        INT          NOT NULL,
    [id_birth_familial_maternal]     INT          NOT NULL,
    [id_birth_familial_paternal]     INT          NOT NULL,
    [id_hospital_admission_child]    INT          NOT NULL,
    [id_hospital_admission_maternal] INT          NOT NULL,
    [id_birth_child_condition]       INT          NOT NULL,
    [id_birth_child_procedure]       INT          NOT NULL,
    [id_maternal_behavior]           INT          NOT NULL,
    [id_maternal_condition]          INT          NOT NULL,
    [id_maternal_history]            INT          NOT NULL,
    [id_maternal_procedure]          INT          NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_dim]
    ON [rodis_wh].[birth_administration_dim]([id_birth_administration] ASC)
    INCLUDE([id_birth_familial_child], [id_birth_familial_maternal], [id_birth_familial_paternal], [id_hospital_admission_child], [id_hospital_admission_maternal], [id_birth_child_condition], [id_birth_child_procedure], [id_maternal_behavior], [id_maternal_condition], [id_maternal_history], [id_maternal_procedure]);

