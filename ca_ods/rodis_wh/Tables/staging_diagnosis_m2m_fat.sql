CREATE TABLE [rodis_wh].[staging_diagnosis_m2m_fat] (
    [id_diagnosis_m2m]      INT          NULL,
    [cd_diagnosis_m2m]      VARCHAR (50) NULL,
    [id_diagnosis]          INT          NULL,
    [cd_diagnosis]          VARCHAR (50) NULL,
    [id_diagnosis_order]    INT          NULL,
    [cd_diagnosis_order]    VARCHAR (50) NULL,
    [id_hospital_admission] INT          NULL,
    [cd_hospital_admission] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_m2m_fat_cd_hospital_admission]
    ON [rodis_wh].[staging_diagnosis_m2m_fat]([cd_hospital_admission] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_m2m_fat_cd_diagnosis_order]
    ON [rodis_wh].[staging_diagnosis_m2m_fat]([cd_diagnosis_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_m2m_fat_cd_diagnosis]
    ON [rodis_wh].[staging_diagnosis_m2m_fat]([cd_diagnosis] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_m2m_fat_cd_diagnosis_order_m2m]
    ON [rodis_wh].[staging_diagnosis_m2m_fat]([cd_diagnosis_m2m] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_m2m_fat_id_diagnosis_order_m2m]
    ON [rodis_wh].[staging_diagnosis_m2m_fat]([id_diagnosis_m2m] ASC);

