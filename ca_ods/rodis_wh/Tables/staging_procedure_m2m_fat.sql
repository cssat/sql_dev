CREATE TABLE [rodis_wh].[staging_procedure_m2m_fat] (
    [id_procedure_m2m]      INT          NULL,
    [cd_procedure_m2m]      VARCHAR (50) NULL,
    [id_procedure]          INT          NULL,
    [cd_procedure]          VARCHAR (50) NULL,
    [id_procedure_order]    INT          NULL,
    [cd_procedure_order]    VARCHAR (50) NULL,
    [id_hospital_admission] INT          NULL,
    [cd_hospital_admission] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_m2m_fat_cd_hospital_admission]
    ON [rodis_wh].[staging_procedure_m2m_fat]([cd_hospital_admission] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_m2m_fat_cd_procedure_order]
    ON [rodis_wh].[staging_procedure_m2m_fat]([cd_procedure_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_m2m_fat_cd_procedure]
    ON [rodis_wh].[staging_procedure_m2m_fat]([cd_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_m2m_fat_cd_procedure_order_m2m]
    ON [rodis_wh].[staging_procedure_m2m_fat]([cd_procedure_m2m] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_m2m_fat_id_procedure_order_m2m]
    ON [rodis_wh].[staging_procedure_m2m_fat]([id_procedure_m2m] ASC);

