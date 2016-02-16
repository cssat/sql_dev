CREATE TABLE [rodis_wh].[procedure_m2m_fat] (
    [id_procedure_m2m]      INT          NOT NULL,
    [cd_procedure_m2m]      VARCHAR (50) NOT NULL,
    [id_procedure]          INT          NOT NULL,
    [id_procedure_order]    INT          NOT NULL,
    [id_hospital_admission] INT          NOT NULL,
    CONSTRAINT [pk_procedure_m2m_fat] PRIMARY KEY CLUSTERED ([id_procedure_m2m] ASC),
    CONSTRAINT [fk_procedure_m2m_fat_id_hospital_admission] FOREIGN KEY ([id_hospital_admission]) REFERENCES [rodis_wh].[hospital_admission_att] ([id_hospital_admission]),
    CONSTRAINT [fk_procedure_m2m_fat_id_procedure] FOREIGN KEY ([id_procedure]) REFERENCES [rodis_wh].[procedure_att] ([id_procedure]),
    CONSTRAINT [fk_procedure_m2m_fat_id_procedure_order] FOREIGN KEY ([id_procedure_order]) REFERENCES [rodis_wh].[procedure_order_att] ([id_procedure_order])
);


GO
CREATE NONCLUSTERED INDEX [idx_procedure_m2m_fat_id_hospital_admission]
    ON [rodis_wh].[procedure_m2m_fat]([id_hospital_admission] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_procedure_m2m_fat_id_procedure_order]
    ON [rodis_wh].[procedure_m2m_fat]([id_procedure_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_procedure_m2m_fat_id_procedure]
    ON [rodis_wh].[procedure_m2m_fat]([id_procedure] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_procedure_m2m_fat_cd_procedure_m2m]
    ON [rodis_wh].[procedure_m2m_fat]([cd_procedure_m2m] ASC);

