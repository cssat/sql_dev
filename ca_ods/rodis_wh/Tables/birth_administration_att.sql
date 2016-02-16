CREATE TABLE [rodis_wh].[birth_administration_att] (
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
    [id_maternal_transfer_type]      INT          NOT NULL,
    [id_child_sex]                   INT          NOT NULL,
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
    [id_maternal_procedure]          INT          NOT NULL,
    [id_facility_type]               INT          NOT NULL,
    CONSTRAINT [pk_birth_administration_att] PRIMARY KEY CLUSTERED ([id_birth_administration] ASC),
    CONSTRAINT [fk_birth_administration_att_id_birth_child_condition] FOREIGN KEY ([id_birth_child_condition]) REFERENCES [rodis_wh].[birth_child_condition_att] ([id_birth_child_condition]),
    CONSTRAINT [fk_birth_administration_att_id_birth_child_procedure] FOREIGN KEY ([id_birth_child_procedure]) REFERENCES [rodis_wh].[birth_child_procedure_att] ([id_birth_child_procedure]),
    CONSTRAINT [fk_birth_administration_att_id_birth_familial_child] FOREIGN KEY ([id_birth_familial_child]) REFERENCES [rodis_wh].[birth_familial_att] ([id_birth_familial]),
    CONSTRAINT [fk_birth_administration_att_id_birth_familial_maternal] FOREIGN KEY ([id_birth_familial_maternal]) REFERENCES [rodis_wh].[birth_familial_att] ([id_birth_familial]),
    CONSTRAINT [fk_birth_administration_att_id_birth_familial_paternal] FOREIGN KEY ([id_birth_familial_paternal]) REFERENCES [rodis_wh].[birth_familial_att] ([id_birth_familial]),
    CONSTRAINT [fk_birth_administration_att_id_certifier_type] FOREIGN KEY ([id_certifier_type]) REFERENCES [rodis_wh].[certifier_type_att] ([id_certifier_type]),
    CONSTRAINT [fk_birth_administration_att_id_child_sex] FOREIGN KEY ([id_child_sex]) REFERENCES [rodis_wh].[child_sex_att] ([id_child_sex]),
    CONSTRAINT [fk_birth_administration_att_id_facility_type] FOREIGN KEY ([id_facility_type]) REFERENCES [rodis_wh].[facility_type_att] ([id_facility_type]),
    CONSTRAINT [fk_birth_administration_att_id_hospital_admission_child] FOREIGN KEY ([id_hospital_admission_child]) REFERENCES [rodis_wh].[hospital_admission_att] ([id_hospital_admission]),
    CONSTRAINT [fk_birth_administration_att_id_hospital_admission_maternal] FOREIGN KEY ([id_hospital_admission_maternal]) REFERENCES [rodis_wh].[hospital_admission_att] ([id_hospital_admission]),
    CONSTRAINT [fk_birth_administration_att_id_maternal_behavior] FOREIGN KEY ([id_maternal_behavior]) REFERENCES [rodis_wh].[maternal_behavior_att] ([id_maternal_behavior]),
    CONSTRAINT [fk_birth_administration_att_id_maternal_condition] FOREIGN KEY ([id_maternal_condition]) REFERENCES [rodis_wh].[maternal_condition_att] ([id_maternal_condition]),
    CONSTRAINT [fk_birth_administration_att_id_maternal_history] FOREIGN KEY ([id_maternal_history]) REFERENCES [rodis_wh].[maternal_history_att] ([id_maternal_history]),
    CONSTRAINT [fk_birth_administration_att_id_maternal_procedure] FOREIGN KEY ([id_maternal_procedure]) REFERENCES [rodis_wh].[maternal_procedure_att] ([id_maternal_procedure]),
    CONSTRAINT [fk_birth_administration_att_id_maternal_transfer_type] FOREIGN KEY ([id_maternal_transfer_type]) REFERENCES [rodis_wh].[maternal_transfer_type_att] ([id_maternal_transfer_type])
);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_facility_type]
    ON [rodis_wh].[birth_administration_att]([id_facility_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_maternal_procedure]
    ON [rodis_wh].[birth_administration_att]([id_maternal_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_maternal_history]
    ON [rodis_wh].[birth_administration_att]([id_maternal_history] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_maternal_condition]
    ON [rodis_wh].[birth_administration_att]([id_maternal_condition] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_maternal_behavior]
    ON [rodis_wh].[birth_administration_att]([id_maternal_behavior] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_birth_child_procedure]
    ON [rodis_wh].[birth_administration_att]([id_birth_child_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_birth_child_condition]
    ON [rodis_wh].[birth_administration_att]([id_birth_child_condition] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_hospital_admission_maternal]
    ON [rodis_wh].[birth_administration_att]([id_hospital_admission_maternal] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_hospital_admission_child]
    ON [rodis_wh].[birth_administration_att]([id_hospital_admission_child] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_birth_familial_paternal]
    ON [rodis_wh].[birth_administration_att]([id_birth_familial_paternal] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_birth_familial_maternal]
    ON [rodis_wh].[birth_administration_att]([id_birth_familial_maternal] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_birth_familial_child]
    ON [rodis_wh].[birth_administration_att]([id_birth_familial_child] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_child_sex]
    ON [rodis_wh].[birth_administration_att]([id_child_sex] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_maternal_transfer_type]
    ON [rodis_wh].[birth_administration_att]([id_maternal_transfer_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_birth_administration_att_id_certifier_type]
    ON [rodis_wh].[birth_administration_att]([id_certifier_type] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_birth_administration_att_cd_birth_administration]
    ON [rodis_wh].[birth_administration_att]([cd_birth_administration] ASC);

