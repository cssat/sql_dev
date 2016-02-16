CREATE TABLE [rodis_wh].[diagnosis_m2m_fat] (
    [id_diagnosis_m2m]      INT          NOT NULL,
    [cd_diagnosis_m2m]      VARCHAR (50) NOT NULL,
    [id_diagnosis]          INT          NOT NULL,
    [id_diagnosis_order]    INT          NOT NULL,
    [id_hospital_admission] INT          NOT NULL,
    CONSTRAINT [pk_diagnosis_m2m_fat] PRIMARY KEY CLUSTERED ([id_diagnosis_m2m] ASC),
    CONSTRAINT [fk_diagnosis_m2m_fat_id_diagnosis] FOREIGN KEY ([id_diagnosis]) REFERENCES [rodis_wh].[diagnosis_att] ([id_diagnosis]),
    CONSTRAINT [fk_diagnosis_m2m_fat_id_diagnosis_order] FOREIGN KEY ([id_diagnosis_order]) REFERENCES [rodis_wh].[diagnosis_order_att] ([id_diagnosis_order]),
    CONSTRAINT [fk_diagnosis_m2m_fat_id_hospital_admission] FOREIGN KEY ([id_hospital_admission]) REFERENCES [rodis_wh].[hospital_admission_att] ([id_hospital_admission])
);


GO
CREATE NONCLUSTERED INDEX [idx_diagnosis_m2m_fat_id_hospital_admission]
    ON [rodis_wh].[diagnosis_m2m_fat]([id_hospital_admission] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_diagnosis_m2m_fat_id_diagnosis_order]
    ON [rodis_wh].[diagnosis_m2m_fat]([id_diagnosis_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_diagnosis_m2m_fat_id_diagnosis]
    ON [rodis_wh].[diagnosis_m2m_fat]([id_diagnosis] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_diagnosis_m2m_fat_cd_diagnosis_m2m]
    ON [rodis_wh].[diagnosis_m2m_fat]([cd_diagnosis_m2m] ASC);

